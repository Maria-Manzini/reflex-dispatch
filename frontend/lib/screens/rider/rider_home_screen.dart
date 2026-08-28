import 'package:flutter/material.dart';

import '../../models/delivery.dart';
import '../../services/rider_service.dart';
import 'delivery_details_screen.dart';

class RiderHomeScreen extends StatefulWidget {
  final RiderService riderService;

  const RiderHomeScreen({super.key, required this.riderService});

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  late Future<List<Delivery>> _deliveriesFuture;

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  void _loadDeliveries() {
    _deliveriesFuture = widget.riderService.getMyDeliveries();
  }

  Future<void> _refresh() async {
    setState(_loadDeliveries);
    await _deliveriesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Deliveries')),
      body: FutureBuilder<List<Delivery>>(
        future: _deliveriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load deliveries.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final deliveries = snapshot.data ?? [];

          if (deliveries.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('No assigned deliveries')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: deliveries.length,
              itemBuilder: (context, index) {
                final delivery = deliveries[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(delivery.customerName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(delivery.address),
                        const SizedBox(height: 4),
                        Text(delivery.item),
                        const SizedBox(height: 6),
                        Text(
                          delivery.status,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeliveryDetailsScreen(
                            delivery: delivery,
                            riderService: widget.riderService,
                          ),
                        ),
                      );

                      if (mounted) {
                        _refresh();
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
