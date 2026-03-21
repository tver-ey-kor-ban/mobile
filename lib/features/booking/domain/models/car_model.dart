class CarBrand {
  final String id;
  final String name;
  final String logoUrl;
  final List<CarModel> models;

  const CarBrand({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.models,
  });
}

class CarModel {
  final String id;
  final String name;
  final List<String> engines;
  final List<int> years;

  const CarModel({
    required this.id,
    required this.name,
    required this.engines,
    required this.years,
  });
}

class SelectedCar {
  final String brand;
  final String model;
  final String engine;
  final int year;

  const SelectedCar({
    required this.brand,
    required this.model,
    required this.engine,
    required this.year,
  });

  String get displayName => '$brand $model $engine ($year)';
}

// Sample car data
final List<CarBrand> carBrands = [
  CarBrand(
    id: 'toyota',
    name: 'Toyota',
    logoUrl: 'https://logo.clearbit.com/toyota.com',
    models: [
      CarModel(
        id: 'camry',
        name: 'Camry',
        engines: ['2.0L', '2.5L', 'Hybrid'],
        years: List.generate(15, (i) => 2010 + i),
      ),
      CarModel(
        id: 'corolla',
        name: 'Corolla',
        engines: ['1.6L', '1.8L', 'Hybrid'],
        years: List.generate(15, (i) => 2010 + i),
      ),
      CarModel(
        id: 'hilux',
        name: 'Hilux',
        engines: ['2.4L Diesel', '2.8L Diesel'],
        years: List.generate(15, (i) => 2010 + i),
      ),
      CarModel(
        id: 'fortuner',
        name: 'Fortuner',
        engines: ['2.4L Diesel', '2.8L Diesel', '2.7L Petrol'],
        years: List.generate(15, (i) => 2010 + i),
      ),
    ],
  ),
  CarBrand(
    id: 'honda',
    name: 'Honda',
    logoUrl: 'https://logo.clearbit.com/honda.com',
    models: [
      CarModel(
        id: 'civic',
        name: 'Civic',
        engines: ['1.5L Turbo', '1.8L', '2.0L'],
        years: List.generate(15, (i) => 2010 + i),
      ),
      CarModel(
        id: 'accord',
        name: 'Accord',
        engines: ['1.5L Turbo', '2.0L Turbo', 'Hybrid'],
        years: List.generate(15, (i) => 2010 + i),
      ),
      CarModel(
        id: 'crv',
        name: 'CR-V',
        engines: ['1.5L Turbo', '2.0L Hybrid'],
        years: List.generate(15, (i) => 2010 + i),
      ),
    ],
  ),
  CarBrand(
    id: 'ford',
    name: 'Ford',
    logoUrl: 'https://logo.clearbit.com/ford.com',
    models: [
      CarModel(
        id: 'ranger',
        name: 'Ranger',
        engines: ['2.0L Diesel', '2.0L Bi-Turbo', '3.0L V6'],
        years: List.generate(15, (i) => 2010 + i),
      ),
      CarModel(
        id: 'everest',
        name: 'Everest',
        engines: ['2.0L Diesel', '3.0L V6'],
        years: List.generate(15, (i) => 2010 + i),
      ),
    ],
  ),
  CarBrand(
    id: 'lexus',
    name: 'Lexus',
    logoUrl: 'https://logo.clearbit.com/lexus.com',
    models: [
      CarModel(
        id: 'rx',
        name: 'RX',
        engines: ['RX 350', 'RX 450h Hybrid'],
        years: List.generate(15, (i) => 2010 + i),
      ),
      CarModel(
        id: 'nx',
        name: 'NX',
        engines: ['NX 250', 'NX 350', 'NX 450h+'],
        years: List.generate(12, (i) => 2014 + i),
      ),
    ],
  ),
  CarBrand(
    id: 'hyundai',
    name: 'Hyundai',
    logoUrl: 'https://logo.clearbit.com/hyundai.com',
    models: [
      CarModel(
        id: 'tucson',
        name: 'Tucson',
        engines: ['2.0L', '1.6L Turbo', 'Hybrid'],
        years: List.generate(15, (i) => 2010 + i),
      ),
      CarModel(
        id: 'santafe',
        name: 'Santa Fe',
        engines: ['2.2L Diesel', '2.5L', 'Hybrid'],
        years: List.generate(15, (i) => 2010 + i),
      ),
    ],
  ),
];
