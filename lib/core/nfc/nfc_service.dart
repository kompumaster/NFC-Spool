import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

typedef NfcAvailabilityProbe = Future<NFCAvailability> Function();

enum NfcStatus { checking, available, disabled, unsupported, error }

class NfcBusyException implements Exception {
  NfcBusyException();

  @override
  String toString() =>
      'Уже выполняется другая NFC-операция. Дождитесь завершения.';
}

class NfcService extends ChangeNotifier {
  NfcService({NfcAvailabilityProbe? probe})
    : _probe = probe ?? (() => FlutterNfcKit.nfcAvailability);

  final NfcAvailabilityProbe _probe;
  NFCAvailability? _availability;
  NfcStatus _status = NfcStatus.checking;
  Object? _error;
  bool _checking = false;
  bool _busy = false;
  Future<void>? _loadFuture;

  NFCAvailability? get availability => _availability;

  NfcStatus get status => _status;

  Object? get error => _error;

  bool get isChecking => _checking;

  bool get isBusy => _busy;

  bool get isAvailable => _status == NfcStatus.available;

  bool get isUnsupported => _status == NfcStatus.unsupported;

  Future<void> ensureLoaded() => _loadFuture ??= refresh();

  /// Runs one NFC session at a time. Calls from other screens are rejected
  /// while a tag is being read or written.
  Future<T> runExclusive<T>(Future<T> Function() operation) async {
    if (_busy) {
      throw NfcBusyException();
    }
    _busy = true;
    notifyListeners();
    try {
      return await operation();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_checking) {
      return;
    }
    _checking = true;
    _status = NfcStatus.checking;
    _error = null;
    notifyListeners();
    try {
      final availability = await _probe();
      _availability = availability;
      _status = switch (availability) {
        NFCAvailability.available => NfcStatus.available,
        NFCAvailability.disabled => NfcStatus.disabled,
        NFCAvailability.not_supported => NfcStatus.unsupported,
      };
    } catch (error) {
      _availability = null;
      _status = NfcStatus.error;
      _error = error;
    } finally {
      _checking = false;
      notifyListeners();
    }
  }
}
