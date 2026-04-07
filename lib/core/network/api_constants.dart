/// API Constants for the application
class ApiConstants {
  /// Base URL for the backend API
  static const String baseUrl = 'https://backend-1-qgqd.onrender.com';

  /// API Version
  static const String apiVersion = '/api/v1';

  // Auth Endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String refreshToken = '$apiVersion/auth/refresh';
  static const String currentUser = '$apiVersion/auth/me';

  // Booking Endpoints
  static const String productOrders = '$apiVersion/product-orders';
  static const String unifiedBooking =
      '$apiVersion/product-orders/unified-booking';

  // Search Endpoints
  static const String searchByImage = '$apiVersion/search/image';
  static const String searchProducts = '$apiVersion/products/search';

  // Shop Endpoints
  static const String shops = '$apiVersion/shops';
  static const String shopDetails = '$apiVersion/shops/';

  // Vehicle Endpoints
  static const String customerVehicles = '$apiVersion/customer-vehicles';
  static const String vehicleMakes = '$apiVersion/vehicles/makes';
  static const String vehicleModels = '$apiVersion/vehicles/models';
}
