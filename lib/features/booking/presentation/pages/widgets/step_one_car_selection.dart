import 'package:flutter/material.dart';
import '../../../domain/models/car_model.dart';

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
  String? selectedBrandId;
  String? selectedModelId;
  String? selectedEngine;
  int? selectedYear;

  @override
  void initState() {
    super.initState();
    if (widget.initialCar != null) {
      final car = widget.initialCar!;
      final brand = carBrands.firstWhere((b) => b.name == car.brand);
      final model = brand.models.firstWhere((m) => m.name == car.model);
      selectedBrandId = brand.id;
      selectedModelId = model.id;
      selectedEngine = car.engine;
      selectedYear = car.year;
    }
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
          const SizedBox(height: 32),

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
          const SizedBox(height: 32),

          // Selected Car Summary
          if (_isComplete()) ...[
            _buildCarSummary(),
          ],
        ],
      ),
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
          // Label
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
          // Dropdown
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
    final brand = carBrands.firstWhere((b) => b.id == selectedBrandId);
    final model = brand.models.firstWhere((m) => m.id == selectedModelId);

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
                  '${brand.name} ${model.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${selectedEngine!} • ${selectedYear!}',
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
    return selectedBrandId != null &&
        selectedModelId != null &&
        selectedEngine != null &&
        selectedYear != null;
  }

  void _notifySelection() {
    if (_isComplete()) {
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
