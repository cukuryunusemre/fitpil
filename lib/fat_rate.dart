import 'package:flutter/material.dart';
import 'dart:math';

String? _selectedOption;
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
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Yağ Oranı Hesaplayıcı",
                          style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightGreen),
                        ),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    "Açıklama",
                                    style: TextStyle(color: Colors.lightGreen),
                                  ),
                                  content: Text(
                                    "Ölçüm yaparken dikkat etmeniz gerekenler\n"
                                    "\tBoyun: adem elması etrafından\n"
                                    "\tBel: göbek deliği etrafından\n"
                                    "\tKalça (Yalnızca kadınlar için): en geniş yerinden\n"
                                    "Hesaplamada Navy BF Calculator algoritması kullanılmaktadır.",
                                    style:
                                        TextStyle(fontSize: 15.0, height: 1.5),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: Navigator.of(context).pop,
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
                          icon: Icon(
                            Icons.info,
                            color: Colors.lightGreen,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Text(
                      "Cinsiyet",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: "Erkek",
                          groupValue: _selectedOption,
                          onChanged: (value) {
                            setState(
                              () {
                                _selectedOption = value;
                              },
                            );
                          },
                        ),
                        Text("Erkek"),
                        Radio<String>(
                          value: "Kadın",
                          groupValue: _selectedOption,
                          onChanged: (value) {
                            setState(
                              () {
                                _selectedOption = value;
                              },
                            );
                          },
                        ),
                        Text("Kadın"),
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
                    SizedBox(height: 8.0),
                    TextField(
                      controller: _neckController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Boyun Çevresi"),
                      onChanged: (value) {
                        setState(() {
                          _calculateFatRate(setState);
                        });
                      },
                    ),
                    SizedBox(height: 8.0),
                    TextField(
                      controller: _waistController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Bel Çevresi"),
                      onChanged: (value) {
                        setState(() {
                          _calculateFatRate(setState);
                        });
                      },
                    ),
                    SizedBox(height: 8.0),
                    if (_selectedOption == "Kadın")
                      TextField(
                        controller: _hipController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: "Kalça Çevresi"),
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
                    )
                  ],
                ),
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
        _hipController.text.isEmpty) {
      _resultController.text = "";
    } else if (height < 100 ||
        height > 260 ||
        neck < 15 ||
        neck > 70 ||
        waist < 30 ||
        waist > 250 ||
        hip < 30 ||
        hip > 250) {
      _resultController.text = "Lütfen Geçerli Değerler Giriniz";
    } else if (_selectedOption == "Erkek") {
      bodyFat = 86.010 * (log(waist - neck) / log(10)) -
          70.041 * (log(height) / log(10)) +
          36.76;

      _resultController.text = "${bodyFat.toStringAsFixed(1)}%";
    } else if (_selectedOption == "Kadın") {
      bodyFat = 163.205 * (log(waist + hip - neck) / log(10)) -
          97.684 * (log(height) / log(10)) -
          78.387;

      _resultController.text = "${bodyFat.toStringAsFixed(1)}%";
    }
  });
}
