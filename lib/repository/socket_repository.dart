import 'package:docsgoogle/clients/socket_client.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketRepository {
  final _socketClient = SocketClient.instance.socket;

  Socket get socekClient => _socketClient!;

  void joinRoom(String documentId) {
    _socketClient!.emit("join", documentId);
  }

  void typing(Map<String, dynamic> data) async {
    _socketClient!.emit("typing", data);
  }

  void changeListener(Function(Map<String, dynamic>) func) async {
    _socketClient!.on("changes", (data) => func(data));
  }

  void autoSave(Map<String, dynamic> data) {
    _socketClient!.emit("save", data);
  }
}
