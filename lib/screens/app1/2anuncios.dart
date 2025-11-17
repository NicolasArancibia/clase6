import 'package:flutter/material.dart';

class Anuncios extends StatefulWidget {
  const Anuncios({super.key});

  @override
  State<Anuncios> createState() => _AnunciosState();
}

class _AnunciosState extends State<Anuncios> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anuncios'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Contenido de Anuncios'),
      ),
    );
  }
}
  
  
