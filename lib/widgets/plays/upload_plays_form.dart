import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

// Función para obtener el teamId basado en un criterio (por ejemplo, el primer equipo)
Future<String?> getTeamId() async {
  try {
    // Obtener el primer documento de la colección 'teams'
    QuerySnapshot teamSnapshot = await FirebaseFirestore.instance.collection('teams').limit(1).get();
    
    if (teamSnapshot.docs.isNotEmpty) {
      // Retornar el ID del primer equipo encontrado
      return teamSnapshot.docs.first.id;
    } else {
      throw Exception('No se encontraron equipos'); 
    }
  } catch (e) {
    throw Exception('Error al obtener el teamId: $e'); 
  }
}

class UploadForm extends StatefulWidget {
  @override
  _UploadFormState createState() => _UploadFormState();
}

class _UploadFormState extends State<UploadForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
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

  Future<String?> _uploadVideo() async {
    if (_videoBytes != null) {
      // El nombre del archivo es simplemente un timestamp con la extensión ".mp4"
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
      // Verificar si se ha seleccionado un video
      if (_videoBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona un video.')),
        );
        return; // Salir de la función si no hay video
      }

      String? videoUrl = await _uploadVideo();
      if (videoUrl != null) {
        try {
          // Obtener el teamId utilizando la función getTeamId
          String? teamId = await getTeamId();
          
          if (teamId != null) {
            // Añadir la jugada en la subcolección 'football_plays' del equipo correspondiente
            await FirebaseFirestore.instance.collection('teams')
              .doc(teamId)
              .collection('football_plays')
              .add({
                'name': _nameController.text.trim(),
                'type': _selectedType,
                'videoUrl': videoUrl,
              });
              
            // Mostrar un mensaje de éxito
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Jugada guardada con éxito')),
            );

            // Limpiar los campos después de guardar
            _nameController.clear();
            setState(() {
              _videoBytes = null; // Limpiar los bytes del video
              _selectedType = null; // Limpiar tipo de jugada
            });

            // Aquí se puede forzar la recarga del contenido si se requiere
            // setState(() {}); // Este es opcional ya que la pantalla se debería actualizar automáticamente si se utiliza un StreamBuilder.
          } else {
            // Mostrar error si no se obtiene el teamId
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se encontró ningún equipo')),
            );
          }
        } catch (e) {
          // Manejo de errores al obtener el teamId o guardar la jugada
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar jugada: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
        ],
      ),
    );
  }
}
