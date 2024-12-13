import 'package:fitpil/pages/activity_page.dart';
import 'package:fitpil/pages/calorie_dart.dart';
import 'package:fitpil/pages/fat_rate.dart';
import 'package:fitpil/screens/workout_routine.dart';
import 'package:fitpil/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart'; // Adım sayar paketi
import '../pages/step_page.dart';
import 'package:fitpil/utils/permission.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:icons_plus/icons_plus.dart';
import '../pages/ffmi_calculate.dart';
import '../pages/onerepmax_calculate.dart';
import 'package:fitpil/pages/step_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<StepCount> _stepCountStream;
  int _steps = 0; // Adım sayacı

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double buttonHeight = screenHeight * 0.245;
    double buttonWidth = screenWidth * 0.45;

    if (MediaQuery.of(context).size.width < 400) {
      buttonHeight = screenHeight * 0.225;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Antrenman Rutini Butonu
            const SizedBox(height: 16.0),
            // Adım ve Aktivite Butonları
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Adım Sayar Butonu
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () async {
                      bool isGranted = await requestBodySensorsPermission();
                      if (isGranted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StepTrackerPage()),
                        );
                      } else {
                        SnackbarHelper.show(context, message: "Lütfen izin verin",backgroundColor: Colors.red);
                      }
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
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
                            const Icon(
                              Icons.directions_walk,
                              color: Colors.white,
                              size: 40.0,
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              "$_steps Adım",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Aktivite Butonu
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ActivityPage()),
                      );
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.purple, Colors.pinkAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_run,
                              color: Colors.white,
                              size: 40.0,
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              "Aktivite",
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
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Kalori Butonu
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.lightGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ffmiCalculate()),
                      );
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Colors.deepOrange, Colors.greenAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(8)),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(MingCute.fitness_fill,
                                color: Colors.white, size: 40),
                            SizedBox(height: 10.0),
                            Text(
                              "FFMI",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.lightGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => rmCalculate(),
                        ),
                      );
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [
                              Color.fromRGBO(154, 0, 0, 1),
                              Colors.black
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(MingCute.barbell_line,
                                color: Colors.white, size: 40),
                            SizedBox(height: 10.0),
                            Text(
                              "1 RM",
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
            SizedBox(
              height: 16,
            ),
            // Kalori ve Yağ Oranı Butonları
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Kalori Butonu
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
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
                          gradient: const LinearGradient(
                              colors: [Colors.green, Colors.greenAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(8)),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Column(
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
                // Yağ Oranı Butonu
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
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
                        gradient: const LinearGradient(
                            colors: [Colors.green, Colors.greenAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Column(
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
            const SizedBox(height: 16.0),
            // SizedBox(
            //   width: screenWidth * 0.92,
            //   height: screenHeight * 0.228,
            //   child: ElevatedButton(
            //     style: ElevatedButton.styleFrom(
            //       padding: EdgeInsets.zero,
            //       backgroundColor: Colors.transparent,
            //       shadowColor: Colors.transparent,
            //     ),
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => WorkoutPage(),
            //         ),
            //       );
            //     },
            //     child: Ink(
            //       decoration: BoxDecoration(
            //         gradient: const LinearGradient(
            //           colors: [Colors.black, Colors.red],
            //           begin: Alignment.topLeft,
            //           end: Alignment.bottomRight,
            //         ),
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //       child: Container(
            //         alignment: Alignment.center,
            //         child: const Column(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             Icon(
            //               Icons.fitness_center,
            //               color: Colors.white54,
            //               size: 50.0,
            //             ),
            //             SizedBox(height: 16.0),
            //             Text(
            //               "Antrenman Rutini",
            //               style:
            //                   TextStyle(color: Colors.white54, fontSize: 20.0),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
