import 'package:flutter/material.dart';
import 'calorie_dart.dart';
import 'fat_rate.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 170.0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              onPressed: () {
                //workoutRoutinePage(context);
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
                      Icon(Icons.fitness_center,
                          color: Colors.white54, size: 50.0), // İlk child
                      SizedBox(
                        height: 16.0,
                      ),
                      Text(
                        "Antrenman Rutini", // İkinci child
                        style: TextStyle(color: Colors.white54, fontSize: 20.0),
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
                width: MediaQuery.of(context).size.width * 0.4,
                height: 170.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    showCaloriePage(context);
                  },
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
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 16.0,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 170.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    showFatRatePage(context);
                  },
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
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 16.0,
          ),
        ],
      ),
    );
  }
}
