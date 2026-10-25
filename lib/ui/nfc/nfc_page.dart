import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:provider/provider.dart';

import '../../core/nfc/nfc_service.dart';
import '../widgets/l_text.dart';

class NfcPage extends StatelessWidget {
  const NfcPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nfc = context.watch<NfcService>();
    final scheme = Theme.of(context).colorScheme;
    final availability = nfc.availability;
    final (icon, title, subtitle, color) = switch (availability) {
      NFCAvailability.available => (
        Icons.nfc,
        'NFC доступен',
        'Можно читать и записывать метки.',
        scheme.primary,
      ),
      NFCAvailability.disabled => (
        Icons.nfc,
        'NFC выключен',
        'Включите NFC в настройках Android и нажмите «Проверить».',
        scheme.error,
      ),
      NFCAvailability.not_supported => (
        Icons.nfc,
        'NFC не поддерживается',
        'Этот телефон не умеет работать с NFC-метками.',
        scheme.error,
      ),
      null => (
        Icons.nfc,
        'Проверка NFC…',
        'Определяю доступность NFC на телефоне.',
        scheme.onSurfaceVariant,
      ),
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: Icon(icon, color: color),
            title: LText(title),
            subtitle: LText(subtitle),
            trailing: IconButton(
              onPressed: nfc.isChecking ? null : nfc.refresh,
              icon: nfc.isChecking
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              tooltip: 'Проверить NFC',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LText(
                  'Как пользоваться',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const _Step(
                  number: '1',
                  text: 'Откройте вкладку «Метка» и выберите QIDI, OpenSpool или Snapmaker U1.',
                ),
                const _Step(
                  number: '2',
                  text: 'Нажмите «Прочитать метку» или «Записать метку».',
                ),
                const _Step(
                  number: '3',
                  text: 'Приложите метку к задней панели телефона рядом с камерой и держите до завершения операции.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LText(
                  'Поддерживаемые метки',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const _InfoLine(
                  icon: Icons.memory,
                  title: 'QIDI',
                  text: 'MIFARE Classic 1K, блок 4, ключ A FFFFFFFFFFFF.',
                ),
                const SizedBox(height: 8),
                const _InfoLine(
                  icon: Icons.nfc,
                  title: 'OpenSpool / Snapmaker U1',
                  text: 'NTAG215 или NTAG216. NTAG213 не поддерживается.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: LText(
              'Сохранение меток, импорт и экспорт .bin, а также отправка на Snapmaker U1 работают без прикладывания метки.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            child: Text(number, style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Expanded(child: LText(text)),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LText(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 2),
              LText(text, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
