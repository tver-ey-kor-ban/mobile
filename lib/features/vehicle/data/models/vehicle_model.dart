/// Model for creating a new vehicle
/// POST /api/v1/my-vehicles
class CreateVehicleRequest {
  final String make;
  final String model;
  final int year;
  final String? engine;
  final String? fuelType;
  final String? transmission;
  final String? licensePlate;
  final String? vin;
  final String? color;
  final String? nickname;
  final bool isPrimary;
  final bool isActive;

  CreateVehicleRequest({
    required this.make,
    required this.model,
    required this.year,
    this.engine,
    this.fuelType,
    this.transmission,
    this.licensePlate,
    this.vin,
    this.color,
    this.nickname,
    this.isPrimary = false,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'engine': engine,
      'fuel_type': fuelType,
      'transmission': transmission,
      'license_plate': licensePlate,
      'vin': vin,
      'color': color,
      'nickname': nickname,
      'is_primary': isPrimary,
      'is_active': isActive,
    };
  }
}

/// Model for a vehicle response
class VehicleResponse {
  final int id;
  final String make;
  final String model;
  final int year;
  final String? engine;
  final String? fuelType;
  final String? transmission;
  final String? licensePlate;
  final String? vin;
  final String? color;
  final String? nickname;
  final bool isPrimary;
  final bool isActive;
  final DateTime createdAt;

  VehicleResponse({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.engine,
    this.fuelType,
    this.transmission,
    this.licensePlate,
    this.vin,
    this.color,
    this.nickname,
    required this.isPrimary,
    required this.isActive,
    required this.createdAt,
  });

  factory VehicleResponse.fromJson(Map<String, dynamic> json) {
    return VehicleResponse(
      id: json['id'] ?? 0,
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      engine: json['engine'],
      fuelType: json['fuel_type'],
      transmission: json['transmission'],
      licensePlate: json['license_plate'],
      vin: json['vin'],
      color: json['color'],
      nickname: json['nickname'],
      isPrimary: json['is_primary'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  String get displayName => nickname ?? '$make $model $year';
}

/// Model for list of vehicles response
class VehiclesListResponse {
  final List<VehicleResponse> vehicles;

  VehiclesListResponse({
    required this.vehicles,
  });

  factory VehiclesListResponse.fromJson(dynamic json) {
    List<dynamic> items;
    if (json is List) {
      // API returns direct array: []
      items = json;
    } else if (json is Map<String, dynamic>) {
      // API returns object with key: {items: []}
      items = json['items'] ?? json['data'] ?? json['vehicles'] ?? [];
    } else {
      items = [];
    }
    return VehiclesListResponse(
      vehicles: items
          .map((e) => VehicleResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
