import 'package:flutter/material.dart';

import '../../models/delivery.dart';
import '../../services/rider_service.dart';
import 'scan_qr_screen.dart';

class DeliveryDetailsScreen extends StatefulWidget {
  final Delivery delivery;
  final RiderService riderService;

  const DeliveryDetailsScreen({
    super.key,
    required this.delivery,
    required this.riderService,
  });

  @override
  State<DeliveryDetailsScreen> createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends State<DeliveryDetailsScreen> {
  late Delivery delivery;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    delivery = widget.delivery;
  }

  Future<void> _pickUp() async {
    setState(() => loading = true);

    try {
      final updated = await widget.riderService.updateStatus(
        deliveryId: delivery.id,
        status: 'in_transit',
      );

      if (!mounted) return;

      setState(() {
        delivery = updated;
      });

      _showMessage('Delivery picked up');
    } catch (error) {
      _showError(error.toString());
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> _scanQr() async {
    final scanCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ScanQrScreen()),
    );

    if (scanCode == null || scanCode.isEmpty) {
      return;
    }

    setState(() => loading = true);

    try {
      final updated = await widget.riderService.updateStatus(
        deliveryId: delivery.id,
        status: 'delivered',
        scanCode: scanCode,
      );

      if (!mounted) return;

      setState(() {
        delivery = updated;
      });

      _showMessage('Delivery confirmed');
    } catch (error) {
      _showError(error.toString());
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final canPickUp = delivery.status == 'assigned';
    final canDeliver = delivery.status == 'in_transit';

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            delivery.customerName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 20),

          _InfoRow(label: 'Phone', value: delivery.phone),

          _InfoRow(label: 'Address', value: delivery.address),

          _InfoRow(label: 'Item', value: delivery.item),

          _InfoRow(label: 'Status', value: delivery.displayStatus),

          const SizedBox(height: 24),

          if (loading) const Center(child: CircularProgressIndicator()),

          if (!loading && canPickUp)
            FilledButton.icon(
              onPressed: _pickUp,
              icon: const Icon(Icons.local_shipping),
              label: const Text('Pick Up Delivery'),
            ),

          if (!loading && canDeliver)
            FilledButton.icon(
              onPressed: _scanQr,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR to Confirm Delivery'),
            ),

          if (!loading && delivery.status == 'delivered')
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.check_circle),
                    SizedBox(width: 12),
                    Expanded(child: Text('Delivery completed successfully.')),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
