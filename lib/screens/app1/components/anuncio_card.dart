import 'package:flutter/material.dart';

class AnuncioCard extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final String autor;
  final String fecha;
  final String? imageUrl; // La imagen es opcional

  const AnuncioCard({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.autor,
    required this.fecha,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias, // Para que la imagen respete los bordes redondeados
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen (si existe)
          if (imageUrl != null)
            Image.network(
              imageUrl!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              // Placeholder mientras carga la imagen
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              // Widget en caso de error al cargar la imagen
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey[200],
                child: Icon(Icons.broken_image, color: Colors.grey[400], size: 50),
              ),
            ),

          // Contenido de texto
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  descripcion,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(autor, style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
                    Text(fecha, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}