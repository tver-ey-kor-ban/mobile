import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/appointment_api_service.dart';
import '../../data/models/appointment_model.dart';

class AppointmentDetailPage extends StatefulWidget {
  final int appointmentId;
  const AppointmentDetailPage({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  final _service = AppointmentApiService();
  AppointmentModel? _appt;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthService>().token;
    if (token != null) _service.setAuthToken(token);
    setState(() => _loading = true);
    final appt = await _service.getAppointmentById(widget.appointmentId);
    setState(() {
      _appt = appt;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Detail'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _appt == null
              ? const Center(child: Text('Appointment not found'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final appt = _appt!;
    final color = _statusColor(appt.status);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color),
              ),
              child: Text(
                appt.status.toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _section('Service Details', [
            _detailRow('Service', appt.serviceName ?? 'N/A'),
            _detailRow('Shop', appt.shopName ?? 'N/A'),
            _detailRow('Date', _formatDate(appt.appointmentDate)),
          ]),
          if (appt.vehicleInfo != null)
            _section('Vehicle', [
              _detailRow('Vehicle', appt.vehicleInfo!),
            ]),
          if (appt.notes != null && appt.notes!.isNotEmpty)
            _section('Notes', [
              _detailRow('Notes', appt.notes!),
            ]),
          if (appt.totalAmount != null)
            _section('Payment', [
              _detailRow('Total', '\$${appt.totalAmount!.toStringAsFixed(2)}'),
            ]),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> rows) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const Divider(),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13))),
        ],
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
      return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return d;
    }
  }
}
