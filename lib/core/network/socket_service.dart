import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer';

class SocketService {
  late IO.Socket socket;
  
  String get _url {
    final host = (!kIsWeb && Platform.isAndroid) ? '10.0.2.2' : 'localhost';
    return 'http://$host:3000/chat';
  }

  Future<void> connect() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');

    socket = IO.io(_url, IO.OptionBuilder()
      .setTransports(['websocket'])
      .setExtraHeaders({'Authorization': 'Bearer $token'})
      .build());

    socket.onConnect((_) {
      log('📡 Connected to WebSocket');
    });

    socket.onDisconnect((_) => log('📡 Disconnected from WebSocket'));
    
    socket.onConnectError((err) => log('📡 Connection Error: $err'));
  }

  void joinOrder(String orderId) {
    socket.emit('joinOrder', orderId);
  }

  void sendMessage(String orderId, String text, String senderId) {
    socket.emit('sendMessage', {
      'orderId': orderId,
      'text': text,
      'senderId': senderId,
    });
  }

  void off(String event) {
    socket.off(event);
  }

  void on(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }

  void disconnect() {
    socket.disconnect();
  }
}

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});
