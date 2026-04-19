import 'package:flutter_test/flutter_test.dart';
import 'package:cassiel_drive/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const CassielDriveApp());
    expect(find.text('Cassiel Drive'), findsOneWidget);
  });
}
