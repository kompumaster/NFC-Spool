import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:nfc_spool/core/nfc/nfc_tag_transport.dart';
import 'package:nfc_spool/data/qidi/qidi_data.dart';
import 'package:nfc_spool/services/qidi_tag_service.dart';

class _FakeQidiTransport implements NfcTagTransport {
  _FakeQidiTransport(this.block);

  Uint8List block;
  bool writeResult = true;
  int closeCount = 0;

  @override
  Future<NfcTagInfo> open({
    Duration timeout = const Duration(seconds: 20),
  }) async {
    return NfcTagInfo(
      kind: NfcTagKind.mifareClassic,
      uid: Uint8List.fromList([0x12, 0x34, 0x56, 0x78]),
      rawType: 'mifare_classic',
    );
  }

  @override
  Future<void> close() async {
    closeCount++;
  }

  @override
  Future<Uint8List> readMifareBlock(int block, Uint8List keyA) async {
    return Uint8List.fromList(this.block);
  }

  @override
  Future<void> writeMifareBlock(
    int block,
    Uint8List data,
    Uint8List keyA,
  ) async {
    if (!writeResult) {
      throw NfcTagException('write rejected');
    }
    this.block = Uint8List.fromList(data);
  }

  @override
  Future<Uint8List> transceive(Uint8List command) async => Uint8List(0);
}

void main() {
  test('QidiTagService reads block 4', () async {
    final transport = _FakeQidiTransport(
      Uint8List.fromList([41, 1, 1, ...List<int>.filled(13, 0)]),
    );

    final data = await QidiTagService(transport).read();

    expect(data.materialId, 41);
    expect(data.colorId, 1);
    expect(data.manufacturerId, 1);
    expect(transport.closeCount, 1);
  });

  test('QidiTagService writes and verifies payload', () async {
    final transport = _FakeQidiTransport(Uint8List(16));
    const payload = QidiTagData(materialId: 1, colorId: 2, manufacturerId: 0);

    await QidiTagService(transport).write(payload);

    expect(transport.block.sublist(0, 3), [1, 2, 0]);
    expect(transport.closeCount, 1);
  });

  test('QidiTagService reports write rejection', () async {
    final transport = _FakeQidiTransport(Uint8List(16))..writeResult = false;

    expect(
      () => QidiTagService(
        transport,
      ).write(const QidiTagData(materialId: 1, colorId: 1, manufacturerId: 1)),
      throwsA(isA<QidiTagException>()),
    );
  });

  test('QidiTagService rejects short read', () async {
    final transport = _FakeQidiTransport(Uint8List(8));

    expect(
      () => QidiTagService(transport).read(),
      throwsA(isA<QidiTagException>()),
    );
  });
}
