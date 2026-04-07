import 'api_config.dart';

/// API Constants for the application
/// Endpoints are built using the ApiConfig which loads from .env file
class ApiConstants {
  /// Base URL for the backend API (loaded from .env)
  static String get baseUrl => ApiConfig.baseUrl;

  /// API Version (loaded from .env)
  static String get apiVersion => ApiConfig.apiVersion;

  // Auth Endpoints
  static String get login => '$apiVersion/auth/login';
  static String get register => '$apiVersion/auth/register';
  static String get refreshToken => '$apiVersion/auth/refresh';
  static String get currentUser => '$apiVersion/auth/me';
  static String get userRoles => '$apiVersion/auth/me/roles';

  // Booking Endpoints
  static String get productOrders => '$apiVersion/product-orders';
  static String get unifiedBooking => '$apiVersion/product-orders/unified-booking';

  // Search Endpoints
  static String get searchByImage => '$apiVersion/search/image';
  static String get searchProducts => '$apiVersion/products/search';

  // Shop Endpoints
  static String get shops => '$apiVersion/shops';
  static String get shopDetails => '$apiVersion/shops/';

  // Vehicle Endpoints
  static String get customerVehicles => '$apiVersion/customer-vehicles';
  static String get vehicleMakes => '$apiVersion/vehicles/makes';
  static String get vehicleModels => '$apiVersion/vehicles/models';

  // Ratings Endpoints
  static String get ratings => '$apiVersion/ratings';
  static String rateProduct(int productId) => '$apiVersion/ratings/products/$productId';
  static String rateService(int serviceId) => '$apiVersion/ratings/services/$serviceId';
  static String rateMechanic(int mechanicId) => '$apiVersion/ratings/mechanics/$mechanicId';
  static String getProductRatings(int productId) => '$apiVersion/ratings/products/$productId';
  static String getServiceRatings(int serviceId) => '$apiVersion/ratings/services/$serviceId';
}
