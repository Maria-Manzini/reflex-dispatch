import 'package:flutter/material.dart';

import 'screens/rider/rider_home_screen.dart';
import 'services/api_rider_service.dart';
import 'services/rider_socket_service.dart';

void main() {
  const baseUrl = 'http://localhost:3000';

  final riderService = ApiRiderService(
    baseUrl: baseUrl,
  );

  final socketService = RiderSocketService(
    baseUrl: baseUrl,
  );

  runApp(
    ReflexApp(
      riderService: riderService,
      socketService: socketService,
    ),
  );
}

class ReflexApp extends StatelessWidget {
  final ApiRiderService riderService;
  final RiderSocketService? socketService;

  const ReflexApp({
    super.key,
    required this.riderService,
    this.socketService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reflex Rider',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: RiderHomeScreen(
        riderService: riderService,
        socketService: socketService,
      ),
    );
  }
}
