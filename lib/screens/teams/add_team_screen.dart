// lib/screens/teams/add_team_Screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTeamScreen extends StatefulWidget {
  final VoidCallback onTeamAdded;

  const AddTeamScreen({Key? key, required this.onTeamAdded}) : super(key: key);

  @override
  _AddTeamScreenState createState() => _AddTeamScreenState();
}

class _AddTeamScreenState extends State<AddTeamScreen> {
  final TextEditingController _teamNameController = TextEditingController();
  String _role = 'Jugador'; // Valor por defecto

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Nuevo Equipo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _teamNameController,
            decoration: const InputDecoration(labelText: 'Nombre del Equipo'),
          ),
          const SizedBox(height: 10),
          DropdownButton<String>(
            value: _role,
            onChanged: (String? newValue) {
              setState(() {
                _role = newValue!;
              });
            },
            items: <String>['Jugador', 'Entrenador']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            String teamName = _teamNameController.text;
            if (teamName.isNotEmpty) {
              // Crea un nuevo equipo en Firestore
              DocumentReference newTeamRef = await FirebaseFirestore.instance.collection('teams').add({
                'name': teamName,
                'role': _role,
                'members': [FirebaseAuth.instance.currentUser!.uid], // Agregar al creador como miembro
              });

              // Actualiza el usuario para incluir el nuevo equipo
              await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
                'teams': FieldValue.arrayUnion([newTeamRef.id]),
              });

              // Llama al callback para recargar los equipos
              widget.onTeamAdded();
              Navigator.of(context).pop();
            }
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
