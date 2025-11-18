import 'package:flutter/material.dart';
import 'package:clase6/screens/app1/appbar.dart';

class Anuncios extends StatefulWidget {
  const Anuncios({super.key});

  @override
  State<Anuncios> createState() => _AnunciosState();
}

class _AnunciosState extends State<Anuncios> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: const Appbar(),

      body: const Center(
        child: Text('Contenido de Anuncios'),
      ),
    );
  }
}
  
  
