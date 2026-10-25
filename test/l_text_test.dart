import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nfc_spool/app_state.dart';
import 'package:nfc_spool/ui/widgets/l_text.dart';

void main() {
  testWidgets('LText switches language from AppState', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final appState = AppState();
    await appState.ensureLoaded();
    appState.language = AppLanguage.en;

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: appState,
        child: const MaterialApp(home: Scaffold(body: LText('Настройки'))),
      ),
    );

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Настройки'), findsNothing);
  });
}
