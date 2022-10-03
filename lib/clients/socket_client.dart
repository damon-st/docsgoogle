import 'package:docsgoogle/constants/colors.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketClient {
  io.Socket? socket;
  static SocketClient? _instance;

  SocketClient._internal() {
    socket = io.io(urlHOST, <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket!.connect();
  }

  static SocketClient get instance {
    return _instance ??= SocketClient._internal();
  }
}
