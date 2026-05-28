import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/invoice_api_service.dart';
import '../../data/models/invoice_model.dart';
import 'shop_invoice_detail_page.dart';

class ShopInvoicesPage extends StatefulWidget {
  final int shopId;
  const ShopInvoicesPage({super.key, required this.shopId});

  @override
  State<ShopInvoicesPage> createState() => _ShopInvoicesPageState();
}

class _ShopInvoicesPageState extends State<ShopInvoicesPage>
    with SingleTickerProviderStateMixin {
  final _service = InvoiceApiService();
  late TabController _tabs;
  final _statuses = [
    'all',
    'draft',
    'sent',
    'paid',
    'partially_paid',
    'overdue',
    'cancelled'
  ];
  List<InvoiceModel> _invoices = [];
  bool _loading = true;
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _statuses.length, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) {
        setState(() => _selectedStatus = _statuses[_tabs.index]);
        _load();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = context.read<AuthService>().token;
    if (token != null) _service.setAuthToken(token);
    setState(() => _loading = true);
    final list = await _service.getShopInvoices(
      widget.shopId,
      status: _selectedStatus == 'all' ? null : _selectedStatus,
    );
    setState(() {
      _invoices = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: _statuses.map((s) {
            final label = s == 'all'
                ? 'All'
                : s
                    .replaceAll('_', ' ')
                    .split(' ')
                    .map((w) => w[0].toUpperCase() + w.substring(1))
                    .join(' ');
            return Tab(text: label);
          }).toList(),
        ),
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
    final statusLabel = inv.status
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  ShopInvoiceDetailPage(shopId: widget.shopId, invoice: inv)),
        ).then((_) => _load()),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Invoice #${inv.id}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
              _badge(statusLabel, color),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Total: \$${inv.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                      fontSize: 14)),
              if (inv.dueDate != null)
                Text('Due: ${_formatDate(inv.dueDate!)}',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ]),
            if (inv.payments.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Paid: \$${inv.payments.fold(0.0, (s, p) => s + p.amount).toStringAsFixed(2)}',
                style: TextStyle(fontSize: 12, color: Colors.green.shade700),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
