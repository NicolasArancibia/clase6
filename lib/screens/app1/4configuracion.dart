import 'package:flutter/material.dart';
import 'package:clase6/screens/app1/appbar.dart';

class Configuracion extends StatefulWidget {
  const Configuracion({super.key});

  @override
  State<Configuracion> createState() => _ConfiguracionState();
}

class _ConfiguracionState extends State<Configuracion> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: const Appbar(),

      body: const Center(
        child: Text('Contenido de Configuración'),
      ),
    );
  }
}
  
  
