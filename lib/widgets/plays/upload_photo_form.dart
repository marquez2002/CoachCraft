import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';

/// Función para obtener el ID del equipo (teamId)
Future<String?> getTeamId() async {
  try {
    QuerySnapshot teamSnapshot = await FirebaseFirestore.instance.collection('teams').limit(1).get();
    if (teamSnapshot.docs.isNotEmpty) {
      return teamSnapshot.docs.first.id; // Retorna el ID del primer equipo
    } else {
      throw Exception('No se encontraron equipos');
    }
  } catch (e) {
    throw Exception('Error al obtener el teamId: $e');
  }
}

class UploadPhotosForm extends StatefulWidget {
  @override
  _UploadPhotosFormState createState() => _UploadPhotosFormState();
}

class _UploadPhotosFormState extends State<UploadPhotosForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedType; // Tipo de foto
  Uint8List? _photoBytes; // Bytes de la foto seleccionada
  bool _isUploading = false; // Estado de carga

  /// Función para seleccionar una foto
  Future<void> _selectPhoto() async {
    // Solicitar permisos de almacenamiento
    if (await Permission.storage.request().isGranted) {
      try {
        // Abrir selector de archivos
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
        );

        if (result != null && result.files.single.bytes != null) {
          setState(() {
            _photoBytes = result.files.single.bytes;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se seleccionó ninguna foto.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar la foto: $e')),
        );
      }
    } else {
      // Mostrar mensaje si el permiso es denegado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso denegado. Actívelo en configuración.')),
      );
    }
  }

  /// Función para subir la foto a Firebase Storage
  Future<String?> _uploadPhoto() async {
    if (_photoBytes != null) {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child('photos/$fileName');

      try {
        UploadTask uploadTask = storageRef.putData(_photoBytes!);
        TaskSnapshot snapshot = await uploadTask;

        if (snapshot.state == TaskState.success) {
          String downloadUrl = await snapshot.ref.getDownloadURL();
          return downloadUrl;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al subir la foto')),
          );
          return null;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir la foto: $e')),
        );
        return null;
      }
    }
    return null;
  }

  /// Función para manejar el envío del formulario
  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_photoBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona una foto.')),
        );
        return;
      }

      setState(() {
        _isUploading = true; // Activar estado de carga
      });

      String? photoUrl = await _uploadPhoto();
      if (photoUrl != null) {
        try {
          String? teamId = await getTeamId();
          if (teamId != null) {
            await FirebaseFirestore.instance.collection('teams')
                .doc(teamId)
                .collection('photos')
                .add({
              'name': _nameController.text.trim(),
              'type': _selectedType,
              'photoUrl': photoUrl,
              'timestamp': FieldValue.serverTimestamp(),
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Foto guardada con éxito')),
            );

            // Limpiar los campos después de guardar
            _nameController.clear();
            setState(() {
              _photoBytes = null;
              _selectedType = null;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se encontró ningún equipo')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar foto: $e')),
          );
        }
      }

      setState(() {
        _isUploading = false; // Desactivar estado de carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre de la foto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedType,
                hint: const Text('Seleccionar tipo'),
                items: const [
                  DropdownMenuItem(value: 'ataque', child: Text('Ataque')),
                  DropdownMenuItem(value: 'defensa', child: Text('Defensa')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecciona un tipo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectPhoto,
                  child: Text(
                    _photoBytes != null ? 'Foto seleccionada' : 'Seleccionar Foto',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Botón para subir la foto
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _handleSubmit, // Deshabilitar mientras se sube
                  child: _isUploading
                      ? const CircularProgressIndicator()
                      : const Text('Subir Foto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
