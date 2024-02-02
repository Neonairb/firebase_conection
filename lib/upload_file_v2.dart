import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadImage2 extends StatefulWidget {
  const UploadImage2({super.key});

  @override
  State<UploadImage2> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage2> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _showIdController = TextEditingController();

  // Colleccion dentro de Firestone Database
  final CollectionReference _items =
      FirebaseFirestore.instance.collection('images');

  XFile? image = XFile('');

  Map<String, String> images = {};

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
              top: 20,
              right: 20,
              left: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create your items'),
              TextField(
                  controller: _idController,
                  decoration: const InputDecoration(
                      labelText: 'ID', hintText: 'Enter the ID')),
              // LOGICA PARA SUBIR IMAGENES
              IconButton(
                onPressed: () async {
                  image = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (image == null) return;
                },
                icon: const Icon(Icons.add_a_photo),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // Esta sera la id de la imagen para asi
                    // poder sobreescribirla en un futuro
                    final String id = _idController.text;

                    // Coleccion dentro del Strorage de la database
                    Reference referenceRoot = FirebaseStorage.instance.ref();
                    Reference referenceDireImages =
                        referenceRoot.child('images').child(id);

                    if (image != XFile('')) {
                      try {
                        // Aqui especificamos el tipo de la imagen para que firebase lo reconozca como tal
                        await referenceDireImages.putFile(
                          File(image!.path),
                          SettableMetadata(contentType: 'image/jpeg'),
                        );
                      } catch (e) {
                        print(e);
                      }
                    }

                    _idController.text = '';
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    setState(() {_loadImages();});
                  },
                  child: const Text('Create'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, String>> getAllImages() async {
    Map<String, String> imageURLs = {};

    try {
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceImages = referenceRoot.child('images');

      // Lista de elementos en el directorio 'images'
      ListResult listResult = await referenceImages.listAll();

      // Iterar sobre cada elemento y obtener la URL de descarga
      for (var item in listResult.items) {
        String name = item.name;
        String downloadURL = await item.getDownloadURL();
        imageURLs.addEntries([MapEntry(name, downloadURL)]);
      }
    } catch (e) {
      print('Error getting images: $e');
      // Manejar el error según sea necesario
    }

    return imageURLs;
  }

  @override
  void initState() {
    super.initState();
    // _stream = FirebaseFirestore.instance.collection('images').snapshots();
    _loadImages();
  }

  // Función para cargar las imágenes al inicio
  Future<void> _loadImages() async {
    images = await getAllImages();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool pressed = false;
    return RefreshIndicator(
      onRefresh: () async {
        await _loadImages();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Upload and display items'),
        ),
        body: images.isNotEmpty
            ? ListView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  String imageName = images.keys.elementAt(index);
                  String imageURL = images[imageName]!;
      
                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(imageURL),
                        ),
                        title: Text(imageName, style: const TextStyle(fontSize: 30)),
                      ),
                      const Divider(height: 30),
                    ],
                  );
                },
              )
            : const Center(
                child: Text('No images available'),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _create();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
