import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Necesario para saber quién crea la emergencia
import 'dart:math'; // Para la ubicación simulada
import 'package:clase6/screens/app1/appbar.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final MapController _mapController = MapController();
  // Tu ubicación "Simulada" (La Reina, Santiago)
  final LatLng _miUbicacion = const LatLng(-33.444, -70.540);

  // Datos del formulario
  String _selectedAuthority = 'Carabineros';
  String? _selectedCategory;
  bool _contactarTodos = true;
  bool _enviarUbicacion = true;
  bool _llamarServicio = false;

  final List<String> _authorities = ['Carabineros', 'Bomberos', 'Ambulancia'];
  final List<String> _categories = [
    'Accidente',
    'Hostigamiento',
    'Conducta irregular',
    'Robo'
  ];

  // --- 1. MOSTRAR INFORMACIÓN AL TOCAR UN PIN (NUEVO) ---
  void _showDetailModal(Map<String, dynamic> data) {
    // Formatear fecha (simple)
    final timestamp = data['timestamp'] as Timestamp?;
    final fecha = timestamp != null 
        ? "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year} a las ${timestamp.toDate().hour}:${timestamp.toDate().minute}"
        : "Fecha desconocida";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(height: 4, width: 40, color: Colors.grey[300])),
              const SizedBox(height: 20),
              
              // Título con la Categoría
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
                  const SizedBox(width: 10),
                  Text(
                    data['category'] ?? 'Emergencia',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(height: 30),
              
              // Detalles
              _buildDetailRow(Icons.admin_panel_settings, "Autoridad", data['authority'] ?? 'No especificada'),
              _buildDetailRow(Icons.person, "Reportado por", data['user'] ?? 'Anónimo'),
              _buildDetailRow(Icons.access_time, "Fecha y Hora", fecha),
              
              const SizedBox(height: 20),
              
              // Botón Cerrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
    );
  }

  // --- 2. MODAL DE CREACIÓN (Mismo de antes) ---
  void _showEmergencyModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(height: 4, width: 40, color: Colors.grey[300]),
                    const SizedBox(height: 20),
                    Text('Nueva Emergencia',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 10),
                    const Text(
                        'Se simulará una ubicación cercana para pruebas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey)), 
                    const SizedBox(height: 20),
                    
                    Row(
                      children: _authorities.map((auth) {
                        final isSelected = _selectedAuthority == auth;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setModalState(() => _selectedAuthority = auth),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: isSelected
                                    ? Border(
                                        bottom: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            width: 3))
                                    : null,
                              ),
                              child: Text(auth,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.black)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      hint: const Text('Selecciona categoría'),
                      items: _categories
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) =>
                          setModalState(() => _selectedCategory = v),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8))),
                    ),
                    const SizedBox(height: 20),
                    
                    SwitchListTile(
                        title: const Text('Contactar a todos'),
                        value: _contactarTodos,
                        onChanged: (v) =>
                            setModalState(() => _contactarTodos = v)),
                    SwitchListTile(
                        title: const Text('Enviar ubicación'),
                        value: _enviarUbicacion,
                        onChanged: (v) =>
                            setModalState(() => _enviarUbicacion = v)),
                    SwitchListTile(
                        title: const Text('Llamar servicio'),
                        value: _llamarServicio,
                        onChanged: (v) =>
                            setModalState(() => _llamarServicio = v)),
                    const SizedBox(height: 20),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showConfirmationDialog();
                        },
                        child: const Text('Confirmar'),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Confirmar emergencia?'),
        content: const Text('Esto enviará una alerta a las autoridades.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitEmergency();
            },
            child: const Text('ENVIAR'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitEmergency() async {
    try {
      // --- SIMULACIÓN DE UBICACIÓN ---
      final random = Random();
      double latOffset = (random.nextDouble() - 0.5) * 0.010; // +/- 500 metros
      double lngOffset = (random.nextDouble() - 0.5) * 0.010;

      final simuladaLat = _miUbicacion.latitude + latOffset;
      final simuladaLng = _miUbicacion.longitude + lngOffset;

      // Obtenemos el usuario actual
      final user = FirebaseAuth.instance.currentUser;
      final userEmail = user?.email ?? 'Usuario Anónimo';

      await FirebaseFirestore.instance.collection('emergencies').add({
        'authority': _selectedAuthority,
        'category': _selectedCategory ?? 'General',
        'contactAll': _contactarTodos,
        'location': GeoPoint(simuladaLat, simuladaLng),
        'timestamp': FieldValue.serverTimestamp(),
        'user': userEmail, // Guardamos quién la creó
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('🚨 Emergencia enviada (Simulada cerca)'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(title: 'Mapa'),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('emergencies').snapshots(),
            builder: (context, snapshot) {
              
              List<Marker> markers = [
                // MI UBICACIÓN (PIN AZUL)
                Marker(
                  point: _miUbicacion,
                  width: 60,
                  height: 60,
                  child: const Column(
                    children: [
                      Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                      Text("Yo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ];

              // EMERGENCIAS (PINES ROJOS INTERACTIVOS)
              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final geo = data['location'] as GeoPoint?;
                  final category = data['category'] ?? 'Alerta';
                  
                  if (geo != null) {
                    markers.add(
                      Marker(
                        point: LatLng(geo.latitude, geo.longitude),
                        width: 60, // Hacemos el área táctil un poco más grande
                        height: 60,
                        child: GestureDetector( // <--- AQUÍ ESTÁ LA MAGIA DEL CLICK
                          onTap: () {
                            _showDetailModal(data); // Abrimos el sub-menú
                          },
                          child: Column(
                            children: [
                              const Icon(Icons.location_on, color: Colors.red, size: 40),
                              Text(category, 
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.redAccent)
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                }
              }

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: _miUbicacion,
                  zoom: 14.5,
                  // Importante: Evita que el mapa rote para que los pines se lean bien
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.clase6.lareina.app',
                  ),
                  MarkerLayer(markers: markers),
                ],
              );
            },
          ),

          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1262CC),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                onPressed: _showEmergencyModal,
                child: const Text('Emergencia',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}