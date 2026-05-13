import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/mechanic_api_service.dart';
import '../../data/models/mechanic_booking_model.dart';
import 'pending_bookings_page.dart';
import 'today_bookings_page.dart';
import 'pending_orders_page.dart';
import 'mechanic_performance_page.dart';

class MechanicDashboardPage extends StatefulWidget {
  const MechanicDashboardPage({super.key});

  @override
  State<MechanicDashboardPage> createState() =>
      _MechanicDashboardPageState();
}

class _MechanicDashboardPageState extends State<MechanicDashboardPage> {
  final _service = MechanicApiService();
  List<MyShopModel> _shops = [];
  int? _selectedShopId;
  String? _selectedShopName;
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = context.read<AuthService>();
    if (auth.token != null) _service.setAuthToken(auth.token!);
    setState(() => _loading = true);

    final shops = await _service.getMyShops();
    int? shopId = auth.shopId;
    String? shopName;

    if (shops.isNotEmpty) {
      if (shopId == null ||
          !shops.any((s) => s.shopId == shopId)) {
        shopId = shops.first.shopId;
        shopName = shops.first.shopName;
        auth.setShopId(shopId);
      } else {
        shopName = shops.firstWhere((s) => s.shopId == shopId).shopName;
      }
    }

    Map<String, dynamic>? stats;
    if (shopId != null) {
      stats = await _service.getAllMechanicsPerformance(shopId);
    }

    setState(() {
      _shops = shops;
      _selectedShopId = shopId;
      _selectedShopName = shopName;
      _stats = stats;
      _loading = false;
    });
  }

  void _switchShop(MyShopModel shop) {
    context.read<AuthService>().setShopId(shop.shopId);
    setState(() {
      _selectedShopId = shop.shopId;
      _selectedShopName = shop.shopName;
    });
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (_selectedShopId == null) return;
    final stats =
        await _service.getAllMechanicsPerformance(_selectedShopId!);
    setState(() => _stats = stats);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final isOwner = auth.isShopOwner;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isOwner ? 'Shop Dashboard' : 'Mechanic Dashboard'),
            if (_selectedShopName != null)
              Text(_selectedShopName!,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (_shops.length > 1)
            PopupMenuButton<MyShopModel>(
              icon: const Icon(Icons.store_outlined),
              onSelected: _switchShop,
              itemBuilder: (_) => _shops
                  .map((s) => PopupMenuItem(
                        value: s,
                        child: Row(children: [
                          Icon(
                            s.shopId == _selectedShopId
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            size: 18,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(s.shopName),
                        ]),
                      ))
                  .toList(),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _selectedShopId == null
              ? _buildNoShop()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_stats != null) _buildStatsCards(),
                        const SizedBox(height: 20),
                        const Text('Quick Actions',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _buildActionGrid(context),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildNoShop() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.store_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No shop assigned',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text(
            'You are not assigned to any shop yet.\nAsk your shop owner to add you.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ]),
      ),
    );
  }

  Widget _buildStatsCards() {
    final summary = _stats?['shop_summary'] ?? {};
    final totalJobs = summary['total_jobs'] ?? 0;
    final revenue = (summary['total_revenue'] ?? 0.0).toDouble();
    final mechanics = summary['mechanic_count'] ?? 0;

    return Row(children: [
      _statCard('Total Jobs', '$totalJobs', Icons.build_outlined, Colors.blue),
      const SizedBox(width: 8),
      _statCard('Revenue',
          '\$${revenue.toStringAsFixed(0)}', Icons.attach_money, Colors.green),
      const SizedBox(width: 8),
      _statCard('Mechanics', '$mechanics', Icons.people_outlined, Colors.purple),
    ]);
  }

  Widget _statCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color)),
          Text(label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final shopId = _selectedShopId!;
    final items = [
      _ActionItem(
        icon: Icons.pending_actions_outlined,
        label: 'Pending\nBookings',
        color: Colors.orange,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PendingBookingsPage(shopId: shopId)),
        ),
      ),
      _ActionItem(
        icon: Icons.today_outlined,
        label: "Today's\nBookings",
        color: Colors.blue,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => TodayBookingsPage(shopId: shopId)),
        ),
      ),
      _ActionItem(
        icon: Icons.shopping_cart_outlined,
        label: 'Pending\nOrders',
        color: Colors.purple,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PendingOrdersPage(shopId: shopId)),
        ),
      ),
      _ActionItem(
        icon: Icons.bar_chart_outlined,
        label: 'Performance',
        color: Colors.green,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => MechanicPerformancePage(shopId: shopId)),
        ),
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: items.map((item) {
        return GestureDetector(
          onTap: item.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: item.color.withValues(alpha: 0.3)),
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, color: item.color, size: 36),
                  const SizedBox(height: 8),
                  Text(item.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: item.color)),
                ]),
          ),
        );
      }).toList(),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
