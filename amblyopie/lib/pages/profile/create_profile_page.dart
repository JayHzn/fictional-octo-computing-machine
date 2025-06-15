import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({super.key});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _lastNameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String? _gender;
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;

  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;
  String? _error;

  Future<void> _pickFromGallery() async {
    final img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() {
        _pickedImage = img;
        _pickedImageBytes = bytes;});
    }
  }

  Future<void> _takePhoto() async {
    final img = await _picker.pickImage(source: ImageSource.camera);
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() {
        _pickedImage = img;
        _pickedImageBytes = bytes;});
    }
  }

  Future<String?> _uploadPhoto(String uid, String profileId) async {
    if (_pickedImage == null) return null;

    final path = 'users/$uid/profiles/$profileId.jpg';
    final ref = FirebaseStorage.instance.ref(path);
    if (kIsWeb) {
      // Web : On lit en mémoire
      final bytes = await _pickedImage!.readAsBytes();
      await ref.putData(bytes);
    } else {
      // Mobile : On envoie le file
      await ref.putFile(File(_pickedImage!.path));
    }
    return ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {_isSaving = true; _error = null;});
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final profileRef = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('profiles');
    final docRef = profileRef.doc();

    try {
      // Upload photo
      final photoUrl = await _uploadPhoto(uid, docRef.id) ?? '';

      // Enregistrer en Firestore
      await docRef.set({
        'lastName' : _lastNameCtrl.text.trim(),
        'firstName' : _firstNameCtrl.text.trim(),
        'age' : int.parse(_ageCtrl.text),
        'gender' : _gender,
        'photoUrl' : photoUrl,
        'createdAt' : FieldValue.serverTimestamp(),
      });

      Navigator.pop(context); // Retourne à la page précédente

    } on FirebaseException catch (e) {
      setState(() => _error = '[Firestore:${e.code}] ${e.message}');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() =>_isSaving = false);
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _lastNameCtrl,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) => (v?.isEmpty ?? true) ? 'Requis' : null,
              ),
              TextFormField(
                controller: _firstNameCtrl,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (v) => (v?.isEmpty ?? true) ? 'Requis' : null,
              ),
              TextFormField(
                controller: _ageCtrl,
                decoration: const InputDecoration(labelText: 'Âge'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 0) return 'Âge invalide';
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Sexe'),
                items: ['Garçon', 'Fille', 'Autre']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
                onChanged: (v) => setState(() => _gender = v),
                validator: (v) => v == null ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              _pickedImage == null
                ? const Placeholder(fallbackHeight: 150)
                : kIsWeb
                  ? (_pickedImageBytes != null
                      ? Image.memory(_pickedImageBytes!, height: 150)
                      : const SizedBox(height: 150)
                    )
                  : Image.file(
                    File(_pickedImage!.path),
                    height: 150,
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo),
                    label: const Text('Galerie'),
                  ),
                  TextButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Caméra'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _isSaving
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('Enregistrer le profil'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}