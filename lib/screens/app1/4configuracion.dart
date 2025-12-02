import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Importamos con alias (se mantiene aunque esta pantalla sea estética)
import 'package:google_sign_in/google_sign_in.dart' as g_signin;
import 'package:clase6/screens/app1/appbar.dart';
import 'package:clase6/screens/login.dart';

class Configuracion extends StatefulWidget {
  const Configuracion({super.key});

  @override
  State<Configuracion> createState() => _ConfiguracionState();
}

class _ConfiguracionState extends State<Configuracion> {
  final User? user = FirebaseAuth.instance.currentUser;
  final g_signin.GoogleSignIn _googleSignIn = g_signin.GoogleSignIn.instance;

  // Estado local de toggles (UI only)
  final Map<String, bool> _toggles = {
    'ubicacion': true,
    'notificaciones': false,
    'permitir_mensajes': false,
    'cuenta_privada': false,
    'informacion_publica': false,
    'tema_oscuro': false,
  };

  void _toggle(String key) => setState(() => _toggles[key] = !_toggles[key]!);

  void _signOut() async {
    // Sólo navegación local para la versión estética
    try {
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _rowAction(IconData icon, String label, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Widget _toggleTile(IconData icon, String label, String key) {
    final value = _toggles[key] ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Switch.adaptive(
            value: value,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (v) => _toggle(key),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(title: 'Configuración'),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 12),
          _rowAction(Icons.star, 'Valoranos', onTap: () {}),
          _rowAction(Icons.report_problem, 'Reportar Fallas', onTap: () {}),
          _rowAction(Icons.headset_mic, 'Ayuda y Soporte', onTap: () {}),

          _sectionHeader('Aplicación'),
          const SizedBox(height: 4),
          _toggleTile(Icons.location_on, 'Ubicación', 'ubicacion'),
          const SizedBox(height: 8),
          _toggleTile(Icons.notifications, 'Notificaciones', 'notificaciones'),
          const SizedBox(height: 8),
          _toggleTile(Icons.message, 'Permitir mensajes', 'permitir_mensajes'),
          const SizedBox(height: 8),
          _toggleTile(Icons.lock, 'Cuenta privada', 'cuenta_privada'),
          const SizedBox(height: 8),
          _toggleTile(Icons.info, 'Informacion publica', 'informacion_publica'),
          const SizedBox(height: 8),
          _toggleTile(Icons.dark_mode, 'Tema oscuro', 'tema_oscuro'),

          const SizedBox(height: 12),
          _rowAction(Icons.help_outline, 'Preguntas Frecuentes', onTap: () {}),
          _rowAction(Icons.description_outlined, 'Terminos y Condiciones', onTap: () {}),

          _sectionHeader('Cuenta'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 4),
                const Icon(Icons.logout, color: Colors.redAccent),
                const SizedBox(width: 12),
                Expanded(child: Text('Cerrar Sesión', style: const TextStyle(color: Colors.redAccent))),
                TextButton(
                  onPressed: _signOut,
                  child: const Text('Salir', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
  
  
