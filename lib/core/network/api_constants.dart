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
  static const String userRoles = '$apiVersion/auth/me/roles';

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
  static const String myVehicles = '$apiVersion/my-vehicles';
  static String myVehicleDetail(int id) => '$apiVersion/my-vehicles/$id';
  static String setPrimaryVehicle(int id) => '$apiVersion/my-vehicles/$id/set-primary';
  static const String primaryVehicle = '$apiVersion/my-vehicles/primary';
  static const String vehicleMakes = '$apiVersion/vehicles/makes';
  static const String vehicleModels = '$apiVersion/vehicles/models';

  // Rating Endpoints
  static String rateProduct(int productId) => '$apiVersion/ratings/products/$productId';
  static String rateService(int serviceId) => '$apiVersion/ratings/services/$serviceId';
  static String rateMechanic(int mechanicId) => '$apiVersion/ratings/mechanics/$mechanicId';
  static String getProductRatings(int productId) => '$apiVersion/ratings/products/$productId';
  static String getServiceRatings(int serviceId) => '$apiVersion/ratings/services/$serviceId';
}
