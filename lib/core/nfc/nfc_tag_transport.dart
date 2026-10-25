import 'dart:typed_data';

enum NfcTagKind { mifareClassic, ntag, unknown }

class NfcTagInfo {
  const NfcTagInfo({
    required this.kind,
    required this.uid,
    required this.rawType,
    this.mifareType,
  });

  final NfcTagKind kind;
  final Uint8List uid;
  final String rawType;
  final String? mifareType;
}

class NfcTagException implements Exception {
  NfcTagException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Low-level NFC transport. A session starts with [open] and must be closed
/// with [close]. Implementations are intentionally small so the tag codecs can
/// be tested without Android NFC hardware.
abstract class NfcTagTransport {
  Future<NfcTagInfo> open({Duration timeout = const Duration(seconds: 20)});

  Future<void> close();

  Future<Uint8List> readMifareBlock(int block, Uint8List keyA);

  Future<void> writeMifareBlock(int block, Uint8List data, Uint8List keyA);

  Future<Uint8List> transceive(Uint8List command);
}
