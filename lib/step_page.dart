import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

class StepTrackerPage extends StatefulWidget {
  @override
  _StepTrackerPageState createState() => _StepTrackerPageState();
}

class _StepTrackerPageState extends State<StepTrackerPage> {
  late Stream<StepCount> _stepCountStream;
  int _todaySteps = 0; // Bugünkü adım
  final int _stepGoal = 5000; // Günlük hedef

  @override
  void initState() {
    super.initState();
    _initPedometer();
  }

  void _initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(_onStepCount).onError(_onStepCountError);
  }

  void _onStepCount(StepCount event) {
    setState(() {
      _todaySteps = event.steps; // Bugünkü adımları güncelle
    });
  }

  void _onStepCountError(error) {
    print("Adım sayar hatası: $error");
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_todaySteps / _stepGoal).clamp(0.0, 1.0); // Yüzdesel ilerleme
    int percentage = (progress * 100).toInt(); // Yuvarlanmış yüzde

    return Scaffold(
      appBar: AppBar(
        title: Text("Adım Takibi"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Bugünkü Adımlarınız",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  // Adım Sayısı
                  Text(
                    "$_todaySteps / $_stepGoal",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Pil Görselleştirme
                  Stack(
                    children: [
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width * 0.8 * progress,
                        decoration: BoxDecoration(
                          color: progress >= 1.0 ? Colors.green : Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Yüzde Bilgisi
                  Text(
                    "$percentage% Tamamlandı",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      print("Adım detaylarına gidiliyor...");
                    },
                    child: Text("Detayları Görüntüle"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
