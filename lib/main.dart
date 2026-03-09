// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_theme.dart';
import 'core/di/service_locator.dart';
import 'presentation/screens/task_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait — standard for enterprise field apps
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  setupServiceLocator();

  runApp(const FieldServiceApp());
}

class FieldServiceApp extends StatelessWidget {
  const FieldServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Field Service Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const TaskListScreen(),
    );
  }
}
