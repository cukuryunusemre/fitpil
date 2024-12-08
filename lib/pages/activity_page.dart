import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitpil/utils/snackbar_helper.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  int currentStep = 0; // Adım sayacı
  String? selectedActivity; // Seçilen aktivite
  String? selectedTempo; // Seçilen tempo
  double duration = 30; // Süre (dakika)
  double? caloriesBurned; // Yakılan kalori
  double? weight; // Kullanıcının girdiği kilo
  final TextEditingController weightController =
      TextEditingController(); // Kilo için text controller

  // Aktivite ve MET değerleri
  final Map<String, Map<String, double>> activities = {
    'Yürüme': {'Yavaş': 2.8, 'Orta': 3.8, 'Hızlı': 4.8},
    'Koşu': {'Yavaş': 7.0, 'Orta': 9.8, 'Hızlı': 11.5},
    'Yüzme': {'Hafif': 6.0, 'Orta': 8.0, 'Hızlı': 10.0},
    'Ağırlık': {'Hafif': 3.5, 'Orta': 6.0, 'Yoğun': 8.0},
    'Spor': {'Hafif': 4.0, 'Orta': 7.0, 'Yoğun': 10.0},
  };

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bilgilendirme'),
        content: Text(
          "Bu uygulamadaki kalori hesaplamaları, MET değerlerine dayanır ve "
          "kişisel faktörlere (yaş, metabolizma hızı, sağlık durumu) "
          "göre değişiklik gösterebilir. Sonuçlar yaklaşık değerlerdir.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.white54,
        ),
        title: Text(
          'Aktivite Kalori Hesaplama',
          style: TextStyle(color: Colors.white70),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.pink],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            tooltip: 'Bilgilendirme',
            color: Colors.white54,
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Stepper(
        currentStep: currentStep,
        type: StepperType.vertical,
        onStepTapped: (int step) {
          setState(() {
            currentStep = step;
          });
        },
        onStepContinue: () {
          if (currentStep < 3) {
            if (currentStep == 0 && weight == null) {
              SnackbarHelper.show(
                context,
                message: 'Lütfen geçerli bir kilo girin!',
                icon: Icons.error_outline,
                backgroundColor: Colors.redAccent,
              );
              return;
            }
            setState(() {
              currentStep++;
            });
          } else {
            if (selectedActivity != null &&
                selectedTempo != null &&
                weight != null) {
              double met = activities[selectedActivity!]![selectedTempo!]!;
              double durationHours = duration / 60.0; // Süreyi saate çevir
              setState(() {
                caloriesBurned = met * weight! * durationHours;
              });
            } else {
              SnackbarHelper.show(
                context,
                message: 'Lütfen tüm seçimleri tamamlayınız',
                icon: Icons.error_outline,
                backgroundColor: Colors.redAccent,
              );
            }
          }
        },
        onStepCancel: () {
          if (currentStep > 0) {
            setState(() {
              currentStep--;
            });
          }
        },
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentStep > 0)
                  ElevatedButton(
                    onPressed: details.onStepCancel,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Geri'),
                  ),
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(currentStep == 3 ? 'Hesapla' : 'İleri'),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: Text('Kilonuzu Girin'),
            content: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly, // Sadece rakamları kabul et
                    ],
                    decoration: InputDecoration(
                      hintText: 'Kilo (kg)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (value) {
                      // Sadece geçerli sayıları kontrol et
                      double? enteredWeight = double.tryParse(value);
                      if (enteredWeight != null &&
                          enteredWeight >= 30 &&
                          enteredWeight <= 300) {
                        setState(() {
                          weight = enteredWeight;
                        });
                      } else {
                        setState(() {
                          weight = null; // Geçersiz kilo
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: Text('Aktivite Seç'),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: activities.keys.map((activity) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedActivity = activity;
                      selectedTempo = null; // Tempo sıfırlanır
                    });
                  },
                  child: Column(
                    children: [
                      Icon(
                        activity == 'Yürüme'
                            ? Icons.directions_walk
                            : activity == 'Koşu'
                                ? Icons.directions_run
                                : activity == 'Ağırlık'
                                    ? Icons.fitness_center
                                    : activity == 'Yüzme'
                                        ? Icons.pool
                                        : Icons.sports_soccer,
                        size: 50,
                        color: selectedActivity == activity
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      Text(activity),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Step(
            title: Text('Tempo Seç'),
            content: selectedActivity == null
                ? Text('Önce bir aktivite seçin.')
                : Column(
                    children: activities[selectedActivity!]!.keys.map((tempo) {
                      return RadioListTile<String>(
                        title: Text(tempo),
                        value: tempo,
                        groupValue: selectedTempo,
                        onChanged: (value) {
                          setState(() {
                            selectedTempo = value;
                          });
                        },
                      );
                    }).toList(),
                  ),
          ),
          Step(
            title: Text('Süre ve Hesaplama'),
            content: Column(
              children: [
                Text(
                  'Süre (dakika): ${duration.toInt()}',
                  style: TextStyle(fontSize: 16),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    tickMarkShape:
                        SliderTickMarkShape.noTickMark, // Çentikleri gizler
                  ),
                  child: Slider(
                    value: duration,
                    min: 10,
                    max: 180,
                    divisions: 34,
                    label: '${duration.toInt()} dk',
                    onChanged: (value) {
                      setState(() {
                        duration = value;
                      });
                    },
                  ),
                ),
                if (caloriesBurned != null)
                  Text(
                    'Yakılan Kalori: ${caloriesBurned!.toStringAsFixed(1)} kcal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
