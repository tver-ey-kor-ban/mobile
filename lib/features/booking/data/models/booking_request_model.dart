/// Model for creating a unified booking (service + products)
/// POST /api/v1/product-orders/unified-booking
class UnifiedBookingRequest {
  final int shopId;
  final int? customerVehicleId;
  final String? vehicleInfo;
  final int? serviceId;
  final String? serviceNotes;
  final DateTime appointmentDate;
  final List<ProductItem> productItems;
  final String? productNotes;
  final DateTime? pickupDate;
  final String? customerAddress;
  final String? customerPhone;
  final double? customerLocationLat;
  final double? customerLocationLng;
  final String? notes;

  UnifiedBookingRequest({
    required this.shopId,
    this.customerVehicleId,
    this.vehicleInfo,
    this.serviceId,
    this.serviceNotes,
    required this.appointmentDate,
    this.productItems = const [],
    this.productNotes,
    this.pickupDate,
    this.customerAddress,
    this.customerPhone,
    this.customerLocationLat,
    this.customerLocationLng,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'shop_id': shopId,
      'vehicle_info': vehicleInfo,
      'service_id': serviceId,
      'service_notes': serviceNotes,
      'appointment_date': appointmentDate.toUtc().toIso8601String(),
      'product_items': productItems.map((item) => item.toJson()).toList(),
      'product_notes': productNotes,
      'pickup_date': pickupDate?.toUtc().toIso8601String(),
      'customer_address': customerAddress,
      'customer_phone': customerPhone,
      'customer_location_lat': customerLocationLat,
      'customer_location_lng': customerLocationLng,
      'notes': notes,
    };

    // Only include customer_vehicle_id if it's provided (saved vehicle selected)
    if (customerVehicleId != null) {
      json['customer_vehicle_id'] = customerVehicleId;
    }

    return json;
  }
}

class ProductItem {
  final int productId;
  final int quantity;

  ProductItem({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
    };
  }
}

/// Model for creating a simple product order
/// POST /api/v1/product-orders
class ProductOrderRequest {
  final int shopId;
  final int customerVehicleId;
  final List<ProductItem> items;
  final DateTime? pickupDate;
  final String? notes;

  ProductOrderRequest({
    required this.shopId,
    required this.customerVehicleId,
    required this.items,
    this.pickupDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'shop_id': shopId,
      'customer_vehicle_id': customerVehicleId,
      'items': items.map((item) => item.toJson()).toList(),
      'pickup_date': pickupDate?.toUtc().toIso8601String(),
      'notes': notes,
    };
  }
}

/// Response model for booking creation
class BookingResponse {
  final int id;
  final String status;
  final String? message;
  final DateTime? createdAt;
  final Map<String, dynamic>? data;

  BookingResponse({
    required this.id,
    required this.status,
    this.message,
    this.createdAt,
    this.data,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      id: json['id'] ?? json['order_id'] ?? 0,
      status: json['status'] ?? 'pending',
      message: json['message'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      data: json,
    );
  }
}
