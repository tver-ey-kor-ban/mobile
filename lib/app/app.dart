import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/home/presentation/pages/home_page.dart'; // Import your home page
import '../features/notifications/services/notification_manager.dart';
import '../shared/services/auth_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService()..tryRestoreSession(),
        ),
        ChangeNotifierProxyProvider<AuthService, NotificationManager>(
          create: (context) => NotificationManager(),
          update: (context, authService, notificationManager) {
            return (notificationManager ?? NotificationManager())..updateAuth(authService);
          },
        ),
      ],
      child: MaterialApp(
        navigatorKey: NotificationManager.navigatorKey,
        title: 'Mr. Lube Service',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.red, useMaterial3: true),
        home: const HomePage(),
      ),
    );
  }
}
