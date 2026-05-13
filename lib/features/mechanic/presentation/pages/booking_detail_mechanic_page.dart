import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/mechanic_api_service.dart';
import '../../data/models/mechanic_booking_model.dart';

class BookingDetailMechanicPage extends StatefulWidget {
  final int shopId;
  final int appointmentId;

  const BookingDetailMechanicPage({
    super.key,
    required this.shopId,
    required this.appointmentId,
  });

  @override
  State<BookingDetailMechanicPage> createState() =>
      _BookingDetailMechanicPageState();
}

class _BookingDetailMechanicPageState
    extends State<BookingDetailMechanicPage> {
  final _service = MechanicApiService();
  MechanicBookingModel? _booking;
  bool _loading = true;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthService>().token;
    if (token != null) _service.setAuthToken(token);
    setState(() => _loading = true);
    final b = await _service.getBookingDetail(
        widget.shopId, widget.appointmentId);
    setState(() {
      _booking = b;
      _loading = false;
    });
  }

  Future<void> _accept() async {
    setState(() => _acting = true);
    final ok = await _service.acceptBooking(
        widget.shopId, widget.appointmentId);
    setState(() => _acting = false);
    if (ok && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Booking accepted')));
      Navigator.pop(context, true);
    }
  }

  Future<void> _reject() async {
    final ctrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject Booking'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Reason',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (reason == null || reason.isEmpty) return;
    setState(() => _acting = true);
    final ok = await _service.rejectBooking(
        widget.shopId, widget.appointmentId, reason);
    setState(() => _acting = false);
    if (ok && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Booking rejected')));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking #${widget.appointmentId}'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _booking == null
              ? const Center(child: Text('Booking not found'))
              : _buildContent(),
      bottomNavigationBar: _booking?.status == 'pending' && !_loading
          ? _buildActions()
          : null,
    );
  }

  Widget _buildContent() {
    final b = _booking!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _section('Customer', [
          _row('Name', b.customer?.name ?? 'N/A'),
          _row('Phone', b.customer?.phone ?? 'N/A'),
        ]),
        _section('Booking Details', [
          if (b.serviceName != null) _row('Service', b.serviceName!),
          _row('Vehicle', b.vehicleInfo),
          _row('Date', _formatDate(b.appointmentDate)),
          _row('Total', '\$${b.totalAmount.toStringAsFixed(2)}'),
          _row('Status', b.status.toUpperCase()),
        ]),
        if (b.notes != null && b.notes!.isNotEmpty)
          _section('Notes', [_row('Note', b.notes!)]),
      ]),
    );
  }

  Widget _section(String title, List<Widget> rows) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          const Divider(),
          ...rows,
        ]),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style:
                  TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 13)),
        ),
      ]),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _acting ? null : _reject,
            icon: const Icon(Icons.close),
            label: const Text('Reject'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _acting ? null : _accept,
            icon: _acting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check),
            label: const Text('Accept'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ]),
    );
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
