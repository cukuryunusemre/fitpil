import 'package:fitpil/screens/workout_routine.dart';
import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'pages/profil.dart';
import 'screens/progress_page.dart';
import 'dart:async';
import 'pages/menu.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        '/profile': (context) => WorkoutPage(),
        '/progress': (context) => ProgressPage(),
      },
    );
  }
}

Future<void> checkPermissions() async {
  // Kamera izni kontrolü
  var cameraStatus = await Permission.camera.status;
  if (cameraStatus.isDenied) {
    await Permission.camera.request();
  }

  // Konum izni kontrolü
  var locationStatus = await Permission.location.status;
  if (locationStatus.isDenied) {
    await Permission.location.request();
  }

  // Kalıcı olarak reddedilmişse, ayarlara yönlendirme
  if (cameraStatus.isPermanentlyDenied || locationStatus.isPermanentlyDenied) {
    await openAppSettings();
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Splash ekranından ana menüye yönlendirme
    Timer(const Duration(seconds: 3), () async {
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
            const SizedBox(height: 20),
            const Text(
              "Fit Pill",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pacifico',
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
                color: Colors.green), // Yükleme animasyonu
          ],
        ),
      ),
    );
  }
}

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int _selectedIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);
  String profileImage = 'images/user_icon.png'; // Varsayılan resim yolu

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Veriyi yükle
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      profileImage = prefs.getString('profile_image') ?? '';
    });
  }

  final List<Widget> _pages = [
    ProgressPage(),
    HomePage(),
    WorkoutPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String? profileImageUrl = null;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.greenAccent],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: profileImage.isNotEmpty
                            ? FileImage(File(
                                profileImage)) // Profil resmi dosyadan çekilir
                            : AssetImage('assets/default_user.png')
                                as ImageProvider, // Varsayılan resim
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    icon: const Icon(Icons.menu),
                  ),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Fit Pill",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pacifico',
                        color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer(); // Sağdaki menüyü aç
            },
          ),
        ],
      ),
      endDrawer: MenuDrawer(),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: GNav(
          gap: 8, // Simge ve yazı arasındaki boşluk
          activeColor: Colors.lightGreenAccent[700], // Seçili öğe rengi
          iconSize: 25, // Simge boyutu
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          duration: const Duration(milliseconds: 400), // Animasyon süresi
          tabBackgroundColor: Colors.lightGreenAccent.withOpacity(0.3), // Seçili öğe arka plan rengi
          tabs: const [
            GButton(
              icon: Icons.analytics,
              text: 'Takip',
            ),
            GButton(
              icon: Icons.home,
              text: 'Ana Sayfa',
            ),
            GButton(
              icon: FontAwesomeIcons.dumbbell,
              text: ' Antrenman',
            ),

          ],
          selectedIndex: _selectedIndex,
          onTabChange: _onItemTapped,
        ),
      ),
    );
  }
}

class SetupScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Bilgileri'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'İsim Soyisim'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Yaş'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Boy (cm)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Kilo (kg)'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('name', nameController.text);
                prefs.setString('age', ageController.text);
                prefs.setString('height', heightController.text);
                prefs.setString('weight', weightController.text);
                prefs.setBool('isFirstLaunch', false);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainMenu()),
                );
              },
              child: const Text('Kaydet ve Devam Et'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainMenu()),
                );
              },
              child: const Text('Atla ve Devam Et'),
            ),
          ],
        ),
      ),
    );
  }
}
