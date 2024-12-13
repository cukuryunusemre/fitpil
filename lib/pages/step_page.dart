import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:pedometer/pedometer.dart';

class StepTrackerPage extends StatefulWidget {
  const StepTrackerPage({super.key});

  @override
  _StepTrackerPageState createState() => _StepTrackerPageState();
}

class _StepTrackerPageState extends State<StepTrackerPage> {
  late Stream<StepCount> _stepCountStream;
  int _todaySteps = 0;
  List<int> _weeklySteps = List.filled(7, 0);

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
    final lastDateStr = prefs.getString('lastResetDate');
    final savedWeeklySteps = prefs.getStringList('weeklySteps')
        ?.map((e) => int.tryParse(e) ?? 0)
        .toList() ??
        List.filled(7, 0);

    final currentDate = DateTime.now();
    DateTime lastResetDate = lastDateStr != null
        ? DateTime.tryParse(lastDateStr) ?? currentDate
        : currentDate;

    if (lastResetDate.day != currentDate.day) {
      // Geçmiş günlerin adımlarını haftalık listeye ekle
      final dayDifference = currentDate.difference(lastResetDate).inDays;
      for (int i = 0; i < dayDifference && i < 7; i++) {
        int dayIndex = (currentDate.weekday - i - 1) % 7;
        if (dayIndex < 0) dayIndex += 7;
        _weeklySteps[dayIndex] = i == 0 ? _todaySteps : 0;
      }
      _todaySteps = 0;
      lastResetDate = currentDate;
      prefs.setStringList('weeklySteps',
          _weeklySteps.map((steps) => steps.toString()).toList());
      prefs.setString('lastResetDate', currentDate.toIso8601String());
    } else {
      setState(() {
        _weeklySteps = savedWeeklySteps;
      });
    }
  }

  Future<void> _saveSteps() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        'weeklySteps', _weeklySteps.map((e) => e.toString()).toList());
    prefs.setString('lastResetDate', DateTime.now().toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adım Takibi ve Analiz'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.lightBlue, Colors.blue],
            ),
          ),
        ),
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
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    title: ChartTitle(text: 'Haftalık Adım Grafiği'),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries<StepData, String>>[
                      ColumnSeries<StepData, String>(
                        dataSource: _generateStepData(),
                        xValueMapper: (StepData data, _) => data.day,
                        yValueMapper: (StepData data, _) => data.steps,
                        name: 'Adımlar',
                        color: Colors.blueAccent,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<StepData> _generateStepData() {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return List.generate(7, (index) {
      return StepData(days[index], _weeklySteps[index]);
    });
  }
}

class StepData {
  final String day;
  final int steps;

  StepData(this.day, this.steps);
}
