import 'dart:io';
import 'package:fitpil/pages/blog_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  _MenuDrawerState createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  String name = 'Bilinmiyor'; // Varsayılan ad
  String profileImage = 'images/user_icon.png'; // Varsayılan resim yolu

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
        color: Colors.white24,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                colors: [Colors.green, Colors.greenAccent],
              )),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60, // Profil resmi çapı
                    backgroundImage: profileImage.isNotEmpty
                        ? FileImage(
                            File(profileImage)) // Profil resmi dosyadan çekilir
                        : const AssetImage('assets/default_user.png')
                            as ImageProvider, // Varsayılan resim
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
            ListTile(
              title: const Text('Blog'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BloggerPostsPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Seçenek 2'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Seçenek 3'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
