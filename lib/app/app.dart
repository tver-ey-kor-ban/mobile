import 'package:flutter/material.dart';
import '../features/home/presentation/pages/home_page.dart'; // Import your home page

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mr. Lube Service',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red, useMaterial3: true),
      // CHANGE THIS LINE:
      home: HomePage(),
    );
  }
}
