import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/mechanic_api_service.dart';
import '../../data/models/mechanic_booking_model.dart';

class PendingOrdersPage extends StatefulWidget {
  final int shopId;
  const PendingOrdersPage({super.key, required this.shopId});

  @override
  State<PendingOrdersPage> createState() => _PendingOrdersPageState();
}

class _PendingOrdersPageState extends State<PendingOrdersPage> {
  final _service = MechanicApiService();
  List<MechanicOrderModel> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthService>().token;
    if (token != null) _service.setAuthToken(token);
    setState(() => _loading = true);
    final list = await _service.getPendingOrders(widget.shopId);
    setState(() {
      _orders = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Orders (${_orders.length})'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _orders.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      itemBuilder: (_, i) => _buildCard(_orders[i]),
                    ),
            ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
        SizedBox(height: 16),
        Text('No pending orders',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildCard(MechanicOrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Order #${order.id}',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text('\$${order.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                    fontSize: 15)),
          ]),
          const SizedBox(height: 6),
          Text(order.customerName ?? 'Customer',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          if (order.items.isNotEmpty) ...[
            ...order.items.take(3).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item['name'] ?? ''} x${item['quantity'] ?? 1}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '\$${((item['unit_price'] ?? 0) * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ]),
                )),
            if (order.items.length > 3)
              Text('+${order.items.length - 3} more items',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 8),
          ],
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton(
              onPressed: () => _action(order, 'reject'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red)),
              child: const Text('Reject'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _action(order, 'accept'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text('Accept'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _markReady(order),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white),
              child: const Text('Ready'),
            ),
          ]),
        ]),
      ),
    );
  }

  Future<void> _action(MechanicOrderModel order, String action) async {
    if (action == 'reject') {
      final ctrl = TextEditingController();
      final reason = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Rejection Reason'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              hintText: 'e.g. Out of stock',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, ctrl.text),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child:
                  const Text('Reject', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (reason == null || reason.isEmpty) return;
      await _service.rejectOrder(widget.shopId, order.id, reason);
    } else {
      await _service.acceptOrder(widget.shopId, order.id);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Order ${action == 'accept' ? 'accepted' : 'rejected'}')),
      );
      _load();
    }
  }

  Future<void> _markReady(MechanicOrderModel order) async {
    await _service.markOrderReady(widget.shopId, order.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order marked as ready for pickup')),
      );
      _load();
    }
  }
}
