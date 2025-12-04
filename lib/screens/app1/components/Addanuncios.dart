import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Addanuncios extends StatefulWidget {
  const Addanuncios({super.key});

  @override
  State<Addanuncios> createState() => _AddanunciosState();
}

class _AddanunciosState extends State<Addanuncios> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  bool _isUploading = false;
  double _progress = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (file != null) setState(() => _pickedImage = file);
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al seleccionar imagen: $e')));
    }
  }

  Future<String?> _uploadFile(XFile file) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Necesitas iniciar sesión para subir archivos')));
      return null;
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${user.uid}.jpg';
    final storageRef = FirebaseStorage.instance.ref().child('anuncios/${user.uid}/$fileName');

    try {
      setState(() {
        _isUploading = true;
        _progress = 0;
      });

      final uploadTask = storageRef.putFile(File(file.path));
      uploadTask.snapshotEvents.listen((event) {
        final bytesTransferred = event.bytesTransferred.toDouble();
        final totalBytes = event.totalBytes.toDouble();
        if (mounted) setState(() => _progress = totalBytes > 0 ? (bytesTransferred / totalBytes) : 0);
      });

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      if (mounted) {
        setState(() {
        _isUploading = false;
        _progress = 0;
      });
      }

      return downloadUrl;
    } catch (e) {
      if (mounted) {
        setState(() {
        _isUploading = false;
        _progress = 0;
      });
      }
      debugPrint('Upload error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error subiendo imagen: $e')));
      return null;
    }
  }

  Future<void> _saveAnuncio() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El título no puede estar vacío')));
      return;
    }

    String? imageUrl;
    if (_pickedImage != null) {
      imageUrl = await _uploadFile(_pickedImage!);
      if (imageUrl == null) return; 
    }

    final user = FirebaseAuth.instance.currentUser;
    final anuncioDoc = {
      'title': title,
      'description': desc,
      'imageUrl': imageUrl,
      'userId': user?.uid,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('anuncios').add(anuncioDoc);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ ¡Anuncio publicado correctamente!'),
            backgroundColor: Color(0xFF1565C0),
            duration: Duration(seconds: 4),
          ),
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } catch (e) {
      debugPrint('Error guardando anuncio: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error guardando anuncio: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Anuncio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nuevo Anuncio',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        labelText: 'Título del anuncio',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        hintText: 'Escribe los detalles de tu anuncio aquí...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Preview de la imagen seleccionada
                    if (_pickedImage != null)
                      Column(
                        children: [
                          Image.file(File(_pickedImage!.path), height: 200, fit: BoxFit.cover),
                          const SizedBox(height: 8),
                        ],
                      ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Galería'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Cámara'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    if (_isUploading)
                      Column(
                        children: [
                          LinearProgressIndicator(value: _progress),
                          const SizedBox(height: 8),
                          Text('${(_progress * 100).toStringAsFixed(0)} %'),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveAnuncio,
                          icon: const Icon(Icons.upload),
                          label: const Text('Publicar Anuncio'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


