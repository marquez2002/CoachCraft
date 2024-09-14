// lib/screens/teams/team_list_widget.dart

import 'package:CoachCraft/models/teams.dart';
import 'package:CoachCraft/screens/menu/login_screen.dart';
import 'package:CoachCraft/screens/teams/add_team_screen.dart';
import 'package:CoachCraft/services/login/login_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeamListWidget extends StatefulWidget {
  const TeamListWidget({Key? key}) : super(key: key);

  @override
  _TeamListWidgetState createState() => _TeamListWidgetState();
}

class _TeamListWidgetState extends State<TeamListWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  List<Teams> userTeams = [];

  @override
  void initState() {
    super.initState();
    _loadUserTeams();
  }

  Future<void> _loadUserTeams() async {
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user!.uid).get();
      List<dynamic> teamIds = userDoc['teams'] ?? [];
      List<Teams> teams = [];

      for (String teamId in teamIds) {
        DocumentSnapshot teamDoc = await _firestore.collection('teams').doc(teamId).get();
        teams.add(Teams(
          name: teamDoc['name'],
          role: teamDoc['role'],
        ));
      }

      setState(() {
        userTeams = teams;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Equipos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddTeamScreen(onTeamAdded: _loadUserTeams),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await LoginService().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: userTeams.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(userTeams[index].name),
            subtitle: Text('Rol: ${userTeams[index].role}'),
          );
        },
      ),
    );
  }
}
