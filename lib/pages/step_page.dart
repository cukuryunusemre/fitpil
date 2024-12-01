import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart'; // Grafik kütüphanesi
import 'package:pedometer/pedometer.dart';

class StepTrackerPage extends StatefulWidget {
  const StepTrackerPage({super.key});

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
    final lastDate = prefs.getString('lastResetDate');
    final savedWeeklySteps =
        prefs.getStringList('weeklySteps')?.map((e) => int.parse(e)).toList() ??
            List.filled(7, 0);

    final currentDate = DateTime.now();
    final lastResetDate =
    lastDate != null ? DateTime.parse(lastDate) : currentDate;

    final daysDifference = currentDate.difference(lastResetDate).inDays;
    if (daysDifference > 0) {
      // Her günü tek tek kontrol et ve sıfırla
      for (int i = 1; i <= daysDifference && i < 7; i++) {
        int index = (currentDate.weekday - i) % 7;
        _weeklySteps[index] = 0;
      }
    }


    // Günlük sıfırlama
    if (lastResetDate.day != currentDate.day) {
      int previousDayIndex = lastResetDate.weekday - 1;
      int currentDayIndex = currentDate.weekday - 1;

      setState(() {
        // Eski günün adımlarını haftalık listeye ekle
        _weeklySteps[previousDayIndex] = _todaySteps;

        // Günlük adımları sıfırla
        _todaySteps = 0;

        // Haftalık adımları kaydet
        prefs.setStringList(
            'weeklySteps', _weeklySteps.map((e) => e.toString()).toList());
        prefs.setString('lastResetDate', currentDate.toIso8601String());
      });
    } else {
      // Gün sıfırlanmadıysa kaydedilmiş haftalık adımları yükle
      setState(() {
        _weeklySteps = savedWeeklySteps;
      });
    }
  }

  Future<void> _saveSteps() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        'weeklySteps', _weeklySteps.map((e) => e.toString()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adım Takibi ve Analiz'),
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
                    const Text('Bugünkü Adımlar',
                        style: TextStyle(fontSize: 20)),
                    Text('$_todaySteps',
                        style: const TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold)),
                    const Divider(),
                    const Text('Haftalık Adımlar',
                        style: TextStyle(fontSize: 20)),
                    Text('${_weeklySteps.reduce((a, b) => a + b)}',
                        style: const TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                                  return const Text('Pzt',
                                      style: TextStyle(fontSize: 12));
                                case 1:
                                  return const Text('Sal',
                                      style: TextStyle(fontSize: 12));
                                case 2:
                                  return const Text('Çar',
                                      style: TextStyle(fontSize: 12));
                                case 3:
                                  return const Text('Per',
                                      style: TextStyle(fontSize: 12));
                                case 4:
                                  return const Text('Cum',
                                      style: TextStyle(fontSize: 12));
                                case 5:
                                  return const Text('Cmt',
                                      style: TextStyle(fontSize: 12));
                                case 6:
                                  return const Text('Paz',
                                      style: TextStyle(fontSize: 12));
                                default:
                                  return const Text('');
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
