import 'package:flutter/material.dart';
import 'package:clase6/screens/app1/appbar.dart';
import 'package:clase6/screens/app1/components/Addanuncios.dart';
import 'package:clase6/screens/app1/components/anuncio_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Anuncios extends StatefulWidget {
  const Anuncios({super.key});

  @override
  State<Anuncios> createState() => _AnunciosState();
}

class _AnunciosState extends State<Anuncios> {
  bool _showEmergencias = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(title: 'Anuncios'),
      // Selector superior y lista de anuncios
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Selector Anuncios / Emergencias
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Mostrar sección Anuncios
                      setState(() => _showEmergencias = false);
                    },
                    child: Column(
                      children: [
                        Text('Anuncios', style: TextStyle(fontWeight: FontWeight.bold, color: !_showEmergencias ? Theme.of(context).colorScheme.primary : Colors.black87)),
                        const SizedBox(height: 6),
                        // Mostrar línea solo si está seleccionado
                        _showEmergencias ? const SizedBox(height: 3) : Container(height: 3, color: Theme.of(context).colorScheme.primary, width: 80),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Mostrar sección Emergencias en la misma página
                      setState(() => _showEmergencias = true);
                    },
                    child: Column(
                      children: [
                        Text('Emergencias', style: TextStyle(fontWeight: FontWeight.bold, color: _showEmergencias ? Theme.of(context).colorScheme.primary : Colors.black87)),
                        const SizedBox(height: 6),
                        // Mostrar línea solo si está seleccionado
                        _showEmergencias ? Container(height: 3, color: Theme.of(context).colorScheme.primary, width: 80) : const SizedBox(height: 3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Contenido variable: Anuncios o Emergencias
          Expanded(
            child: _showEmergencias
                ? StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('emergencies').orderBy('timestamp', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return Center(child: Text('Error: \\${snapshot.error}'));
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No hay emergencias activas.')));

                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 10, bottom: 80),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final category = data['category'] ?? 'Emergencia';
                          final authority = data['authority'] ?? 'No especificada';
                          final user = data['user'] ?? 'Anónimo';
                          final timestamp = data['timestamp'] as Timestamp?;
                          final fecha = timestamp != null
                              ? "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}"
                              : 'Fecha desconocida';

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      Text(fecha, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Autoridad: ' + authority, style: const TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  Text('Reportado por: ' + user),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () async {
                                          final shouldDelete = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text('Eliminar emergencia'),
                                              content: const Text('¿Eliminar esta emergencia? Esta acción no se puede deshacer.'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
                                              ],
                                            ),
                                          );

                                          if (shouldDelete == true) {
                                            try {
                                              await FirebaseFirestore.instance.collection('emergencies').doc(doc.id).delete();
                                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Emergencia eliminada')));
                                            } catch (e) {
                                              debugPrint('Error eliminando emergencia: $e');
                                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error eliminando emergencia: $e')));
                                            }
                                          }
                                        },
                                        child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('anuncios').orderBy('createdAt', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return Center(child: Text('Error: \\${snapshot.error}'));
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No hay anuncios publicados.')));

                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 10, bottom: 80),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final titulo = data['title'] ?? '';
                          final descripcion = data['description'] ?? '';
                          final autor = data['userId'] ?? 'Anónimo';
                          final imageUrl = data['imageUrl'] as String?;
                          final timestamp = data['createdAt'] as Timestamp?;
                          final fecha = timestamp != null
                              ? "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}"
                              : 'Fecha desconocida';

                          return AnuncioCard(
                            titulo: titulo,
                            descripcion: descripcion,
                            autor: autor,
                            fecha: fecha,
                            imageUrl: imageUrl,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Addanuncios()),
          );
        },
        label: const Text('Generar Anuncio'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
  
  
