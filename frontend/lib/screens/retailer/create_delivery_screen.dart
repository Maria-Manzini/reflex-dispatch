import 'package:flutter/material.dart';

import '../../services/retailer_sync_service.dart';

class CreateDeliveryScreen extends StatefulWidget {
  final String retailerId;
  final RetailerSyncService syncService;

  const CreateDeliveryScreen({
    super.key,
    required this.retailerId,
    required this.syncService,
  });

  @override
  State<CreateDeliveryScreen> createState() =>
      _CreateDeliveryScreenState();
}

class _CreateDeliveryScreenState
    extends State<CreateDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _customerNameController =
      TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _itemController = TextEditingController();

  bool _submitting = false;

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _submitting = true);

    try {
      final result = await widget.syncService.submit(
        retailerId: widget.retailerId,
        customerName:
            _customerNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        item: _itemController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      final message =
          result.state == DeliverySubmitState.created
              ? 'Delivery request created.'
              : 'Saved offline. It will sync when connection returns.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to create delivery: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _itemController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Delivery'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(
                labelText: 'Customer name',
                border: OutlineInputBorder(),
              ),
              validator: _required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              validator: _required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Delivery address',
                border: OutlineInputBorder(),
              ),
              validator: _required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _itemController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Item description',
                border: OutlineInputBorder(),
              ),
              validator: _required,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed:
                  _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.add),
              label: Text(
                _submitting
                    ? 'Submitting...'
                    : 'Create Delivery',
              ),
            ),
          ],
        ),
      ),
    );
  }
}