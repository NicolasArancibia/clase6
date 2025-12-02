import 'package:clase6/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clase6/main.dart';     // HomeScreen
import 'package:clase6/screens/login.dart'; // LoginScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double opacity = 1.0;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => opacity = 0.0);

      Future.delayed(const Duration(milliseconds: 500), () {
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // Usuario autenticado → a Home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          // No autenticado → a Login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).extension<CustomColors>()!.azul,
      //backgroundColor: const Color(0xFFb9e9fa), //#b9e9fa (celeste del logo)
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: opacity,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('assets/images/LogoApp.png'),
                width: 400,
                height: 400,
              ),
              // Text(
              //   'Soy el Splashscreen',
              //   style: TextStyle(
              //     fontSize: 24,
              //     color: Theme.of(context).colorScheme.onPrimary,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
