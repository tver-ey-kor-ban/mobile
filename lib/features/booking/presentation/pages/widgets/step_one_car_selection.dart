import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/car_model.dart';
import '../../../../../shared/services/auth_service.dart';
import '../../../../vehicles/services/vehicle_api_service.dart';
import '../../../../vehicles/data/models/vehicle_model.dart';

class StepOneCarSelection extends StatefulWidget {
  final Function(SelectedCar) onCarSelected;
  final SelectedCar? initialCar;

  const StepOneCarSelection({
    super.key,
    required this.onCarSelected,
    this.initialCar,
  });

  @override
  State<StepOneCarSelection> createState() => _StepOneCarSelectionState();
}

class _StepOneCarSelectionState extends State<StepOneCarSelection> {
  // Manual Selection Fields
  String? selectedBrandId;
  String? selectedModelId;
  String? selectedEngine;
  int? selectedYear;

  // Saved Vehicles Fields
  final _vehicleService = VehicleApiService();
  List<VehicleModel> _savedVehicles = [];
  VehicleModel? _selectedSavedVehicle;
  bool _loadingVehicles = false;
  bool _useSavedVehicle = true;

  @override
  void initState() {
    super.initState();
    
    // Safety check for initial manual car setup
    if (widget.initialCar != null && widget.initialCar!.customerVehicleId == null) {
      try {
        final car = widget.initialCar!;
        final brand = carBrands.firstWhere(
          (b) => b.name.toLowerCase() == car.brand.toLowerCase(),
          orElse: () => carBrands.first,
        );
        final model = brand.models.firstWhere(
          (m) => m.name.toLowerCase() == car.model.toLowerCase(),
          orElse: () => brand.models.first,
        );
        selectedBrandId = brand.id;
        selectedModelId = model.id;
        selectedEngine = car.engine;
        selectedYear = car.year;
        _useSavedVehicle = false;
      } catch (_) {
        // Fallback gracefully
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSavedVehicles());
  }

  Future<void> _loadSavedVehicles() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    if (token == null) return;

    setState(() => _loadingVehicles = true);
    try {
      _vehicleService.setAuthToken(token);
      final list = await _vehicleService.getMyVehicles();
      setState(() {
        _savedVehicles = list;
        _loadingVehicles = false;

        if (widget.initialCar != null) {
          if (widget.initialCar!.customerVehicleId != null) {
            _selectedSavedVehicle = list.firstWhere(
              (v) => v.id == widget.initialCar!.customerVehicleId,
              orElse: () => null as dynamic,
            );
            if (_selectedSavedVehicle != null) {
              _useSavedVehicle = true;
            }
          } else {
            _useSavedVehicle = false;
          }
        } else if (list.isNotEmpty) {
          _useSavedVehicle = true;
          // Auto-select primary vehicle if available, else first
          final primary = list.firstWhere((v) => v.isPrimary, orElse: () => list.first);
          _selectSavedVehicle(primary);
        } else {
          _useSavedVehicle = false;
        }
      });
    } catch (_) {
      setState(() => _loadingVehicles = false);
    }
  }

  void _selectSavedVehicle(VehicleModel vehicle) {
    setState(() {
      _selectedSavedVehicle = vehicle;
      
      // Try to find matches in our static lists to sync dropdown states
      CarBrand? brand;
      for (final b in carBrands) {
        if (b.name.toLowerCase() == vehicle.make.toLowerCase()) {
          brand = b;
          break;
        }
      }

      if (brand != null) {
        selectedBrandId = brand.id;
        CarModel? model;
        for (final m in brand.models) {
          if (m.name.toLowerCase() == vehicle.model.toLowerCase()) {
            model = m;
            break;
          }
        }
        if (model != null) {
          selectedModelId = model.id;
          final matchedEngine = model.engines.firstWhere(
            (e) => e.toLowerCase() == (vehicle.engine ?? '').toLowerCase(),
            orElse: () => model!.engines.isNotEmpty ? model.engines.first : '',
          );
          selectedEngine = matchedEngine.isNotEmpty ? matchedEngine : null;
          
          if (model.years.contains(vehicle.year)) {
            selectedYear = vehicle.year;
          } else {
            selectedYear = model.years.isNotEmpty ? model.years.first : null;
          }
        } else {
          selectedModelId = null;
          selectedEngine = null;
          selectedYear = null;
        }
      } else {
        selectedBrandId = null;
        selectedModelId = null;
        selectedEngine = null;
        selectedYear = null;
      }
    });

    _notifySelection();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Your Vehicle',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide your vehicle details',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Tab Selector (only shown if user has saved vehicles)
          if (_savedVehicles.isNotEmpty) ...[
            _buildTabSelector(),
            const SizedBox(height: 24),
          ],

          if (_useSavedVehicle && _savedVehicles.isNotEmpty) ...[
            if (_loadingVehicles)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              _buildSavedVehiclesList(),
          ] else ...[
            // Car Brand Dropdown
            _buildDropdownCard(
              icon: Icons.directions_car,
              label: 'Car Brand',
              hint: 'Select Brand',
              value: selectedBrandId,
              items: carBrands
                  .map((brand) => DropdownMenuItem(
                        value: brand.id,
                        child: Row(
                          children: [
                            Icon(Icons.directions_car,
                                size: 20, color: Colors.red.shade700),
                            const SizedBox(width: 12),
                            Text(brand.name),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedBrandId = value;
                  selectedModelId = null;
                  selectedEngine = null;
                  selectedYear = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // Car Model Dropdown
            _buildDropdownCard(
              icon: Icons.model_training,
              label: 'Car Model',
              hint:
                  selectedBrandId == null ? 'Select Brand First' : 'Select Model',
              value: selectedModelId,
              enabled: selectedBrandId != null,
              items: selectedBrandId != null
                  ? carBrands
                      .firstWhere((b) => b.id == selectedBrandId)
                      .models
                      .map((model) => DropdownMenuItem(
                            value: model.id,
                            child: Text(model.name),
                          ))
                      .toList()
                  : [],
              onChanged: (value) {
                setState(() {
                  selectedModelId = value;
                  selectedEngine = null;
                  selectedYear = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // Engine Type Dropdown
            _buildDropdownCard(
              icon: Icons.settings,
              label: 'Engine Type',
              hint: selectedModelId == null
                  ? 'Select Model First'
                  : 'Select Engine',
              value: selectedEngine,
              enabled: selectedModelId != null,
              items: selectedModelId != null
                  ? carBrands
                      .firstWhere((b) => b.id == selectedBrandId)
                      .models
                      .firstWhere((m) => m.id == selectedModelId)
                      .engines
                      .map((engine) => DropdownMenuItem(
                            value: engine,
                            child: Text(engine),
                          ))
                      .toList()
                  : [],
              onChanged: (value) {
                setState(() {
                  selectedEngine = value;
                  selectedYear = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // Year Dropdown
            _buildDropdownCard(
              icon: Icons.calendar_today,
              label: 'Year',
              hint:
                  selectedEngine == null ? 'Select Engine First' : 'Select Year',
              value: selectedYear?.toString(),
              enabled: selectedEngine != null,
              items: selectedEngine != null
                  ? carBrands
                      .firstWhere((b) => b.id == selectedBrandId)
                      .models
                      .firstWhere((m) => m.id == selectedModelId)
                      .years
                      .map((year) => DropdownMenuItem(
                            value: year.toString(),
                            child: Text(year.toString()),
                          ))
                      .toList()
                  : [],
              onChanged: (value) {
                setState(() {
                  selectedYear = int.tryParse(value!);
                });
                if (_isComplete()) {
                  _notifySelection();
                }
              },
            ),
          ],
          const SizedBox(height: 32),

          // Selected Car Summary
          if (_isComplete()) ...[
            _buildCarSummary(),
          ],
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _useSavedVehicle = true;
                  if (_selectedSavedVehicle != null) {
                    _selectSavedVehicle(_selectedSavedVehicle!);
                  } else {
                    _notifySelection();
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _useSavedVehicle ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _useSavedVehicle
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Saved Vehicles',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _useSavedVehicle ? Colors.red.shade700 : Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _useSavedVehicle = false;
                  _notifySelection();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: !_useSavedVehicle ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: !_useSavedVehicle
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Manual Entry',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: !_useSavedVehicle ? Colors.red.shade700 : Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedVehiclesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _savedVehicles.length,
      itemBuilder: (context, index) {
        final vehicle = _savedVehicles[index];
        final isSelected = _selectedSavedVehicle?.id == vehicle.id;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _selectSavedVehicle(vehicle),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.red.shade50.withValues(alpha: 0.4) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? Colors.red.shade600 : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? Colors.red.shade900.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red.shade100 : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.directions_car_filled,
                      color: isSelected ? Colors.red.shade700 : Colors.grey.shade600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.red.shade900 : Colors.black87,
                                ),
                              ),
                            ),
                            if (vehicle.isPrimary) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.green.shade300, width: 0.5),
                                ),
                                child: Text(
                                  'Primary',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${vehicle.engine ?? "No Engine Details"} • ${vehicle.licensePlate ?? "No License Plate"}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? Colors.red.shade800.withValues(alpha: 0.7) : Colors.grey.shade600,
                          ),
                        ),
                        if (vehicle.color != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Color: ${vehicle.color}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.red.shade800.withValues(alpha: 0.6) : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.red.shade700 : Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdownCard({
    required IconData icon,
    required String label,
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: value,
              hint: Text(
                hint,
                style: TextStyle(color: Colors.grey.shade400),
              ),
              isExpanded: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: true,
                fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                enabled: enabled,
              ),
              items: items,
              onChanged: enabled ? onChanged : null,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: enabled ? Colors.red.shade700 : Colors.grey.shade400,
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarSummary() {
    final String make;
    final String modelName;
    final String engine;
    final int year;

    if (_useSavedVehicle && _selectedSavedVehicle != null) {
      make = _selectedSavedVehicle!.make;
      modelName = _selectedSavedVehicle!.model;
      engine = _selectedSavedVehicle!.engine ?? 'N/A';
      year = _selectedSavedVehicle!.year;
    } else {
      final brand = carBrands.firstWhere((b) => b.id == selectedBrandId);
      final model = brand.models.firstWhere((m) => m.id == selectedModelId);
      make = brand.name;
      modelName = model.name;
      engine = selectedEngine!;
      year = selectedYear!;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade500, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vehicle Selected',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$make $modelName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$engine • $year',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isComplete() {
    if (_useSavedVehicle) {
      return _selectedSavedVehicle != null;
    }
    return selectedBrandId != null &&
        selectedModelId != null &&
        selectedEngine != null &&
        selectedYear != null;
  }

  void _notifySelection() {
    if (_useSavedVehicle && _selectedSavedVehicle != null) {
      widget.onCarSelected(SelectedCar(
        brand: _selectedSavedVehicle!.make,
        model: _selectedSavedVehicle!.model,
        engine: _selectedSavedVehicle!.engine ?? 'N/A',
        year: _selectedSavedVehicle!.year,
        customerVehicleId: _selectedSavedVehicle!.id,
      ));
    } else if (_isComplete()) {
      final brand = carBrands.firstWhere((b) => b.id == selectedBrandId);
      final model = brand.models.firstWhere((m) => m.id == selectedModelId);

      widget.onCarSelected(SelectedCar(
        brand: brand.name,
        model: model.name,
        engine: selectedEngine!,
        year: selectedYear!,
      ));
    }
  }
}
