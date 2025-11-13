import 'package:clase6/screens/prueba.dart';
import 'package:clase6/screens/prueba2.dart';
import 'package:flutter/material.dart';
import 'package:clase6/screens/chats.dart';
import 'package:clase6/screens/products.dart';
import 'package:clase6/screens/map_screen.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}



class _PerfilState extends State<Perfil> {
  final int _currentIndex = 1; // El índice inicial será 0 para 'Otros'

  void _onTabTapped(int index) {
    if (index == 0) {
    
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Prueba()),
      );

    } else if (index == 1) {

      
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProductsScreen()),
      );
    } else if (index == 3) {
Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Prueba2()),
      );    
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

      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 80, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Juan Pérez',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'juan@example.com',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: const [
                        ListTile(
                          leading: Icon(Icons.phone),
                          title: Text('Teléfono'),
                          subtitle: Text('+34 123 456 789'),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.location_on),
                          title: Text('Ubicación'),
                          subtitle: Text('Madrid, España'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  onPressed: () {},
                  child: const Text('Editar Perfil'),
                  
                ),
              ],
            ),
          ),
        ),
      ),

    floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción al presionar el botón
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatsScreen()),
          );
        },
        child: const Icon(Icons.diversity_1),
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
  
  
