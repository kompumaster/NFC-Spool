import 'dart:async';

import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nfc_spool/core/nfc/nfc_service.dart';

void main() {
  test('NFC availability is checked', () async {
    final service = NfcService(probe: () async => NFCAvailability.available);
    await service.ensureLoaded();

    expect(service.isAvailable, isTrue);
    expect(service.status, NfcStatus.available);
    expect(service.isChecking, isFalse);

    service.dispose();
  });

  test('disabled NFC is reported', () async {
    final service = NfcService(probe: () async => NFCAvailability.disabled);
    await service.ensureLoaded();

    expect(service.isAvailable, isFalse);
    expect(service.availability, NFCAvailability.disabled);
    expect(service.status, NfcStatus.disabled);

    service.dispose();
  });

  test('failed probe is reported as error and can be retried', () async {
    var fail = true;
    final service = NfcService(
      probe: () async {
        if (fail) {
          throw Exception('no plugin');
        }
        return NFCAvailability.available;
      },
    );
    await service.ensureLoaded();

    expect(service.status, NfcStatus.error);
    expect(service.isAvailable, isFalse);
    expect(service.isUnsupported, isFalse);
    expect(service.error, isNotNull);

    fail = false;
    await service.refresh();

    expect(service.status, NfcStatus.available);
    expect(service.isAvailable, isTrue);
    expect(service.error, isNull);

    service.dispose();
  });

  test('exclusive NFC operations cannot overlap', () async {
    final service = NfcService(probe: () async => NFCAvailability.available);
    final started = Completer<void>();
    final release = Completer<void>();

    final first = service.runExclusive(() async {
      started.complete();
      await release.future;
      return 1;
    });

    await started.future;
    expect(service.isBusy, isTrue);

    await expectLater(
      service.runExclusive(() async => 2),
      throwsA(isA<NfcBusyException>()),
    );

    release.complete();
    expect(await first, 1);
    expect(service.isBusy, isFalse);

    service.dispose();
  });

  test('exclusive lock resets after an error', () async {
    final service = NfcService(probe: () async => NFCAvailability.available);

    await expectLater(
      service.runExclusive<void>(() async => throw Exception('write failed')),
      throwsA(isA<Exception>()),
    );

    expect(service.isBusy, isFalse);
    expect(await service.runExclusive(() async => 3), 3);

    service.dispose();
  });
}
