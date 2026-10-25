import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nfc_spool/core/nfc/nfc_service.dart';

void main() {
  test('NFC availability is checked', () async {
    final service = NfcService(probe: () async => NFCAvailability.available);
    await service.ensureLoaded();

    expect(service.isAvailable, isTrue);
    expect(service.isChecking, isFalse);

    service.dispose();
  });

  test('disabled NFC is reported', () async {
    final service = NfcService(probe: () async => NFCAvailability.disabled);
    await service.ensureLoaded();

    expect(service.isAvailable, isFalse);
    expect(service.availability, NFCAvailability.disabled);

    service.dispose();
  });

  test('failed probe is treated as unsupported', () async {
    final service = NfcService(probe: () async => throw Exception('no plugin'));
    await service.ensureLoaded();

    expect(service.isAvailable, isFalse);
    expect(service.isUnsupported, isTrue);

    service.dispose();
  });
}
