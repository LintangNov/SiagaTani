import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:siaga_tani/view/on_boarding.dart';
import 'package:get/get.dart'; // 1. Pastikan import ini ada
import 'firebase_options.dart';

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
    // 2. Ganti MaterialApp menjadi GetMaterialApp
    return GetMaterialApp( 
      debugShowCheckedModeBanner: false,
      title: 'SiagaTani',
      theme: ThemeData(primarySwatch: Colors.green),
      // Home tetap ke HomePage (yang isinya Splash Screen)
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingScreen();
  }
}