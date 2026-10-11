import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/app_config.dart';

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(() => service.disconnect());
  return service;
});

final notificationStreamProvider = StreamProvider.autoDispose<Map<String, dynamic>>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  wsService.connect();
  return wsService.notificationStream;
});

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _controller;
  bool _isConnecting = false;
  Timer? _reconnectTimer;

  Stream<Map<String, dynamic>> get notificationStream {
    _controller ??= StreamController<Map<String, dynamic>>.broadcast();
    return _controller!.stream;
  }

  void connect({String channel = 'all'}) {
    if (_isConnecting || (_channel != null && _controller != null && !_controller!.isClosed)) {
      return;
    }
    _isConnecting = true;

    try {
      final baseUrl = AppConfig.apiBaseUrl.replaceFirst('http', 'ws');
      final wsUri = Uri.parse('$baseUrl/ws/notifications?channel=$channel');

      _channel = WebSocketChannel.connect(wsUri);
      _isConnecting = false;

      _channel!.stream.listen(
        (data) {
          try {
            final decoded = jsonDecode(data.toString()) as Map<String, dynamic>;
            _controller?.add(decoded);
          } catch (e) {
            debugPrint('Failed to decode WebSocket payload: $e');
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _scheduleReconnect(channel);
        },
        onDone: () {
          debugPrint('WebSocket connection closed.');
          _scheduleReconnect(channel);
        },
      );
    } catch (e) {
      _isConnecting = false;
      debugPrint('WebSocket connection exception: $e');
      _scheduleReconnect(channel);
    }
  }

  void _scheduleReconnect(String channel) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      connect(channel: channel);
    });
  }

  void sendPing() {
    try {
      _channel?.sink.add('ping');
    } catch (e) {
      debugPrint('Error sending ping to WebSocket: $e');
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _controller?.close();
    _controller = null;
  }
}
