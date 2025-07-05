import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static IO.Socket? socket;
  static Function(Map<String, dynamic>)? heartRateCallback;
  
  static void initSocket() {
    // For web applications, use the server URL
    final serverUrl = 'http://localhost:3000';
    
    print("Initializing socket connection to: $serverUrl");
    
    // Disconnect the existing socket if it exists
    if (socket != null) {
      print("Disconnecting existing socket");
      socket!.disconnect();
    }
    
    socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket', 'polling'],
      'autoConnect': true,
      'forceNew': true,
    });
    
    socket!.onConnect((_) {
      print('Connected to socket server: ${socket!.id}');
    });
    
    socket!.onConnectError((error) {
      print('Socket connection error: $error');
    });
    
    socket!.onDisconnect((_) {
      print('Disconnected from socket server');
    });
    
    socket!.on('heartRateUpdate', (data) {
      print('Received heart rate update in socket service: $data');
      if (heartRateCallback != null) {
        heartRateCallback!(data);
      } else {
        print('Heart rate callback is null!');
      }
    });
  }
  
  static void setHeartRateCallback(Function(Map<String, dynamic>) callback) {
    print('Setting heart rate callback');
    heartRateCallback = callback;
  }
  
  static void disconnect() {
    socket?.disconnect();
  }
  
  static bool get isConnected => socket?.connected ?? false;
}