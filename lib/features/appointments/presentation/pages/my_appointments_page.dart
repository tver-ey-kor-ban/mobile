import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/appointment_api_service.dart';
import '../../data/models/appointment_model.dart';
import 'appointment_detail_page.dart';

class MyAppointmentsPage extends StatefulWidget {
  const MyAppointmentsPage({super.key});

  @override
  State<MyAppointmentsPage> createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _service = AppointmentApiService();
  Map<String, List<AppointmentModel>> _grouped = {};
  bool _loading = true;

  static const _tabs = ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'];
  static const _statusMap = {
    'All': null,
    'Pending': 'pending',
    'Confirmed': 'confirmed',
    'Completed': 'completed',
    'Cancelled': 'cancelled',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = context.read<AuthService>().token;
    if (token != null) _service.setAuthToken(token);
    setState(() => _loading = true);
    final all = await _service.getMyAppointments();
    final grouped = <String, List<AppointmentModel>>{'All': all};
    for (final status in ['pending', 'confirmed', 'completed', 'cancelled']) {
      grouped[status] = all.where((a) => a.status == status).toList();
    }
    setState(() {
      _grouped = grouped;
      _loading = false;
    });
  }

  List<AppointmentModel> get _current {
    final tab = _tabs[_tabController.index];
    final key = _statusMap[tab];
    if (key == null) return _grouped['All'] ?? [];
    return _grouped[key] ?? [];
  }

  Future<void> _cancel(AppointmentModel appt) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final ok = await _service.cancelAppointment(appt.id);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment cancelled')),
        );
        _load();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          onTap: (_) => setState(() {}),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _current.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _current.length,
                      itemBuilder: (_, i) =>
                          _buildCard(_current[i]),
                    ),
            ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('No appointments',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(AppointmentModel appt) {
    final statusColor = _statusColor(appt.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AppointmentDetailPage(appointmentId: appt.id),
          ),
        ).then((_) => _load()),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      appt.serviceName ?? 'Appointment #${appt.id}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _statusChip(appt.status, statusColor),
                ],
              ),
              if (appt.shopName != null) ...[
                const SizedBox(height: 8),
                _row(Icons.store_outlined, appt.shopName!),
              ],
              if (appt.vehicleInfo != null) ...[
                const SizedBox(height: 4),
                _row(Icons.directions_car_outlined, appt.vehicleInfo!),
              ],
              const SizedBox(height: 4),
              _row(Icons.calendar_today_outlined, _formatDate(appt.appointmentDate)),
              if (appt.totalAmount != null) ...[
                const SizedBox(height: 4),
                _row(Icons.attach_money,
                    '\$${appt.totalAmount!.toStringAsFixed(2)}'),
              ],
              if (appt.status == 'pending') ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _cancel(appt),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        ),
      ],
    );
  }

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
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
      return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return d;
    }
  }
}
