class ApiConstants {
  static const String baseUrl = 'https://backend-1-qgqd.onrender.com';
  static const String apiVersion = '/api/v1';

  // Auth endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String refreshToken = '$apiVersion/auth/refresh';
  static const String logout = '$apiVersion/auth/logout';
  static const String me = '$apiVersion/auth/me';

  // Booking endpoints
  static const String productOrders = '$apiVersion/product-orders';
  static const String unifiedBooking =
      '$apiVersion/product-orders/unified-booking';

  // Service endpoints
  static const String services = '$apiVersion/services';
  static const String shops = '$apiVersion/shops';

  // Vehicle endpoints
  static const String vehicles = '$apiVersion/vehicles';
  static const String customerVehicles = '$apiVersion/customer-vehicles';
}
