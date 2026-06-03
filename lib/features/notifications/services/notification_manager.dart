import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../shared/services/auth_service.dart';
import '../../mechanic/presentation/pages/booking_detail_mechanic_page.dart';
import '../../mechanic/services/mechanic_api_service.dart';
import '../../appointments/presentation/pages/appointment_detail_page.dart';
import '../data/models/notification_model.dart';
import '../presentation/widgets/notification_popup_banner.dart';
import 'notification_api_service.dart';

class NotificationManager extends ChangeNotifier {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final _apiService = NotificationApiService();
  AuthService? _authService;
  Timer? _pollTimer;
  final Set<int> _seenNotificationIds = {};
  bool _isFirstFetch = true;
  
  late final FlutterLocalNotificationsPlugin _localNotificationsPlugin;

  NotificationManager() {
    _initLocalNotifications();
  }

  void _initLocalNotifications() async {
    _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          try {
            final appointmentId = int.tryParse(response.payload!);
            if (appointmentId != null) {
              final ctx = navigatorKey.currentContext;
              if (ctx != null) {
                handleNavigation(ctx, NotificationModel(
                  id: 0,
                  type: 'deep_link',
                  title: '',
                  message: '',
                  status: 'read',
                  createdAt: '',
                  appointmentId: appointmentId,
                ));
              }
            }
          } catch (e) {
            debugPrint('Error handling local notification tap: $e');
          }
        }
      },
    );

    final androidImplementation =
        _localNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  void updateAuth(AuthService authService) {
    final oldAuth = _authService;
    _authService = authService;

    if (_authService?.isAuthenticated == true && _authService?.token != null) {
      _apiService.setAuthToken(_authService!.token!);
      if (oldAuth?.token != _authService?.token || _pollTimer == null) {
        _startPolling();
      }
    } else {
      _stopPolling();
      _seenNotificationIds.clear();
      _isFirstFetch = true;
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) => _checkForNotifications());
    _checkForNotifications();
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  DateTime _parseDateTime(String dateStr) {
    try {
      var dt = DateTime.parse(dateStr);
      if (!dt.isUtc && !dateStr.contains('Z') && !dateStr.contains('+')) {
        dt = DateTime.parse('${dateStr.replaceFirst(' ', 'T')}Z');
      }
      return dt.toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<void> _checkForNotifications() async {
    if (_authService == null || !_authService!.isAuthenticated || _authService!.token == null) return;

    try {
      final result = await _apiService.getMyNotifications(status: 'unread', limit: 50);
      var notifications = result['notifications'] as List<NotificationModel>? ?? [];

      if (_authService?.isCustomer == true) {
        notifications = notifications.where((n) => n.type != 'new_booking').toList();
      }

      final now = DateTime.now();

      for (final n in notifications) {
        if (!_seenNotificationIds.contains(n.id)) {
          _seenNotificationIds.add(n.id);
          
          final createdTime = _parseDateTime(n.createdAt);
          final diff = now.difference(createdTime).inMinutes.abs();

          if (!_isFirstFetch || diff <= 5) {
            _showPopup(n);
            _showLocalNotification(n);
          }
        }
      }
      _isFirstFetch = false;
    } catch (e) {
      debugPrint('Error polling notifications: $e');
    }
  }

  Future<void> _showLocalNotification(NotificationModel notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'default_channel_id',
      'Alerts',
      channelDescription: 'Notifications for Mr. Lube Service booking status',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      color: Color(0xFFD32F2F),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotificationsPlugin.show(
      notification.id,
      notification.title,
      notification.message,
      platformChannelSpecifics,
      payload: notification.appointmentId?.toString(),
    );
  }

  void _showPopup(NotificationModel notification) {
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: NotificationPopupBanner(
          notification: notification,
          onDismiss: () {
            entry.remove();
          },
          onTap: () {
            _apiService.markAsRead(notification.id);
            final ctx = navigatorKey.currentContext;
            if (ctx != null) {
              handleNavigation(ctx, notification);
            }
          },
        ),
      ),
    );

    overlayState.insert(entry);
  }

  void triggerDemoNotification({
    required String title,
    required String message,
    required String type,
    int? appointmentId,
    int? orderId,
  }) {
    final mockNotif = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      type: type,
      title: title,
      message: message,
      status: 'unread',
      createdAt: DateTime.now().toIso8601String(),
      appointmentId: appointmentId,
      orderId: orderId,
    );
    _showPopup(mockNotif);
    _showLocalNotification(mockNotif);
  }

  Future<void> handleNavigation(BuildContext context, NotificationModel notification) async {
    if (notification.appointmentId != null) {
      if (_authService?.isMechanic == true || _authService?.isShopOwner == true) {
        int? shopId = _authService?.shopId;
        if (shopId == null) {
          try {
            final mechService = MechanicApiService();
            mechService.setAuthToken(_authService!.token!);
            final shops = await mechService.getMyShops();
            if (shops.isNotEmpty) {
              shopId = shops.first.shopId;
              _authService?.setShopId(shopId);
            }
          } catch (e) {
            debugPrint('Error getting shopId for deep link: $e');
          }
        }

        if (!context.mounted) return;

        if (shopId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingDetailMechanicPage(
                shopId: shopId!,
                appointmentId: notification.appointmentId!,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not determine shop for this booking')),
          );
        }
      } else {
        if (!context.mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AppointmentDetailPage(
              appointmentId: notification.appointmentId!,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}
