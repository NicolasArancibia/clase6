import 'package:flutter/material.dart';
import 'package:clase6/screens/app1/appbar.dart';
class Mapa extends StatefulWidget {
  const Mapa({super.key});

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: const Appbar(),

      body: const Center(
        child: Text('Contenido del Mapa'),
      ),
            
    );
    
  }
}