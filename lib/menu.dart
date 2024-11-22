import 'package:flutter/material.dart';

class MenuDrawer extends StatelessWidget {
  // Örnek profil resmi URL'si
  final String _profileImage = 'https://example.com/profile_image.jpg'; // Burada profil resmi URL'sini kullanabilirsiniz.

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.5,  // Yarım sayfa genişliği
      child: Container(
        color: Colors.greenAccent,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,  // Profil resmi çapı
                    backgroundImage: NetworkImage(_profileImage),  // Profil resmi URL'si
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Kullanıcı Adı',  // Buraya kullanıcının adı eklenebilir
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
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
