import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

String _selectedOption = "Erkek";
final TextEditingController _heightController = TextEditingController();
final TextEditingController _neckController = TextEditingController();
final TextEditingController _waistController = TextEditingController();
final TextEditingController _hipController = TextEditingController();
final TextEditingController _resultController = TextEditingController();
bool _isFatRateCalculated = false;

void showFatRatePage(BuildContext context) {
  _heightController.clear();
  _neckController.clear();
  _waistController.clear();
  _hipController.clear();
  _resultController.clear();
  _selectedOption = "Erkek";
  _isFatRateCalculated = false; // Reset the flag on page load
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: FractionallySizedBox(
                heightFactor:
                    MediaQuery.of(context).size.height > 800 ? 0.62 : 0.7,
                child: Container(
                    padding: const EdgeInsets.all(16),
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Expanded(
                                child: Text(
                                  "Yağ Oranı Hesaplayıcı",
                                  style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.lightGreen),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text(
                                          "Açıklama",
                                          style: TextStyle(
                                              color: Colors.lightGreen),
                                        ),
                                        content: const Text(
                                          "Ölçüm yaparken dikkat etmeniz gerekenler\n"
                                          "\tBoyun: adem elması etrafından\n"
                                          "\tBel: göbek deliği etrafından\n"
                                          "\tKalça (Yalnızca kadınlar için): en geniş yerinden\n"
                                          "Hesaplamada Navy BF Calculator algoritması kullanılmaktadır.",
                                          style: TextStyle(
                                              fontSize: 15.0, height: 1.5),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                Navigator.of(context).pop,
                                            child: const Text(
                                              "Anladım",
                                              style: TextStyle(
                                                  color: Colors.lightGreen,
                                                  fontSize: 18.0),
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Expanded(
                                  child: Icon(
                                    Icons.info,
                                    color: Colors.lightGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 6.0,
                          ),
                          Row(
                            children: [
                              SegmentedButton<String>(
                                segments: <ButtonSegment<String>>[
                                  ButtonSegment<String>(
                                    value: "Erkek",
                                    label: SizedBox(
                                      width: 75.0,
                                      child: const Icon(
                                        Icons.man,
                                        size: 40,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  ButtonSegment<String>(
                                    value: "Kadın",
                                    label: SizedBox(
                                      width: 75.0,
                                      child: const Icon(
                                        Icons.woman,
                                        size: 40,
                                        color: Colors.pinkAccent,
                                      ),
                                    ),
                                  ),
                                ],
                                selected: <String>{_selectedOption},
                                style: ButtonStyle(
                                  side: WidgetStateProperty.resolveWith<
                                      BorderSide?>((states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return BorderSide.none;
                                    }
                                    return BorderSide.none;
                                  }),
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith<Color?>(
                                          (states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return Colors
                                          .lightGreen; // Seçili buton rengi
                                    }
                                    return Colors
                                        .grey[300]; // Varsayılan buton rengi
                                  }),
                                ),
                                onSelectionChanged: (Set<String> newSelection) {
                                  setState(() {
                                    _selectedOption = newSelection.first;
                                  });
                                },
                                showSelectedIcon: false,
                              )
                            ],
                          ),
                          TextField(
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration:
                                const InputDecoration(labelText: "Boy (cm)"),
                            onChanged: (value) {
                              setState(() {
                                _calculateFatRate(setState);
                              });
                            },
                          ),
                          const SizedBox(height: 6.0),
                          TextField(
                            controller: _neckController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                                labelText: "Boyun Çevresi"),
                            onChanged: (value) {
                              setState(() {
                                _calculateFatRate(setState);
                              });
                            },
                          ),
                          const SizedBox(height: 6.0),
                          TextField(
                            controller: _waistController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration:
                                const InputDecoration(labelText: "Bel Çevresi"),
                            onChanged: (value) {
                              setState(() {
                                _calculateFatRate(setState);
                              });
                            },
                          ),
                          const SizedBox(height: 6.0),
                          if (_selectedOption == "Kadın")
                            TextField(
                              controller: _hipController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                  labelText: "Kalça Çevresi"),
                              onChanged: (value) {
                                setState(() {
                                  _calculateFatRate(setState);
                                });
                              },
                            ),
                          const SizedBox(height: 16.0),
                          TextField(
                            controller: _resultController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: "Yağ Oranı",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          // Show save button if the fat rate is calculated
                          if (_isFatRateCalculated)
                            ElevatedButton(
                              onPressed: () {
                                _showSaveDialog(context);
                              },
                              child:
                                  const Text("Bu Yağ Oranını Profile Kaydet"),
                            ),
                        ],
                      ),
                    )),
              ),
            );
          },
        );
      });
}

void _calculateFatRate(StateSetter setState) {
  double height = double.tryParse(_heightController.text) ?? 0;
  double neck = double.tryParse(_neckController.text) ?? 0;
  double waist = double.tryParse(_waistController.text) ?? 0;
  double hip = double.tryParse(_hipController.text) ?? 0;
  double bodyFat;

  setState(() {
    if (_heightController.text.isEmpty ||
        _neckController.text.isEmpty ||
        _waistController.text.isEmpty ||
        (_selectedOption == "Kadın" && _hipController.text.isEmpty)) {
      _resultController.text = "";
      _isFatRateCalculated = false;
    } else if (height < 100 ||
        height > 260 ||
        neck < 15 ||
        neck > 70 ||
        waist < 30 ||
        waist > 250 ||
        (_selectedOption == "Kadın" &&
            (hip < 30 || hip > 250 || (hip <= neck))) ||
        (waist <= neck)) {
      _resultController.text = "Lütfen Geçerli Değerler Giriniz";
      _isFatRateCalculated = false;
    } else if (_selectedOption == "Erkek") {
      bodyFat = 495 /
              (1.0324 -
                  0.19077 * log(waist - neck) / ln10 +
                  0.15456 * log(height) / ln10) -
          450;
      if (bodyFat < 0) {
        _resultController.text = "Lütfen Geçerli Değerler Giriniz";
        _isFatRateCalculated = false;
      } else {
        _resultController.text = "${bodyFat.toStringAsFixed(1)}%";
        _isFatRateCalculated = true;
      }
    } else if (_selectedOption == "Kadın" && _hipController.text.isNotEmpty) {
      bodyFat = 495 /
              (1.29579 -
                  0.35004 * (log(waist + hip - neck) / ln10) +
                  0.22100 * (log(height) / ln10)) -
          450;
      if (bodyFat < 0) {
        _resultController.text = "Lütfen Geçerli Değerler Giriniz";
        _isFatRateCalculated = false;
      } else {
        _resultController.text = "${bodyFat.toStringAsFixed(1)}%";
        _isFatRateCalculated = true;
      }
    }
  });
}

void _showSaveDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Yağ Oranını Profilinize Kaydetmek İstiyor Musunuz?"),
        actions: [
          TextButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('fatPercentage',
                  _resultController.text); // Save to shared preferences
              Navigator.of(context).pop();
            },
            child: const Text("Evet"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Hayır"),
          ),
        ],
      );
    },
  );
}
