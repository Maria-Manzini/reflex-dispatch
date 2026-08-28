import 'package:flutter/material.dart';

import 'screens/rider/rider_home_screen.dart';
import 'services/api_rider_service.dart';

void main() {
  const baseUrl = 'http://localhost:3000';

  final riderService = ApiRiderService(baseUrl: baseUrl);

  runApp(ReflexApp(riderService: riderService));
}

class ReflexApp extends StatelessWidget {
  final ApiRiderService riderService;

  const ReflexApp({super.key, required this.riderService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reflex Rider',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: RiderHomeScreen(riderService: riderService),
    );
  }
}
