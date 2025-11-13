import 'package:clase6/screens/perfil.dart';
import 'package:clase6/screens/prueba.dart';
import 'package:flutter/material.dart';
import 'package:clase6/screens/products.dart';
import 'package:clase6/screens/map_screen.dart';

class Prueba2 extends StatefulWidget {
  const Prueba2({super.key});

  @override
  State<Prueba2> createState() => _Prueba2State();
}



class _Prueba2State extends State<Prueba2> {
  final int _currentIndex = 3; // El índice inicial será 0 para 'Otros'

  void _onTabTapped(int index) {
    if (index == 0) {
    
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Prueba()),
      );

    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Perfil()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProductsScreen()),
      );
    } else if (index == 3) {
      // Ya estamos en esta pantalla, no hacemos nada);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MapScreen()),
            );
          },
        ),
        title: const Text(
          'La Reina',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color.fromARGB(255, 255, 255, 255), size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapScreen()),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
  
  
