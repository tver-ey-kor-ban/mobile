class MechanicCustomer {
  final int id;
  final String name;
  final String phone;

  MechanicCustomer({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory MechanicCustomer.fromJson(Map<String, dynamic> json) {
    return MechanicCustomer(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['full_name'] ?? 'Unknown',
      phone: json['phone'] ?? json['username'] ?? '',
    );
  }
}

class MechanicBookingModel {
  final int appointmentId;
  final MechanicCustomer? customer;
  final String vehicleInfo;
  final String appointmentDate;
  final double totalAmount;
  final String? notes;
  final String status;
  final String? serviceName;

  MechanicBookingModel({
    required this.appointmentId,
    this.customer,
    required this.vehicleInfo,
    required this.appointmentDate,
    required this.totalAmount,
    this.notes,
    required this.status,
    this.serviceName,
  });

  factory MechanicBookingModel.fromJson(Map<String, dynamic> json) {
    return MechanicBookingModel(
      appointmentId: json['appointment_id'] ?? json['id'] ?? 0,
      customer: json['customer'] != null
          ? MechanicCustomer.fromJson(json['customer'])
          : null,
      vehicleInfo: json['vehicle_info'] ?? '',
      appointmentDate: json['appointment_date'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      notes: json['notes'],
      status: json['status'] ?? 'pending',
      serviceName: json['service_name'] ?? json['service']?['name'],
    );
  }
}

class MechanicOrderModel {
  final int id;
  final int? customerId;
  final String? customerName;
  final double totalAmount;
  final String status;
  final String createdAt;
  final List<Map<String, dynamic>> items;

  MechanicOrderModel({
    required this.id,
    this.customerId,
    this.customerName,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.items = const [],
  });

  factory MechanicOrderModel.fromJson(Map<String, dynamic> json) {
    return MechanicOrderModel(
      id: json['id'] ?? 0,
      customerId: json['customer_id'],
      customerName:
          json['customer_name'] ?? json['customer']?['name'] ?? 'Unknown',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [],
    );
  }
}

class MyShopModel {
  final int shopId;
  final String shopName;
  final String role;
  final bool isActive;

  MyShopModel({
    required this.shopId,
    required this.shopName,
    required this.role,
    required this.isActive,
  });

  factory MyShopModel.fromJson(Map<String, dynamic> json) {
    return MyShopModel(
      shopId: json['shop_id'] ?? 0,
      shopName: json['shop_name'] ?? '',
      role: json['role'] ?? 'mechanic',
      isActive: json['is_active'] ?? true,
    );
  }
}
