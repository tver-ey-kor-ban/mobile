import 'package:flutter/material.dart';
import '../../../domain/models/car_model.dart';
import '../../../domain/models/service_model.dart';

class StepThreeConfirmation extends StatelessWidget {
  final SelectedCar selectedCar;
  final List<CarService> selectedServices;
  final double totalPrice;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final String? notes;

  const StepThreeConfirmation({
    super.key,
    required this.selectedCar,
    required this.selectedServices,
    required this.totalPrice,
    this.selectedDate,
    this.selectedTime,
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirm Your Booking',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review your booking details before confirming',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Vehicle Info Card
          _buildSection(
            title: 'Vehicle Information',
            icon: Icons.directions_car,
            child: _buildVehicleInfo(),
          ),
          const SizedBox(height: 16),

          // Selected Services
          _buildSection(
            title: 'Selected Services',
            icon: Icons.build,
            child: _buildServicesList(),
          ),
          const SizedBox(height: 16),

          // Appointment Time
          _buildSection(
            title: 'Appointment',
            icon: Icons.calendar_today,
            child: _buildAppointmentInfo(),
          ),
          const SizedBox(height: 16),

          // Notes
          if (notes != null && notes!.isNotEmpty)
            _buildSection(
              title: 'Additional Notes',
              icon: Icons.note,
              child: Text(notes!),
            ),

          const SizedBox(height: 24),

          // Total Summary
          _buildTotalSummary(),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildVehicleInfo() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.directions_car,
            size: 32,
            color: Colors.red.shade700,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${selectedCar.brand} ${selectedCar.model}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${selectedCar.engine} • ${selectedCar.year}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicesList() {
    final totalDuration = selectedServices.fold<Duration>(
      Duration.zero,
      (sum, service) => sum + service.estimatedTime,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...selectedServices.map((service) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDuration(service.estimatedTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${service.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${selectedServices.length} services',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              'Total time: ${_formatDuration(totalDuration)}',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppointmentInfo() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoItem(
            icon: Icons.calendar_today,
            label: 'Date',
            value: selectedDate != null
                ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                : 'Not selected',
          ),
        ),
        Expanded(
          child: _buildInfoItem(
            icon: Icons.access_time,
            label: 'Time',
            value: selectedTime != null
                ? '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                : 'Not selected',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade700, Colors.red.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Payment will be collected at the service center',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes} min';
  }
}
