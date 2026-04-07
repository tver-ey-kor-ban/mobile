import 'package:flutter/material.dart';
import 'package:my_app/app/app.dart';
import 'package:my_app/core/network/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.initialize();
  runApp(const MyApp());
}
