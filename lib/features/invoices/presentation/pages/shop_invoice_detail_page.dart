import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/invoice_api_service.dart';
import '../../data/models/invoice_model.dart';

class ShopInvoiceDetailPage extends StatefulWidget {
  final int shopId;
  final InvoiceModel invoice;

  const ShopInvoiceDetailPage({
    super.key,
    required this.shopId,
    required this.invoice,
  });

  @override
  State<ShopInvoiceDetailPage> createState() => _ShopInvoiceDetailPageState();
}

class _ShopInvoiceDetailPageState extends State<ShopInvoiceDetailPage> {
  final _service = InvoiceApiService();
  late InvoiceModel _invoice;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _invoice = widget.invoice;
  }

  Future<void> _send() async {
    final token = context.read<AuthService>().token;
    if (token != null) _service.setAuthToken(token);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Send Invoice'),
        content: const Text('Send this invoice to the customer?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Send', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _acting = true);
    final ok = await _service.sendInvoice(widget.shopId, _invoice.id);
    setState(() => _acting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Invoice sent' : 'Failed to send invoice'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ));
      if (ok) Navigator.pop(context, true);
    }
  }

  Future<void> _recordPayment() async {
    final token = context.read<AuthService>().token;
    if (token != null) _service.setAuthToken(token);

    final amountCtrl =
        TextEditingController(text: _invoice.totalAmount.toStringAsFixed(2));
    final refCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String method = 'cash';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('Record Payment'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                controller: amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: method,
                decoration: const InputDecoration(
                    labelText: 'Method', border: OutlineInputBorder()),
                items: ['cash', 'card', 'transfer', 'mobile_payment', 'other']
                    .map((m) {
                  final label = m.replaceAll('_', ' ');
                  return DropdownMenuItem(
                      value: m,
                      child: Text(label[0].toUpperCase() + label.substring(1)));
                }).toList(),
                onChanged: (v) => setDlg(() => method = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: refCtrl,
                decoration: const InputDecoration(
                    labelText: 'Reference (optional)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder()),
              ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child:
                  const Text('Record', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;
    setState(() => _acting = true);

    final data = {
      'amount': double.tryParse(amountCtrl.text) ?? 0,
      'method': method,
      if (refCtrl.text.isNotEmpty) 'reference': refCtrl.text,
      if (notesCtrl.text.isNotEmpty) 'notes': notesCtrl.text,
    };

    final ok = await _service.recordPayment(widget.shopId, _invoice.id, data);
    setState(() => _acting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Payment recorded' : 'Failed to record payment'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ));
      if (ok) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inv = _invoice;
    final statusLabel = inv.status
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
    final canSend = inv.status == 'draft';
    final canPay = inv.status == 'sent' ||
        inv.status == 'partially_paid' ||
        inv.status == 'overdue';

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice #${inv.id}'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Invoice #${inv.id}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          _badge(statusLabel, _statusColor(inv.status)),
                        ]),
                    if (inv.dueDate != null) ...[
                      const SizedBox(height: 8),
                      Text('Due: ${_formatDate(inv.dueDate!)}',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600)),
                    ],
                    const SizedBox(height: 4),
                    Text('Created: ${_formatDate(inv.createdAt)}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ]),
            ),
          ),
          const SizedBox(height: 12),

          // Items
          if (inv.items.isNotEmpty) ...[
            const Text('Items',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: inv.items
                    .map((item) => ListTile(
                          dense: true,
                          leading: Icon(
                            item.itemType == 'labor'
                                ? Icons.build_outlined
                                : Icons.inventory_2_outlined,
                            size: 18,
                            color: item.itemType == 'labor'
                                ? Colors.blue
                                : Colors.orange,
                          ),
                          title: Text(item.name,
                              style: const TextStyle(fontSize: 13)),
                          subtitle: Text(
                              '${item.quantity} × \$${item.unitPrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 12)),
                          trailing: Text(
                              '\$${item.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Pricing
          const Text('Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _priceRow('Labor', inv.laborCost),
                _priceRow('Parts', inv.partsCost),
                if (inv.taxAmount > 0) _priceRow('Tax', inv.taxAmount),
                if (inv.discountAmount > 0)
                  _priceRow('Discount', -inv.discountAmount,
                      color: Colors.green),
                const Divider(),
                _priceRow('Total', inv.totalAmount,
                    bold: true, color: Colors.red.shade700),
                if (inv.payments.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _priceRow(
                    'Paid',
                    inv.payments.fold(0.0, (s, p) => s + p.amount),
                    color: Colors.green,
                  ),
                ],
              ]),
            ),
          ),

          // Payments
          if (inv.payments.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('Payment History',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...inv.payments.map((p) => Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.payments_outlined, size: 18),
                    title: Text(
                        '\$${p.amount.toStringAsFixed(2)} via ${p.method}',
                        style: const TextStyle(fontSize: 13)),
                    subtitle: p.reference != null
                        ? Text('Ref: ${p.reference}',
                            style: const TextStyle(fontSize: 12))
                        : null,
                    trailing: Text(_formatDate(p.createdAt),
                        style: const TextStyle(fontSize: 11)),
                  ),
                )),
          ],

          const SizedBox(height: 80),
        ]),
      ),
      bottomNavigationBar: (canSend || canPay)
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(children: [
                if (canSend)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _acting ? null : _send,
                      icon: _acting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send_outlined),
                      label: const Text('Send'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                if (canSend && canPay) const SizedBox(width: 12),
                if (canPay)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _acting ? null : _recordPayment,
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text('Record Payment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
              ]),
            )
          : null,
    );
  }

  Widget _priceRow(String label, double amount,
      {bool bold = false, Color? color}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: color,
      fontSize: bold ? 15 : 13,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: style),
        Text('\$${amount.abs().toStringAsFixed(2)}', style: style),
      ]),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'paid':
        return Colors.green;
      case 'sent':
        return Colors.blue;
      case 'partially_paid':
        return Colors.teal;
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
