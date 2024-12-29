/*
 * Archivo: team_data_team_screen.dart
 * Descripción: Este archivo contiene la pantalla correspondiente a los datos del equipo.
 *              Pudiendo modificar cada uno de sus valores.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:CoachCraft/provider/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

// Clase principal para añadir/modificar los datos del club
class TeamDataScreen extends StatefulWidget {
  const TeamDataScreen({super.key});

  @override
  _TeamDataScreenState createState() => _TeamDataScreenState();
}

class _TeamDataScreenState extends State<TeamDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pavilionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _shieldImageUrl; 
  Uint8List? _shieldImageBytes; 
  String? teamId; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeamData(); 
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pavilionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Función correspondiente para cargar los datos del equipo existente en Firebase
  Future<void> _loadTeamData() async {
    try {
      String teamNameToSearch = Provider.of<TeamProvider>(context, listen: false).selectedTeamName;
      QuerySnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .where('name', isEqualTo: teamNameToSearch)
          .limit(1)
          .get();

      if (teamSnapshot.docs.isNotEmpty) {
        DocumentSnapshot teamDoc = teamSnapshot.docs.first;
        teamId = teamDoc.id;
        Map<String, dynamic> teamData = teamDoc.data() as Map<String, dynamic>;

        String teamName = teamData['name'] ?? '';
        // Comprueba que el nombre del equipo no está vacio.
        if (teamName.isNotEmpty) {
          setState(() {
            _nameController.text = teamName;
          });
        } else {
          _showSnackBar('El nombre del equipo está vacío en la base de datos');
          return;
        }

        DocumentReference teamDataDocRef = FirebaseFirestore.instance
            .collection('teams')
            .doc(teamId)
            .collection('teamData')
            .doc('data');

        DocumentSnapshot teamDataDoc = await teamDataDocRef.get();

        if (!teamDataDoc.exists) {
          await teamDataDocRef.set({
            'nombre': teamName,
            'pabellon': null,
            'direccion': null,
            'escudo': null,
          });
          _showSnackBar('Nuevos datos incorporados a la base de datos.');
        } else {
          Map<String, dynamic>? data = teamDataDoc.data() as Map<String, dynamic>?;
          if (data != null) {
            _pavilionController.text = data['pabellon'] ?? '';
            _addressController.text = data['direccion'] ?? '';
            _shieldImageUrl = data['escudo'];
            setState(() {}); 
          } else {
            _showSnackBar('No se encontraron datos del equipo');
          }
        }
      } else {
        _showSnackBar('No hay datos en la colección de equipos');
        return;
      }
    } catch (e) {
      print(e);
      _showSnackBar('Error al cargar los datos: $e');
    } finally {
      setState(() {
        _isLoading = false; 
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Función que permite seleccionar una imagen para modifica la imagen por default o la prexistente.
  Future<void> _pickShieldImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _shieldImageBytes = bytes;
      });
    } else {
      _showSnackBar('No se seleccionó ninguna imagen');
    }
  }
  
  // Función que permite modificar una imagen.
  Future<String?> _uploadShieldImage() async {
    if (_shieldImageBytes != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('team_shields/$fileName');

      try {
        UploadTask uploadTask = storageRef.putData(_shieldImageBytes!);
        TaskSnapshot snapshot = await uploadTask;

        if (snapshot.state == TaskState.success) {
          String downloadUrl = await snapshot.ref.getDownloadURL();
          print('Imagen subida: $downloadUrl');
          return downloadUrl;
        } else {
          _showSnackBar('Error al subir la imagen');
          return null;
        }
      } catch (e) {
        print(e);
        _showSnackBar('Error al subir la imagen: $e');
        return null;
      }
    }
    return null;
  }

  // Función que permite guardar los datos del equipo.
  Future<void> _saveTeamData() async {
    if (_formKey.currentState!.validate()) {
      String? shieldUrl = await _uploadShieldImage();

      Map<String, dynamic> teamData = {
        'nombre': _nameController.text,
        'pabellon': _pavilionController.text.isEmpty ? null : _pavilionController.text,
        'direccion': _addressController.text.isEmpty ? null : _addressController.text,
        'escudo': shieldUrl ?? _shieldImageUrl,
      };

      try {
        await FirebaseFirestore.instance
            .collection('teams')
            .doc(teamId)
            .collection('teamData')
            .doc('data')
            .set(teamData, SetOptions(merge: true));

        if (teamData['nombre'] != null) {
          await FirebaseFirestore.instance
              .collection('teams')
              .doc(teamId)
              .update({'name': teamData['nombre']});
        }

        _showSnackBar('Datos del equipo guardados correctamente');
        _loadTeamData(); 
      } catch (e) {
        print(e);
        _showSnackBar('Error al guardar los datos: $e');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Datos del Equipo'),
            pinned: false,
            floating: true, 
          ),
          SliverToBoxAdapter(
            child: _isLoading
                ? Center(child: CircularProgressIndicator()) 
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickShieldImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: _shieldImageBytes != null
                                  ? MemoryImage(_shieldImageBytes!)
                                  : _shieldImageUrl != null
                                      ? NetworkImage(_shieldImageUrl!)
                                      : const AssetImage('assets/image/default_shield.png') as ImageProvider,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Nombre del Equipo'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese el nombre del equipo';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _pavilionController,
                            decoration: const InputDecoration(labelText: 'Pabellón'),
                          ),
                          TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(labelText: 'Dirección'),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _saveTeamData,
                            child: const Text('Guardar Datos del Equipo'),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
