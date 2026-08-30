import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityService {
  Future<bool> get isConnected;

  Stream<bool> get changes;
}

class DeviceConnectivityService implements ConnectivityService {
  final Connectivity _connectivity;

  DeviceConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();

    return _hasConnection(results);
  }

  @override
  Stream<bool> get changes {
    return _connectivity.onConnectivityChanged.map(_hasConnection).distinct();
  }
}
