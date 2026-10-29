import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../widgets/l_text.dart';

import 'package:provider/provider.dart';

import '../../core/nfc/flutter_nfc_transport.dart';
import '../../core/nfc/nfc_service.dart';
import '../../app_state.dart';
import '../../core/utils/byte_utils.dart';
import '../../data/openspool/openspool_bin_codec.dart';
import '../../data/openspool/openspool_data.dart';
import '../../data/openspool/openspool_ntag.dart';
import '../../data/qidi/qidi_bin_codec.dart';
import '../../data/qidi/qidi_data.dart';
import '../../data/records/record_repository.dart';
import '../../data/records/tag_record.dart';
import '../../data/snapmaker/snapmaker_models.dart';
import '../../l10n/app_translations.dart';
import '../../services/openspool_tag_service.dart';
import '../../services/qidi_tag_service.dart';
import '../../services/snapmaker_status_service.dart';
import '../snapmaker/snapmaker_send_dialog.dart';

class RecordDetailPage extends StatefulWidget {
  const RecordDetailPage({required this.record, super.key});

  final TagRecord record;

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  late TagRecord _record = widget.record;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final qidi = _record.qidiData;
    final os = _record.openspoolData;
    final language = context.watch<AppState>().language;
    final nfc = context.watch<NfcService>();
    final available = nfc.isAvailable;
    final nfcBusy = nfc.isBusy;
    final snapmaker = context.watch<SnapmakerStatusService>();
    final snapmakerBlocked = snapmaker.isBlocked;
    final snapmakerHint = snapmaker.status == SnapmakerStatus.unknown
        ? 'Snapmaker не проверен — откройте Настройки → Snapmaker U1 и нажмите «Проверить».'
        : 'Snapmaker недоступен — проверьте подключение в Настройках.';

    return Scaffold(
      appBar: AppBar(
        title: LText(_record.name),
        actions: [
          IconButton(
            tooltip: AppTranslations.translate(language, 'Переименовать'),
            onPressed: _busy ? null : _rename,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: AppTranslations.translate(language, 'Удалить'),
            onPressed: _busy ? null : _delete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: LText(
                      _record.type == TagRecordType.qidi
                          ? 'QIDI'
                          : 'OpenSpool ${_profileLabel()}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  LText(
                    _record.summary,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  LText(
                    'Создано: ${_formatDate(_record.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          if (qidi != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LText(
                      'Блок 4',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      bytesToHexSpace(qidi.rawBlock ?? qidi.toBlock()),
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: 'Материал',
                      value:
                          qidiMaterialById(
                            qidi.materialId,
                            _record.qidiModel ?? QidiPrinterModel.plus4,
                          )?.name ??
                          'ID ${qidi.materialId}',
                    ),
                    _InfoRow(
                      label: 'Цвет',
                      value:
                          qidiColorById(qidi.colorId)?.name ??
                          'ID ${qidi.colorId}',
                    ),
                    _InfoRow(
                      label: 'Производитель',
                      value:
                          qidiManufacturerById(qidi.manufacturerId)?.name ??
                          'ID ${qidi.manufacturerId}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _busy || !available || nfcBusy ? null : _writeQidi,
              icon: _busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.nfc),
              label: LText(_busy ? 'Записываю…' : 'Записать на метку'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _busy ? null : _exportQidi,
              icon: const Icon(Icons.save_alt),
              label: const LText('Экспорт .bin'),
            ),
          ],
          if (os != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(label: 'Метка', value: os.ntagType.label),
                    _InfoRow(label: 'Бренд', value: os.brand ?? '—'),
                    _InfoRow(label: 'Материал', value: os.type),
                    _InfoRow(label: 'Подтип', value: os.subtype ?? '—'),
                    _InfoRow(label: 'Цвет', value: os.colorHex),
                    _InfoRow(
                      label: 'Сопло',
                      value: _tempRange(os.minTemp, os.maxTemp),
                    ),
                    _InfoRow(
                      label: 'Стол',
                      value: _tempRange(os.bedMinTemp, os.bedMaxTemp),
                    ),
                    if (os.alpha != null)
                      _InfoRow(label: 'Alpha', value: os.alpha!),
                    if (os.weight != null)
                      _InfoRow(label: 'Вес', value: '${os.weight} г'),
                    if (os.diameter != null)
                      _InfoRow(label: 'Диаметр', value: '${os.diameter} мм'),
                    if (os.additionalColorHexes.isNotEmpty)
                      _InfoRow(
                        label: 'Доп. цвета',
                        value: os.additionalColorHexes.join(', '),
                      ),
                    const Divider(height: 24),
                    LText(
                      'JSON',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      const JsonEncoder.withIndent('  ').convert(
                        os.toJson(
                          profile:
                              _record.openspoolProfile ??
                              OpenSpoolProfile.standard,
                          tier: _record.openspoolTier ?? OpenSpoolTier.all,
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _busy || !available || nfcBusy
                  ? null
                  : _writeOpenSpool,
              icon: _busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.nfc),
              label: LText(_busy ? 'Записываю…' : 'Записать на метку'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _busy ? null : _exportOpenSpool,
              icon: const Icon(Icons.save_alt),
              label: LText(
                os.ntagType == OpenSpoolNtagType.ntag216
                    ? 'Экспорт .bin (924)'
                    : 'Экспорт .bin (540)',
              ),
            ),
            if (_record.openspoolProfile == OpenSpoolProfile.u1) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _busy || snapmakerBlocked ? null : _sendOpenSpool,
                icon: const Icon(Icons.print_outlined),
                label: const LText('Отправить на U1'),
              ),
              if (snapmakerBlocked) ...[
                const SizedBox(height: 4),
                LText(snapmakerHint, style: const TextStyle(fontSize: 12)),
              ],
            ],
          ],
        ],
      ),
    );
  }

  String _profileLabel() {
    return _record.openspoolProfile == OpenSpoolProfile.u1 ? 'U1' : 'Standard';
  }

  String _tempRange(int? min, int? max) {
    if (min == null && max == null) {
      return '—';
    }
    return '${min ?? '—'}–${max ?? '—'} °C';
  }

  Future<void> _rename() async {
    final repository = context.read<RecordRepository>();
    var draft = _record.name;
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const LText('Имя записи'),
        content: TextFormField(
          initialValue: _record.name,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onChanged: (text) => draft = text,
          onFieldSubmitted: (text) => Navigator.of(context).pop(text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const LText('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(draft),
            child: const LText('Сохранить'),
          ),
        ],
      ),
    );
    if (value == null || value.trim().isEmpty) {
      return;
    }

    try {
      await repository.rename(_record.id, value);
      if (!mounted) {
        return;
      }
      setState(() {
        _record = repository.records.firstWhere(
          (record) => record.id == _record.id,
          orElse: () => _record,
        );
      });
    } catch (e) {
      if (mounted) {
        _message('Не удалось переименовать: $e');
      }
    }
  }

  Future<void> _delete() async {
    final repository = context.read<RecordRepository>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const LText('Удалить запись?'),
        content: LText('«${_record.name}» будет удалена.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const LText('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const LText('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    await repository.delete(_record.id);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _writeQidi() async {
    final qidi = _record.qidiData;
    if (qidi == null) {
      return;
    }
    if (!context.read<NfcService>().isAvailable) {
      _message('NFC недоступен.');
      return;
    }
    final nfc = context.read<NfcService>();

    setState(() => _busy = true);
    try {
      await nfc.runExclusive(
        () => QidiTagService(FlutterNfcTagTransport()).write(qidi),
      );
      if (mounted) {
        _message('Метка записана и проверена');
      }
    } catch (e) {
      if (mounted) {
        _message(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _exportQidi() async {
    final qidi = _record.qidiData;
    if (qidi == null) {
      return;
    }
    final language = context.read<AppState>().language;

    setState(() => _busy = true);
    try {
      final bytes = QidiBinCodec.encode(qidi);
      final safeName = _record.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final uri = await FilePicker.saveFile(
        dialogTitle: AppTranslations.translate(language, 'Сохранить QIDI .bin'),
        fileName: '$safeName.bin',
        bytes: bytes,
        mimeType: 'application/octet-stream',
      );
      if (mounted && uri != null) {
        _message('Файл сохранён');
      }
    } catch (e) {
      if (mounted) {
        _message('Не удалось экспортировать .bin: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _writeOpenSpool() async {
    final os = _record.openspoolData;
    if (os == null) {
      return;
    }
    if (!context.read<NfcService>().isAvailable) {
      _message('NFC недоступен.');
      return;
    }
    final nfc = context.read<NfcService>();

    final repository = context.read<RecordRepository>();
    setState(() => _busy = true);
    try {
      final profile = _record.openspoolProfile ?? OpenSpoolProfile.standard;
      final result = await nfc.runExclusive(
        () => OpenSpoolTagService(FlutterNfcTagTransport()).write(
          os,
          profile: profile,
          tier: _record.openspoolTier ?? OpenSpoolTier.standard,
        ),
      );
      if (!mounted) {
        return;
      }
      if (result.data.id != os.id) {
        await repository.updateOpenSpoolData(_record.id, result.data);
        if (!mounted) {
          return;
        }
        setState(() {
          _record = repository.records.firstWhere(
            (record) => record.id == _record.id,
            orElse: () => _record,
          );
        });
      }
      _message(
        profile == OpenSpoolProfile.u1
            ? 'Snapmaker-метка записана и проверена (${result.ntagType.label})'
            : 'OpenSpool-метка записана и проверена (${result.ntagType.label})',
      );
    } catch (e) {
      if (mounted) {
        _message(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _exportOpenSpool() async {
    final os = _record.openspoolData;
    if (os == null) {
      return;
    }
    final language = context.read<AppState>().language;

    setState(() => _busy = true);
    try {
      final profile = _record.openspoolProfile ?? OpenSpoolProfile.standard;
      final bytes = OpenSpoolBinCodec.encode(
        os,
        profile: profile,
        tier: _record.openspoolTier ?? OpenSpoolTier.standard,
      );
      final safeName = _record.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final uri = await FilePicker.saveFile(
        dialogTitle: AppTranslations.translate(
          language,
          'Сохранить OpenSpool .bin',
        ),
        fileName: '$safeName.bin',
        bytes: bytes,
        mimeType: 'application/octet-stream',
      );
      if (mounted && uri != null) {
        _message('Файл сохранён');
      }
    } catch (e) {
      if (mounted) {
        _message('Не удалось экспортировать .bin: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _sendOpenSpool() async {
    final os = _record.openspoolData;
    if (os == null) {
      return;
    }
    await showSnapmakerSendDialog(
      context,
      SnapmakerTagPayload.fromOpenSpool(os),
    );
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: LText(text)));
  }

  String _formatDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}.${two(date.month)}.${date.year} '
        '${two(date.hour)}:${two(date.minute)}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: LText(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(child: LText(value)),
        ],
      ),
    );
  }
}
