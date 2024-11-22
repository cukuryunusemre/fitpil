import 'package:fitpil/calorie_dart.dart';
import 'package:fitpil/fat_rate.dart';
import 'package:fitpil/workout_routine.dart';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart'; // Adım sayar paketi
import '../step_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<StepCount> _stepCountStream;
  int _steps = 0; // Adım sayacı

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
      _steps = event.steps;
    });
  }

  void _onStepCountError(error) {
    print("Adım sayar hatası: $error");
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double responseHeight = screenHeight;
    double responseWidth = screenWidth * 0.45;
    if (screenHeight > 800) {
      responseHeight = screenHeight * 0.25;
    } else {
      responseHeight = responseHeight * 0.21;
    }
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        // Taşmayı önlemek için kaydırılabilir yapı
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: 10.0),

            // Adım Sayar Butonu
            SizedBox(
              width: screenWidth * 0.95,
              height: screenHeight * 0.24,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StepTrackerPage()),
                  );
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.lightBlueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_walk,
                          color: Colors.white,
                          size: 50.0,
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          "$_steps Adım",
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            // Antrenman Rutini Butonu
            SizedBox(
              width: screenWidth * 0.95,
              height: screenHeight * 0.22,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutPage(),
                    ),
                  );
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black, Colors.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          color: Colors.white54,
                          size: 50.0,
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          "Antrenman Rutini",
                          style:
                              TextStyle(color: Colors.white54, fontSize: 20.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: responseWidth,
                  height: responseHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.lightGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      showCaloriePage(context);
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Colors.green, Colors.greenAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(8)),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant,
                              color: Colors.white,
                              size: 40.0,
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              "Kalori",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                SizedBox(
                  width: responseWidth,
                  height: responseHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.lightGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      showFatRatePage(context);
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.green, Colors.greenAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.water_drop,
                              color: Colors.white,
                              size: 40.0,
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              "Yağ Oranı",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
