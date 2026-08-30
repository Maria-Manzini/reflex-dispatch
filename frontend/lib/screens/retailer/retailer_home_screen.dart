import 'package:flutter/material.dart';

import '../../cache/pending_delivery_store.dart';
import '../../models/delivery.dart';
import '../../services/delivery_socket_service.dart';
import '../../services/retailer_service.dart';
import '../../services/retailer_sync_service.dart';
import 'create_delivery_screen.dart';

class RetailerHomeScreen extends StatefulWidget {
  final String retailerId;
  final RetailerService retailerService;
  final RetailerSyncService syncService;
  final PendingDeliveryStore pendingStore;
  final DeliverySocketService? socketService;

  const RetailerHomeScreen({
    super.key,
    required this.retailerId,
    required this.retailerService,
    required this.syncService,
    required this.pendingStore,
    this.socketService,
  });

  @override
  State<RetailerHomeScreen> createState() =>
      _RetailerHomeScreenState();
}

class _RetailerHomeScreenState
    extends State<RetailerHomeScreen> {
  late Future<_RetailerData> _dataFuture;

  @override
  void initState() {
    super.initState();

    _dataFuture = _fetchData();

    widget.syncService.start(
      onSyncComplete: () {
        if (mounted) {
          _reload();
        }
      },
    );

    widget.socketService?.connect(
      onDeliveryChanged: () {
        if (mounted) {
          _reload();
        }
      },
    );

    widget.syncService.syncPending().then(
      (count) {
        if (count > 0 && mounted) {
          _reload();
        }
      },
    );
  }

  Future<_RetailerData> _fetchData() async {
    final pending = await widget.pendingStore.all();

    try {
      final deliveries =
          await widget.retailerService.getMyDeliveries(
        retailerId: widget.retailerId,
      );

      return _RetailerData(
        deliveries: deliveries,
        pending: pending,
      );
    } catch (error) {
      return _RetailerData(
        deliveries: const [],
        pending: pending,
        remoteError: error.toString(),
      );
    }
  }

  void _reload() {
    setState(() {
      _dataFuture = _fetchData();
    });
  }

  Future<void> _refresh() async {
    await widget.syncService.syncPending();

    final future = _fetchData();

    setState(() {
      _dataFuture = future;
    });

    await future;
  }

  Future<void> _openCreateDelivery() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateDeliveryScreen(
          retailerId: widget.retailerId,
          syncService: widget.syncService,
        ),
      ),
    );

    if (result == true && mounted) {
      _reload();
    }
  }

  @override
  void dispose() {
    widget.socketService?.dispose();
    widget.syncService.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retailer Deliveries'),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _openCreateDelivery,
        icon: const Icon(Icons.add),
        label: const Text('New Delivery'),
      ),
      body: FutureBuilder<_RetailerData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Unable to load deliveries',
              ),
            );
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (data.remoteError != null)
                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(16),
                      child: Text(
                        'Unable to refresh online deliveries.\n'
                        '${data.remoteError}',
                      ),
                    ),
                  ),

                if (data.pending.isNotEmpty) ...[
                  Text(
                    'Pending sync',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),
                  const SizedBox(height: 8),

                  ...data.pending.map(
                    (pending) => Card(
                      child: ListTile(
                        leading:
                            const Icon(Icons.cloud_off),
                        title: Text(
                          pending.customerName,
                        ),
                        subtitle: Text(
                          '${pending.address}\n'
                          '${pending.item}',
                        ),
                        isThreeLine: true,
                        trailing:
                            const Text('Pending'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],

                Text(
                  'My requests',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium,
                ),

                const SizedBox(height: 8),

                if (data.deliveries.isEmpty &&
                    data.pending.isEmpty)
                  const Padding(
                    padding:
                        EdgeInsets.only(top: 120),
                    child: Center(
                      child: Text(
                        'No delivery requests yet',
                      ),
                    ),
                  ),

                ...data.deliveries.map(
                  (delivery) =>
                      _DeliveryCard(
                    delivery: delivery,
                  ),
                ),

                const SizedBox(height: 90),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RetailerData {
  final List<Delivery> deliveries;
  final List<PendingDelivery> pending;
  final String? remoteError;

  const _RetailerData({
    required this.deliveries,
    required this.pending,
    this.remoteError,
  });
}

class _DeliveryCard extends StatelessWidget {
  final Delivery delivery;

  const _DeliveryCard({
    required this.delivery,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              delivery.customerName,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(height: 8),
            Text(delivery.phone),
            const SizedBox(height: 4),
            Text(delivery.address),
            const SizedBox(height: 4),
            Text(delivery.item),
            const SizedBox(height: 12),
            Chip(
              label:
                  Text(delivery.displayStatus),
            ),
          ],
        ),
      ),
    );
  }
}