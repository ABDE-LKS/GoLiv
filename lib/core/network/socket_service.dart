import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer';
import 'package:wassali/core/network/network_config.dart';

class SocketService {
  IO.Socket? socket;
  
  String get _url {
    // Standardize URL using NetworkConfig if available
    return '${NetworkConfig.baseUrl.replaceAll('/api', '')}/chat';
  }

  final List<Map<String, dynamic>> _bufferedListeners = [];
  final List<Map<String, dynamic>> _bufferedEmits = [];

  Future<void> connect() async {
    if (socket?.connected == true) return;

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');

    socket = IO.io(_url, IO.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({'token': token})
      .setExtraHeaders({'Authorization': 'Bearer $token'})
      .disableAutoConnect() // Prevent race condition with onConnect listener
      .enableReconnection()
      .setReconnectionAttempts(10)
      .setReconnectionDelay(2000)
      .build());

    // Attach all buffered listeners
    for (var l in _bufferedListeners) {
      socket?.on(l['event'], l['callback']);
    }
    _bufferedListeners.clear();

    socket?.onConnect((_) {
      log('📡 Connected to WebSocket');
      // Execute all buffered emits
      for (var e in _bufferedEmits) {
        socket?.emit(e['event'], e['data']);
      }
      _bufferedEmits.clear();
    });

    socket?.onDisconnect((_) => log('📡 Disconnected from WebSocket'));
    socket?.onConnectError((err) => log('📡 Connection Error: $err'));
    socket?.onReconnect((_) => log('📡 Reconnected to WebSocket'));

    // Now connect safely
    socket?.connect();
  }

  void _safeEmit(String event, dynamic data) {
    if (socket == null || !socket!.connected) {
      _bufferedEmits.add({'event': event, 'data': data});
    } else {
      socket?.emit(event, data);
    }
  }

  void joinConversation(String conversationId) {
    _safeEmit('joinConversation', conversationId);
  }

  void sendMessage(String conversationId, String text, {String? image}) {
    _safeEmit('sendMessage', {
      'conversationId': conversationId,
      'text': text,
      'image': image,
    });
  }

  void emitTyping(String conversationId, bool isTyping) {
    _safeEmit('typing', {
      'conversationId': conversationId,
      'isTyping': isTyping,
    });
  }

  void emitMarkAsRead(String conversationId) {
    _safeEmit('markAsRead', {
      'conversationId': conversationId,
    });
  }

  void off(String event) {
    _bufferedListeners.removeWhere((l) => l['event'] == event);
    socket?.off(event);
  }

  void on(String event, Function(dynamic) callback) {
    if (socket == null) {
      _bufferedListeners.add({'event': event, 'callback': callback});
    } else {
      socket?.on(event, callback);
    }
  }

  void disconnect() {
    socket?.disconnect();
    socket = null;
    _bufferedListeners.clear();
    _bufferedEmits.clear();
  }
}

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});
