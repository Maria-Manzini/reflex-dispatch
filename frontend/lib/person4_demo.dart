import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'cache/pending_delivery_store.dart';
import 'models/rider_option.dart';
import 'network/connectivity_service.dart';
import 'screens/dispatcher/dispatcher_home_screen.dart';
import 'screens/retailer/retailer_home_screen.dart';
import 'services/api_dispatcher_service.dart';
import 'services/api_retailer_service.dart';
import 'services/delivery_socket_service.dart';
import 'services/retailer_sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  const role = String.fromEnvironment('ROLE', defaultValue: 'retailer');

  const retailerId = String.fromEnvironment('RETAILER_ID');

  const riderId = String.fromEnvironment('RIDER_ID');

  const riderName = String.fromEnvironment(
    'RIDER_NAME',
    defaultValue: 'Demo Rider',
  );

  final socketService = DeliverySocketService(baseUrl: baseUrl);

  late Widget home;

  if (role == 'dispatcher') {
    final dispatcherService = ApiDispatcherService(baseUrl: baseUrl);

    final riders = riderId.isEmpty
        ? <RiderOption>[]
        : [RiderOption(id: riderId, name: riderName)];

    home = DispatcherHomeScreen(
      dispatcherService: dispatcherService,
      riders: riders,
      socketService: socketService,
    );
  } else {
    if (retailerId.isEmpty) {
      home = const _ConfigurationScreen(
        message: 'RETAILER_ID is required for the retailer demo.',
      );
    } else {
      final retailerService = ApiRetailerService(baseUrl: baseUrl);

      final pendingStore = await HivePendingDeliveryStore.open();

      final syncService = RetailerSyncService(
        retailerService: retailerService,
        pendingStore: pendingStore,
        connectivityService: DeviceConnectivityService(),
      );

      home = RetailerHomeScreen(
        retailerId: retailerId,
        retailerService: retailerService,
        syncService: syncService,
        pendingStore: pendingStore,
        socketService: socketService,
      );
    }
  }

  runApp(
    MaterialApp(
      title: 'Reflex Person 4 Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: home,
    ),
  );
}

class _ConfigurationScreen extends StatelessWidget {
  final String message;

  const _ConfigurationScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
