import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cassiel_drive/core/theme/app_theme.dart';
import 'package:cassiel_drive/providers/storage_provider.dart';
import 'package:cassiel_drive/providers/auth_provider.dart';
import 'package:cassiel_drive/services/upload_manager.dart';
import 'package:cassiel_drive/widgets/file_tile.dart';
import 'package:cassiel_drive/widgets/upload_progress_card.dart';

class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({super.key});

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends State<PlaygroundScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showUploads = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StorageProvider>().loadFiles();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storageProvider = context.watch<StorageProvider>();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final files = storageProvider.filteredFiles;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (storageProvider.folderPath.isNotEmpty)
                    GestureDetector(
                      onTap: () => storageProvider.navigateBack(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withAlpha(13)
                              : Colors.black.withAlpha(10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.arrow_back_rounded,
                            color: isDark ? Colors.white70 : Colors.black54,
                            size: 20),
                      ),
                    ),
                  if (storageProvider.folderPath.isNotEmpty)
                    const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storageProvider.folderPath.isNotEmpty
                              ? storageProvider.folderPath.last
                              : 'Playground',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        if (storageProvider.folderPath.isNotEmpty)
                          Text(
                            storageProvider.folderPath.join(' / '),
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  // Upload toggle
                  GestureDetector(
                    onTap: () => setState(() => _showUploads = !_showUploads),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _showUploads
                            ? Theme.of(context).primaryColor.withAlpha(26)
                            : (isDark
                                ? Colors.white.withAlpha(13)
                                : Colors.black.withAlpha(10)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          Icon(
                            Icons.upload_file_rounded,
                            color: _showUploads
                                ? Theme.of(context).primaryColor
                                : (isDark ? Colors.white70 : Colors.black54),
                            size: 22,
                          ),
                          if (storageProvider.uploads
                              .where((u) =>
                                  u.status ==
                                  UploadStatus.uploading)
                              .isNotEmpty)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // AI Organize button
                  GestureDetector(
                    onTap: () => _showOrganizeDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withAlpha(13)
                            : Colors.black.withAlpha(10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.auto_fix_high_rounded,
                          color: isDark ? Colors.white70 : Colors.black54,
                          size: 22),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (v) =>
                    context.read<StorageProvider>().setSearchQuery(v),
                decoration: InputDecoration(
                  hintText: 'Search files...',
                  prefixIcon: Icon(Icons.search_rounded,
                      color: isDark ? Colors.white38 : Colors.black38),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            context
                                .read<StorageProvider>()
                                .setSearchQuery('');
                          },
                        )
                      : null,
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 12),

            // Upload queue (collapsible)
            if (_showUploads && storageProvider.uploads.isNotEmpty) ...[
              SizedBox(
                height: 150,
                child: ListView.builder(
                  itemCount: storageProvider.uploads.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final task = storageProvider.uploads[index];
                    return UploadProgressCard(
                      task: task,
                      onCancel: () =>
                          storageProvider.cancelUpload(task.id),
                      onRetry: () =>
                          storageProvider.retryUpload(task.id),
                      onRemove: () =>
                          storageProvider.removeUpload(task.id),
                    );
                  },
                ),
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
            ],

            // File list
            Expanded(
              child: storageProvider.isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor))
                  : files.isEmpty
                      ? _buildEmptyState(context)
                      : RefreshIndicator(
                          onRefresh: () => storageProvider.loadFiles(),
                          color: Theme.of(context).primaryColor,
                          child: ListView.builder(
                            itemCount: files.length,
                            padding: const EdgeInsets.only(bottom: 100),
                            itemBuilder: (context, index) {
                              final file = files[index];
                              return FileTile(
                                file: file,
                                onTap: file.isFolder
                                    ? () => storageProvider.navigateToFolder(
                                        file.id, file.name)
                                    : null,
                                onDelete: () =>
                                    _confirmDelete(context, file),
                                onRename: () =>
                                    _showRenameDialog(context, file),
                                onDownload: () =>
                                    storageProvider.downloadFile(file),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton(
          onPressed: () => _pickAndUploadFiles(context),
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded,
              size: 64, color: Colors.white.withAlpha(51)),
          const SizedBox(height: 16),
          Text(
            'No files yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withAlpha(77),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to upload files',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadFiles(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null && context.mounted) {
      final storageProvider = context.read<StorageProvider>();
      for (final file in result.files) {
        if (file.bytes != null) {
          storageProvider.uploadFile(file.name, file.bytes!);
        }
      }
      setState(() => _showUploads = true);
    }
  }

  void _confirmDelete(BuildContext context, file) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A1A2E)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<StorageProvider>().deleteFile(file);
              Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, file) {
    final controller = TextEditingController(text: file.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A1A2E)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Rename File'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter new name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<StorageProvider>()
                  .renameFile(file, controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showOrganizeDialog(BuildContext context) {
    final accounts = context.read<AuthProvider>().accounts;
    if (accounts.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A1A2E)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(Icons.auto_fix_high_rounded,
                color: Theme.of(context).primaryColor, size: 22),
            const SizedBox(width: 8),
            const Text('AI Organize'),
          ],
        ),
        content: const Text(
          'The AI organizer will sort your files into category folders (Images, Videos, Documents, etc.).\n\nProceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<StorageProvider>()
                  .organizeFiles(accounts.first.id);
            },
            child: const Text('Organize'),
          ),
        ],
      ),
    );
  }
}
