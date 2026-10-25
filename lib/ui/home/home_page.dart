import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../../core/nfc/nfc_service.dart';
import '../../l10n/app_translations.dart';
import '../nfc/nfc_page.dart';
import '../records/records_page.dart';
import '../settings/settings_page.dart';
import '../tag/tag_page.dart';
import '../widgets/l_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  DateTime? _lastBackAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<NfcService>().refresh();
    }
  }

  void _onPopInvoked(bool didPop, Object? result) {
    if (didPop) {
      return;
    }
    final now = DateTime.now();
    final last = _lastBackAt;
    if (last == null || now.difference(last) > const Duration(seconds: 2)) {
      _lastBackAt = now;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: LText('Нажмите «Назад» ещё раз для выхода')),
        );
      return;
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final language = appState.language;
    final index = appState.homeTab;
    String t(String source) => AppTranslations.translate(language, source);

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        appBar: AppBar(title: const LText('NFC/Spool')),
        body: IndexedStack(
          index: index,
          children: const [NfcPage(), TagPage(), RecordsPage(), SettingsPage()],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) {
            context.read<AppState>().homeTab = value;
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.nfc_outlined),
              selectedIcon: const Icon(Icons.nfc),
              label: t('NFC'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.sell_outlined),
              selectedIcon: const Icon(Icons.sell),
              label: t('Метка'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.inventory_2_outlined),
              selectedIcon: const Icon(Icons.inventory_2),
              label: t('Данные'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: t('Настройки'),
            ),
          ],
        ),
      ),
    );
  }
}
