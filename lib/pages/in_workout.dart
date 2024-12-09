import 'package:fitpil/pages/calorie_dart.dart';
import 'package:fitpil/screens/workout_routine.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';
import '../utils/showDialog_helper.dart';
import '../utils/snackbar_helper.dart';

class InWorkoutPage extends StatefulWidget {
  final String title;
  final Color iconColor;
  final int pageId;
  const InWorkoutPage({
    Key? key,
    required this.title,
    required this.iconColor,
    required this.pageId,
  }) : super(key: key);
  @override
  State<InWorkoutPage> createState() => _InWorkoutPageState();
}

class _InWorkoutPageState extends State<InWorkoutPage> {
  int? expandedIndex;
  List<Map<String, dynamic>> exercises = [];
  Map<int, List<Map<String, dynamic>>> exerciseInputs =
      {}; // Reps ve Weight verileri
  Map<int, List<TextEditingController>> repsControllers =
      {}; // Tekrar için kontroller
  Map<int, List<TextEditingController>> weightControllers =
      {}; // Ağırlık için kontroller

  List<Map<String, dynamic>> prepareData() {
    List<Map<String, dynamic>> workoutData = [];

    for (var exercise in exercises) {
      final exerciseId = exercise['id'];
      final title = exercise['title'];

      List<Map<String, dynamic>> sets = [];
      for (int i = 0; i < exerciseInputs[exerciseId]!.length; i++) {
        sets.add({
          "set": i + 1,
          "reps": exerciseInputs[exerciseId]![i]['reps'],
          "weight": exerciseInputs[exerciseId]![i]['weight'],
        });
      }

      workoutData.add({
        "title": title,
        "sets": sets,
      });
    }

    return workoutData;
  }

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    // Veritabanından ilgili sayfaya ait egzersizleri çek
    final fetchedExercises =
        await DatabaseHelper.instance.fetchExercises(widget.pageId);
    setState(() {
      exercises = List<Map<String, dynamic>>.from(fetchedExercises);
    });
    for (var exercise in exercises) {
      final exerciseId = exercise['id'];

      // Egzersiz için boş giriş değerleri oluştur
      if (!exerciseInputs.containsKey(exerciseId)) {
        exerciseInputs[exerciseId] = List.generate(
          exercise['sets'],
          (index) => {"reps": "", "weight": ""},
        );
      }

      // TextEditingController oluştur ve sakla
      if (!repsControllers.containsKey(exerciseId)) {
        repsControllers[exerciseId] = List.generate(
          exercise['sets'],
          (index) => TextEditingController(
            text: exerciseInputs[exerciseId]![index]['reps'],
          ),
        );
      }
      if (!weightControllers.containsKey(exerciseId)) {
        weightControllers[exerciseId] = List.generate(
          exercise['sets'],
          (index) => TextEditingController(
            text: exerciseInputs[exerciseId]![index]['weight'],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Tüm TextEditingController'ları temizle
    repsControllers.values
        .expand((controllers) => controllers)
        .forEach((controller) => controller.dispose());
    weightControllers.values
        .expand((controllers) => controllers)
        .forEach((controller) => controller.dispose());
    super.dispose();
  }

  void saveWorkout() async {
    DateTime now = DateTime.now();
    String formattedDate = "${now.day}-${now.month}-${now.year}";
    String routinName = widget.title;

    final historyId = await DatabaseHelper.instance
        .insertDynamicPage(routinName, widget.pageId);
    for (var exercise in exercises) {
      final exerciseId = exercise['id'];
      final exerciseName = exercise['title'];

      for (int setIndex = 0;
          setIndex < exerciseInputs[exerciseId]!.length;
          setIndex++) {
        final reps = exerciseInputs[exerciseId]![setIndex]['reps'];
        final weight = exerciseInputs[exerciseId]![setIndex]['weight'];

        if (reps.isNotEmpty && weight.isNotEmpty) {
          // Veritabanına kaydet
          await DatabaseHelper.instance.insertWorkout(
            widget.pageId,
            exerciseName,
            setIndex + 1,
            reps,
            weight,
            formattedDate,
            routinName,
            historyId,
          );
        }
      }
    }
    print("Workout saved to database.");
    // setState(() async {});
    // await DatabaseHelper.instance.insertDynamicPage(routinName, widget.pageId);
    setState(() {});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showExitConfirmationDialog(context);
        return shouldPop ?? false; // Eğer null dönerse çıkışı engelle
      },
      child: Scaffold(
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
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  final exerciseId = exercise['id'];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 4,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            splashColor: Colors.transparent),
                        child: ExpansionTile(
                          key: Key(index.toString()),
                          title: Text(
                            exercise['title'],
                            style: TextStyle(fontSize: 18),
                          ),
                          subtitle: Text(
                            "${exercise['sets']} sets x ${exercise['reps']} reps",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          initiallyExpanded: index == expandedIndex,
                          onExpansionChanged: (isExpanded) {
                            if (isExpanded) {
                              setState(() {
                                expandedIndex = index;
                              });
                            } else {
                              setState(() {
                                expandedIndex = -1;
                              });
                            }
                          },
                          children: List.generate(
                            exercise['sets'],
                            (setIndex) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: Text("${setIndex + 1}. Set")),
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: weightControllers[
                                          exerciseId]![setIndex],
                                      decoration: InputDecoration(
                                        labelText: "Ağırlık",
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          exerciseInputs[exerciseId]![setIndex]
                                              ['weight'] = value;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: repsControllers[exerciseId]![
                                          setIndex],
                                      decoration: InputDecoration(
                                        labelText: "Tekrar / Süre",
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          exerciseInputs[exerciseId]![setIndex]
                                              ['reps'] = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen),
                      onPressed: () async {
                        // saveWorkout();
                        showConfirmationDialog(
                            context: context,
                            title: 'Çıkış',
                            content:
                                'Antrenman kaydediliyor ve çıkış yapılıyor',
                            confirmButtonText: 'Kaydet',
                            cancelButtonText: 'Vazgeç',
                            onConfirm: () {
                              saveWorkout();
                              SnackbarHelper.show(
                                context,
                                message: 'Antrenman Başarıyla Kaydedildi!',
                                icon: Icons.save,
                                backgroundColor: Colors.lightGreen,
                              );
                            });
                      },
                      child: Text(
                        "Kaydet ve Çık",
                        style: TextStyle(color: Colors.white),
                      )),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent),
                      onPressed: () {
                        showConfirmationDialog(
                            context: context,
                            title: 'Çıkış',
                            content: 'Antrenman kaydedilmeden çıkılıyor',
                            confirmButtonText: 'Çıkış',
                            cancelButtonText: 'Vazgeç',
                            onConfirm: () {
                              Navigator.pop(context);
                            });
                      },
                      child: Text(
                        "Kaydetmeden Çık",
                        style: TextStyle(color: Colors.white),
                      )),
                ),
                SizedBox(width: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> showExitConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Çıkış"),
        content: Text("Antrenman kaydedilmeden çıkılsın mı?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Çıkışı onayla
            },
            child: Text("Evet"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Çıkışı iptal et
            },
            child: Text("Hayır"),
          ),
        ],
      );
    },
  );
}
