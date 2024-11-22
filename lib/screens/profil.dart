import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final String fatPercentage = "Bilgi Yok"; // Yağ oranı değeri
  final String BMI = "Bilgi Yok"; // BMI değeri
  final String Kcal = "Bilgi Yok"; // Günlük Kalori değeri

  bool isEditMode = false; // Düzenleme modu

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      nameController.text = prefs.getString('name') ?? '';
      ageController.text = prefs.getString('age') ?? '';
      heightController.text = prefs.getString('height') ?? '';
      weightController.text = prefs.getString('weight') ?? '';

      String? imagePath = prefs.getString('profile_image');
      if (imagePath != null && imagePath.isNotEmpty) {
        _profileImage = File(imagePath);
      }
    });
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', nameController.text);
    await prefs.setString('age', ageController.text);
    await prefs.setString('height', heightController.text);
    await prefs.setString('weight', weightController.text);

    if (_profileImage != null) {
      await prefs.setString('profile_image', _profileImage!.path);
    }
  }

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
                    await _saveProfileData();
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
                    await _saveProfileData();
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
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        setState(() {});
                        await _saveProfileData();
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
      body: Padding(
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
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nameController.text.isEmpty ? 'İsim Soyisim' : nameController.text,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (isEditMode)
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editField('Ad Soyad', nameController),
                  ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3, // Sağlı sollu üç sütun
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildInfoTile('Yaş', ageController.text, 'Yaş', ageController),
                  _buildInfoTile('Boy (cm)', heightController.text, 'Boy (cm)', heightController),
                  _buildInfoTile('Kilo (kg)', weightController.text, 'Kilo (kg)', weightController),
                  _buildReadOnlyTile('Yağ Oranı', fatPercentage),
                  _buildReadOnlyTile('BMI', BMI),
                  _buildReadOnlyTile('Günlük Kalori', Kcal),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: isEditMode ? Colors.green : Colors.blue,
        child: Icon(isEditMode ? Icons.done : Icons.edit),
        onPressed: () {
          setState(() {
            isEditMode = !isEditMode; // Düzenleme modunu aç/kapat
          });
        },
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, String label, TextEditingController controller) {
    return Card(
      margin: EdgeInsets.all(4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text(value.isEmpty ? 'Bilgi Yok' : value, style: TextStyle(color: Colors.grey[600])),
          if (isEditMode)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editField(label, controller),
            ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyTile(String title, String value) {
    return Card(
      margin: EdgeInsets.all(4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text(value, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
