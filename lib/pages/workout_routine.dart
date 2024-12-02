import 'package:fitpil/pages/in_workout.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

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

  const DynamicPage(
      {super.key,
      required this.pageId,
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
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen),
                onPressed: () {
                  _editExercise(index);
                  Navigator.pop(context); // Dialog'u kapat
                },
                child: Text(
                  "Güncelle",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () {
                  Navigator.pop(context); // Dialog'u kapat
                },
                child: Text(
                  "Vazgeç",
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
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Expanded(
              flex: 2,
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
            Expanded(
              flex: 1,
              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () {
                  Navigator.pop(context); // Dialog'u kapat
                },
                child: Text(
                  "Vazgeç",
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
                widget.iconColor, // Başlangıç rengi
                Colors.red, // Bitiş rengi
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
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView(
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
                          style:
                              TextStyle(fontSize: 14.0, color: Colors.blueGrey),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            _editExerciseDialog(index);
                          },
                          icon: Icon(Icons.edit,
                              color: Colors.orangeAccent, size: 20),
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
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  width: 200,
                  height: 60,
                  margin: EdgeInsets.only(left: 25, bottom: 10, right: 0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.iconColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InWorkoutPage(
                            title: widget.title,
                            iconColor: widget.iconColor,
                            pageId: widget.pageId,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Başla",
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                        Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  width: 60,
                  height: 60,
                  // padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(bottom: 10, right: 0, left: 30),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [widget.iconColor, Colors.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    splashColor: Colors.transparent,
                    highlightElevation: 0,
                    hoverElevation: 0,
                    child: Icon(
                      widget.icon,
                      size: 30,
                      color: Colors.white70,
                    ),
                    onPressed: _createExercise,
                    tooltip: "Yeni Rutin Ekle",
                  ),
                ),
              ),
            ],
          ),
        ],
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
  int _pageCount = 1;
  IconData _selectedIcon = Icons.fitness_center;
  Color _iconColor = Colors.black;
  TextEditingController _pageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPages(); // Sayfaları yükle
    _loadPageCount(); // Toplam sayfa sayısını yükle
  }

  void _addPage() async {
    int currentPageCount = await DatabaseHelper.instance.getPageCount();

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
      _iconColor = Colors.black; // Varsayılan renk
    } else {
      _loadPageCount();
      final newPage = {
        'title': 'Rutin ${currentPageCount + 1}',
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
      _iconColor = Colors.black; // Varsayılan renk
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

  void _loadPageCount() async {
    final pageCount =
        await DatabaseHelper.instance.getPageCount(); // Sayfa sayısını al
    setState(() {
      _pageCount = pageCount; // Toplam sayfa sayısını bir state değişkenine ata
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _loadPages();
  //   _loadPageCount();
  // }

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
        return StatefulBuilder(builder: (context, setState) {
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
                      Expanded(
                        child: IconButton(
                          icon:
                              Icon(Icons.circle, color: Colors.black, size: 30),
                          onPressed: () {
                            setState(() {
                              _iconColor = Colors.black;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Icon(Icons.circle,
                              color: Colors.blueAccent, size: 30),
                          onPressed: () {
                            setState(() {
                              _iconColor = Colors.blueAccent;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Icon(Icons.circle,
                              color: Colors.redAccent, size: 30),
                          onPressed: () {
                            setState(() {
                              _iconColor = Colors.redAccent;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Icon(Icons.circle,
                              color: Colors.greenAccent, size: 30),
                          onPressed: () {
                            setState(() {
                              _iconColor = Colors.greenAccent;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Icon(Icons.circle,
                              color: Colors.deepOrangeAccent, size: 30),
                          onPressed: () {
                            setState(() {
                              _iconColor = Colors.deepOrangeAccent;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon:
                              Icon(Icons.circle, color: Colors.teal, size: 30),
                          onPressed: () {
                            setState(() {
                              _iconColor = Colors.teal;
                            });
                          },
                        ),
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
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
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
        });
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
    _iconColor = Colors.black;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
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
                        icon: Icon(Icons.fitness_center,
                            size: 40,
                            color: _selectedIcon == Icons.fitness_center
                                ? _iconColor
                                : Colors.grey),
                        onPressed: () {
                          setState(() {
                            _selectedIcon = Icons.fitness_center;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.directions_run,
                            size: 40,
                            color: _selectedIcon == Icons.directions_run
                                ? _iconColor
                                : Colors.grey),
                        onPressed: () {
                          setState(() {
                            _selectedIcon = Icons.directions_run;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.self_improvement,
                            size: 40,
                            color: _selectedIcon == Icons.self_improvement
                                ? _iconColor
                                : Colors.grey),
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
                      Expanded(
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _iconColor = Colors.black;
                            });
                          },
                          icon: Icon(
                            Icons.circle,
                            color: Colors.black,
                            size: 30,
                          ),
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Icon(
                            Icons.circle,
                            color: Colors.blueAccent,
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              _iconColor = Colors.blueAccent;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Icon(
                            Icons.circle,
                            color: Colors.redAccent,
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              _iconColor = Colors.redAccent;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Icon(
                            Icons.circle,
                            color: Colors.greenAccent,
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              _iconColor = Colors.greenAccent;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: IconButton(
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
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Icon(
                            Icons.circle,
                            color: Colors.teal,
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              _iconColor = Colors.teal;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightGreen),
                        onPressed: () {
                          _addPage();
                          Navigator.pop(context); // Dialog'u kapat
                        },
                        child: Center(
                          child: Text(
                            "Kaydet",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Vazgeç",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          bottom: const TabBar(
            splashFactory: NoSplash.splashFactory,
            labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white70),
            unselectedLabelStyle:
                TextStyle(fontSize: 14, color: Colors.white54),
            indicatorColor: Colors.white,
            indicatorWeight: 4.0,
            tabs: [
              Tab(
                text: "Rutinlerim",
              ),
              Tab(
                text: "Geçmiş",
              ),
            ],
          ),
          automaticallyImplyLeading:
              false, // Varsayılan leading özelliğini devre dışı bırak
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black, // Başlangıç rengi
                  Colors.red, // Bitiş rengi
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
        body: TabBarView(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
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
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      // padding: EdgeInsets.all(16),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.black, Colors.red],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                      ),
                      child: FloatingActionButton(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        splashColor: Colors.transparent,
                        highlightElevation: 0,
                        hoverElevation: 0,
                        child: Icon(
                          Icons.add,
                          color: Colors.white70,
                        ),
                        onPressed: _showDialog,
                        tooltip: "Yeni Rutin Ekle",
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper.instance.fetchDynamicPages(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('Bir hata oluştu: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('Henüz geçmiş bulunmuyor.'));
                    } else {
                      final historyList = snapshot.data!;
                      return Expanded(
                        child: ListView.builder(
                          itemCount: historyList.length,
                          itemBuilder: (context, index) {
                            final workout = historyList[index];
                            return ListTile(
                              title:
                                  Text(workout['title'] ?? 'Bilinmeyen Başlık'),
                              subtitle: Text(
                                workout['createdAt'] != null
                                    ? DateFormat('dd MMM yyyy').format(
                                        DateTime.parse(workout['createdAt']),
                                      )
                                    : 'Tarih Yok',
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Silme Onayı'),
                                        content: Text(
                                            'Bu geçmişi ve ilgili tüm verileri silmek istediğinize emin misiniz?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('Vazgeç'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await DatabaseHelper.instance
                                                  .deleteHistoryWorkoutWithWorkouts(
                                                      workout[
                                                          'id']); // Silme işlemi
                                              Navigator.pop(
                                                  context); // Diyalog kapat
                                              (context as Element)
                                                  .reassemble(); // Arayüzü yenile
                                            },
                                            child: Text('Sil'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: Icon(Icons.delete),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailHistoryPage(
                                      historyId: workout['id'],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class DetailHistoryPage extends StatelessWidget {
  final int historyId; // historyWorkoutPages tablosundaki id

  const DetailHistoryPage({Key? key, required this.historyId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detay Sayfası'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance
            .getWorkoutsByHistoryId(historyId), // Filtreleme fonksiyonu
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Bu sayfa için veri bulunamadı.'));
          } else {
            final workouts = snapshot.data!;
            return ListView.builder(
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final workout = workouts[index];
                return ListTile(
                  title: Text(workout['title'] ?? 'Hareket İsmi Yok'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Set Sayısı: ${workout['set_count'] ?? 'Bilinmiyor'}'),
                      Text('Tekrar: ${workout['reps'] ?? 'Bilinmiyor'}'),
                      Text('Ağırlık: ${workout['weight'] ?? 'Bilinmiyor'}'),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
