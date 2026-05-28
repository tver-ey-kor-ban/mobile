import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/quotation_api_service.dart';

class CreateQuotationPage extends StatefulWidget {
  final int shopId;
  final int? appointmentId;

  const CreateQuotationPage({
    super.key,
    required this.shopId,
    this.appointmentId,
  });

  @override
  State<CreateQuotationPage> createState() => _CreateQuotationPageState();
}

class _CreateQuotationPageState extends State<CreateQuotationPage> {
  final _service = QuotationApiService();
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _laborCtrl = TextEditingController(text: '0');
  final _partsCtrl = TextEditingController(text: '0');
  final _taxCtrl = TextEditingController(text: '0');
  final _discountCtrl = TextEditingController(text: '0');

  final List<Map<String, dynamic>> _items = [];
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _laborCtrl.dispose();
    _partsCtrl.dispose();
    _taxCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  double get _total {
    final labor = double.tryParse(_laborCtrl.text) ?? 0;
    final parts = double.tryParse(_partsCtrl.text) ?? 0;
    final tax = double.tryParse(_taxCtrl.text) ?? 0;
    final discount = double.tryParse(_discountCtrl.text) ?? 0;
    return labor + parts + tax - discount;
  }

  void _addItem() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final priceCtrl = TextEditingController();
    String itemType = 'labor';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('Add Item'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              value: itemType,
              decoration: const InputDecoration(
                  labelText: 'Type', border: OutlineInputBorder()),
              items: ['labor', 'part']
                  .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t[0].toUpperCase() + t.substring(1))))
                  .toList(),
              onChanged: (v) => setDlg(() => itemType = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Qty', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: priceCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Unit Price', border: OutlineInputBorder()),
                ),
              ),
            ]),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
                setState(() {
                  _items.add({
                    'item_type': itemType,
                    'name': nameCtrl.text,
                    'quantity': int.tryParse(qtyCtrl.text) ?? 1,
                    'unit_price': double.tryParse(priceCtrl.text) ?? 0,
                  });
                });
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final token = context.read<AuthService>().token;
    if (token != null) _service.setAuthToken(token);

    setState(() => _submitting = true);

    final data = {
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      if (widget.appointmentId != null) 'appointment_id': widget.appointmentId,
      'items': _items,
      'labor_cost': double.tryParse(_laborCtrl.text) ?? 0,
      'parts_cost': double.tryParse(_partsCtrl.text) ?? 0,
      'tax_amount': double.tryParse(_taxCtrl.text) ?? 0,
      'discount_amount': double.tryParse(_discountCtrl.text) ?? 0,
    };

    final ok = await _service.createQuotation(widget.shopId, data);
    setState(() => _submitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Quotation created' : 'Failed to create quotation'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ));
      if (ok) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Quotation'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                  labelText: 'Title *', border: OutlineInputBorder()),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            // Items section
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Line Items',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ]),
            if (_items.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('No items added',
                    style: TextStyle(color: Colors.grey.shade500)),
              )
            else
              ...List.generate(_items.length, (i) {
                final item = _items[i];
                final total =
                    (item['unit_price'] as double) * (item['quantity'] as int);
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      item['item_type'] == 'labor'
                          ? Icons.build_outlined
                          : Icons.inventory_2_outlined,
                      size: 18,
                    ),
                    title: Text(item['name']),
                    subtitle: Text(
                        '${item['quantity']} × \$${(item['unit_price'] as double).toStringAsFixed(2)}'),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('\$${total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: Colors.red),
                        onPressed: () => setState(() => _items.removeAt(i)),
                      ),
                    ]),
                  ),
                );
              }),

            const SizedBox(height: 20),
            const Text('Cost Breakdown',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _numField(_laborCtrl, 'Labor Cost')),
              const SizedBox(width: 12),
              Expanded(child: _numField(_partsCtrl, 'Parts Cost')),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _numField(_taxCtrl, 'Tax')),
              const SizedBox(width: 12),
              Expanded(child: _numField(_discountCtrl, 'Discount')),
            ]),
            const SizedBox(height: 16),

            // Total preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: ListenableBuilder(
                listenable: Listenable.merge(
                    [_laborCtrl, _partsCtrl, _taxCtrl, _discountCtrl]),
                builder: (_, __) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Estimated Total',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('\$${_total.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.red.shade700)),
                    ]),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Create Quotation',
                      style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _numField(TextEditingController ctrl, String label) {
    return TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
          labelText: label,
          prefixText: '\$',
          border: const OutlineInputBorder()),
    );
  }
}
