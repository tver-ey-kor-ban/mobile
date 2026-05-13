class VehicleModel {
  final int id;
  final String make;
  final String model;
  final int year;
  final String? engine;
  final String? fuelType;
  final String? licensePlate;
  final String? color;
  final int? mileage;
  final bool isPrimary;

  VehicleModel({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.engine,
    this.fuelType,
    this.licensePlate,
    this.color,
    this.mileage,
    this.isPrimary = false,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? 0,
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      engine: json['engine'],
      fuelType: json['fuel_type'],
      licensePlate: json['license_plate'],
      color: json['color'],
      mileage: json['mileage'],
      isPrimary: json['is_primary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'make': make,
      'model': model,
      'year': year,
      if (engine != null) 'engine': engine,
      if (fuelType != null) 'fuel_type': fuelType,
      if (licensePlate != null) 'license_plate': licensePlate,
      if (color != null) 'color': color,
      if (mileage != null) 'mileage': mileage,
      'is_primary': isPrimary,
    };
  }

  String get displayName => '$year $make $model';
}
