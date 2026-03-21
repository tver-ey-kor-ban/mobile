class CarService {
  final String id;
  final String name;
  final String description;
  final double price;
  final Duration estimatedTime;
  final String icon;
  final List<String> compatibleBrands;
  final List<String>? compatibleModels;

  const CarService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.estimatedTime,
    required this.icon,
    required this.compatibleBrands,
    this.compatibleModels,
  });

  bool isCompatibleWith(String brand, String model) {
    if (!compatibleBrands.contains(brand)) return false;
    if (compatibleModels == null) return true;
    return compatibleModels!.contains(model);
  }
}

// Sample services data
final List<CarService> carServices = [
  // Common services for all brands
  const CarService(
    id: 'oil_change',
    name: 'Oil Change',
    description: 'Change engine oil and oil filter',
    price: 35.0,
    estimatedTime: Duration(minutes: 30),
    icon: 'oil',
    compatibleBrands: ['Toyota', 'Honda', 'Ford', 'Lexus', 'Hyundai'],
  ),
  const CarService(
    id: 'tire_rotation',
    name: 'Tire Rotation',
    description: 'Rotate tires for even wear',
    price: 25.0,
    estimatedTime: Duration(minutes: 20),
    icon: 'tire',
    compatibleBrands: ['Toyota', 'Honda', 'Ford', 'Lexus', 'Hyundai'],
  ),
  const CarService(
    id: 'brake_inspection',
    name: 'Brake Inspection',
    description: 'Inspect brake pads, rotors, and fluid',
    price: 45.0,
    estimatedTime: Duration(minutes: 45),
    icon: 'brake',
    compatibleBrands: ['Toyota', 'Honda', 'Ford', 'Lexus', 'Hyundai'],
  ),
  const CarService(
    id: 'air_filter',
    name: 'Air Filter Replacement',
    description: 'Replace engine air filter',
    price: 20.0,
    estimatedTime: Duration(minutes: 15),
    icon: 'air',
    compatibleBrands: ['Toyota', 'Honda', 'Ford', 'Lexus', 'Hyundai'],
  ),
  const CarService(
    id: 'battery_check',
    name: 'Battery Check & Service',
    description: 'Test battery and clean terminals',
    price: 15.0,
    estimatedTime: Duration(minutes: 15),
    icon: 'battery',
    compatibleBrands: ['Toyota', 'Honda', 'Ford', 'Lexus', 'Hyundai'],
  ),
  const CarService(
    id: 'ac_service',
    name: 'A/C Service',
    description: 'Check and recharge air conditioning',
    price: 85.0,
    estimatedTime: Duration(minutes: 60),
    icon: 'ac',
    compatibleBrands: ['Toyota', 'Honda', 'Ford', 'Lexus', 'Hyundai'],
  ),
  const CarService(
    id: 'transmission_service',
    name: 'Transmission Service',
    description: 'Change transmission fluid',
    price: 120.0,
    estimatedTime: Duration(minutes: 90),
    icon: 'transmission',
    compatibleBrands: ['Toyota', 'Honda', 'Ford', 'Lexus', 'Hyundai'],
  ),
  const CarService(
    id: 'wheel_alignment',
    name: 'Wheel Alignment',
    description: 'Align wheels for better handling',
    price: 65.0,
    estimatedTime: Duration(minutes: 60),
    icon: 'alignment',
    compatibleBrands: ['Toyota', 'Honda', 'Ford', 'Lexus', 'Hyundai'],
  ),
  // Brand-specific services
  const CarService(
    id: 'toyota_hybrid_check',
    name: 'Hybrid System Check',
    description: 'Specialized hybrid battery and system inspection',
    price: 95.0,
    estimatedTime: Duration(minutes: 45),
    icon: 'hybrid',
    compatibleBrands: ['Toyota', 'Lexus'],
    compatibleModels: ['Camry', 'Corolla', 'RX', 'NX'],
  ),
  const CarService(
    id: 'ford_diesel_service',
    name: 'Diesel Engine Service',
    description: 'Specialized diesel engine maintenance',
    price: 150.0,
    estimatedTime: Duration(minutes: 120),
    icon: 'diesel',
    compatibleBrands: ['Ford'],
    compatibleModels: ['Ranger', 'Everest'],
  ),
  const CarService(
    id: 'luxury_detail',
    name: 'Luxury Detail Package',
    description: 'Premium interior and exterior detailing',
    price: 200.0,
    estimatedTime: Duration(hours: 3),
    icon: 'detail',
    compatibleBrands: ['Lexus'],
  ),
];

// Get services for a specific car
List<CarService> getServicesForCar(String brand, String model) {
  return carServices
      .where((service) => service.isCompatibleWith(brand, model))
      .toList();
}
