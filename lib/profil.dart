import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  File? _profileImage;

  final String fatPercentage = " "; // Yağ oranı değeri
  final String BMI = " "; // BMI değeri

  bool isEditMode = false; // Düzenleme modu

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Resim Kaynağı Seç',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blue),
                title: Text('Kameradan Çek'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _profileImage = File(pickedFile.path);
                    });
                  }
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green),
                title: Text('Galeriden Seç'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _profileImage = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editField(String label, TextEditingController controller) {
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$label Düzenle',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: label,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: label == 'Yaş' || label == 'Boy (cm)' || label == 'Kilo (kg)'
                        ? TextInputType.number
                        : TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '$label boş olamaz.';
                      }
                      if (label == 'Ad Soyad' && !RegExp(r'^[a-zA-ZğüşöçİĞÜŞÖÇ\s]+$').hasMatch(value)) {
                        return 'Geçerli bir $label giriniz.';
                      }
                      if ((label == 'Yaş' || label == 'Boy (cm)' || label == 'Kilo (kg)') &&
                          int.tryParse(value) == null) {
                        return 'Geçerli bir $label giriniz.';
                      }
                      if (label == 'Yaş' && (int.tryParse(value)! <= 0 || int.tryParse(value)! > 100)) {
                        return 'Geçerli bir $label giriniz.';
                      }
                      if ((label == 'Kilo (kg)') && (int.tryParse(value)! <= 0 || int.tryParse(value)! > 635 )) {
                        return 'Geçerli bir $label giriniz.';
                      }
                      if (label == 'Boy (cm)' && (int.tryParse(value)! <= 0 || int.tryParse(value)! > 250 )){
                        return 'Geçerli bir $label giriniz.';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        setState(() {});
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Kaydet'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _showImageSourceSheet,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : AssetImage('images/user_icon.png') as ImageProvider,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 18,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildInfoTile('Ad Soyad', nameController.text, 'Ad Soyad', nameController),
                _buildInfoTile('Yaş', ageController.text, 'Yaş', ageController),
                _buildInfoTile('Boy (cm)', heightController.text, 'Boy (cm)', heightController),
                _buildInfoTile('Kilo (kg)', weightController.text, 'Kilo (kg)', weightController),
                _buildReadOnlyTile('Yağ Oranı', fatPercentage),
                _buildReadOnlyTile('Vücut Kitle İndeksi (BMI)', BMI),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: isEditMode ? Colors.green : Colors.blue,
              child: Icon(isEditMode ? Icons.done : Icons.edit),
              onPressed: () {
                setState(() {
                  isEditMode = !isEditMode; // Düzenleme modunu aç/kapat
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, String label, TextEditingController controller) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value.isEmpty ? 'Bilgi Yok' : value, style: TextStyle(color: Colors.grey[600])),
        trailing: isEditMode
            ? IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => _editField(label, controller),
        )
            : null,
      ),
    );
  }

  Widget _buildReadOnlyTile(String title, String value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value, style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }
}
