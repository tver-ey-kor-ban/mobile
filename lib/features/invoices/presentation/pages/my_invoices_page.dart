import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/invoice_api_service.dart';
import '../../data/models/invoice_model.dart';

class MyInvoicesPage extends StatefulWidget {
  const MyInvoicesPage({super.key});

  @override
  State<MyInvoicesPage> createState() => _MyInvoicesPageState();
}

class _MyInvoicesPageState extends State<MyInvoicesPage> {
  final _service = InvoiceApiService();
  List<InvoiceModel> _invoices = [];
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
    final list = await _service.getMyInvoices();
    setState(() {
      _invoices = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Invoices'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _invoices.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _invoices.length,
                      itemBuilder: (_, i) => _buildCard(_invoices[i]),
                    ),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.receipt_outlined, size: 64, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text('No invoices',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600)),
      ]),
    );
  }

  Widget _buildCard(InvoiceModel inv) {
    final color = _statusColor(inv.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Invoice #${inv.id}',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
            _chip(inv.status, color),
          ]),
          if (inv.shopName != null) ...[
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.store_outlined,
                  size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(inv.shopName!,
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade600)),
            ]),
          ],
          const SizedBox(height: 10),
          if (inv.items.isNotEmpty) ...[
            ...inv.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.name} x${item.quantity}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Text('\$${item.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 12)),
                      ]),
                )),
            const Divider(),
          ],
          _summaryRow('Labor', inv.laborCost),
          _summaryRow('Parts', inv.partsCost),
          if (inv.taxAmount > 0) _summaryRow('Tax', inv.taxAmount),
          if (inv.discountAmount > 0)
            _summaryRow('Discount', -inv.discountAmount),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text('\$${inv.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                    fontSize: 16)),
          ]),
          if (inv.dueDate != null) ...[
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.calendar_today_outlined,
                  size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text('Due: ${_formatDate(inv.dueDate!)}',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade600)),
            ]),
          ],
          if (inv.payments.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Payments (${inv.payments.length})',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            ...inv.payments.map((p) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(p.method.toUpperCase(),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                        Text('\$${p.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500)),
                      ]),
                )),
          ],
        ]),
      ),
    );
  }

  Widget _summaryRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        Text('\$${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
                fontSize: 12,
                color: amount < 0 ? Colors.green : Colors.grey.shade700)),
      ]),
    );
  }

  Widget _chip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status.toUpperCase(),
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.bold)),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'paid':
        return Colors.green;
      case 'partially_paid':
        return Colors.blue;
      case 'overdue':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(String d) {
    try {
      final dt = DateTime.parse(d);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return d;
    }
  }
}
