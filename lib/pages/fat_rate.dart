import 'package:flutter/material.dart';
import 'dart:math';

String _selectedOption = "Erkek";
final TextEditingController _heightController = TextEditingController();
final TextEditingController _neckController = TextEditingController();
final TextEditingController _waistController = TextEditingController();
final TextEditingController _hipController = TextEditingController();
final TextEditingController _resultController = TextEditingController();

void showFatRatePage(BuildContext context) {
  _heightController.clear();
  _neckController.clear();
  _waistController.clear();
  _hipController.clear();
  _resultController.clear();
  _selectedOption = "Erkek";
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
                    padding: EdgeInsets.all(16),
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
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
                                        title: Text(
                                          "Açıklama",
                                          style: TextStyle(
                                              color: Colors.lightGreen),
                                        ),
                                        content: Text(
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
                                            child: Text(
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
                                icon: Expanded(
                                  child: Icon(
                                    Icons.info,
                                    color: Colors.lightGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 6.0,
                          ),
                          Row(
                            children: [
                              SegmentedButton<String>(
                                segments: <ButtonSegment<String>>[
                                  ButtonSegment<String>(
                                    value: "Erkek",
                                    label: Container(
                                      width: 75.0,
                                      child: Icon(
                                        Icons.man,
                                        size: 40,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  ButtonSegment<String>(
                                    value: "Kadın",
                                    label: Container(
                                      width: 75.0,
                                      child: Icon(
                                        Icons.woman,
                                        size: 40,
                                        color: Colors.pinkAccent,
                                      ),
                                    ),
                                  ),
                                ],
                                selected: <String>{_selectedOption},
                                style: ButtonStyle(
                                  side: MaterialStateProperty.resolveWith<
                                      BorderSide?>((states) {
                                    if (states
                                        .contains(MaterialState.selected)) {
                                      return BorderSide.none;
                                    }
                                    return BorderSide.none;
                                  }),
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color?>(
                                          (states) {
                                    if (states
                                        .contains(MaterialState.selected)) {
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
                            decoration: InputDecoration(labelText: "Boy (cm)"),
                            onChanged: (value) {
                              setState(() {
                                _calculateFatRate(setState);
                              });
                            },
                          ),
                          SizedBox(height: 6.0),
                          TextField(
                            controller: _neckController,
                            keyboardType: TextInputType.number,
                            decoration:
                                InputDecoration(labelText: "Boyun Çevresi"),
                            onChanged: (value) {
                              setState(() {
                                _calculateFatRate(setState);
                              });
                            },
                          ),
                          SizedBox(height: 6.0),
                          TextField(
                            controller: _waistController,
                            keyboardType: TextInputType.number,
                            decoration:
                                InputDecoration(labelText: "Bel Çevresi"),
                            onChanged: (value) {
                              setState(() {
                                _calculateFatRate(setState);
                              });
                            },
                          ),
                          SizedBox(height: 6.0),
                          if (_selectedOption == "Kadın")
                            TextField(
                              controller: _hipController,
                              keyboardType: TextInputType.number,
                              decoration:
                                  InputDecoration(labelText: "Kalça Çevresi"),
                              onChanged: (value) {
                                setState(() {
                                  _calculateFatRate(setState);
                                });
                              },
                            ),
                          SizedBox(height: 16.0),
                          TextField(
                            controller: _resultController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: "Yağ Oranı",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(
                            height: 6.0,
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
    } else if (_selectedOption == "Erkek") {
      bodyFat = 495 /
              (1.0324 -
                  0.19077 * log(waist - neck) / ln10 +
                  0.15456 * log(height) / ln10) -
          450;
      if (bodyFat < 0) {
        _resultController.text = "Lütfen Geçerli Değerler Giriniz";
      } else {
        _resultController.text = "${bodyFat.toStringAsFixed(1)}%";
      }
    } else if (_selectedOption == "Kadın" && _hipController.text.isNotEmpty) {
      bodyFat = 495 /
              (1.29579 -
                  0.35004 * log(height + hip - neck) / ln10 +
                  0.22100 * log(height) / ln10) -
          450;
      if (bodyFat < 0) {
        _resultController.text = "Lütfen Geçerli Değerler Giriniz";
      } else {
        _resultController.text = "${bodyFat.toStringAsFixed(1)}%";
      }
    }
  });
}
