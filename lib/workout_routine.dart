import 'package:flutter/material.dart';

// page içine egzersiz ekleme yapılacak

void main() {
  runApp(MaterialApp(
    home: WorkoutPage(),
  ));
}

class DynamicPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;

  DynamicPage(
      {required this.title, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: Icon(icon, color: iconColor),
      ),
      body: Center(
        child: Text(
          "$title İçeriği",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class WorkoutPage extends StatefulWidget {
  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  List<Map<String, dynamic>> pages = [];
  int pageCount = 1;
  IconData _selectedIcon = Icons.fitness_center;
  Color _iconColor = Colors.blue;
  TextEditingController _pageController = TextEditingController();

  void _addPage() {
    if (_pageController.text.isNotEmpty) {
      setState(() {
        pages.add({
          'title': _pageController.text,
          'icon': _selectedIcon,
          'iconColor': _iconColor,
        });
        _pageController.clear(); // Sayfa ismini temizle
        _selectedIcon = Icons.fitness_center; // Varsayılan ikon
        _iconColor = Colors.blue; // Varsayılan renk
      });
    }
  }

  void _deletePage(int index) {
    setState(() {
      pages.removeAt(index); // Sayfayı sil
    });
  }

  void _editPage(int index) {
    _pageController.text = pages[index]['title'];
    _selectedIcon = pages[index]['icon'];
    _iconColor = pages[index]['iconColor'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Rutini Düzenle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sayfa ismi girişi
              TextField(
                controller: _pageController,
                decoration: InputDecoration(
                  labelText: "Rutin İsmi",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              // İkon seçimi
              Text("İkon"),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.fitness_center,
                      size: 40,
                      color: _selectedIcon == Icons.fitness_center
                          ? _iconColor
                          : Colors.grey, // Seçilen ikona rengini uygula
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedIcon = Icons.fitness_center;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.directions_run,
                      size: 40,
                      color: _selectedIcon == Icons.directions_run
                          ? _iconColor
                          : Colors.grey, // Seçilen ikona rengini uygula
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedIcon = Icons.directions_run;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              // İkon rengi seçimi
              Text("İkon Rengi"),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.circle,
                      color: Colors.blue,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        _iconColor = Colors.blue;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.circle,
                      color: Colors.red,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        _iconColor = Colors.red;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.circle,
                      color: Colors.green,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        _iconColor = Colors.green;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.circle,
                      color: Colors.deepOrangeAccent,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        _iconColor = Colors.deepOrangeAccent;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
              onPressed: () {
                setState(() {
                  // Sayfa bilgilerini güncelle
                  pages[index] = {
                    'title': _pageController.text,
                    'icon': _selectedIcon,
                    'iconColor': _iconColor,
                  };
                });
                Navigator.pop(context); // Dialog'u kapat
              },
              child: Center(
                child: Text(
                  "Rutini Güncelleyin",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Rutin Oluşturun"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sayfa ismi girişi
              TextField(
                controller: _pageController,
                decoration: InputDecoration(
                  labelText: "Rutin İsmi",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              // İkon seçimi
              Text("İkon"),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.fitness_center,
                      size: 40,
                      color: _iconColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedIcon = Icons.fitness_center;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.directions_run,
                      size: 40,
                      color: _iconColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedIcon = Icons.directions_run;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              // İkon rengi seçimi
              Text("İkon Rengi"),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.circle,
                      color: Colors.blue,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        _iconColor = Colors.blue;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.circle,
                      color: Colors.red,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        _iconColor = Colors.red;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.circle,
                      color: Colors.green,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        _iconColor = Colors.green;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.circle,
                      color: Colors.deepOrangeAccent,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        _iconColor = Colors.deepOrangeAccent;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen),
                onPressed: () {
                  _addPage();
                  Navigator.pop(context); // Dialog'u kapat
                },
                child: Text(
                  "Rutini Kaydet",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Varsayılan leading özelliğini devre dışı bırak
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green, // Başlangıç rengi
                Colors.greenAccent, // Bitiş rengi
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Geri Dön Butonu
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Başlık ve İkon
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                        size: 50,
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: pages.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(
              pages[index]['icon'],
              color: pages[index]['iconColor'],
              size: 40,
            ),
            title: Text(
              pages[index]['title'],
              style: TextStyle(fontSize: 18),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    _editPage(index);
                  },
                  icon: Icon(
                    Icons.edit,
                    color: pages[index]['iconColor'],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _deletePage(index);
                  },
                  icon: Icon(
                    Icons.delete,
                    color: pages[index]['iconColor'],
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DynamicPage(
                    title: pages[index]['title'],
                    icon: pages[index]['icon'],
                    iconColor: pages[index]['iconColor'],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightGreen,
        onPressed: _showDialog,
        child: Icon(Icons.add),
        tooltip: "Yeni Sayfa ekle",
      ),
    );
  }
}
