import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:nfc_spool/core/nfc/nfc_tag_transport.dart';
import 'package:nfc_spool/data/openspool/openspool_data.dart';
import 'package:nfc_spool/data/openspool/openspool_ntag.dart';
import 'package:nfc_spool/services/openspool_tag_service.dart';

class _FakeNtagTransport implements NfcTagTransport {
  _FakeNtagTransport({OpenSpoolNtagType ntagType = OpenSpoolNtagType.ntag215})
    : pages = List.generate(
        OpenSpoolNtagLayout.forType(ntagType).totalPages,
        (_) => Uint8List(4),
      ) {
    pages[3] = Uint8List.fromList(OpenSpoolNtagLayout.forType(ntagType).cc);
    pages[0] = Uint8List.fromList([0x04, 0x11, 0x22, 0x33]);
    pages[1] = Uint8List.fromList([0x44, 0x55, 0x66, 0x77]);
  }

  final List<Uint8List> pages;
  bool present = true;
  bool shortUserReads = false;
  int closeCount = 0;

  @override
  Future<NfcTagInfo> open({
    Duration timeout = const Duration(seconds: 20),
  }) async {
    if (!present) {
      throw NfcTagException('tag not found');
    }
    return NfcTagInfo(
      kind: NfcTagKind.ntag,
      uid: Uint8List.fromList([0x04, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66]),
      rawType: 'mifare_ultralight',
    );
  }

  @override
  Future<void> close() async {
    closeCount++;
  }

  @override
  Future<Uint8List> readMifareBlock(int block, Uint8List keyA) async {
    return Uint8List(0);
  }

  @override
  Future<void> writeMifareBlock(
    int block,
    Uint8List data,
    Uint8List keyA,
  ) async {}

  @override
  Future<Uint8List> transceive(Uint8List data) async {
    if (data.isEmpty) {
      return Uint8List(0);
    }
    if (data[0] == 0x30 && data.length >= 2) {
      final page = data[1];
      final out = <int>[];
      for (var i = 0; i < 4; i++) {
        out.addAll(pages[page + i]);
      }
      if (shortUserReads && page >= 4) {
        return Uint8List.fromList(out.sublist(0, 4));
      }
      return Uint8List.fromList(out);
    }
    if (data[0] == 0xA2 && data.length >= 6) {
      final page = data[1];
      pages[page] = Uint8List.fromList(data.sublist(2, 6));
      return Uint8List.fromList([0x0A]);
    }
    return Uint8List(0);
  }
}

void main() {
  test('OpenSpoolTagService writes and reads NDEF on NTAG pages', () async {
    final transport = _FakeNtagTransport();
    final service = OpenSpoolTagService(transport);
    const data = OpenSpoolTagData(
      type: 'PLA',
      colorHex: '#FF0000',
      brand: 'QIDI',
      minTemp: 190,
      maxTemp: 220,
    );

    await service.write(data);
    final restored = await service.read();

    expect(transport.pages[3], [0xE1, 0x10, 0x3E, 0x00]);
    expect(restored.type, 'PLA');
    expect(restored.colorHex, '#FF0000');
    expect(restored.brand, 'QIDI');
    expect(restored.uid, [0x04, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66]);
    expect(transport.closeCount, 2);
  });

  test('OpenSpoolTagService reads and writes NTAG216', () async {
    final transport = _FakeNtagTransport(ntagType: OpenSpoolNtagType.ntag216);
    final service = OpenSpoolTagService(transport);
    final data = OpenSpoolTagData(
      type: 'PETG',
      colorHex: '#A5FF52',
      brand: 'Snapmaker',
      subtype: List.filled(600, 'X').join(),
      minTemp: 220,
      maxTemp: 250,
      bedMinTemp: 70,
      bedMaxTemp: 80,
      weight: 750,
      diameter: 1.75,
    );

    final result = await service.write(data, profile: OpenSpoolProfile.u1);
    final restored = await service.read();

    expect(result.ntagType, OpenSpoolNtagType.ntag216);
    expect(transport.pages[3], [0xE1, 0x10, 0x6D, 0x00]);
    expect(restored.ntagType, OpenSpoolNtagType.ntag216);
    expect(restored.subtype, List.filled(600, 'X').join());
    expect(restored.id, isNotEmpty);
  });

  test('OpenSpoolTagService rejects NTAG213', () async {
    final transport = _FakeNtagTransport();
    transport.pages[3] = Uint8List.fromList([0xE1, 0x10, 0x12, 0x00]);
    final service = OpenSpoolTagService(transport);

    expect(
      () => service.read(),
      throwsA(
        isA<OpenSpoolTagException>().having(
          (error) => error.message,
          'message',
          contains('NTAG213'),
        ),
      ),
    );
  });

  test('OpenSpoolTagService rejects a short page block', () async {
    final transport = _FakeNtagTransport()..shortUserReads = true;
    final service = OpenSpoolTagService(transport);

    expect(
      () => service.read(),
      throwsA(
        isA<OpenSpoolTagException>().having(
          (error) => error.message,
          'message',
          contains('вместо'),
        ),
      ),
    );
  });

  test('OpenSpoolTagService reports missing tag', () async {
    final transport = _FakeNtagTransport()..present = false;
    final service = OpenSpoolTagService(transport);

    expect(() => service.read(), throwsA(isA<OpenSpoolTagException>()));
  });
}
