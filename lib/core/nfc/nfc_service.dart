import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

typedef NfcAvailabilityProbe = Future<NFCAvailability> Function();

class NfcService extends ChangeNotifier {
  NfcService({NfcAvailabilityProbe? probe})
    : _probe = probe ?? (() => FlutterNfcKit.nfcAvailability);

  final NfcAvailabilityProbe _probe;
  NFCAvailability? _availability;
  bool _checking = false;
  Future<void>? _loadFuture;

  NFCAvailability? get availability => _availability;

  bool get isChecking => _checking;

  bool get isAvailable => _availability == NFCAvailability.available;

  bool get isUnsupported => _availability == NFCAvailability.not_supported;

  Future<void> ensureLoaded() => _loadFuture ??= refresh();

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
