import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuDrawer extends StatefulWidget {
  @override
  _MenuDrawerState createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  String name = 'Bilinmiyor'; // Varsayılan ad
  String profileImage = 'images/user_icon.png';  // Varsayılan resim yolu

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Veriyi yükle
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString('name') ?? 'Bilinmiyor';
      profileImage = prefs.getString('profile_image') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.5, // Yarım sayfa genişliği
      child: Container(
        color: Colors.greenAccent,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50, // Profil resmi çapı
                    backgroundImage: profileImage.isNotEmpty
                        ? FileImage(File(profileImage)) // Profil resmi dosyadan çekilir
                        : AssetImage('assets/default_user.png') as ImageProvider, // Varsayılan resim
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
            ListTile(
              title: Text('Seçenek 1'),
              onTap: () {},
            ),
            ListTile(
              title: Text('Seçenek 2'),
              onTap: () {},
            ),
            ListTile(
              title: Text('Seçenek 3'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
