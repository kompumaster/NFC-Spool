import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nfc_spool/app.dart';

void main() {
  const nfcChannel = MethodChannel('flutter_nfc_kit/method');
  const packageInfoChannel = MethodChannel(
    'dev.fluttercommunity.plus/package_info',
  );

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(nfcChannel, (call) async {
          if (call.method == 'getNFCAvailability') {
            return 'not_supported';
          }
          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(packageInfoChannel, (call) async {
          if (call.method == 'getAll') {
            return {
              'appName': 'NFC/Spool',
              'packageName': 'io.github.kompumaster.nfcspool',
              'version': '0.1.0',
              'buildNumber': '1',
              'buildSignature': '',
              'installerStore': null,
              'installTime': null,
              'updateTime': null,
            };
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(nfcChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(packageInfoChannel, null);
  });

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
