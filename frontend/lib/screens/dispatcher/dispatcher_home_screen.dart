import 'package:flutter/material.dart';

import '../../models/delivery.dart';
import '../../models/rider_option.dart';
import '../../services/delivery_socket_service.dart';
import '../../services/dispatcher_service.dart';

class DispatcherHomeScreen extends StatefulWidget {
  final DispatcherService dispatcherService;
  final List<RiderOption> riders;
  final DeliverySocketService? socketService;

  const DispatcherHomeScreen({
    super.key,
    required this.dispatcherService,
    required this.riders,
    this.socketService,
  });

  @override
  State<DispatcherHomeScreen> createState() => _DispatcherHomeScreenState();
}

class _DispatcherHomeScreenState extends State<DispatcherHomeScreen> {
  late Future<List<Delivery>> _deliveriesFuture;

  final Map<String, String?> _selectedRiderIds = {};

  final Set<String> _assigning = {};

  @override
  void initState() {
    super.initState();

    _deliveriesFuture = widget.dispatcherService.getOpenDeliveries();

    widget.socketService?.connect(
      onDeliveryChanged: () {
        if (mounted) {
          _refresh();
        }
      },
    );
  }

  Future<void> _refresh() async {
    final future = widget.dispatcherService.getOpenDeliveries();

    setState(() {
      _deliveriesFuture = future;
    });

    await future;
  }

  Future<void> _assign(Delivery delivery) async {
    final riderId = _selectedRiderIds[delivery.id];

    if (riderId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Select a rider first')));

      return;
    }

    setState(() {
      _assigning.add(delivery.id);
    });

    try {
      await widget.dispatcherService.assignDelivery(
        deliveryId: delivery.id,
        riderId: riderId,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rider assigned successfully')),
      );

      await _refresh();
    } on DispatcherApiException catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.statusCode == 409
          ? 'This delivery has already been assigned.'
          : error.toString();

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

      await _refresh();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to assign rider: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _assigning.remove(delivery.id);
        });
      }
    }
  }

  @override
  void dispose() {
    widget.socketService?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open Deliveries')),
      body: FutureBuilder<List<Delivery>>(
        future: _deliveriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: [
                  const SizedBox(height: 180),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Unable to load open deliveries.\n\n'
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
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
                  Center(child: Text('No open delivery requests')),
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
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delivery.customerName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(delivery.phone),
                        const SizedBox(height: 4),
                        Text(delivery.address),
                        const SizedBox(height: 4),
                        Text(delivery.item),
                        const SizedBox(height: 12),
                        Chip(label: Text(delivery.displayStatus)),
                        const SizedBox(height: 12),

                        if (widget.riders.isEmpty)
                          const Text('No rider options are available yet.')
                        else
                          DropdownButtonFormField<String>(
                            initialValue: _selectedRiderIds[delivery.id],
                            decoration: const InputDecoration(
                              labelText: 'Assign rider',
                              border: OutlineInputBorder(),
                            ),
                            items: widget.riders
                                .map(
                                  (rider) => DropdownMenuItem<String>(
                                    value: rider.id,
                                    child: Text(rider.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRiderIds[delivery.id] = value;
                              });
                            },
                          ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed:
                                widget.riders.isEmpty ||
                                    _assigning.contains(delivery.id)
                                ? null
                                : () => _assign(delivery),
                            child: _assigning.contains(delivery.id)
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Assign Rider'),
                          ),
                        ),
                      ],
                    ),
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
