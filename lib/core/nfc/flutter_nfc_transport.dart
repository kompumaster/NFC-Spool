import 'dart:typed_data';

import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

import 'nfc_tag_transport.dart';

class FlutterNfcTagTransport implements NfcTagTransport {
  bool _open = false;

  @override
  Future<NfcTagInfo> open({
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final tag = await FlutterNfcKit.poll(
      timeout: timeout,
      androidCheckNDEF: false,
      readIso14443B: false,
      readIso15693: false,
    );
    _open = true;

    return NfcTagInfo(
      kind: switch (tag.type) {
        NFCTagType.mifare_classic => NfcTagKind.mifareClassic,
        NFCTagType.mifare_ultralight => NfcTagKind.ntag,
        _ => NfcTagKind.unknown,
      },
      uid: _parseUid(tag.id),
      rawType: tag.type.name,
      mifareType: tag.mifareInfo?.type,
    );
  }

  @override
  Future<void> close() async {
    if (!_open) {
      return;
    }
    _open = false;
    try {
      await FlutterNfcKit.finish();
    } catch (_) {
      // The tag can already be gone; closing is best-effort.
    }
  }

  @override
  Future<Uint8List> readMifareBlock(int block, Uint8List keyA) async {
    final authenticated = await FlutterNfcKit.authenticateSector(
      block ~/ 4,
      keyA: keyA,
    );
    if (!authenticated) {
      throw NfcTagException(
        'Не удалось аутентифицировать сектор ${block ~/ 4}.',
      );
    }
    return FlutterNfcKit.readBlock(block);
  }

  @override
  Future<void> writeMifareBlock(
    int block,
    Uint8List data,
    Uint8List keyA,
  ) async {
    final authenticated = await FlutterNfcKit.authenticateSector(
      block ~/ 4,
      keyA: keyA,
    );
    if (!authenticated) {
      throw NfcTagException(
        'Не удалось аутентифицировать сектор ${block ~/ 4}.',
      );
    }
    await FlutterNfcKit.writeBlock(block, data);
  }

  @override
  Future<Uint8List> transceive(Uint8List command) {
    return FlutterNfcKit.transceive<Uint8List>(command);
  }

  Uint8List _parseUid(String id) {
    final normalized = id.replaceAll(RegExp(r'[:\s-]'), '');
    if (normalized.isEmpty ||
        normalized.length.isOdd ||
        !RegExp(r'^[0-9a-fA-F]+$').hasMatch(normalized)) {
      return Uint8List(0);
    }
    return Uint8List.fromList([
      for (var i = 0; i < normalized.length; i += 2)
        int.parse(normalized.substring(i, i + 2), radix: 16),
    ]);
  }
}
