class ApiConstants {
  static const String baseUrl = 'https://backend-1-qgqd.onrender.com';
  static const String apiVersion = '/api/v1';

  // Auth
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String refreshToken = '$apiVersion/auth/refresh';
  static const String logout = '$apiVersion/auth/logout';
  static const String logoutAll = '$apiVersion/auth/logout-all';
  static const String currentUser = '$apiVersion/auth/me';
  static const String userRoles = '$apiVersion/auth/me/roles';

  // Shops
  static const String shops = '$apiVersion/shops';
  static const String myShops = '$apiVersion/shops/my-shops';
  static String shopById(int id) => '$apiVersion/shops/$id';
  static String shopMembers(int shopId) => '$apiVersion/shops/$shopId/members';
  static String shopMember(int shopId, int userId) =>
      '$apiVersion/shops/$shopId/members/$userId';

  // Shop Products
  static String shopProducts(int shopId) =>
      '$apiVersion/shops/$shopId/products';
  static String shopProduct(int shopId, int productId) =>
      '$apiVersion/shops/$shopId/products/$productId';
  static String shopProductsSearch(int shopId) =>
      '$apiVersion/shops/$shopId/products/search';

  // Shop Services
  static String shopServices(int shopId) =>
      '$apiVersion/shops/$shopId/services';
  static String shopService(int shopId, int serviceId) =>
      '$apiVersion/shops/$shopId/services/$serviceId';

  // Browse (public)
  static String browseProducts(int shopId) =>
      '$apiVersion/customers/shops/$shopId/browse/products';
  static String browseServices(int shopId) =>
      '$apiVersion/customers/shops/$shopId/browse/services';
  static String browseShopInfo(int shopId) =>
      '$apiVersion/customers/shops/$shopId/browse/shop-info';

  // Categories
  static const String categories = '$apiVersion/categories';
  static String categoryById(int id) => '$apiVersion/categories/$id';

  // Vehicle Database (public)
  static const String vehicleMakes = '$apiVersion/vehicles/makes';
  static String vehicleModels(int makeId) =>
      '$apiVersion/vehicles/makes/$makeId/models';
  static String vehicleYears(int modelId) =>
      '$apiVersion/vehicles/models/$modelId/years';
  static String vehicleEngines(int yearId) =>
      '$apiVersion/vehicles/years/$yearId/engines';

  // Customer Vehicles
  static const String myVehicles = '$apiVersion/my-vehicles';
  static String myVehicleById(int id) => '$apiVersion/my-vehicles/$id';
  static String setVehiclePrimary(int id) =>
      '$apiVersion/my-vehicles/$id/set-primary';
  static const String primaryVehicle = '$apiVersion/my-vehicles/primary';

  // Unified Booking & Product Orders
  static const String unifiedBooking =
      '$apiVersion/product-orders/unified-booking';
  static const String calculatePrice =
      '$apiVersion/product-orders/calculate-price';
  static const String myOrders = '$apiVersion/product-orders/my-orders';
  static String myOrderById(int id) =>
      '$apiVersion/product-orders/my-orders/$id';
  static String cancelMyOrder(int id) =>
      '$apiVersion/product-orders/my-orders/$id/cancel';
  static String shopOrders(int shopId) =>
      '$apiVersion/product-orders/shops/$shopId/orders';
  static String updateOrderStatus(int shopId, int orderId) =>
      '$apiVersion/product-orders/shops/$shopId/orders/$orderId/status';

  // Customer Appointments
  static const String myAppointments = '$apiVersion/customers/my-appointments';
  static String myAppointmentById(int id) =>
      '$apiVersion/customers/my-appointments/$id';
  static String cancelAppointment(int id) =>
      '$apiVersion/customers/my-appointments/$id/cancel';
  static const String myServiceHistory =
      '$apiVersion/customers/my-service-history';
  static String shopAppointments(int shopId) =>
      '$apiVersion/customers/shops/$shopId/appointments';
  static String updateAppointmentStatus(int shopId, int apptId) =>
      '$apiVersion/customers/shops/$shopId/appointments/$apptId/status';

  // Notifications
  static const String myNotifications = '$apiVersion/mechanic/my-notifications';
  static String markNotificationRead(int id) =>
      '$apiVersion/mechanic/notifications/$id/read';

  // Mechanic Bookings
  static String pendingBookings(int shopId) =>
      '$apiVersion/mechanic/shops/$shopId/pending-bookings';
  static String mechanicBookingDetail(int shopId, int apptId) =>
      '$apiVersion/mechanic/shops/$shopId/bookings/$apptId';
  static String mechanicBookingAction(int shopId, int apptId) =>
      '$apiVersion/mechanic/shops/$shopId/bookings/$apptId/action';
  static String todayBookings(int shopId) =>
      '$apiVersion/mechanic/shops/$shopId/today-bookings';

  // Mechanic Orders
  static String pendingOrders(int shopId) =>
      '$apiVersion/mechanic/shops/$shopId/pending-orders';
  static String mechanicOrderAction(int shopId, int orderId) =>
      '$apiVersion/mechanic/shops/$shopId/orders/$orderId/action';
  static String markOrderReady(int shopId, int orderId) =>
      '$apiVersion/mechanic/shops/$shopId/orders/$orderId/ready';

  // Repair Progress
  static const String myRepairs = '$apiVersion/repair-progress/my-repairs';
  static String myRepairById(int id) =>
      '$apiVersion/repair-progress/my-repairs/$id';
  static String shopRepairs(int shopId) =>
      '$apiVersion/repair-progress/shops/$shopId';
  static String createRepair(int shopId) =>
      '$apiVersion/repair-progress/shops/$shopId';
  static String updateRepair(int shopId, int progressId) =>
      '$apiVersion/repair-progress/shops/$shopId/$progressId';

  // Quotations
  static const String myQuotations = '$apiVersion/quotations/my-quotations';
  static String myQuotationById(int id) =>
      '$apiVersion/quotations/my-quotations/$id';
  static String quotationAction(int id) =>
      '$apiVersion/quotations/my-quotations/$id/action';
  static String shopQuotations(int shopId) =>
      '$apiVersion/quotations/shops/$shopId';
  static String shopQuotationById(int shopId, int id) =>
      '$apiVersion/quotations/shops/$shopId/$id';
  static String sendQuotation(int shopId, int id) =>
      '$apiVersion/quotations/shops/$shopId/$id/send';

  // Invoices
  static const String myInvoices = '$apiVersion/invoices/my-invoices';
  static String myInvoiceById(int id) =>
      '$apiVersion/invoices/my-invoices/$id';
  static String shopInvoices(int shopId) =>
      '$apiVersion/invoices/shops/$shopId';
  static String shopInvoiceById(int shopId, int id) =>
      '$apiVersion/invoices/shops/$shopId/$id';
  static String sendInvoice(int shopId, int id) =>
      '$apiVersion/invoices/shops/$shopId/$id/send';
  static String recordPayment(int shopId, int id) =>
      '$apiVersion/invoices/shops/$shopId/$id/payments';

  // Ratings
  static String rateProduct(int productId) =>
      '$apiVersion/ratings/products/$productId';
  static String rateService(int serviceId) =>
      '$apiVersion/ratings/services/$serviceId';
  static String rateMechanic(int shopId, int mechanicId) =>
      '$apiVersion/shops/$shopId/mechanics/$mechanicId/rate';
  static String getProductRatings(int productId) =>
      '$apiVersion/ratings/products/$productId/reviews';
  static String getServiceRatings(int serviceId) =>
      '$apiVersion/ratings/services/$serviceId/reviews';

  // Mechanic Performance
  static String shopMechanicsPerformance(int shopId) =>
      '$apiVersion/shops/$shopId/mechanics/performance';
  static String myPerformance(int shopId) =>
      '$apiVersion/shops/$shopId/mechanics/my-performance';
  static String mechanicPerformance(int shopId, int mechanicId) =>
      '$apiVersion/shops/$shopId/mechanics/$mechanicId/performance';

  // Chat
  static const String chatRooms = '$apiVersion/chat/rooms';
  static String chatRoom(int roomId) => '$apiVersion/chat/rooms/$roomId';
  static String sendMessage(int roomId) =>
      '$apiVersion/chat/rooms/$roomId/messages';

  // Search
  static String searchByImage(int shopId) =>
      '$apiVersion/shops/$shopId/products/search-by-image';
}
