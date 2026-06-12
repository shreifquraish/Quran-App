import 'package:flutter_test/flutter_test.dart';
import 'package:al_quran_kareem/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const QuranApp());
    expect(find.text('القرآن الكريم'), findsWidgets);
  });
}
