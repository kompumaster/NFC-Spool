import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_state.dart';
import '../../data/openspool/openspool_data.dart';
import '../../data/qidi/qidi_lists_store.dart';
import '../../l10n/app_translations.dart';
import '../snapmaker/snapmaker_section.dart';
import '../widgets/l_text.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _cfgBusy = false;
  late final Future<String> _versionFuture = _loadVersion();

  Future<String> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return '0.1.0';
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final lists = context.watch<QidiListsStore>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        LText('Настройки', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        DropdownButtonFormField<AppLanguage>(
          key: ValueKey('settings-language-${app.language.name}'),
          initialValue: app.language,
          decoration: const InputDecoration(
            label: LText('Язык / Language'),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: AppLanguage.ru, child: LText('Русский')),
            DropdownMenuItem(value: AppLanguage.en, child: LText('English')),
          ],
          onChanged: (value) {
            if (value != null) {
              context.read<AppState>().language = value;
            }
          },
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.list_alt),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LText(
                        lists.hasCfg
                            ? 'QIDI CFG: ${lists.cfgName ?? 'импортирован'}'
                            : 'QIDI CFG не импортирован',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LText(
                  lists.hasCfg
                      ? 'Списки материалов заблокированы: '
                            '${lists.slots.where((slot) => slot.isActive).length} '
                            'активных слотов.'
                      : 'Можно импортировать officiall_filas_list.cfg с принтера.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: _cfgBusy ? null : _importCfg,
                      icon: _cfgBusy
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.file_open_outlined),
                      label: const LText('Импорт .cfg'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _cfgBusy || !lists.hasCfg ? null : _clearCfg,
                      icon: const Icon(Icons.restart_alt),
                      label: const LText('Сбросить'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),
        const SnapmakerSection(),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),
        LText('Списки', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        LText(
          'QIDI: ${lists.materialsFor(app.qidiModel).length} материалов · '
          '24 цвета · 2 производителя.',
        ),
        const SizedBox(height: 4),
        LText(
          'OpenSpool: ${openSpoolMaterials.length} материалов · '
          '${openSpoolManufacturers.length} производителей.',
        ),
        const SizedBox(height: 4),
        const LText(
          'Редактирование списков вручную пока не реализовано. '
          'QIDI CFG импортируется выше.',
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),
        FutureBuilder<String>(
          future: _versionFuture,
          builder: (context, snapshot) {
            final version = snapshot.data ?? '0.1.0';
            return LText('NFC/Spool · $version');
          },
        ),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: _openRepository,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          icon: const Icon(Icons.open_in_new, size: 16),
          label: const LText('https://github.com/kompumaster/NFC-Spool'),
        ),
      ],
    );
  }

  Future<void> _openRepository() async {
    final uri = Uri.parse('https://github.com/kompumaster/NFC-Spool');
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        _message('Не удалось открыть ссылку');
      }
    } catch (e) {
      if (mounted) {
        _message('Не удалось открыть ссылку: $e');
      }
    }
  }

  Future<void> _importCfg() async {
    final store = context.read<QidiListsStore>();
    final language = context.read<AppState>().language;
    setState(() => _cfgBusy = true);
    try {
      final picked = await FilePicker.pickFile(
        dialogTitle: AppTranslations.translate(language, 'Импорт QIDI .cfg'),
        type: FileType.custom,
        allowedExtensions: const ['cfg'],
      );
      if (picked == null) {
        return;
      }
      final bytes = await picked.xFile.readAsBytes();
      final text = utf8.decode(bytes, allowMalformed: true);
      await store.importCfg(text, name: picked.name);
      if (!mounted) {
        return;
      }
      _message('CFG импортирован: ${picked.name}');
    } catch (e) {
      if (mounted) {
        _message('Не удалось импортировать CFG: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _cfgBusy = false);
      }
    }
  }

  Future<void> _clearCfg() async {
    final store = context.read<QidiListsStore>();
    setState(() => _cfgBusy = true);
    try {
      await store.clearCfg();
      if (mounted) {
        _message('CFG сброшен, используются встроенные списки');
      }
    } finally {
      if (mounted) {
        setState(() => _cfgBusy = false);
      }
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: LText(text)));
  }
}
