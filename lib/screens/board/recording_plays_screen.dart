import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jugadas de Estrategia',
      home: RecordingPlayScreen(),
    );
  }
}

class RecordingPlayScreen extends StatefulWidget {
  @override
  _RecordingPlayScreenState createState() => _RecordingPlayScreenState();
}

class _RecordingPlayScreenState extends State<RecordingPlayScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedType; // Tipo de jugada: ataque o defensa
  Uint8List? _videoBytes; // Almacena los bytes del video seleccionado

  // Función para seleccionar un video
  Future<void> _selectVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      _videoBytes = result.files.first.bytes;
      setState(() {});
    }
  }

  // Función para subir el video
  Future<String?> _uploadVideo() async {
    if (_videoBytes != null) {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
      Reference storageRef = FirebaseStorage.instance.ref().child('football_plays/$fileName');

      try {
        UploadTask uploadTask = storageRef.putData(_videoBytes!);
        TaskSnapshot snapshot = await uploadTask;

        if (snapshot.state == TaskState.success) {
          String downloadUrl = await snapshot.ref.getDownloadURL();
          return downloadUrl;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al subir el video')),
          );
          return null;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir el video: $e')),
        );
        return null;
      }
    }
    return null; // Si no hay video, retornar null
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      String? videoUrl = await _uploadVideo();
      if (videoUrl != null) {
        await FirebaseFirestore.instance.collection('football_plays').add({
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'type': _selectedType,
          'videoUrl': videoUrl,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jugada guardada con éxito')),
        );

        // Limpiar los campos después de guardar
        _nameController.clear();
        _descriptionController.clear();
        setState(() {
          _videoBytes = null; // Limpiar los bytes del video
          _selectedType = null; // Limpiar tipo de jugada
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grabaciones'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ExpansionTile(
              title: const Text('Subida de Jugadas'),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Nombre de la jugada'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa un nombre';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        hint: const Text('Seleccionar tipo'),
                        items: [
                          DropdownMenuItem(value: 'ataque', child: Text('Ataque')),
                          DropdownMenuItem(value: 'defensa', child: Text('Defensa')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value; // Actualiza el tipo seleccionado
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor, selecciona un tipo';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(labelText: 'Descripción (opcional)'),
                      ),
                      SizedBox(height: 20),
                      // Botón para seleccionar video
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectVideo,
                          child: Text(
                            _videoBytes != null ? 'Video ya seleccionado' : 'Seleccionar Video',
                          ),
                        ),
                      ),
                      SizedBox(height: 20), // Espaciado entre botones
                      // Botón para subir jugada
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleSubmit,
                          child: const Text('Subir Jugada'),
                        ),
                      ),
                      SizedBox(height: 10),
                          Text(' ')
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
