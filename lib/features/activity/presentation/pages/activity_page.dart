import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../appointments/services/appointment_api_service.dart';
import '../../../appointments/data/models/appointment_model.dart';
import '../../../appointments/presentation/pages/my_appointments_page.dart';
import '../../../mechanic/presentation/pages/mechanic_dashboard_page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _apptService = AppointmentApiService();
  List<AppointmentModel> _appointments = [];
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final auth = context.read<AuthService>();
    if (auth.token != null) _apptService.setAuthToken(auth.token!);
    setState(() => _loading = true);
    final appts = await _apptService.getMyAppointments();
    final orders = await _apptService.getMyOrders();
    setState(() {
      _appointments = appts;
      _orders = orders;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    if (!auth.isAuthenticated) {
      return _buildRequireAuth(context);
    }

    // Mechanics and owners go directly to their dashboard
    if (auth.isMechanic || auth.isShopOwner) {
      return const MechanicDashboardPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 6),
                Text('Appointments (${_appointments.length})'),
              ]),
            ),
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.shopping_bag_outlined, size: 16),
                const SizedBox(width: 6),
                Text('Orders (${_orders.length})'),
              ]),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAppointments(),
                  _buildOrders(),
                ],
              ),
            ),
    );
  }

  Widget _buildRequireAuth(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('Sign in to view your activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Track your appointments and orders here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600)),
          ]),
        ),
      ),
    );
  }

  Widget _buildAppointments() {
    if (_appointments.isEmpty) {
      return _buildEmptyState(
        Icons.calendar_today_outlined,
        'No appointments yet',
        'Book a service to see your appointments here',
        onAction: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyAppointmentsPage()),
        ),
        actionLabel: 'View All Appointments',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _appointments.length,
      itemBuilder: (_, i) {
        final appt = _appointments[i];
        final color = _statusColor(appt.status);
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(Icons.calendar_today, color: color, size: 22),
            ),
            title: Text(appt.serviceName ?? 'Appointment #${appt.id}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              '${appt.shopName ?? ''}\n${_formatDate(appt.appointmentDate)}',
              style: const TextStyle(fontSize: 12),
            ),
            isThreeLine: true,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                appt.status.toUpperCase(),
                style: TextStyle(
                    fontSize: 10, color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrders() {
    if (_orders.isEmpty) {
      return _buildEmptyState(
        Icons.shopping_bag_outlined,
        'No orders yet',
        'Order products from a shop to see them here',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (_, i) {
        final order = _orders[i];
        final status = order['status']?.toString() ?? 'pending';
        final color = _statusColor(status);
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.shopping_bag_outlined,
                  color: color, size: 22),
            ),
            title: Text('Order #${order['id'] ?? ''}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              '\$${(order['total_amount'] ?? 0).toStringAsFixed(2)}\n${_formatDate(order['created_at'] ?? '')}',
              style: const TextStyle(fontSize: 12),
            ),
            isThreeLine: true,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                    fontSize: 10, color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle,
      {VoidCallback? onAction, String? actionLabel}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500)),
          if (onAction != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white),
              child: Text(actionLabel ?? 'View All'),
            ),
          ],
        ]),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'completed':
        return Colors.green;
      case 'confirmed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
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
