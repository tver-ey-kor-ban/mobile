import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/quotation_api_service.dart';
import '../../data/models/quotation_model.dart';
import 'shop_quotation_detail_page.dart';
import 'create_quotation_page.dart';

class ShopQuotationsPage extends StatefulWidget {
  final int shopId;
  const ShopQuotationsPage({super.key, required this.shopId});

  @override
  State<ShopQuotationsPage> createState() => _ShopQuotationsPageState();
}

class _ShopQuotationsPageState extends State<ShopQuotationsPage>
    with SingleTickerProviderStateMixin {
  final _service = QuotationApiService();
  late TabController _tabs;
  final _statuses = ['all', 'draft', 'sent', 'approved', 'rejected', 'expired'];
  List<QuotationModel> _quotations = [];
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
    final list = await _service.getShopQuotations(
      widget.shopId,
      status: _selectedStatus == 'all' ? null : _selectedStatus,
    );
    setState(() {
      _quotations = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotations'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: _statuses
              .map((s) => Tab(text: s[0].toUpperCase() + s.substring(1)))
              .toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => CreateQuotationPage(shopId: widget.shopId)),
        ).then((_) => _load()),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Quotation'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _quotations.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                      itemCount: _quotations.length,
                      itemBuilder: (_, i) => _buildCard(_quotations[i]),
                    ),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.description_outlined, size: 64, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text('No quotations',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        Text('Tap + to create one',
            style: TextStyle(color: Colors.grey.shade500)),
      ]),
    );
  }

  Widget _buildCard(QuotationModel q) {
    final color = _statusColor(q.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  ShopQuotationDetailPage(shopId: widget.shopId, quotation: q)),
        ).then((_) => _load()),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Text(q.title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
              ),
              _statusBadge(q.status, color),
            ]),
            if (q.description != null && q.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(q.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ],
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Total: \$${q.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                      fontSize: 14)),
              Text(_formatDate(q.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _statusBadge(String status, Color color) {
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
