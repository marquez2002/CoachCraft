import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';



Future<String?> uploadVideo(File videoFile, BuildContext context) async {
  // Nombre del archivo en Firebase con carpeta "football_plays"
  String fileName = 'football_plays/${DateTime.now().millisecondsSinceEpoch}.mp4';
  Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

  try {
    // Cargar el archivo
    UploadTask uploadTask = storageRef.putFile(videoFile);
    TaskSnapshot snapshot = await uploadTask;

    // Verificar el estado de la subida
    if (snapshot.state == TaskState.success) {
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Video subido: $downloadUrl'); // Imprimir URL para depuración
      return downloadUrl; // Retornar la URL del video
    } else {
      _showSnackbar(context, 'Error al subir el video');
      return null;
    }
  } catch (e) {
    print('Error al subir video: $e'); // Imprimir el error para depuración
    _showSnackbar(context, 'Error al subir el video: $e');
    return null;
  }
}

// Función auxiliar para mostrar un SnackBar
void _showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
