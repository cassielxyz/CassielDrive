import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

class PdfGuideGenerator {
  /// Generates the setup guide PDF, saves it to Downloads, and opens it.
  static Future<bool> generateAndOpen() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'CassielDrive — Google Cloud Setup Guide',
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Follow these steps to create your own OAuth credentials and connect Google Drive.',
                style: const pw.TextStyle(fontSize: 13),
              ),
              pw.SizedBox(height: 16),

              _step('1. Go to Google Cloud Console', 'Open https://console.cloud.google.com/ in your browser.'),
              _step('2. Create a New Project', 'Click "Select a project" > "New Project".\nName it "CassielDrive" and click Create.'),
              _step('3. Enable Google Drive API', 'Go to "APIs & Services" > "Library".\nSearch "Google Drive API" > click Enable.'),
              _step('4. Configure OAuth Consent Screen',
                  'Go to "APIs & Services" > "OAuth consent screen".\n'
                  'Choose "External" > Create.\n'
                  'Fill in App Name: "CassielDrive"\n'
                  'User support email: your email\n'
                  'Developer contact: your email\n'
                  'Click Save and Continue through all steps.'),
              _step('5. Add Test Users',
                  'On the consent screen, go to "Test users".\n'
                  'Click "Add users" and add YOUR Google email.\n'
                  'This is required while the app is in "Testing" mode.'),
              _step('6. Create OAuth Client ID',
                  'Go to "Credentials" > "Create Credentials" > "OAuth client ID".'),

              pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 8),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.red50,
                  border: pw.Border.all(color: PdfColors.red300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('IMPORTANT: Application Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red900, fontSize: 13)),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Select "Desktop app" (or "iOS/Android" if you prefer custom URI schemes) as the Application type.\n\n'
                      'We use a dynamic loopback port for secure local authentication, which requires the "Desktop app" type for the redirect to function appropriately without strict port matching.\n\n'
                      'Do NOT select "Web application".',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),

              _step('7. Copy Client ID & Secret',
                  'After creating, a dialog will appear with your Client ID and Client Secret (password).\n'
                  'Copy both of these exactly and paste them into the CassielDrive Settings screen.'),
              _step('8. Add Your Google Account',
                  'After saving the credentials in Settings, tap "Add Google Account".\n'
                  'Your browser will open for Google sign-in.\n'
                  'Authorize the app, then return to CassielDrive.'),

              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  border: pw.Border.all(color: PdfColors.green300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Text(
                  'Done! Your Google Drive files will now appear in the app.',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.green900),
                ),
              ),
            ];
          },
        ),
      );

      // Save to the public Downloads folder on Android
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      final filePath = '${downloadsDir.path}/CassielDrive_Setup_Guide.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Open the PDF
      await OpenFile.open(filePath);
      return true;
    } catch (e) {
      debugPrint('PDF error: $e');
      return false;
    }
  }
}

pw.Widget _step(String title, String description) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 12),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
        pw.SizedBox(height: 3),
        pw.Text(description, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
      ],
    ),
  );
}
