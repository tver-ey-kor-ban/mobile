class AppointmentModel {
  final int id;
  final int? serviceId;
  final String? serviceName;
  final String? shopName;
  final int? shopId;
  final String appointmentDate;
  final String status;
  final String? vehicleInfo;
  final String? notes;
  final double? totalAmount;
  final String createdAt;

  AppointmentModel({
    required this.id,
    this.serviceId,
    this.serviceName,
    this.shopName,
    this.shopId,
    required this.appointmentDate,
    required this.status,
    this.vehicleInfo,
    this.notes,
    this.totalAmount,
    required this.createdAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? 0,
      serviceId: json['service_id'],
      serviceName: json['service_name'] ?? json['service']?['name'],
      shopName: json['shop_name'] ?? json['shop']?['name'],
      shopId: json['shop_id'],
      appointmentDate: json['appointment_date'] ?? '',
      status: json['status'] ?? 'pending',
      vehicleInfo: json['vehicle_info'],
      notes: json['notes'] ?? json['service_notes'],
      totalAmount: (json['total_amount'] ?? json['pricing']?['total'])
          ?.toDouble(),
      createdAt: json['created_at'] ?? '',
    );
  }
}
