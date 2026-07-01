import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NetworkStatus { online, offline }

class NetworkService {
  final Connectivity _connectivity = Connectivity();

  Stream<NetworkStatus> get onStatusChange => _connectivity.onConnectivityChanged.map((results) {
    if (results.contains(ConnectivityResult.none)) {
      return NetworkStatus.offline;
    }
    return NetworkStatus.online;
  });

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}

final networkServiceProvider = Provider((ref) => NetworkService());

final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  return ref.watch(networkServiceProvider).onStatusChange;
});
