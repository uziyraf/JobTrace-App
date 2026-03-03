import 'package:flutter/material.dart';
import 'package:jobtracker/ui/widgets/main_layout.dart';
import 'core/services/notification_service.dart';

// Import file baru kita

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().init();
  // await NotificationService().requestPermission();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const MainLayout(), // Gunakan MainLayout di sini
    );
  }
}
