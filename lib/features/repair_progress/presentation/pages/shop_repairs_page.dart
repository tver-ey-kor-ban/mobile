import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/repair_progress_api_service.dart';
import '../../data/models/repair_progress_model.dart';
import 'shop_repair_detail_page.dart';
import 'create_repair_page.dart';

class ShopRepairsPage extends StatefulWidget {
  final int shopId;
  const ShopRepairsPage({super.key, required this.shopId});

  @override
  State<ShopRepairsPage> createState() => _ShopRepairsPageState();
}

class _ShopRepairsPageState extends State<ShopRepairsPage>
    with SingleTickerProviderStateMixin {
  final _service = RepairProgressApiService();
  late TabController _tabs;
  final _stages = ['all', ...RepairProgressModel.stages];
  List<RepairProgressModel> _repairs = [];
  bool _loading = true;
  String _selectedStage = 'all';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _stages.length, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) {
        setState(() => _selectedStage = _stages[_tabs.index]);
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
    final list = await _service.getShopRepairs(
      widget.shopId,
      stage: _selectedStage == 'all' ? null : _selectedStage,
    );
    setState(() {
      _repairs = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repair Progress'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: _stages.map((s) {
            final label = s == 'all'
                ? 'All'
                : s.replaceAll('_', ' ').split(' ').map((w) {
                    return w[0].toUpperCase() + w.substring(1);
                  }).join(' ');
            return Tab(text: label);
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => CreateRepairPage(shopId: widget.shopId)),
        ).then((_) => _load()),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Repair'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _repairs.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                      itemCount: _repairs.length,
                      itemBuilder: (_, i) => _buildCard(_repairs[i]),
                    ),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.build_outlined, size: 64, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text('No repairs',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600)),
      ]),
    );
  }

  Widget _buildCard(RepairProgressModel r) {
    final color = _stageColor(r.stage);
    final stageLabel = r.stage.replaceAll('_', ' ').split(' ').map((w) {
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  ShopRepairDetailPage(shopId: widget.shopId, repair: r)),
        ).then((_) => _load()),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Repair #${r.id}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
              _stageBadge(stageLabel, color),
            ]),
            const SizedBox(height: 6),
            if (r.vehicleInfo != null && r.vehicleInfo!.isNotEmpty)
              _row(Icons.directions_car_outlined, r.vehicleInfo!),
            _row(Icons.notes_outlined, r.description),
            // Progress bar
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: r.progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(r.progress * 100).toInt()}% complete',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        ),
      ]),
    );
  }

  Widget _stageBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Color _stageColor(String s) {
    switch (s) {
      case 'completed':
        return Colors.green;
      case 'ready_for_pickup':
        return Colors.teal;
      case 'quality_check':
        return Colors.indigo;
      case 'in_progress':
        return Colors.blue;
      case 'waiting_parts':
        return Colors.orange;
      case 'diagnosing':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
