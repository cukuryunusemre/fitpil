import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart'; // Grafik kütüphanesi
import 'package:pedometer/pedometer.dart';

class StepTrackerPage extends StatefulWidget {
  @override
  _StepTrackerPageState createState() => _StepTrackerPageState();
}

class _StepTrackerPageState extends State<StepTrackerPage> {
  late Stream<StepCount> _stepCountStream;
  int _todaySteps = 0;
  List<int> _weeklySteps = List.filled(7, 0); // Haftanın her günü için adımlar

  @override
  void initState() {
    super.initState();
    _loadSavedSteps();
    _initPedometer();
  }

  void _initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(_onStepCount).onError(_onStepCountError);
  }

  void _onStepCount(StepCount event) {
    setState(() {
      _todaySteps = event.steps;
    });
    _saveSteps();
  }

  void _onStepCountError(error) {
    debugPrint('Step counter error: $error');
  }

  Future<void> _loadSavedSteps() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('lastResetDate') ?? DateTime.now().toString();
    final savedWeeklySteps = prefs.getStringList('weeklySteps')?.map((e) => int.parse(e)).toList() ?? List.filled(7, 0);

    final currentDate = DateTime.now();

    // Günlük sıfırlama
    if (DateTime.parse(lastDate).day != currentDate.day) {
      setState(() {
        int dayIndex = currentDate.weekday - 1; // Haftanın günü (1=Monday, 7=Sunday)
        _weeklySteps[dayIndex] = _todaySteps;
        _todaySteps = 0;
      });

      prefs.setString('lastResetDate', currentDate.toString());
      prefs.setStringList('weeklySteps', _weeklySteps.map((e) => e.toString()).toList());
    }

    setState(() {
      _weeklySteps = savedWeeklySteps;
    });

    if (DateTime.parse(lastDate).isBefore(currentDate)) {
      int daysDifference = currentDate.difference(DateTime.parse(lastDate)).inDays;

      for (int i = 1; i <= daysDifference; i++) {
        int index = (currentDate.weekday - i) % 7; // Haftanın günü
        _weeklySteps[index] = 0; // Geçmiş günlerin adım sayısını sıfırla
      }

      setState(() {
        int dayIndex = currentDate.weekday - 1;
        _weeklySteps[dayIndex] = _todaySteps;
        _todaySteps = 0;
      });
    }

  }

  Future<void> _saveSteps() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('weeklySteps', _weeklySteps.map((e) => e.toString()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adım Takibi ve Analiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Günlük, Haftalık Bilgiler
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Bugünkü Adımlar', style: TextStyle(fontSize: 20)),
                    Text('$_todaySteps', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                    Divider(),
                    Text('Haftalık Adımlar', style: TextStyle(fontSize: 20)),
                    Text('${_weeklySteps.reduce((a, b) => a + b)}',
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Haftalık Adım Grafiği
            Expanded(
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return Text('Pzt', style: TextStyle(fontSize: 12));
                                case 1:
                                  return Text('Sal', style: TextStyle(fontSize: 12));
                                case 2:
                                  return Text('Çar', style: TextStyle(fontSize: 12));
                                case 3:
                                  return Text('Per', style: TextStyle(fontSize: 12));
                                case 4:
                                  return Text('Cum', style: TextStyle(fontSize: 12));
                                case 5:
                                  return Text('Cmt', style: TextStyle(fontSize: 12));
                                case 6:
                                  return Text('Paz', style: TextStyle(fontSize: 12));
                                default:
                                  return Text('');
                              }
                            },
                          ),
                        ),
                      ),

                      barGroups: _weeklySteps.asMap().entries.map((entry) {
                        int index = entry.key;
                        int steps = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: steps.toDouble(),
                              color: Colors.blueAccent,
                              width: 15,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }).toList(),

                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
