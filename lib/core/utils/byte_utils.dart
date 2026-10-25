import 'dart:typed_data';

String bytesToHex(Uint8List bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

String bytesToHexSpace(Uint8List bytes) {
  return bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join(' ')
      .toUpperCase();
}

Uint8List hexToBytes(String hex) {
  final normalized = hex.replaceAll(' ', '');
  final bytes = <int>[];
  for (var i = 0; i + 1 < normalized.length; i += 2) {
    bytes.add(int.parse(normalized.substring(i, i + 2), radix: 16));
  }
  return Uint8List.fromList(bytes);
}

int calculateBcc(Uint8List data) {
  var bcc = 0;
  for (final byte in data) {
    bcc ^= byte;
  }
  return bcc;
}
