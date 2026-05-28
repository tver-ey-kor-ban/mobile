import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/mechanic_api_service.dart';
import '../../data/models/mechanic_booking_model.dart';
import 'pending_bookings_page.dart';
import 'today_bookings_page.dart';
import 'pending_orders_page.dart';
import 'mechanic_performance_page.dart';
import '../../../quotations/presentation/pages/shop_quotations_page.dart';
import '../../../repair_progress/presentation/pages/shop_repairs_page.dart';
import '../../../invoices/presentation/pages/shop_invoices_page.dart';

class MechanicDashboardPage extends StatefulWidget {
  const MechanicDashboardPage({super.key});

  @override
  State<MechanicDashboardPage> createState() => _MechanicDashboardPageState();
}

class _MechanicDashboardPageState extends State<MechanicDashboardPage> {
  final _service = MechanicApiService();
  List<MyShopModel> _shops = [];
  int? _selectedShopId;
  String? _selectedShopName;
  Map<String, dynamic>? _myPerf;
  Map<String, dynamic>? _teamStats;
  Map<String, dynamic>? _shopStats;
  int _pendingBookings = 0;
  int _todayBookings = 0;
  int _pendingOrders = 0;
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
      if (shopId == null || !shops.any((s) => s.shopId == shopId)) {
        shopId = shops.first.shopId;
        shopName = shops.first.shopName;
        auth.setShopId(shopId);
      } else {
        shopName = shops.firstWhere((s) => s.shopId == shopId).shopName;
      }
    }

    Map<String, dynamic>? myPerf;
    Map<String, dynamic>? teamStats;
    Map<String, dynamic>? shopStats;
    int pendingBookings = 0;
    int todayBookings = 0;
    int pendingOrders = 0;

    if (shopId != null) {
      final results = await Future.wait([
        _service.getMyPerformance(shopId),
        if (auth.isShopOwner) _service.getAllMechanicsPerformance(shopId),
        if (auth.isShopOwner) _service.getShopStatistics(shopId),
        _service.getPendingBookingCount(shopId),
        _service.getTodayBookingCount(shopId),
        _service.getPendingOrderCount(shopId),
      ]);

      int idx = 0;
      myPerf = results[idx++] as Map<String, dynamic>?;
      if (auth.isShopOwner) {
        teamStats = results[idx++] as Map<String, dynamic>?;
        shopStats = results[idx++] as Map<String, dynamic>?;
      }
      pendingBookings = (results[idx++] as int?) ?? 0;
      todayBookings = (results[idx++] as int?) ?? 0;
      pendingOrders = (results[idx] as int?) ?? 0;
    }

    setState(() {
      _shops = shops;
      _selectedShopId = shopId;
      _selectedShopName = shopName;
      _myPerf = myPerf;
      _teamStats = teamStats;
      _shopStats = shopStats;
      _pendingBookings = pendingBookings;
      _todayBookings = todayBookings;
      _pendingOrders = pendingOrders;
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
    final auth = context.read<AuthService>();
    final shopId = _selectedShopId!;

    final results = await Future.wait([
      _service.getMyPerformance(shopId),
      if (auth.isShopOwner) _service.getAllMechanicsPerformance(shopId),
      if (auth.isShopOwner) _service.getShopStatistics(shopId),
      _service.getPendingBookingCount(shopId),
      _service.getTodayBookingCount(shopId),
      _service.getPendingOrderCount(shopId),
    ]);

    int idx = 0;
    final myPerf = results[idx++] as Map<String, dynamic>?;
    Map<String, dynamic>? teamStats;
    Map<String, dynamic>? shopStats;
    if (auth.isShopOwner) {
      teamStats = results[idx++] as Map<String, dynamic>?;
      shopStats = results[idx++] as Map<String, dynamic>?;
    }
    final pendingBookings = (results[idx++] as int?) ?? 0;
    final todayBookings = (results[idx++] as int?) ?? 0;
    final pendingOrders = (results[idx] as int?) ?? 0;

    setState(() {
      _myPerf = myPerf;
      _teamStats = teamStats;
      _shopStats = shopStats;
      _pendingBookings = pendingBookings;
      _todayBookings = todayBookings;
      _pendingOrders = pendingOrders;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final isOwner = auth.isShopOwner;
    final userName = auth.userName ?? (isOwner ? 'Owner' : 'Mechanic');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(isOwner ? 'Shop Dashboard' : 'Mechanic Dashboard'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
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
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : _selectedShopId == null
              ? _buildNoShop()
              : RefreshIndicator(
                  color: Colors.red,
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroHeader(isOwner, userName),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatsRow(isOwner),
                              if (isOwner && _shopStats != null) ...[
                                const SizedBox(height: 16),
                                _buildShopStatsBanner(),
                              ],
                              const SizedBox(height: 24),
                              const Text(
                                'Quick Actions',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A2E)),
                              ),
                              const SizedBox(height: 12),
                              _buildActionGrid(context),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ── Hero header ────────────────────────────────────────────────────────────

  Widget _buildHeroHeader(bool isOwner, String userName) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade800, Colors.red.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              userName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                      fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                ),
                Text(
                  userName,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                if (_selectedShopName != null)
                  Row(
                    children: [
                      Icon(Icons.store_rounded,
                          size: 12, color: Colors.white.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Text(
                        _selectedShopName!,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Text(
              isOwner ? 'Owner' : 'Mechanic',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────────

  Widget _buildStatsRow(bool isOwner) {
    List<_StatData> stats;

    if (isOwner && _teamStats != null) {
      final s = _teamStats!['shop_summary'] ?? {};
      stats = [
        _StatData('Total Jobs', '${s['total_jobs'] ?? 0}', Icons.build_rounded,
            const Color(0xFF4361EE)),
        _StatData(
            'Revenue',
            '\$${((s['total_revenue'] ?? 0.0) as num).toStringAsFixed(0)}',
            Icons.attach_money_rounded,
            const Color(0xFF2DC653)),
        _StatData('Mechanics', '${s['mechanic_count'] ?? 0}',
            Icons.people_rounded, const Color(0xFFF77F00)),
      ];
    } else if (_myPerf != null) {
      final jobs = _myPerf!['total_jobs'] ?? _myPerf!['jobs_completed'] ?? 0;
      final revenue = ((_myPerf!['total_revenue'] ??
              _myPerf!['revenue_generated'] ??
              0.0) as num)
          .toDouble();
      final rating =
          ((_myPerf!['average_rating'] ?? _myPerf!['rating'] ?? 0.0) as num)
              .toDouble();
      stats = [
        _StatData(
            'My Jobs', '$jobs', Icons.build_rounded, const Color(0xFF4361EE)),
        _StatData('Revenue', '\$${revenue.toStringAsFixed(0)}',
            Icons.attach_money_rounded, const Color(0xFF2DC653)),
        _StatData('Rating', rating.toStringAsFixed(1), Icons.star_rounded,
            const Color(0xFFF77F00)),
      ];
    } else {
      stats = const [
        _StatData('My Jobs', '—', Icons.build_rounded, Color(0xFF4361EE)),
        _StatData(
            'Revenue', '—', Icons.attach_money_rounded, Color(0xFF2DC653)),
        _StatData('Rating', '—', Icons.star_rounded, Color(0xFFF77F00)),
      ];
    }

    return Row(
      children: stats
          .map((s) => Expanded(
                child: _StatCard(data: s),
              ))
          .expand((w) => [w, const SizedBox(width: 10)])
          .toList()
        ..removeLast(),
    );
  }

  // ── Shop stats banner (owner only) ────────────────────────────────────────

  Widget _buildShopStatsBanner() {
    final stats = _shopStats!;
    final appts = stats['appointments'] as Map<String, dynamic>? ?? {};
    final orders = stats['orders'] as Map<String, dynamic>? ?? {};
    final revenue = stats['revenue'] as Map<String, dynamic>? ?? {};
    final totalRevenue = (revenue['total'] as num?)?.toDouble() ?? 0.0;
    final products = stats['products'] ?? 0;
    final services = stats['services'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.bar_chart_rounded,
                    size: 16, color: Colors.red.shade700),
              ),
              const SizedBox(width: 8),
              Text('Shop Overview',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey.shade800)),
            ],
          ),
          const SizedBox(height: 14),
          Row(children: [
            _BannerStat('Appointments', '${appts['total'] ?? 0}',
                const Color(0xFF4361EE)),
            _divider(),
            _BannerStat(
                'Orders', '${orders['total'] ?? 0}', const Color(0xFF7B2D8B)),
            _divider(),
            _BannerStat('Revenue', '\$${totalRevenue.toStringAsFixed(0)}',
                const Color(0xFF2DC653)),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 5),
                Text('$products products',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(width: 10),
                Icon(Icons.build_outlined,
                    size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 5),
                Text('$services services',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 36,
        color: Colors.grey.shade200,
        margin: const EdgeInsets.symmetric(horizontal: 12),
      );

  // ── Action grid ────────────────────────────────────────────────────────────

  Widget _buildActionGrid(BuildContext context) {
    final shopId = _selectedShopId!;
    final items = [
      _ActionItem(
        icon: Icons.pending_actions_rounded,
        label: 'Pending\nBookings',
        color: const Color(0xFFF77F00),
        bgColor: const Color(0xFFFFF3E0),
        count: _pendingBookings,
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => PendingBookingsPage(shopId: shopId))),
      ),
      _ActionItem(
        icon: Icons.today_rounded,
        label: "Today's\nBookings",
        color: const Color(0xFF4361EE),
        bgColor: const Color(0xFFE8EEFF),
        count: _todayBookings,
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => TodayBookingsPage(shopId: shopId))),
      ),
      _ActionItem(
        icon: Icons.shopping_cart_rounded,
        label: 'Pending\nOrders',
        color: const Color(0xFF7B2D8B),
        bgColor: const Color(0xFFF3E5F5),
        count: _pendingOrders,
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => PendingOrdersPage(shopId: shopId))),
      ),
      _ActionItem(
        icon: Icons.bar_chart_rounded,
        label: 'Performance',
        color: const Color(0xFF2DC653),
        bgColor: const Color(0xFFE8F8EE),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => MechanicPerformancePage(shopId: shopId))),
      ),
      _ActionItem(
        icon: Icons.description_rounded,
        label: 'Quotations',
        color: const Color(0xFF3A86FF),
        bgColor: const Color(0xFFE3F2FD),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ShopQuotationsPage(shopId: shopId))),
      ),
      _ActionItem(
        icon: Icons.build_circle_rounded,
        label: 'Repair\nProgress',
        color: const Color(0xFF00B4D8),
        bgColor: const Color(0xFFE0F7FA),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => ShopRepairsPage(shopId: shopId))),
      ),
      _ActionItem(
        icon: Icons.receipt_long_rounded,
        label: 'Invoices',
        color: const Color(0xFFE63946),
        bgColor: const Color(0xFFFFEBEE),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ShopInvoicesPage(shopId: shopId))),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _ActionTile(item: items[i]),
    );
  }

  // ── No-shop fallback ───────────────────────────────────────────────────────

  Widget _buildNoShop() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.store_outlined,
                size: 56, color: Colors.red.shade300),
          ),
          const SizedBox(height: 20),
          Text('No shop assigned',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Text(
            'You are not assigned to any shop yet.\nAsk your shop owner to add you.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, height: 1.5),
          ),
        ]),
      ),
    );
  }
}

// ── Supporting data classes ────────────────────────────────────────────────

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatData(this.label, this.value, this.icon, this.color);
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
  final int? count;
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
    this.count,
  });
}

// ── Reusable widgets ──────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            data.value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: data.color),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _BannerStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final _ActionItem item;
  const _ActionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3)),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                        height: 1.3),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: Colors.grey.shade300),
              ],
            ),
          ),
          if (item.count != null && item.count! > 0)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.red.withValues(alpha: 0.4),
                        blurRadius: 6),
                  ],
                ),
                child: Text(
                  item.count! > 99 ? '99+' : '${item.count}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
