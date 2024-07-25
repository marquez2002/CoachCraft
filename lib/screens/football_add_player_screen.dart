import 'package:CoachCraft/models/player.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FootballAddPlayer extends StatefulWidget {
  const FootballAddPlayer({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FootballAddPlayerState createState() => _FootballAddPlayerState();
}

class _FootballAddPlayerState extends State<FootballAddPlayer> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  int _dorsal = 0;
  String _position = 'Portero'; // Valor predeterminado
  double _height = 0.0;
  double _weight = 0.0;
  int _age = 0;

  Future<void> _addPlayer() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String playerId = FirebaseFirestore.instance.collection('teams').doc('teamID').collection('players').doc().id;

      Player player = Player(
        id: playerId,
        name: _name,
        dorsal: _dorsal,
        position: _position,
        height: _height,
        weight: _weight,
        age: _age,
      );

      await FirebaseFirestore.instance.collection('teams').doc('teamID').collection('players').doc(playerId).set(player.toMap());

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Jugador Al Equipo'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length >= 2) {
                    return 'Introduce un nombre correctamente.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Dorsal'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.parse(value)>=0 || int.parse(value)<=99) {
                    return 'Introduce un dorsal en el rango de valores 1-99.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _dorsal = int.parse(value!);
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Posición'),
                value: _position,
                items: ['Portero', 'Ala', 'Pivot', 'Cierre'].map((position) {
                  return DropdownMenuItem<String>(
                    value: position,
                    child: Text(position),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _position = value!;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Altura'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.parse(value)>=50 || double.parse(value)<=250) {
                    return 'Introduce la altura en centimetros.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _height = double.parse(value!);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Peso'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.parse(value)>=20 || double.parse(value)<=250) {
                    return 'Introduce un peso en kilogramos correctamente.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _weight = double.parse(value!);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.parse(value)>=5 || int.parse(value)<=120) {
                    return 'Por favor ingrese la edad';
                  }
                  return null;
                },
                onSaved: (value) {
                  _age = int.parse(value!);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addPlayer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 54, 45, 46),
                ),
                child: const Text('Añadir Jugador'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

