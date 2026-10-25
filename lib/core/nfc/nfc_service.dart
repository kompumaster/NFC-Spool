import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

typedef NfcAvailabilityProbe = Future<NFCAvailability> Function();

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
  bool _checking = false;
  bool _busy = false;
  Future<void>? _loadFuture;

  NFCAvailability? get availability => _availability;

  bool get isChecking => _checking;

  bool get isBusy => _busy;

  bool get isAvailable => _availability == NFCAvailability.available;

  bool get isUnsupported => _availability == NFCAvailability.not_supported;

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
    notifyListeners();
    try {
      _availability = await _probe();
    } catch (_) {
      _availability = NFCAvailability.not_supported;
    } finally {
      _checking = false;
      notifyListeners();
    }
  }
}
