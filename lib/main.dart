import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. Import ini
import 'controllers/auth_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Load .env
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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