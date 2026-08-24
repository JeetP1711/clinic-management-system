import 'package:flutter_test/flutter_test.dart';
import 'package:clinicos/main.dart';

void main() {
  testWidgets('ClinicOS app launch smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ClinicOSApp());
    expect(find.byType(ClinicOSApp), findsOneWidget);
  });
}
