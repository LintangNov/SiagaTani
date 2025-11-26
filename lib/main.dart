import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart'; 
import 'controllers/auth_controller.dart'; // Import controller
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // REGISTER CONTROLLER DI SINI
  Get.put(AuthController()); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( 
      debugShowCheckedModeBanner: false,
      title: 'SiagaTani',
      theme: ThemeData(primarySwatch: Colors.green),
      // KOSONGKAN HOME, biarkan AuthController yang menentukan arah (ke Main/Onboarding)
      home: const Scaffold(body: Center(child: CircularProgressIndicator())), 
    );
  }
}