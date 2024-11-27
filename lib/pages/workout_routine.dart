import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(MaterialApp(
    home: WorkoutPage(),
  ));
}

class DynamicPage extends StatefulWidget {
  final int pageId;
  final String title;
  final IconData icon;
  final Color iconColor;

  DynamicPage(
      {required this.pageId,
      required this.title,
      required this.icon,
      required this.iconColor});
  @override
  State<DynamicPage> createState() => _DynamicPageState();
}

class _DynamicPageState extends State<DynamicPage> {
  List<Map<String, dynamic>> exercises = [];
  int exerciseCount = 1;
  TextEditingController _exerciseController = TextEditingController();
  TextEditingController _setsController = TextEditingController();
  TextEditingController _repsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() async {
    final dbExercises =
        await DatabaseHelper.instance.fetchExercises(widget.pageId);
    setState(() {
      exercises = List<Map<String, dynamic>>.from(dbExercises);
    });
  }

  void _addExercise() async {
    if (_exerciseController.text.isNotEmpty) {
      final newExercise = {
        'pageId': widget.pageId,
        'title': _exerciseController.text,
        'sets': _setsController.text,
        'reps': _repsController.text,
        'order': exercises.length,
      };

      await DatabaseHelper.instance.insertExercise(newExercise);

      _loadExercises();
      _exerciseController.clear();
      _setsController.clear();
      _repsController.clear();
    }
  }

  void _deleteExercise(int index) async {
    final exerciseId = exercises[index]['id'];
    await DatabaseHelper.instance.deleteExercise(exerciseId);
    _loadExercises();
  }

  void _editExerciseDialog(int index) {
    _exerciseController.text = exercises[index]['title'];
    _repsController.text = exercises[index]['reps'].toString();
    _setsController.text = exercises[index]['sets'].toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Egzersizi Düzenle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sayfa ismi girişi
              TextField(
                controller: _exerciseController,
                decoration: InputDecoration(
                  labelText: "Egzersiz İsmi",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _setsController,
                      decoration: InputDecoration(
                        labelText: "Set Sayısı",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: TextField(
                      controller: _repsController,
                      decoration: InputDecoration(labelText: "Tekrar Sayısı"),
                    ),
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
                _editExercise(index);
                Navigator.pop(context); // Dialog'u kapat
              },
              child: Center(
                child: Text(
                  "Egzersizi Güncelleyin",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editExercise(int index) async {
    final exerciseId = exercises[index]['id'];
    final updatedExercise = {
      'title': _exerciseController.text,
      'sets': _setsController.text,
      'reps': _repsController.text,
    };

    await DatabaseHelper.instance.updateExercise(updatedExercise, exerciseId);
    setState(() {
      exercises[index] = {'id': exerciseId, ...updatedExercise};
    });
    _loadExercises();
  }

  void _onReorderInRoutines(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final exercise = exercises.removeAt(oldIndex);
      exercises.insert(newIndex, exercise);
    });

    await _saveOrderToDatabase();
  }

  Future<void> _saveOrderToDatabase() async {
    for (int i = 0; i < exercises.length; i++) {
      await DatabaseHelper.instance.updateExerciseOrder(
        exercises[i]['id'], // Egzersizin ID'si
        i, // Yeni sırası
      );
    }
  }

  void _createExercise() {
    _exerciseController.clear();
    _setsController.clear();
    _repsController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Egzersiz Oluşturun"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sayfa ismi girişi
              TextField(
                controller: _exerciseController,
                decoration: InputDecoration(
                  labelText: "Egzersiz İsmi",
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _setsController,
                      decoration: InputDecoration(
                        labelText: "Set Sayısı",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: TextField(
                      controller: _repsController,
                      decoration: InputDecoration(labelText: "Tekrar Sayısı"),
                    ),
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
                  _addExercise();
                  Navigator.pop(context); // Dialog'u kapat
                },
                child: Text(
                  "Egzersizi Kaydet",
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
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Pacifico',
                          color: Colors.white70,
                        ),
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
      body: ReorderableListView(
        onReorder: _onReorderInRoutines,
        children: [
          for (int index = 0; index < exercises.length; index++)
            ListTile(
              key: ValueKey(exercises[index]['id']),
              leading: ReorderableDragStartListener(
                index: index,
                child: Icon(
                  Icons.drag_handle,
                  color: Colors.orangeAccent,
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercises[index]['title'],
                    style: TextStyle(fontSize: 18.0),
                  ),
                  Text(
                    "${exercises[index]['sets']}x${exercises[index]['reps']}",
                    style: TextStyle(fontSize: 14.0, color: Colors.blueGrey),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      print("deneme");
                      _editExerciseDialog(index);
                    },
                    icon:
                        Icon(Icons.edit, color: Colors.orangeAccent, size: 20),
                  ),
                  IconButton(
                    onPressed: () {
                      _deleteExercise(index);
                    },
                    icon: Icon(Icons.delete, color: Colors.red, size: 20),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightGreen,
        onPressed: _createExercise,
        child: Icon(Icons.add),
        tooltip: "Yeni Egzersiz ekle",
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

  void _addPage() async {
    if (_pageController.text.isNotEmpty) {
      final newPage = {
        'title': _pageController.text,
        'icon': _selectedIcon.codePoint.toString(),
        'iconColor': _iconColor.value.toString(),
      };
      int id = await DatabaseHelper.instance.insertPage(newPage);
      setState(() {
        pages.add({
          'id': id,
          'title': newPage['title']!,
          'icon': IconData(
            int.parse(newPage['icon']!), // Null olmama garantisi
            fontFamily: 'MaterialIcons',
          ),
          'iconColor':
              Color(int.parse(newPage['iconColor']!)), // Null olmama garantisi
        });
      });

      _pageController.clear(); // Sayfa ismini temizle
      _selectedIcon = Icons.fitness_center; // Varsayılan ikon
      _iconColor = Colors.blue; // Varsayılan renk
    }
  }

  void _deletePage(int index) async {
    final pageId = pages[index]['id'];
    await DatabaseHelper.instance.deletePage(pageId);
    setState(() {
      pages.removeAt(index); // Sayfayı sil
    });
  }

  void _deletePageDialog(int index) {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text("Sil"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [Text("${pages[index]['title']} silinsin mi?")],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  _deletePage(index);
                  Navigator.pop(dialogContext);
                },
                child: Text("Sil"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: Text("Kapat"),
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  void _loadPages() async {
    final dbPages = await DatabaseHelper.instance.fetchPages();
    setState(() {
      pages = dbPages.map((page) {
        return {
          'id': page['id'],
          'title': page['title'],
          'icon':
              IconData(int.parse(page['icon']), fontFamily: 'MaterialIcons'),
          'iconColor': Color(int.parse(page['iconColor'])),
        };
      }).toList();
    });
  }

  void _editPage(int index) {
    // İlk olarak düzenleme için mevcut veriyi TextField'a yükle
    _pageController.text = pages[index]['title'];
    _selectedIcon = pages[index]['icon'];
    _iconColor = pages[index]['iconColor'];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text("Rutini Düzenle"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _pageController,
                  decoration: InputDecoration(
                    labelText: "Rutin İsmi",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                // İkon seçimi
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.fitness_center, size: 40),
                      color: _selectedIcon == Icons.fitness_center
                          ? _iconColor
                          : Colors.grey,
                      onPressed: () {
                        setState(() {
                          _selectedIcon = Icons.fitness_center;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.directions_run, size: 40),
                      color: _selectedIcon == Icons.directions_run
                          ? _iconColor
                          : Colors.grey,
                      onPressed: () {
                        setState(() {
                          _selectedIcon = Icons.directions_run;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.self_improvement, size: 40),
                      color: _selectedIcon == Icons.self_improvement
                          ? _iconColor
                          : Colors.grey,
                      onPressed: () {
                        setState(() {
                          _selectedIcon = Icons.self_improvement;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // İkon rengi seçimi
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.circle, color: Colors.blue, size: 30),
                      onPressed: () {
                        setState(() {
                          _iconColor = Colors.blue;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.circle, color: Colors.red, size: 30),
                      onPressed: () {
                        setState(() {
                          _iconColor = Colors.red;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.circle, color: Colors.green, size: 30),
                      onPressed: () {
                        setState(() {
                          _iconColor = Colors.green;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.circle, color: Colors.orange, size: 30),
                      onPressed: () {
                        setState(() {
                          _iconColor = Colors.orange;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // Veritabanında güncelle
                  _updatePageInDatabase(index);

                  // Dialog'u kapat
                  Navigator.pop(dialogContext);
                },
                child: Text(
                  "Güncelle",
                  style: TextStyle(color: Colors.black, fontSize: 16.0),
                ),
              ),
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () {
                  Navigator.pop(dialogContext); // İptal
                },
                child: Text(
                  "İptal",
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updatePageInDatabase(int index) async {
    final updatedPage = {
      'title': _pageController.text,
      'icon': _selectedIcon.codePoint.toString(),
      'iconColor': _iconColor.value.toString(),
    };

    final pageId = pages[index]['id'];
    await DatabaseHelper.instance.updatePage(updatedPage, pageId);

    setState(() {
      pages[index] = {
        'id': pageId,
        'title': updatedPage['title']!,
        'icon': IconData(
          int.parse(updatedPage['icon']!),
          fontFamily: 'MaterialIcons',
        ),
        'iconColor': Color(int.parse(updatedPage['iconColor']!)),
      };
    });
  }

  void _showDialog() {
    _pageController.clear();
    _selectedIcon = Icons.fitness_center;
    _iconColor = Colors.blue;
    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
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
                    IconButton(
                      icon: Icon(
                        Icons.self_improvement,
                        size: 40,
                        color: _iconColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedIcon = Icons.self_improvement;
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                    _deletePageDialog(index);
                    // Navigator.pop(context);
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
                    pageId: pages[index]['id'],
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
