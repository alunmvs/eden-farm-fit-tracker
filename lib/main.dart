import 'package:eden_farm_tech_test_hartono/screens/sign_in_screen.dart';
import 'package:eden_farm_tech_test_hartono/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EdenFarm TechTest - Hartono',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              actionsIconTheme: IconThemeData(color: Colors.blue),
              titleTextStyle: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                  fontSize: 20)),
          inputDecorationTheme: InputDecorationTheme(
              contentPadding: EdgeInsets.all(20),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
      home: const SplashScreen(),
    );
  }
}
