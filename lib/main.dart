import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/profil.dart';
import 'screens/progress_page.dart';
import 'dart:async';
import 'menu.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fit Pill',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Splash Screen başlangıç rotası
      routes: {
        '/': (context) => SplashScreen(),
        '/main_menu': (context) => MainMenu(),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
        '/progress': (context) => ProgressPage(),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Splash ekranından ana menüye yönlendirme
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/main_menu');
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/maskot1.png', // Logonuzun yolu
              width: 150, // Splash ekranı logo genişliği
              height: 150, // Splash ekranı logo yüksekliği
            ),
            SizedBox(height: 20),
            Text(
              "Fit Pill",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pacifico',
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
                color: Colors.green), // Yükleme animasyonu
          ],
        ),
      ),
    );
  }
}

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int _selectedIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);

  final List<Widget> _pages = [
    ProgressPage(),
    HomePage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Fit Pill',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pacifico',
                color: Colors.white70,
              ),
            ),
          ],
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green,
                Colors.greenAccent,
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();  // Sağdaki menüyü aç
            },
          ),
        ],
      ),
      endDrawer: MenuDrawer(),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Takip',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 45),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightGreenAccent[700],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
