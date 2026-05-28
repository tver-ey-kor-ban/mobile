import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/quotation_api_service.dart';
import '../../data/models/quotation_model.dart';

class ShopQuotationDetailPage extends StatefulWidget {
  final int shopId;
  final QuotationModel quotation;

  const ShopQuotationDetailPage({
    super.key,
    required this.shopId,
    required this.quotation,
  });

  @override
  State<ShopQuotationDetailPage> createState() =>
      _ShopQuotationDetailPageState();
}

class _ShopQuotationDetailPageState extends State<ShopQuotationDetailPage> {
  final _service = QuotationApiService();
  bool _sending = false;

  Future<void> _sendQuotation() async {
    // Read token before any async gap
    final token = context.read<AuthService>().token;
    if (token != null) _service.setAuthToken(token);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Send Quotation'),
        content: const Text('Send this quotation to the customer?'),
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

    setState(() => _sending = true);
    final ok = await _service.sendQuotation(widget.shopId, widget.quotation.id);
    setState(() => _sending = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Quotation sent to customer' : 'Failed to send'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ));
      if (ok) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.quotation;
    final canSend = q.status == 'draft';

    return Scaffold(
      appBar: AppBar(
        title: Text('Quotation #${q.id}'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header card
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
                          Expanded(
                            child: Text(q.title,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          _statusBadge(q.status),
                        ]),
                    if (q.description != null && q.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(q.description!,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600)),
                    ],
                    const SizedBox(height: 8),
                    Text('Created: ${_formatDate(q.createdAt)}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ]),
            ),
          ),
          const SizedBox(height: 12),

          // Items
          if (q.items.isNotEmpty) ...[
            const Text('Items',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: q.items.map((item) {
                  return ListTile(
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
                    title:
                        Text(item.name, style: const TextStyle(fontSize: 13)),
                    subtitle: Text(
                        '${item.quantity} × \$${item.unitPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 12)),
                    trailing: Text('\$${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Pricing summary
          const Text('Pricing',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _pricingRow('Labor', q.laborCost),
                _pricingRow('Parts', q.partsCost),
                if (q.taxAmount > 0) _pricingRow('Tax', q.taxAmount),
                if (q.discountAmount > 0)
                  _pricingRow('Discount', -q.discountAmount,
                      color: Colors.green),
                const Divider(),
                _pricingRow('Total', q.totalAmount,
                    bold: true, color: Colors.red.shade700),
              ]),
            ),
          ),

          if (q.rejectionReason != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Colors.red.shade50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Rejection reason: ${q.rejectionReason}',
                          style: TextStyle(
                              color: Colors.red.shade800, fontSize: 13),
                        ),
                      ),
                    ]),
              ),
            ),
          ],

          const SizedBox(height: 80),
        ]),
      ),
      bottomNavigationBar: canSend
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _sending ? null : _sendQuotation,
                icon: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_outlined),
                label: const Text('Send to Customer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          : null,
    );
  }

  Widget _pricingRow(String label, double amount,
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

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style:
            TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'approved':
        return Colors.green;
      case 'sent':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'expired':
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
