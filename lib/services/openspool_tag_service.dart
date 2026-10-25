import 'dart:math' as math;
import 'dart:typed_data';

import '../core/nfc/nfc_tag_transport.dart';
import '../data/openspool/openspool_data.dart';
import '../data/openspool/openspool_ndef_codec.dart';
import '../data/openspool/openspool_ntag.dart';

class OpenSpoolTagException implements Exception {
  OpenSpoolTagException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OpenSpoolWriteResult {
  const OpenSpoolWriteResult({required this.data, required this.ntagType});

  final OpenSpoolTagData data;
  final OpenSpoolNtagType ntagType;
}

class OpenSpoolTagService {
  OpenSpoolTagService(this.transport);

  final NfcTagTransport transport;

  Future<Uint8List> _readPageBlock(int page) async {
    final response = await transport.transceive(
      Uint8List.fromList([0x30, page]),
    );
    if (response.length < 4) {
      throw OpenSpoolTagException('NTAG не вернул страницу $page.');
    }
    return response;
  }

  Future<Uint8List> _readHeader() async {
    final header = await _readPageBlock(0);
    if (header.length < 16) {
      throw OpenSpoolTagException('NTAG вернул неполный заголовок.');
    }
    return header.sublist(0, 16);
  }

  Future<OpenSpoolNtagLayout> _detectLayout() async {
    final response = await _readPageBlock(OpenSpoolNtagLayout.ccPage);
    if (response.length < 4) {
      throw OpenSpoolTagException('NTAG вернул неполную CC-страницу.');
    }
    final cc = response.sublist(0, 4);
    final layout = OpenSpoolNtagLayout.fromCc(cc);
    if (layout != null) {
      return layout;
    }
    if (OpenSpoolNtagLayout.isNtag213(cc)) {
      throw OpenSpoolTagException(
        'NTAG213 не поддерживается. Используйте NTAG215 или NTAG216.',
      );
    }
    throw OpenSpoolTagException(
      'Не удалось определить тип метки. '
      'Ожидается NTAG215/216, CC: ${_hex(cc)}.',
    );
  }

  Future<Uint8List> _readUserArea(OpenSpoolNtagLayout layout) async {
    final user = Uint8List(layout.userAreaSize);
    for (
      var page = OpenSpoolNtagLayout.firstUserPage;
      page <= layout.lastUserPage;
      page += 4
    ) {
      final chunk = await _readPageBlock(page);
      final take = math.min(16, (layout.lastUserPage - page + 1) * 4);
      final offset = (page - OpenSpoolNtagLayout.firstUserPage) * 4;
      if (chunk.length < take) {
        throw OpenSpoolTagException(
          'NTAG вернул ${chunk.length} байт вместо $take '
          'для страницы $page.',
        );
      }
      user.setRange(offset, offset + take, chunk);
    }
    return user;
  }

  Future<void> _writePage(int page, Uint8List data) async {
    if (data.length != 4) {
      throw ArgumentError('NTAG page must be 4 bytes');
    }

    final response = await transport.transceive(
      Uint8List.fromList([0xA2, page, ...data]),
    );
    if (response.isNotEmpty && response[0] != 0x0A) {
      throw OpenSpoolTagException('NTAG не подтвердил запись страницы $page.');
    }
  }

  Future<OpenSpoolTagData> read() {
    return _withTag((info) async {
      _requireNtag(info);
      final layout = await _detectLayout();
      final header = await _readHeader();
      final userArea = await _readUserArea(layout);
      final data = OpenSpoolNdefCodec.parse(userArea);
      return data
          .withNtagType(layout.type)
          .withUid(Uint8List.fromList(header.sublist(0, 7)));
    });
  }

  Future<OpenSpoolWriteResult> write(
    OpenSpoolTagData data, {
    OpenSpoolProfile profile = OpenSpoolProfile.standard,
    OpenSpoolTier tier = OpenSpoolTier.standard,
  }) {
    return _withTag((info) async {
      _requireNtag(info);
      final layout = await _detectLayout();
      final payload =
          profile == OpenSpoolProfile.u1 &&
              (data.id == null || data.id!.trim().isEmpty)
          ? data.withId(newOpenSpoolTagId())
          : data;
      final tlv = OpenSpoolNdefCodec.build(
        payload,
        profile: profile,
        tier: tier,
        maxLength: layout.userAreaSize,
      );

      final pageCount = (tlv.length + 3) ~/ 4;
      for (var index = 0; index < pageCount; index++) {
        final offset = index * 4;
        final page = Uint8List(4);
        for (var i = 0; i < 4; i++) {
          final source = offset + i;
          page[i] = source < tlv.length ? tlv[source] : 0;
        }
        await _writePage(OpenSpoolNtagLayout.firstUserPage + index, page);
      }

      final readBack = await _readUserArea(layout);
      final tlvReadBack = OpenSpoolNdefCodec.findTlv(readBack);
      final expectedTlv = OpenSpoolNdefCodec.findTlv(tlv);
      if (tlvReadBack == null ||
          expectedTlv == null ||
          tlvReadBack.length != expectedTlv.length ||
          !_matches(
            readBack.sublist(
              tlvReadBack.offset,
              tlvReadBack.offset + tlvReadBack.length,
            ),
            tlv.sublist(
              expectedTlv.offset,
              expectedTlv.offset + expectedTlv.length,
            ),
          )) {
        throw OpenSpoolTagException(
          'Проверка после записи OpenSpool не совпала.',
        );
      }
      return OpenSpoolWriteResult(data: payload, ntagType: layout.type);
    });
  }

  void _requireNtag(NfcTagInfo info) {
    if (info.kind != NfcTagKind.ntag) {
      throw OpenSpoolTagException(
        'Это не NTAG215/216. Приложите подходящую метку к телефону.',
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
    } on OpenSpoolTagException {
      rethrow;
    } catch (error) {
      throw OpenSpoolTagException(
        'Не удалось прочитать или записать OpenSpool-метку. '
        'Проверьте, что это NTAG215/216, и держите метку у телефона. '
        'Ошибка: $error',
      );
    }
  }

  static String _hex(List<int> bytes) {
    return bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');
  }

  bool _matches(List<int> a, List<int> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
