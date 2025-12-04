import 'package:clase6/screens/app1/4configuracion.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:clase6/screens/splashscreen.dart';
import 'package:clase6/screens/login.dart';
import 'package:clase6/theme/theme.dart';
import 'package:clase6/screens/app1/navbar.dart';

// GlobalKey para acceder al estado de la app desde cualquier lugar
final GlobalKey<MainAppState> mainAppKey = GlobalKey();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCq7zY99Ys4JZpLgtBkDusBuJ7qIAdGzjc",
    authDomain: "app1-eed04.firebaseapp.com",
    projectId: "app1-eed04",
    storageBucket: "app1-eed04.firebasestorage.app",
  messagingSenderId: "973044396365",
  appId: "1:973044396365:web:7a27986e012adede0ac704"
      ),
    );
  } on FirebaseException catch (e) {
    // Si la app ya estaba inicializada, ignora el error
    if (e.code != 'duplicate-app') rethrow;
  }

  runApp(MainApp(key: mainAppKey));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: const SplashScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ignore: unused_element
  void _signOut(BuildContext context) async {
    await GoogleSignIn.instance.signOut();
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Configuracion(),
      bottomNavigationBar: NavBar(),

     
    );

}}
