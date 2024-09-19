import 'package:CoachCraft/provider/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

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
  String? _shieldImageUrl; // URL de la imagen del escudo
  Uint8List? _shieldImageBytes; // Imagen del escudo como bytes
  String? teamId; // Almacena el ID del documento del equipo

  @override
  void initState() {
    super.initState();
    _loadTeamData(); // Cargar datos al iniciar
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pavilionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadTeamData() async {
    try {
      // Suponiendo que tienes el nombre del equipo disponible
      String teamNameToSearch = Provider.of<TeamProvider>(context, listen: false).selectedTeamName;

      // Obtener el equipo desde la colección 'teams' que coincida con el nombre
      QuerySnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .where('name', isEqualTo: teamNameToSearch) // Filtrar por el nombre del equipo
          .limit(1)
          .get();

      if (teamSnapshot.docs.isNotEmpty) {
        DocumentSnapshot teamDoc = teamSnapshot.docs.first;
        teamId = teamDoc.id; // Almacenar el ID del documento del equipo
        Map<String, dynamic> teamData = teamDoc.data() as Map<String, dynamic>;

        // Usar el nombre del equipo
        String teamName = teamData['name'] ?? '';
        if (teamName.isNotEmpty) {
          setState(() {
            _nameController.text = teamName; // Usar el nombre del equipo
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El nombre del equipo está vacío en la base de datos')),
          );
          return;
        }

        // Verificar si el documento de datos del equipo existe en la subcolección 'teamData'
        DocumentReference teamDataDocRef = FirebaseFirestore.instance
            .collection('teams')
            .doc(teamId)
            .collection('teamData')
            .doc('data');

        DocumentSnapshot teamDataDoc = await teamDataDocRef.get();

        if (!teamDataDoc.exists) {
          // Si el documento no existe, crearlo con los campos iniciales
          await teamDataDocRef.set({
            'nombre': teamName,
            'pabellon': null,
            'direccion': null,
            'escudo': null,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Documento de datos creado para el equipo')),
          );
        } else {
          // Si el documento existe, cargar los datos
          Map<String, dynamic>? data = teamDataDoc.data() as Map<String, dynamic>?;
          if (data != null) {
            _pavilionController.text = data['pabellon'] ?? '';
            _addressController.text = data['direccion'] ?? '';
            _shieldImageUrl = data['escudo']; // Asegúrate de que esto se asigne correctamente
            setState(() {}); // Actualiza el estado para reflejar los cambios
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se encontraron datos del equipo')),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay datos en la colección de equipos')),
        );
        return;
      }
    } catch (e) {
      print(e); // Imprimir el error para depuración
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los datos: $e')),
      );
    }
  }


  Future<void> _pickShieldImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _shieldImageBytes = bytes; // Almacenar la imagen seleccionada
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se seleccionó ninguna imagen')),
      );
    }
  }

  Future<String?> _uploadShieldImage() async {
    if (_shieldImageBytes != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('team_shields/$fileName');

      try {
        // Cargar el archivo como bytes
        UploadTask uploadTask = storageRef.putData(_shieldImageBytes!);
        TaskSnapshot snapshot = await uploadTask;

        // Verificar el estado de la subida
        if (snapshot.state == TaskState.success) {
          String downloadUrl = await snapshot.ref.getDownloadURL();
          print('Imagen subida: $downloadUrl'); // Imprimir URL para depuración
          return downloadUrl; // Retornar la URL de la imagen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al subir la imagen')),
          );
          return null;
        }
      } catch (e) {
        print(e); // Imprimir el error para depuración
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir la imagen: $e')),
        );
        return null;
      }
    }
    return null; // Si no hay imagen, retornar null
  }

  Future<void> _saveTeamData() async {
    if (_formKey.currentState!.validate()) {
      String? shieldUrl = await _uploadShieldImage(); // Subir la imagen y obtener la URL

      // Crea un mapa con los datos del equipo
      Map<String, dynamic> teamData = {
        'nombre': _nameController.text,
        'pabellon': _pavilionController.text.isEmpty ? null : _pavilionController.text,
        'direccion': _addressController.text.isEmpty ? null : _addressController.text,
        'escudo': shieldUrl ?? _shieldImageUrl, // Usar la URL existente si no se subió una nueva
      };

      try {
        // Guardar datos en el documento del equipo en la subcolección 'teamData'
        await FirebaseFirestore.instance
            .collection('teams')
            .doc(teamId) // Usar el ID del documento
            .collection('teamData')
            .doc('data') // Usar un documento específico para los datos del equipo
            .set(teamData, SetOptions(merge: true));

        // Si se modificó el nombre, actualizar el nombre en el documento principal del equipo
        if (teamData['nombre'] != null) {
          await FirebaseFirestore.instance
              .collection('teams')
              .doc(teamId) // Usar el ID del documento
              .update({'name': teamData['nombre']}); // Actualizar el nombre del equipo
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos del equipo guardados correctamente')),
        );
        _loadTeamData(); // Volver a cargar los datos después de guardar
      } catch (e) {
        print(e); // Imprimir el error para depuración
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar los datos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos del Equipo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( // Hacer que el contenido sea desplazable
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
    );
  }
}
