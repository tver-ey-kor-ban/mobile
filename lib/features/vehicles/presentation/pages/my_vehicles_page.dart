import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/vehicle_api_service.dart';
import '../../data/models/vehicle_model.dart';

class MyVehiclesPage extends StatefulWidget {
  const MyVehiclesPage({super.key});

  @override
  State<MyVehiclesPage> createState() => _MyVehiclesPageState();
}

class _MyVehiclesPageState extends State<MyVehiclesPage> {
  final _service = VehicleApiService();
  List<VehicleModel> _vehicles = [];
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
    final list = await _service.getMyVehicles();
    setState(() {
      _vehicles = list;
      _loading = false;
    });
  }

  Future<void> _delete(VehicleModel v) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text('Remove ${v.displayName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _service.deleteVehicle(v.id);
      _load();
    }
  }

  Future<void> _setPrimary(VehicleModel v) async {
    await _service.setVehiclePrimary(v.id);
    _load();
  }

  void _showAddDialog([VehicleModel? existing]) {
    final makeCtrl = TextEditingController(text: existing?.make ?? '');
    final modelCtrl = TextEditingController(text: existing?.model ?? '');
    final yearCtrl =
        TextEditingController(text: existing?.year.toString() ?? '');
    final plateCtrl = TextEditingController(text: existing?.licensePlate ?? '');
    final colorCtrl = TextEditingController(text: existing?.color ?? '');
    bool isPrimary = existing?.isPrimary ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(existing == null ? 'Add Vehicle' : 'Edit Vehicle'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _field('Make', makeCtrl),
              const SizedBox(height: 8),
              _field('Model', modelCtrl),
              const SizedBox(height: 8),
              _field('Year', yearCtrl, keyboard: TextInputType.number),
              const SizedBox(height: 8),
              _field('License Plate', plateCtrl),
              const SizedBox(height: 8),
              _field('Color', colorCtrl),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Primary Vehicle'),
                value: isPrimary,
                onChanged: (v) => setS(() => isPrimary = v ?? false),
                contentPadding: EdgeInsets.zero,
              ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white),
              onPressed: () async {
                final data = {
                  'make': makeCtrl.text,
                  'model': modelCtrl.text,
                  'year': int.tryParse(yearCtrl.text) ?? 0,
                  if (plateCtrl.text.isNotEmpty)
                    'license_plate': plateCtrl.text,
                  if (colorCtrl.text.isNotEmpty) 'color': colorCtrl.text,
                  'is_primary': isPrimary,
                };
                Navigator.pop(ctx);
                if (existing == null) {
                  await _service.addVehicle(data);
                } else {
                  await _service.updateVehicle(existing.id, data);
                }
                _load();
              },
              child: Text(existing == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType? keyboard}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _vehicles.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _vehicles.length,
                      itemBuilder: (_, i) => _buildCard(_vehicles[i]),
                    ),
            ),
    );
  }

  Widget _buildEmpty() {
    return ListView(children: [
      const SizedBox(height: 80),
      Center(
        child: Column(children: [
          Icon(Icons.directions_car_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No vehicles added',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showAddDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Vehicle'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white),
          ),
        ]),
      ),
    ]);
  }

  Widget _buildCard(VehicleModel v) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.directions_car, color: Colors.red.shade700),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.displayName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    if (v.licensePlate != null)
                      Text(v.licensePlate!,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600)),
                  ]),
            ),
            if (v.isPrimary)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: const Text('Primary',
                    style: TextStyle(fontSize: 11, color: Colors.green)),
              ),
          ]),
          const SizedBox(height: 12),
          if (v.color != null) _row(Icons.palette_outlined, v.color!),
          if (v.fuelType != null)
            _row(Icons.local_gas_station_outlined, v.fuelType!),
          if (v.mileage != null) _row(Icons.speed_outlined, '${v.mileage} km'),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (!v.isPrimary)
              TextButton(
                onPressed: () => _setPrimary(v),
                child: const Text('Set Primary'),
              ),
            IconButton(
              icon: Icon(Icons.edit_outlined, color: Colors.grey.shade600),
              onPressed: () => _showAddDialog(v),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _delete(v),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 15, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
      ]),
    );
  }
}
