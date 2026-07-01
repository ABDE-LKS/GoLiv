import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final customRequestNotifierProvider = StateNotifierProvider<CustomRequestNotifier, CustomRequestState>((ref) {
  return CustomRequestNotifier(ref.watch(apiClientProvider));
});

class CustomRequestState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  CustomRequestState({this.isLoading = false, this.error, this.isSuccess = false});

  CustomRequestState copyWith({bool? isLoading, String? error, bool? isSuccess, bool clearError = false}) {
    return CustomRequestState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class CustomRequestNotifier extends StateNotifier<CustomRequestState> {
  final ApiClient _apiClient;

  CustomRequestNotifier(this._apiClient) : super(CustomRequestState());

  Future<void> submitCustomRequest(String notes, String deliveryLocation) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _apiClient.dio.post('/orders/custom-request', data: {
        'notes': notes,
        'deliveryLocation': deliveryLocation,
      });
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = CustomRequestState();
  }
}
