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
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Kullanıcı girişleri için kontrolörler
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController bloodTypeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  File? _profileImage; // Seçilen profil fotoğrafı

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path); // Seçilen fotoğrafı kaydet
      });
    }
  }

  // Form doğrulaması
  bool _validateForm() {
    if (nameController.text.isEmpty ||
        ageController.text.isEmpty ||
        heightController.text.isEmpty ||
        weightController.text.isEmpty ||
        bmiController.text.isEmpty ||
        bloodTypeController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty) {
      return false;
    }

    // Yaş kontrolü
    if (int.tryParse(ageController.text) == null) {
      return false;
    }

    // E-posta kontrolü
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text)) {
      return false;
    }

    // Telefon numarası kontrolü
    if (phoneController.text.length != 10) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profil Fotoğrafı
            GestureDetector(
              onTap: _pickImage, // Resim seçme
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!) // Seçilen resim
                    : AssetImage('images/user_icon.png')
                as ImageProvider, // Varsayılan resim
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
            SizedBox(height: 16),

            // Profil Bilgileri Görüntüleme
            Divider(),
            _buildInfoTile('Ad Soyad', nameController.text),
            _buildInfoTile('Yaş', ageController.text),
            _buildInfoTile('Boy ve Kilo', '${heightController.text}cm | ${weightController.text}kg'),
            _buildInfoTile('BMI', bmiController.text),
            _buildInfoTile('E-posta', emailController.text),
            _buildInfoTile('Telefon', phoneController.text),
            Divider(),

            // Profil Düzenleme Butonu
            ElevatedButton(
              onPressed: () {
                // Düzenleme ekranına geçiş
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Profil Düzenle'),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildInputField('Ad Soyad', nameController),
                            _buildInputField('Yaş', ageController),
                            _buildInputField('Boy (cm)', heightController),
                            _buildInputField('Kilo (kg)', weightController),
                            _buildInputField('Vücut Kitle Endeksi (BMI)', bmiController),
                            _buildInputField('E-posta', emailController),
                            _buildInputField('Telefon', phoneController),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // Formu kontrol et
                            if (_validateForm()) {
                              setState(() {
                                Navigator.of(context).pop(); // Düzenlemeyi kapat
                              });
                            } else {
                              // Hata mesajı
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lütfen tüm alanları doğru girin!')),
                              );
                            }
                          },
                          child: Text('Güncelle'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Kapat
                          },
                          child: Text('İptal'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Profil Düzenle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: label == 'Yaş' || label == 'Boy (cm)' || label == 'Kilo (kg)' || label == 'Telefon'
            ? TextInputType.number
            : TextInputType.text,
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value.isEmpty ? 'Bilgi Yok' : value,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
