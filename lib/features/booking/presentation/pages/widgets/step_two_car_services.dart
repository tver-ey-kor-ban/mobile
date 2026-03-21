import 'package:flutter/material.dart';
import '../../../domain/models/car_model.dart';
import '../../../domain/models/service_model.dart';

class StepTwoCarServices extends StatefulWidget {
  final SelectedCar selectedCar;
  final Function(List<CarService>, double) onServicesSelected;
  final List<String>? initiallySelectedServiceIds;

  const StepTwoCarServices({
    super.key,
    required this.selectedCar,
    required this.onServicesSelected,
    this.initiallySelectedServiceIds,
  });

  @override
  State<StepTwoCarServices> createState() => _StepTwoCarServicesState();
}

class _StepTwoCarServicesState extends State<StepTwoCarServices> {
  final Set<String> selectedServiceIds = {};
  List<CarService> availableServices = [];

  @override
  void initState() {
    super.initState();
    availableServices = getServicesForCar(
      widget.selectedCar.brand,
      widget.selectedCar.model,
    );
    if (widget.initiallySelectedServiceIds != null) {
      selectedServiceIds.addAll(widget.initiallySelectedServiceIds!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Car Info Header
        _buildCarInfoHeader(),
        const SizedBox(height: 20),

        // Section Title
        const Text(
          'Available Services',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select services for your ${widget.selectedCar.brand} ${widget.selectedCar.model}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),

        // Services List
        Expanded(
          child: ListView.builder(
            itemCount: availableServices.length,
            itemBuilder: (context, index) {
              final service = availableServices[index];
              return _buildServiceCard(service);
            },
          ),
        ),

        // Total Summary
        if (selectedServiceIds.isNotEmpty) ...[
          _buildTotalSummary(),
        ],
      ],
    );
  }

  Widget _buildCarInfoHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade700, Colors.red.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.selectedCar.brand} ${widget.selectedCar.model}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.selectedCar.engine} • ${widget.selectedCar.year}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(CarService service) {
    final isSelected = selectedServiceIds.contains(service.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.red.shade700 : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              selectedServiceIds.remove(service.id);
            } else {
              selectedServiceIds.add(service.id);
            }
          });
          _notifySelection();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Service Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getServiceIcon(service.icon),
                  color:
                      isSelected ? Colors.red.shade700 : Colors.grey.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Service Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(service.estimatedTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price and Checkbox
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${service.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.red.shade700 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color:
                          isSelected ? Colors.red.shade700 : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? Colors.red.shade700
                            : Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalSummary() {
    final selectedServices = availableServices
        .where((s) => selectedServiceIds.contains(s.id))
        .toList();
    final total = selectedServices.fold<double>(
      0,
      (sum, service) => sum + service.price,
    );
    final totalDuration = selectedServices.fold<Duration>(
      Duration.zero,
      (sum, service) => sum + service.estimatedTime,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${selectedServices.length} services selected',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                'Est. time: ${_formatDuration(totalDuration)}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getServiceIcon(String icon) {
    switch (icon) {
      case 'oil':
        return Icons.oil_barrel;
      case 'tire':
        return Icons.tire_repair;
      case 'brake':
        return Icons.car_crash;
      case 'air':
        return Icons.air;
      case 'battery':
        return Icons.battery_full;
      case 'ac':
        return Icons.ac_unit;
      case 'transmission':
        return Icons.settings;
      case 'alignment':
        return Icons.align_horizontal_center;
      case 'hybrid':
        return Icons.electric_car;
      case 'diesel':
        return Icons.local_gas_station;
      case 'detail':
        return Icons.auto_awesome;
      default:
        return Icons.build;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes} min';
  }

  void _notifySelection() {
    final selectedServices = availableServices
        .where((s) => selectedServiceIds.contains(s.id))
        .toList();
    final total = selectedServices.fold<double>(
      0,
      (sum, service) => sum + service.price,
    );
    widget.onServicesSelected(selectedServices, total);
  }
}
