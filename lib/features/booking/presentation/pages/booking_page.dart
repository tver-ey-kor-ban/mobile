import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/pages/login_page.dart' as login;
import '../../../../shared/services/auth_service.dart';
import '../../../shop/services/browse_api_service.dart';
import '../../../shop/data/models/browse_models.dart';
import '../../services/booking_api_service.dart';
import '../../data/models/booking_request_model.dart';
import '../../domain/models/car_model.dart';
import 'widgets/step_one_car_selection.dart';

class BookingPage extends StatefulWidget {
  final int? shopId;
  final String? shopName;
  final int? preSelectedServiceId;

  const BookingPage({
    super.key,
    this.shopId,
    this.shopName,
    this.preSelectedServiceId,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _browseService = BrowseApiService();
  final _bookingService = BookingApiService();

  int _step = 0;
  bool _authChecked = false;

  // Step 1 — Vehicle
  SelectedCar? _selectedCar;

  // Step 2 — Service + Products
  List<ShopServiceItem> _services = [];
  List<ShopProduct> _products = [];
  bool _loadingItems = true;
  ShopServiceItem? _selectedService;
  final Map<int, int> _productQty = {}; // productId → quantity

  // Step 3 — Date / Notes
  DateTime? _appointmentDate;
  final _notesCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    final auth = context.read<AuthService>();
    if (!auth.isAuthenticated) {
      await login.showLoginModal(context);
      if (!auth.isAuthenticated && mounted) {
        Navigator.of(context).pop();
        return;
      }
    }
    if (auth.token != null) {
      _browseService.setAuthToken(auth.token!);
      _bookingService.setAuthToken(auth.token!);
    }
    setState(() => _authChecked = true);
    if (widget.shopId != null) _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _loadingItems = true);
    try {
      final servicesRes = await _browseService.getShopServices(widget.shopId!);
      final productsRes = await _browseService.getShopProducts(widget.shopId!);
      setState(() {
        _services = servicesRes.services.where((s) => s.isAvailable).toList();
        _products = productsRes.products
            .where((p) => p.isAvailable && (p.stockQuantity ?? 1) > 0)
            .toList();
        // Pre-select service if passed in
        if (widget.preSelectedServiceId != null) {
          final pre = _services.cast<ShopServiceItem?>().firstWhere(
                (s) => s?.id == widget.preSelectedServiceId,
                orElse: () => null,
              );
          if (pre != null) _selectedService = pre;
        }
        _loadingItems = false;
      });
    } catch (_) {
      setState(() => _loadingItems = false);
    }
  }

  // ── Validation ──────────────────────────────────────────────

  bool get _step1Valid => _selectedCar != null;

  bool get _step2Valid =>
      _selectedService != null || _productQty.values.any((q) => q > 0);

  // Date is required only when a service is selected
  bool get _step3Valid => _selectedService == null || _appointmentDate != null;

  void _next() {
    if (_step == 0 && !_step1Valid) {
      _snack('Please select your vehicle');
      return;
    }
    if (_step == 1 && !_step2Valid) {
      _snack('Please select a service or add at least one product');
      return;
    }
    if (_step == 2) {
      if (!_step3Valid) {
        _snack('Please select an appointment date & time');
        return;
      }
      _submit();
      return;
    }
    setState(() => _step++);
  }

  // ── Submit ───────────────────────────────────────────────────

  Future<void> _submit() async {
    setState(() => _submitting = true);

    final items = _productQty.entries
        .where((e) => e.value > 0)
        .map((e) => ProductItem(productId: e.key, quantity: e.value))
        .toList();

    final request = UnifiedBookingRequest(
      shopId: widget.shopId!,
      customerVehicleId: _selectedCar!.customerVehicleId,
      vehicleInfo: _selectedCar!.displayName,
      serviceId: _selectedService?.id,
      appointmentDate: _appointmentDate,
      productItems: items,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    try {
      await _bookingService.createUnifiedBooking(request);
      setState(() => _submitting = false);
      if (mounted) _showSuccess();
    } catch (e) {
      setState(() => _submitting = false);
      if (mounted) _snack('Booking failed: ${e.toString()}', error: true);
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 64),
          const SizedBox(height: 16),
          const Text('Booking Confirmed!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Your booking at ${widget.shopName ?? 'the shop'} has been submitted.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ]),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red : null,
    ));
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_authChecked) {
      return Scaffold(
        appBar: AppBar(
            title: Text(widget.shopName != null
                ? 'Book at ${widget.shopName}'
                : 'Book Appointment')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.shopId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book Appointment')),
        body: const Center(
            child: Text('No shop selected. Please choose a shop first.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shopName != null
            ? 'Book at ${widget.shopName}'
            : 'Book Appointment'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(children: [
        _buildStepper(),
        Expanded(
          child: _step == 0
              ? _buildStep1()
              : _step == 1
                  ? _buildStep2()
                  : _buildStep3(),
        ),
        _buildFooter(),
      ]),
    );
  }

  Widget _buildStepper() {
    const labels = ['Vehicle', 'Services', 'Confirm'];
    return Container(
      color: Colors.red.shade700,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: List.generate(3, (i) {
          final done = i < _step;
          final active = i == _step;
          return Expanded(
            child: Row(children: [
              if (i > 0)
                Expanded(
                  child: Container(
                      height: 2, color: done ? Colors.white : Colors.white30),
                ),
              Column(children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      active || done ? Colors.white : Colors.white30,
                  child: done
                      ? Icon(Icons.check, size: 16, color: Colors.red.shade700)
                      : Text('${i + 1}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: active
                                  ? Colors.red.shade700
                                  : Colors.white70)),
                ),
                const SizedBox(height: 4),
                Text(labels[i],
                    style: TextStyle(
                        fontSize: 10,
                        color: active || done ? Colors.white : Colors.white60)),
              ]),
              if (i < 2) const Expanded(child: SizedBox()),
            ]),
          );
        }),
      ),
    );
  }

  // ── Step 1: Vehicle Selection ─────────────────────────────────

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: StepOneCarSelection(
        initialCar: _selectedCar,
        onCarSelected: (car) => setState(() => _selectedCar = car),
      ),
    );
  }

  // ── Step 2: Service + Products ───────────────────────────────

  Widget _buildStep2() {
    if (_loadingItems) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Services section
        if (_services.isNotEmpty) ...[
          const Text('Select a Service',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Optional — choose one service',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 10),
          ..._services.map((s) => _serviceCard(s)),
          const SizedBox(height: 20),
        ],

        // Products section
        if (_products.isNotEmpty) ...[
          const Text('Add Products',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Optional — add items to your order',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 10),
          ..._products.map((p) => _productCard(p)),
        ],

        if (_services.isEmpty && _products.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('No services or products available.',
                  style: TextStyle(color: Colors.grey.shade500)),
            ),
          ),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _serviceCard(ShopServiceItem s) {
    final selected = _selectedService?.id == s.id;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? Colors.red.shade700 : Colors.grey.shade300,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() {
          _selectedService = selected ? null : s;
        }),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected ? Colors.red.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.build_outlined,
                  color: selected ? Colors.red.shade700 : Colors.grey.shade500,
                  size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    if (s.description != null)
                      Text(s.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                    if (s.estimatedMinutes != null)
                      Text('~${s.estimatedMinutes} min',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500)),
                  ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('\$${s.price.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: selected ? Colors.red.shade700 : Colors.black87)),
              const SizedBox(height: 4),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? Colors.red.shade700 : Colors.grey.shade400,
                size: 20,
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _productCard(ShopProduct p) {
    final qty = _productQty[p.id] ?? 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: qty > 0 ? Colors.red.shade300 : Colors.grey.shade300,
          width: qty > 0 ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: qty > 0 ? Colors.red.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.inventory_2_outlined,
                color: qty > 0 ? Colors.red.shade700 : Colors.grey.shade500,
                size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              if (p.description != null)
                Text(p.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Text('\$${p.price.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.red.shade700)),
            ]),
          ),
          // Quantity stepper
          Row(children: [
            _qtyBtn(
              icon: Icons.remove,
              onTap: qty > 0
                  ? () => setState(() {
                        if (qty == 1) {
                          _productQty.remove(p.id);
                        } else {
                          _productQty[p.id] = qty - 1;
                        }
                      })
                  : null,
            ),
            SizedBox(
              width: 32,
              child: Text('$qty',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            _qtyBtn(
              icon: Icons.add,
              onTap: () => setState(() => _productQty[p.id] = qty + 1),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _qtyBtn({required IconData icon, required VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: onTap != null ? Colors.red.shade700 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 16,
            color: onTap != null ? Colors.white : Colors.grey.shade400),
      ),
    );
  }

  // ── Step 3: Date + Confirm ───────────────────────────────────

  Widget _buildStep3() {
    final serviceTotal = _selectedService?.price ?? 0.0;
    final productsTotal = _productQty.entries.fold(0.0, (sum, e) {
      final p = _products.firstWhere((p) => p.id == e.key,
          orElse: () =>
              ShopProduct(id: 0, name: '', price: 0, isAvailable: false));
      return sum + p.price * e.value;
    });
    final total = serviceTotal + productsTotal;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Date & Time',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          if (_selectedService == null) ...[
            const SizedBox(width: 8),
            Text('(optional for product orders)',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ]),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _pickDateTime,
          icon: const Icon(Icons.calendar_today_outlined),
          label: Text(
            _appointmentDate == null
                ? _selectedService == null
                    ? 'Select pickup date & time (optional)'
                    : 'Select appointment date & time *'
                : _formatDateTime(_appointmentDate!),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: BorderSide(
                color: _appointmentDate == null
                    ? Colors.grey.shade400
                    : Colors.red.shade700),
            foregroundColor: _appointmentDate == null
                ? Colors.grey.shade600
                : Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 20),
        const Text('Notes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: _notesCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Any special requests or notes...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),

        // Order summary
        const Text('Order Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _summaryRow('Vehicle', _selectedCar?.displayName ?? ''),
              if (_selectedService != null) ...[
                const Divider(height: 16),
                _summaryRow('Service', _selectedService!.name,
                    value: '\$${serviceTotal.toStringAsFixed(2)}'),
              ],
              if (_productQty.isNotEmpty) ...[
                const Divider(height: 16),
                ..._productQty.entries.map((e) {
                  final p = _products.firstWhere((p) => p.id == e.key,
                      orElse: () => ShopProduct(
                          id: 0, name: '', price: 0, isAvailable: false));
                  return _summaryRow('${p.name} ×${e.value}', '',
                      value: '\$${(p.price * e.value).toStringAsFixed(2)}');
                }),
              ],
              const Divider(height: 16),
              _summaryRow('Total', '',
                  value: '\$${total.toStringAsFixed(2)}', bold: true),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _summaryRow(String label, String sub,
      {String? value, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                    fontSize: bold ? 15 : 13)),
            if (sub.isNotEmpty)
              Text(sub,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ]),
        ),
        if (value != null)
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                  fontSize: bold ? 16 : 13,
                  color: bold ? Colors.red.shade700 : null)),
      ]),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return;
    setState(() {
      _appointmentDate =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  String _formatDateTime(DateTime dt) {
    final d = '${dt.day}/${dt.month}/${dt.year}';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$d  $h:$m';
  }

  // ── Footer ───────────────────────────────────────────────────

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(children: [
        if (_step > 0)
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: _submitting ? null : () => setState(() => _step--),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Back'),
            ),
          ),
        if (_step > 0) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _submitting ? null : _next,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(_step == 2 ? 'Confirm Booking' : 'Next',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }
}
