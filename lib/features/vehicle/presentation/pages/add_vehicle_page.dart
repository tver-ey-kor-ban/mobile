import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../data/models/vehicle_model.dart';
import '../../services/vehicle_api_service.dart';

export '../../data/models/vehicle_model.dart';

class AddVehiclePage extends StatefulWidget {
  final VehicleResponse? vehicle;
  final bool isEditing;

  const AddVehiclePage({
    super.key,
    this.vehicle,
    this.isEditing = false,
  });

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _engineController;
  late final TextEditingController _fuelTypeController;
  late final TextEditingController _transmissionController;
  late final TextEditingController _licensePlateController;
  late final TextEditingController _vinController;
  late final TextEditingController _colorController;
  late final TextEditingController _nicknameController;

  late bool _isPrimary;
  bool _isLoading = false;

  final VehicleApiService _vehicleService = VehicleApiService();

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _makeController = TextEditingController(text: v?.make ?? '');
    _modelController = TextEditingController(text: v?.model ?? '');
    _yearController = TextEditingController(text: v?.year.toString() ?? '');
    _engineController = TextEditingController(text: v?.engine ?? '');
    _fuelTypeController = TextEditingController(text: v?.fuelType ?? '');
    _transmissionController = TextEditingController(text: v?.transmission ?? '');
    _licensePlateController = TextEditingController(text: v?.licensePlate ?? '');
    _vinController = TextEditingController(text: v?.vin ?? '');
    _colorController = TextEditingController(text: v?.color ?? '');
    _nicknameController = TextEditingController(text: v?.nickname ?? '');
    _isPrimary = v?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _engineController.dispose();
    _fuelTypeController.dispose();
    _transmissionController.dispose();
    _licensePlateController.dispose();
    _vinController.dispose();
    _colorController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      if (auth.token != null) {
        _vehicleService.setAuthToken(auth.token!);
      }

      final request = CreateVehicleRequest(
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        engine: _engineController.text.trim().isEmpty
            ? null
            : _engineController.text.trim(),
        fuelType: _fuelTypeController.text.trim().isEmpty
            ? null
            : _fuelTypeController.text.trim(),
        transmission: _transmissionController.text.trim().isEmpty
            ? null
            : _transmissionController.text.trim(),
        licensePlate: _licensePlateController.text.trim().isEmpty
            ? null
            : _licensePlateController.text.trim(),
        vin: _vinController.text.trim().isEmpty
            ? null
            : _vinController.text.trim(),
        color: _colorController.text.trim().isEmpty
            ? null
            : _colorController.text.trim(),
        nickname: _nicknameController.text.trim().isEmpty
            ? null
            : _nicknameController.text.trim(),
        isPrimary: _isPrimary,
        isActive: true,
      );

      if (widget.isEditing && widget.vehicle != null) {
        await _vehicleService.updateVehicle(widget.vehicle!.id, request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle updated successfully!')),
          );
          Navigator.pop(context, true);
        }
      } else {
        await _vehicleService.addVehicle(request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle added successfully!')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Required Information'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _makeController,
                label: 'Make (Brand)',
                hint: 'e.g., Toyota, Honda',
                icon: Icons.branding_watermark_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Make is required';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _modelController,
                label: 'Model',
                hint: 'e.g., Camry, Accord',
                icon: Icons.directions_car_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Model is required';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _yearController,
                label: 'Year',
                hint: 'e.g., 2020',
                icon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Year is required';
                  }
                  final year = int.tryParse(value);
                  if (year == null || year < 1900 || year > 2100) {
                    return 'Enter a valid year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Optional Information'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _engineController,
                label: 'Engine',
                hint: 'e.g., 2.5L V4',
                icon: Icons.settings_outlined,
              ),
              _buildTextField(
                controller: _fuelTypeController,
                label: 'Fuel Type',
                hint: 'e.g., Gasoline, Diesel',
                icon: Icons.local_gas_station_outlined,
              ),
              _buildTextField(
                controller: _transmissionController,
                label: 'Transmission',
                hint: 'e.g., Automatic, Manual',
                icon: Icons.sync_outlined,
              ),
              _buildTextField(
                controller: _licensePlateController,
                label: 'License Plate',
                hint: 'e.g., ABC-123',
                icon: Icons.confirmation_number_outlined,
              ),
              _buildTextField(
                controller: _vinController,
                label: 'VIN',
                hint: 'Vehicle Identification Number',
                icon: Icons.numbers_outlined,
              ),
              _buildTextField(
                controller: _colorController,
                label: 'Color',
                hint: 'e.g., Black, White',
                icon: Icons.color_lens_outlined,
              ),
              _buildTextField(
                controller: _nicknameController,
                label: 'Nickname',
                hint: 'e.g., My Car, Family SUV',
                icon: Icons.edit_outlined,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.star_outline, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Set as Primary Vehicle',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'This will be your default vehicle for bookings',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isPrimary,
                        onChanged: (value) {
                          setState(() => _isPrimary = value);
                        },
                        // ignore: deprecated_member_use
                        activeColor: Colors.red.shade700,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.isEditing ? 'Update Vehicle' : 'Add Vehicle',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.red.shade700,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.red.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade700, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }
}
