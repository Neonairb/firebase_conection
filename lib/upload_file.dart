import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadImage extends StatefulWidget {
  const UploadImage({super.key});

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  final TextEditingController _idController = TextEditingController();

  // Colleccion dentro de Firestone Database
  final CollectionReference _items =
      FirebaseFirestore.instance.collection('images');

  String imageUrl = '';

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
                        final file = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (file == null) return;

                        // Aqui hay que especificar la ID de la imagen para asi
                        // poder sobreescribirla en un futuro
                        String fileName =
                            DateTime.now().microsecondsSinceEpoch.toString();

                        // Coleccion dentro del Strorage de la database
                        Reference referenceRoot =
                            FirebaseStorage.instance.ref();
                        Reference referenceDireImages =
                            referenceRoot.child('images').child(fileName);

                        try {
                          // Aqui especificamos el tipo de la imagen para que firebase lo reconozca como tal
                          await referenceDireImages.putFile(
                            File(file.path),
                            SettableMetadata(
                                contentType:
                                    'image/jpeg'), // Ajusta el tipo MIME según el formato de la imagen
                          );

                          String url =
                              await referenceDireImages.getDownloadURL();
                          print(url);
                        } catch (e) {
                          print(e);
                        }
                      },
                      icon: const Icon(Icons.add_a_photo)),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                        onPressed: () async {
                          final String id = _idController.text;
                          // await _items.add({
                          //   'id': id,
                          //   'url': imageUrl
                          // });
                          _idController.text = '';
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                                                },
                        child: const Text('Create')),
                  ),
                ],
              ));
        });
  }

  late Stream<QuerySnapshot> _stream;

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance.collection('images').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Upload and display items'),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: _stream,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong ${snapshot.error}');
              }
              if (snapshot.hasData) {
                QuerySnapshot querySnapshot = snapshot.data;
                List<QueryDocumentSnapshot> document = querySnapshot.docs;

                List<Map> items = document.map((e) => e.data() as Map).toList();

                return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map thisItems = items[index];
                      return ListTile(
                        title: Text(thisItems['name']),
                        subtitle: Text(thisItems['number'].toString()),
                        leading: CircleAvatar(
                          radius: 27,
                          backgroundImage: NetworkImage(thisItems['url']),
                        ),
                      );
                    });
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _create();
          },
          child: const Icon(Icons.add),
        ));
  }
}
