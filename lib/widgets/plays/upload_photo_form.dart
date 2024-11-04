/*
 * Archivo: upload_photos_form.dart
 * Descripción: Este archivo contiene un servicio que permite subir las fotos que se guardan en el sistema.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
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

class UploadPhotosForm extends StatefulWidget {
  @override
  _UploadPhotosFormState createState() => _UploadPhotosFormState();
}

class _UploadPhotosFormState extends State<UploadPhotosForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedType; 
  Uint8List? _photoBytes;

  // Función para seleccionar una foto
  Future<void> _selectPhoto() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      _photoBytes = result.files.first.bytes;
      setState(() {});
    }
  }

  Future<String?> _uploadPhoto() async {
    if (_photoBytes != null) {
      // El nombre del archivo es simplemente un timestamp con la extensión ".jpg"
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

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      // Verificar si se ha seleccionado una foto
      if (_photoBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona una foto.')),
        );
        return;
      }

      String? photoUrl = await _uploadPhoto();
      if (photoUrl != null) {
        try {
          // Obtener el teamId utilizando la función getTeamId
          String? teamId = await getTeamId();
          
          if (teamId != null) {
            // Añadir la foto en la subcolección 'photos' del equipo correspondiente
            await FirebaseFirestore.instance.collection('teams')
              .doc(teamId)
              .collection('photos')
              .add({
                'name': _nameController.text.trim(),
                'type': _selectedType,
                'photoUrl': photoUrl,
              });
              
            // Mostrar un mensaje de éxito
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
            // Mostrar error si no se obtiene el teamId
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se encontró ningún equipo')),
            );
          }
        } catch (e) {
          // Manejo de errores al obtener el teamId o guardar la foto
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar foto: $e')),
          );
        }
      }
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
                decoration: InputDecoration(labelText: 'Nombre de la foto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un nombre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),  // Agrega espaciado entre los elementos
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
              // Botón para seleccionar foto
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectPhoto,
                  child: Text(
                    _photoBytes != null ? 'Foto ya seleccionada' : 'Seleccionar Foto',
                  ),
                ),
              ),
              SizedBox(height: 20),  // Espaciado entre botones
              // Botón para subir foto
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  child: const Text('Subir Foto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
