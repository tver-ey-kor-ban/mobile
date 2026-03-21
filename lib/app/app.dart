import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/home/presentation/pages/home_page.dart'; // Import your home page
import '../shared/services/auth_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'Mr. Lube Service',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.red, useMaterial3: true),
        // CHANGE THIS LINE:
        home: const HomePage(),
      ),
    );
  }
}
