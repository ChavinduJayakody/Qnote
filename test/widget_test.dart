import 'package:flutter_test/flutter_test.dart';
import 'package:qnote/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const QnoteApp());
    expect(find.text('Qnote'), findsOneWidget);
    expect(find.text('Your thoughts, amplified.'), findsOneWidget);
  });
}
