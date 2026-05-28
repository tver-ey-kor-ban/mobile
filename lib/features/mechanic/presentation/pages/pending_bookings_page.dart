import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/mechanic_api_service.dart';
import '../../data/models/mechanic_booking_model.dart';
import 'booking_detail_mechanic_page.dart';

class PendingBookingsPage extends StatefulWidget {
  final int shopId;
  const PendingBookingsPage({super.key, required this.shopId});

  @override
  State<PendingBookingsPage> createState() => _PendingBookingsPageState();
}

class _PendingBookingsPageState extends State<PendingBookingsPage> {
  final _service = MechanicApiService();
  List<MechanicBookingModel> _bookings = [];
  int _count = 0;
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
    final result = await _service.getPendingBookings(widget.shopId);
    setState(() {
      _count = result['count'] as int;
      _bookings = result['bookings'] as List<MechanicBookingModel>;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Bookings ($_count)'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _bookings.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _bookings.length,
                      itemBuilder: (_, i) => _buildCard(_bookings[i]),
                    ),
            ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
        SizedBox(height: 16),
        Text('No pending bookings!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildCard(MechanicBookingModel booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingDetailMechanicPage(
              shopId: widget.shopId,
              appointmentId: booking.appointmentId,
            ),
          ),
        ).then((_) => _load()),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                booking.customer?.name ?? 'Customer',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${booking.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                    fontSize: 15),
              ),
            ]),
            const SizedBox(height: 6),
            if (booking.serviceName != null)
              _row(Icons.build_outlined, booking.serviceName!),
            _row(Icons.directions_car_outlined, booking.vehicleInfo),
            _row(Icons.calendar_today_outlined,
                _formatDate(booking.appointmentDate)),
            if (booking.notes != null && booking.notes!.isNotEmpty)
              _row(Icons.notes_outlined, booking.notes!),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              OutlinedButton.icon(
                onPressed: () => _quickAction(booking, 'reject'),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Reject'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _quickAction(booking, 'accept'),
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Accept'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Future<void> _quickAction(MechanicBookingModel booking, String action) async {
    if (action == 'reject') {
      final ctrl = TextEditingController();
      final reason = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Reason for Rejection'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              hintText: 'Enter reason...',
              border: OutlineInputBorder(),
            ),
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
      await _service.rejectBooking(
          widget.shopId, booking.appointmentId, reason);
    } else {
      await _service.acceptBooking(widget.shopId, booking.appointmentId);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Booking ${action == 'accept' ? 'accepted' : 'rejected'}')),
      );
      _load();
    }
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
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
