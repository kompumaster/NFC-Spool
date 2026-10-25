import 'package:flutter/foundation.dart';

import '../data/snapmaker/snapmaker_models.dart';
import 'snapmaker_service.dart';

enum SnapmakerStatus { unknown, checking, available, unavailable }

class SnapmakerStatusService extends ChangeNotifier {
  SnapmakerStatus _status = SnapmakerStatus.unknown;
  String? _error;
  List<SnapmakerToolHead> _toolHeads = const [];

  SnapmakerStatus get status => _status;

  String? get error => _error;

  List<SnapmakerToolHead> get toolHeads => _toolHeads;

  bool get isAvailable => _status == SnapmakerStatus.available;

  bool get isBlocked => _status != SnapmakerStatus.available;

  Future<bool> check({required String host, required int port}) async {
    if (_status == SnapmakerStatus.checking) {
      return false;
    }
    _status = SnapmakerStatus.checking;
    _error = null;
    notifyListeners();

    final service = SnapmakerService(host: host, port: port);
    try {
      _toolHeads = await service.getToolHeads();
      _status = SnapmakerStatus.available;
      notifyListeners();
      return true;
    } catch (error) {
      _toolHeads = const [];
      _error = snapmakerFriendlyError(error);
      _status = SnapmakerStatus.unavailable;
      notifyListeners();
      return false;
    } finally {
      service.close();
    }
  }

  void markUnavailable(String message) {
    _toolHeads = const [];
    _error = message;
    _status = SnapmakerStatus.unavailable;
    notifyListeners();
  }
}
