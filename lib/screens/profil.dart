import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitpil/utils/permission.dart';
import 'package:fitpil/utils/snackbar_helper.dart';
import 'package:fitpil/pages/fat_rate.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  File? _profileImage;

  String fatPercentage = "Bilgi Yok"; // Yağ oranı değeri
  final String BMI = " "; // BMI değeri
  String Kcal = "Bilgi Yok"; // Günlük Kalori değeri

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
      Kcal = prefs.getString('Kcal') ?? 'Bilgi Yok';
      fatPercentage = prefs.getString('fatPercentage') ?? 'Bilgi Yok';

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Resim Kaynağı Seç',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Kameradan Çek'),
                onTap: () async {
                  bool isGranted =
                      await requestCameraPermission(); // Kamera iznini kontrol et
                  if (isGranted) {
                    Navigator.pop(context);
                    final pickedFile = await ImagePicker()
                        .pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      setState(() {
                        _profileImage = File(pickedFile.path);
                      });
                      await _saveProfileData();
                    }
                  } else {
                    SnackbarHelper.show(
                      context,
                      message: 'Kamera izni gerekli!',
                      icon: Icons.camera_alt_outlined,
                      backgroundColor: Colors.redAccent,
                    );
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Galeriden Seç'),
                onTap: () async {
                  bool isGranted =
                      await requestStoragePermission(); // Depolama iznini kontrol et
                  if (isGranted) {
                    Navigator.pop(context); // Dialog'u kapat
                    final pickedFile = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _profileImage = File(pickedFile.path);
                      });
                      await _saveProfileData(); // Veriyi kaydet
                    }
                  } else {
                    SnackbarHelper.show(
                      context,
                      message: 'Depolama izni gerekli!',
                      icon: Icons.storage_outlined,
                      backgroundColor: Colors.redAccent,
                    );
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
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: label,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: label == 'Yaş' ||
                            label == 'Boy (cm)' ||
                            label == 'Kilo (kg)'
                        ? TextInputType.number
                        : TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '$label boş olamaz.';
                      }
                      if ((label == 'Yaş' ||
                              label == 'Boy (cm)' ||
                              label == 'Kilo (kg)') &&
                          int.tryParse(value) == null) {
                        return 'Geçerli bir $label giriniz.';
                      }
                      if (label == 'Yaş' &&
                          (int.parse(value) <= 10 || int.parse(value) > 100)) {
                        return 'Yaş 10 ile 100 arasında olmalıdır.';
                      }
                      if (label == 'Kilo (kg)' &&
                          (int.parse(value) < 10 || int.parse(value) > 635)) {
                        return 'Kilo 10 ile 635 arasında olmalıdır.';
                      }
                      if (label == 'Boy (cm)' &&
                          (int.parse(value) < 50 || int.parse(value) > 250)) {
                        return 'Boy 50 ile 250 arasında olmalıdır.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        setState(() {});
                        await _saveProfileData();
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Kaydet'),
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
              onTap: () {
                if (_profileImage != null) {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierColor: Colors.black.withOpacity(0.8),
                    builder: (BuildContext context) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Center(
                          child: Hero(
                            tag: 'profile_photo',
                            child: Material(
                              color: Colors.transparent,
                              child: ClipOval(
                                child: Image.file(
                                  _profileImage!,
                                  width: 300,
                                  height: 300,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Hero(
                    tag: 'profile_photo',
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage('images/user_icon.png') as ImageProvider,
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: _showImageSourceSheet,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nameController.text.isEmpty
                      ? 'İsim Soyisim'
                      : nameController.text,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (isEditMode)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editField('Ad Soyad', nameController),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              // Burası GridView'e doğru alan sağlayacak
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9, // Kutu boyutunu daha dengeli yapar
                children: [
                  _buildInfoTile(
                      'Yaş', ageController.text, 'Yaş', ageController),
                  _buildInfoTile('Boy (cm)', heightController.text, 'Boy (cm)',
                      heightController),
                  _buildInfoTile('Kilo (kg)', weightController.text,
                      'Kilo (kg)', weightController),
                  _buildReadOnlyTile('Yağ Oranı', fatPercentage,color: _getFatPercentageColor(fatPercentage)),
                  _buildReadOnlyTile('BMI', _calculateBMI(), color: _getBMIColor()),
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

  Widget _buildInfoTile(String title, String value, String label,
      TextEditingController controller) {
    return Card(
      color: Colors.greenAccent,
      margin: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600,color: Colors.white)),
          const SizedBox(height: 8),
          Text(value.isEmpty ? 'Bilgi Yok' : value,
              style: TextStyle(color: Colors.white)),
          if (isEditMode)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editField(label, controller),
            ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyTile(String title, String value,{Color? color}) {
    return Card(
      color: color ?? Colors.blueAccent[200],
      margin: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600,color: Colors.white)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
  String _calculateBMI() {
    if (heightController.text.isNotEmpty && weightController.text.isNotEmpty) {
      final double heightInMeters = double.parse(heightController.text) / 100;
      final double weight = double.parse(weightController.text);

      if (heightInMeters > 0 && weight > 0) {
        final double bmi = weight / (heightInMeters * heightInMeters);

        if (bmi < 18.5) {
          return 'Zayıf (${bmi.toStringAsFixed(1)})';
        } else if (bmi >= 18.5 && bmi < 25) {
          return 'Normal (${bmi.toStringAsFixed(1)})';
        } else if (bmi >= 25 && bmi < 30) {
          return 'Kilolu (${bmi.toStringAsFixed(1)})';
        } else if (bmi >=30 && bmi <40){
          return 'Obez (${bmi.toStringAsFixed(1)})';
        }else{
          return  'Morbid Obez(${bmi.toStringAsFixed(1)})';
    }
      }
    }
    return 'Bilgi Yok';
  }

  Color _getBMIColor() {
    if (heightController.text.isNotEmpty && weightController.text.isNotEmpty) {
      final double heightInMeters = double.parse(heightController.text) / 100;
      final double weight = double.parse(weightController.text);

      if (heightInMeters > 0 && weight > 0) {
        final double bmi = weight / (heightInMeters * heightInMeters);

        if (bmi < 18.5) {
          return Colors.redAccent; // Zayıf
        } else if (bmi >= 18.5 && bmi < 25) {
          return Colors.green; // Normal
        } else if (bmi >= 25 && bmi < 30) {
          return Colors.orange; // Kilolu
        } else if (bmi >= 30 && bmi < 40) {
          return Colors.red; // obez
        } else {
          return Color.fromARGB(255, 128, 0, 0); // Morbidobez
        }
      }
    }
    return Colors.blueAccent; // Bilgi Yok
  }

  Color _getFatPercentageColor(String fatPercentage) {
    // Ensure the value is numeric, otherwise return a default color.
    double fat = double.tryParse(fatPercentage.replaceAll('%', '')) ?? 0;

    if (fat <= 7 && fat > 0) {
      return Colors.red;
    }else if(fat > 7 && fat <= 15){
      return Colors.green;
    } else if (fat > 15 && fat <= 20) {
      return Colors.orange;
    }else if (fat > 20 && fat <= 25) {
      return Colors.red;
    } else if (fat > 25) {
      return Color.fromARGB(255, 128, 0, 0);
    }

    return Colors.blueAccent;
  }

}

