import 'package:socket_io_client/socket_io_client.dart'
    as io;

class RiderSocketService {
  final String baseUrl;

  io.Socket? _socket;

  RiderSocketService({
    required this.baseUrl,
  });

  void connect({
    required void Function() onDeliveryChanged,
  }) {
    if (_socket != null) {
      return;
    }

    final socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.on('delivery:assigned', (_) {
      onDeliveryChanged();
    });

    socket.on('delivery:updated', (_) {
      onDeliveryChanged();
    });

    socket.connect();

    _socket = socket;
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}