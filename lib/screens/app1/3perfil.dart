import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Importamos con alias
import 'package:google_sign_in/google_sign_in.dart' as g_signin;
import 'package:clase6/screens/app1/appbar.dart';
import 'package:clase6/screens/app1/editarperfil.dart';
import 'package:clase6/screens/login.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final User? user = FirebaseAuth.instance.currentUser;
  final g_signin.GoogleSignIn _googleSignIn = g_signin.GoogleSignIn.instance;
  
  Map<String, dynamic>? perfilData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Perfiles')
          .doc(user!.uid)
          .get();
      
      if (mounted) {
        setState(() {
          perfilData = doc.data() ?? {};
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error cargando perfil: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _signOut() async {
    try {
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint("Error cerrando sesión: $e");
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        appBar: Appbar(title: 'Perfil'),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final username = perfilData?['username'] ?? '@${user?.displayName ?? 'usuario'}';
    final company = perfilData?['company'] ?? '';
    final calle = perfilData?['calle'] ?? '';
    final comuna = perfilData?['comuna'] ?? '';
    final perfilPrivado = perfilData?['perfilPrivado'] ?? false;
    final mensajesDirect = perfilData?['mensajesDirect'] ?? true;
    final notificaciones = perfilData?['notificaciones'] ?? true;

    return Scaffold(
      appBar: const Appbar(title: 'Perfil'),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Avatar con botón de cambiar foto
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? const Icon(Icons.person, size: 80, color: Colors.white)
                          : null,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Nombre
                Text(
                  user?.displayName ?? 'Usuario',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Email
                Text(
                  user?.email ?? 'correo@ejemplo.com',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),

                // Username
                Text(
                  username,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),

                // Información de Ubicación y Empresa - Diseño Mejorado
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.cyan.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (company.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Icon(Icons.business, color: Colors.blue, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Compañía',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      company,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (calle.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.orange, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Calle',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      calle,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (comuna.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.apartment, color: Colors.green, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Comuna',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    comuna,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Sección de Privacidad
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Privacidad y Seguridad',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildToggleTile(
                        'Perfil Privado',
                        perfilPrivado,
                        (value) async {
                          await _actualizarPerfil(
                            'perfilPrivado',
                            value,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildToggleTile(
                        'Mensajes Directos',
                        mensajesDirect,
                        (value) async {
                          await _actualizarPerfil(
                            'mensajesDirect',
                            value,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildToggleTile(
                        'Notificaciones',
                        notificaciones,
                        (value) async {
                          await _actualizarPerfil(
                            'notificaciones',
                            value,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Botón Editar Perfil
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditarPerfil(
                            perfilData: perfilData ?? {},
                          ),
                        ),
                      );
                      if (result == true) {
                        _cargarPerfil(); // Recargar datos
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Perfil actualizado correctamente'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar Perfil'),
                  ),
                ),
                const SizedBox(height: 20),

                // Botón Cerrar Sesión
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Cerrar Sesión',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTile(
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _actualizarPerfil(String campo, dynamic valor) async {
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('Perfiles')
          .doc(user!.uid)
          .update({campo: valor});

      setState(() {
        perfilData?[campo] = valor;
      });
    } catch (e) {
      debugPrint("Error actualizando perfil: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }
}