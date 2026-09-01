import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/kiosk_shell.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const GigiKioskApp());
}

class GigiKioskApp extends StatelessWidget {
  const GigiKioskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GIGI Sports Kiosk',
      debugShowCheckedModeBanner: false,
      theme: buildKioskTheme(),
      home: const KioskShell(),
    );
  }
}
