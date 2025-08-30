// socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:logger/logger.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? socket;
  final Logger _logger = Logger();

  void initializeSocket() {
    if (socket != null) return; // Prevent multiple initializations
    socket = io.io(
      'https://wassup-backend-5isl.onrender.com',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .build(),
    );

    socket?.onConnect((_) {
      _logger.i('Socket connected');
    });

    socket?.onDisconnect((_) {
      _logger.e('Socket disconnected');
    });

    socket?.onError((error) {
      _logger.e('Socket error: $error');
    });
  }

  void joinRoom(String roomId) {
    socket?.emit('join_room', roomId);
  }

  void sendMessage(String roomId, Map<String, dynamic> message) {
    socket?.emit('message', {
      'room': roomId,
      'message': message,
    });
  }

  void getMessages(String roomId) {
    socket?.emit('get_messages', {'roomId': roomId});
  }

  void getUserDetails() {
    socket?.emit('get_user_details', {});
  }

  void dispose() {
    socket?.dispose();
    socket = null;
  }
}