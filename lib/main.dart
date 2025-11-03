// ...existing code...
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'Screen/LoginScreen.dart';
import 'Screen/CadastroScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAlODpz-btQN4QgzJmHeG6U-E4bzYrGOxM",
        authDomain: "stockmananger-31761.firebaseapp.com",
        projectId: "stockmananger-31761",
        storageBucket: "stockmananger-31761.firebasestorage.app",
        messagingSenderId: "386175800939",
        appId: "1:386175800939:web:15b0c052cca255b0be832e",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const Loginscreen(),
    );
  }
}
// ...existing code...