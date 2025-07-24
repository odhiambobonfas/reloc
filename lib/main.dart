import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import your screen
import 'package:reloc/views/auth/auth_screen.dart';
// You can switch back to routing once this screen works.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Relocation App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // Or use your custom theme
      home: const AuthScreen(), // 👈 Starting screen
    );
  }
}
