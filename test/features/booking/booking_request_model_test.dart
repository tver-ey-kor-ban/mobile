import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/booking/data/models/booking_request_model.dart';

void main() {
  group('UnifiedBookingRequest', () {
    test('toJson includes all fields when provided', () {
      final request = UnifiedBookingRequest(
        shopId: 1,
        customerVehicleId: 5,
        vehicleInfo: 'Toyota Camry 2.5L (2020)',
        serviceId: 10,
        serviceNotes: 'Oil change service',
        appointmentDate: DateTime(2026, 4, 10, 10, 30),
        productItems: [ProductItem(productId: 1, quantity: 2)],
        customerPhone: '0123456789',
        notes: 'Additional notes',
      );

      final json = request.toJson();

      expect(json['shop_id'], 1);
      expect(json['customer_vehicle_id'], 5);
      expect(json['vehicle_info'], 'Toyota Camry 2.5L (2020)');
      expect(json['service_id'], 10);
      expect(json['service_notes'], 'Oil change service');
      expect(json['customer_phone'], '0123456789');
      expect(json['notes'], 'Additional notes');
      expect(json['product_items'], isA<List>());
      expect((json['product_items'] as List).length, 1);
    });

    test('toJson excludes customer_vehicle_id when null (new vehicle)', () {
      final request = UnifiedBookingRequest(
        shopId: 1,
        customerVehicleId: null, // New vehicle - not saved
        vehicleInfo: 'Honda Civic 1.8L (2019)',
        appointmentDate: DateTime(2026, 4, 10, 10, 30),
      );

      final json = request.toJson();

      expect(json['shop_id'], 1);
      expect(json.containsKey('customer_vehicle_id'), false);
      expect(json['vehicle_info'], 'Honda Civic 1.8L (2019)');
    });

    test('toJson formats dates correctly', () {
      final appointmentDate = DateTime(2026, 4, 10, 10, 30);
      final pickupDate = DateTime(2026, 4, 10, 14, 0);

      final request = UnifiedBookingRequest(
        shopId: 1,
        appointmentDate: appointmentDate,
        pickupDate: pickupDate,
      );

      final json = request.toJson();

      expect(json['appointment_date'], '2026-04-10T03:30:00.000Z');
      expect(json['pickup_date'], '2026-04-10T07:00:00.000Z');
    });

    test('productItems defaults to empty list', () {
      final request = UnifiedBookingRequest(
        shopId: 1,
        appointmentDate: DateTime.now(),
      );

      final json = request.toJson();

      expect(json['product_items'], isA<List>());
      expect((json['product_items'] as List).isEmpty, true);
    });
  });

  group('ProductItem', () {
    test('toJson returns correct map', () {
      final item = ProductItem(productId: 5, quantity: 3);

      final json = item.toJson();

      expect(json['product_id'], 5);
      expect(json['quantity'], 3);
    });
  });

  group('ProductOrderRequest', () {
    test('toJson includes all fields', () {
      final request = ProductOrderRequest(
        shopId: 1,
        customerVehicleId: 5,
        items: [ProductItem(productId: 1, quantity: 2)],
        pickupDate: DateTime(2026, 4, 10, 14, 0),
        notes: 'Order notes',
      );

      final json = request.toJson();

      expect(json['shop_id'], 1);
      expect(json['customer_vehicle_id'], 5);
      expect(json['items'], isA<List>());
      expect(json['notes'], 'Order notes');
    });

    test('toJson handles null pickupDate', () {
      final request = ProductOrderRequest(
        shopId: 1,
        customerVehicleId: 5,
        items: [],
      );

      final json = request.toJson();

      expect(json['pickup_date'], null);
    });
  });

  group('BookingResponse', () {
    test('fromJson parses correctly with id field', () {
      final json = {
        'id': 123,
        'status': 'confirmed',
        'message': 'Booking created successfully',
        'created_at': '2026-04-05T10:30:00Z',
      };

      final response = BookingResponse.fromJson(json);

      expect(response.id, 123);
      expect(response.status, 'confirmed');
      expect(response.message, 'Booking created successfully');
      expect(response.createdAt, isNotNull);
    });

    test('fromJson parses correctly with order_id field', () {
      final json = {
        'order_id': 456,
        'status': 'pending',
      };

      final response = BookingResponse.fromJson(json);

      expect(response.id, 456);
      expect(response.status, 'pending');
    });

    test('fromJson uses defaults for missing fields', () {
      final json = <String, dynamic>{};

      final response = BookingResponse.fromJson(json);

      expect(response.id, 0);
      expect(response.status, 'pending');
      expect(response.message, null);
      expect(response.createdAt, null);
    });
  });
}
