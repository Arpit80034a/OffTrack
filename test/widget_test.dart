import 'package:flutter_test/flutter_test.dart';
import 'package:offtrack/main.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ScheduleManagerApp());
    expect(find.text('Schedule Manager'), findsOneWidget);
  });
}
