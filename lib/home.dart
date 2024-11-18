// hata mesajlarını düzelt

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController fat_percentageController = TextEditingController();
  TextEditingController body_weightController = TextEditingController();
  List<String> activity_level = [
    "Sedanter (Hareketsiz)",
    "Az Aktif (1-3 gün egzersiz)",
    "Orta Aktif (3-5 gün egzersiz.)",
    "Çok Aktif (6-7 gün egzersiz)",
    "Atletik (Profesyonel Sporcu)"
  ];
  int? selectedIndex;
  double? result;
  String fat_rate_warning = '';
  String bw_warning = '';
  String? for_cut;
  String? for_bulk;

  void _showCaloriPage() {
    fat_percentageController.clear();
    body_weightController.clear();
    selectedIndex = null;
    fat_rate_warning = '';
    bw_warning = '';
    result = null;
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
                children: [
                  // Yağ Oranı TextField
                  TextField(
                    controller: fat_percentageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Yağ Oranı"),
                    onChanged: (_) =>
                        _calculateCalori(setState), // Hemen kontrol et
                  ),
                  SizedBox(
                    height: 20,
                    child: Text(
                      fat_rate_warning,
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                  // Vücut Ağırlığı TextField
                  TextField(
                    controller: body_weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Vücut Ağırlığı"),
                    onChanged: (_) =>
                        _calculateCalori(setState), // Hemen kontrol et
                  ),
                  SizedBox(
                    height: 20,
                    child: Text(
                      bw_warning,
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                  // Aktivite Seviyesi DropdownButton
                  DropdownButton<int>(
                    value: selectedIndex,
                    hint: Text("Aktivite Seviyenizi Seçin"),
                    isExpanded: true,
                    items: activity_level.asMap().entries.map((entry) {
                      int index = entry.key;
                      String activity = entry.value;

                      return DropdownMenuItem<int>(
                        value: index,
                        child: Text(activity),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedIndex = value;
                        _calculateCalori(
                            setState); // Seçim değiştikçe kontrol et
                      });
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  // Sonuç Gösterimi
                  if (result != null)
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text("BMR Değeriniz: \n"
                          "Günlük almanız gereken kalori : ${result!.isNaN ? "Tanımsız" : result!.toStringAsFixed(2)}"),
                    ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // Yağ oranı ve vücut ağırlığını kontrol et ve kalori hesapla
  void _calculateCalori(StateSetter setState) {
    double fat = double.tryParse(fat_percentageController.text) ?? 0;
    double bw = double.tryParse(body_weightController.text) ?? 0;
    double lean_body_mass = bw * (1 - (fat / 100));
    double bmr = 370 + (21.6 * lean_body_mass);

    // Hata mesajlarını anında güncelle
    setState(() {
      if (fat < 2 || fat > 60) {
        fat_rate_warning = "Yağ oranı 2'den düşük ve 60'dan yüksek olamaz.";
        result = null;
      } else if (bw < 25 || bw > 300) {
        bw_warning = "Vücut ağırlığı 25'ten düşük ve 300'den yüksek olamaz.";
        result = null;
      } else {
        if (fat_percentageController.text.isEmpty ||
            body_weightController.text.isEmpty ||
            selectedIndex == null) {
          result = null; // Sonuç yok
          fat_rate_warning = ''; // Uyarı mesajlarını sıfırla
          bw_warning = '';
        } else {
          fat_rate_warning = ''; // Yağ oranı hatası yok
          bw_warning = ''; // Vücut ağırlığı hatası yok
          // Aktivite seviyesine göre kalori hesaplama
          if (selectedIndex == 0) {
            result = bmr * 1.2; // Sedanter
          } else if (selectedIndex == 1) {
            result = bmr * 1.375; // Az Aktif
          } else if (selectedIndex == 2) {
            result = bmr * 1.55; // Orta Aktif
          } else if (selectedIndex == 3) {
            result = bmr * 1.725; // Çok Aktif
          } else if (selectedIndex == 4) {
            result = bmr * 1.9; // Atletik
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 120.0,
                height: 120.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _showCaloriPage,
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
            ],
          ),
        ],
      ),
    );
  }
}
