import 'dart:typed_data';

import '../core/nfc/nfc_tag_transport.dart';
import '../data/qidi/qidi_data.dart';

class QidiTagException implements Exception {
  QidiTagException(this.message);

  final String message;

  @override
  String toString() => message;
}

class QidiTagService {
  QidiTagService(this.transport);

  final NfcTagTransport transport;

  Future<QidiTagData> read() {
    return _withTag((info) async {
      _requireClassic(info);
      final block = await transport.readMifareBlock(
        qidiDataBlock,
        Uint8List.fromList(qidiDefaultKeyA),
      );
      if (block.length < qidiBlockSize) {
        throw QidiTagException(
          'Метка вернула ${block.length} байт вместо $qidiBlockSize.',
        );
      }
      return QidiTagData.fromBlock(
        block,
        uid: info.uid.isEmpty ? null : info.uid,
      );
    });
  }

  Future<void> write(QidiTagData data) {
    final expected = data.toBlock();
    return _withTag((info) async {
      _requireClassic(info);
      await transport.writeMifareBlock(
        qidiDataBlock,
        expected,
        Uint8List.fromList(qidiDefaultKeyA),
      );

      final readBack = await transport.readMifareBlock(
        qidiDataBlock,
        Uint8List.fromList(qidiDefaultKeyA),
      );
      if (!_blockMatches(readBack, expected)) {
        throw QidiTagException('Проверка после записи не совпала.');
      }
    });
  }

  void _requireClassic(NfcTagInfo info) {
    if (info.kind != NfcTagKind.mifareClassic) {
      throw QidiTagException(
        'Это не MIFARE Classic 1K. Приложите QIDI-метку к телефону.',
      );
    }
  }

  Future<T> _withTag<T>(Future<T> Function(NfcTagInfo info) action) async {
    try {
      final info = await transport.open();
      try {
        return await action(info);
      } finally {
        await transport.close();
      }
    } on QidiTagException {
      rethrow;
    } catch (error) {
      throw QidiTagException(
        'Не удалось прочитать или записать QIDI-метку. '
        'Проверьте, что это MIFARE Classic 1K, и держите метку у телефона. '
        'Ошибка: $error',
      );
    }
  }

  bool _blockMatches(Uint8List actual, Uint8List expected) {
    if (actual.length < expected.length) {
      return false;
    }
    for (var i = 0; i < expected.length; i++) {
      if (actual[i] != expected[i]) {
        return false;
      }
    }
    return true;
  }
}
