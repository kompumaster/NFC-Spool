import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nfc_spool/app.dart';

void main() {
  testWidgets('app starts on the NFC tab', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'app_language': 'ru'});
    await tester.pumpWidget(const NfcSpoolApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('NFC/Spool'), findsWidgets);
    expect(find.text('Как пользоваться'), findsOneWidget);
    expect(find.text('NFC'), findsWidgets);
    expect(find.text('Метка'), findsOneWidget);
    expect(find.text('Данные'), findsOneWidget);
    expect(find.text('Настройки'), findsOneWidget);
  });

  testWidgets('tag and settings tabs work without NFC', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'app_language': 'ru'});
    await tester.pumpWidget(const NfcSpoolApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Метка'));
    await tester.pump();

    expect(find.text('Чтение QIDI-метки'), findsOneWidget);
    expect(
      find.text('NFC недоступен — чтение и запись метки выключены.'),
      findsWidgets,
    );

    await tester.tap(find.text('Настройки'));
    await tester.pump();

    expect(find.text('Язык / Language'), findsOneWidget);
    expect(find.text('QIDI CFG не импортирован'), findsOneWidget);
  });
}
