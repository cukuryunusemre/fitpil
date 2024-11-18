import 'package:fitpil/main.dart';
import 'package:flutter/material.dart';

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
double? maintain_calorie;
double bmr = 0;
String fat_rate_warning = '';
String bw_warning = '';
double for_cut = 0;
double for_bulk = 0;

void showCaloriePage(BuildContext context) {
  fat_percentageController.clear();
  body_weightController.clear();
  selectedIndex = null;
  fat_rate_warning = '';
  bw_warning = '';
  maintain_calorie = null;
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Kalori Hesaplayıcı",
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
                                "Girilen yağ oranı ve vücut kütlesi ile bmr (bazal metabolizma hızı) ve "
                                "günlük almanız gereken kalori ihtiyacınız hesaplanır."
                                "Kilo vermek için günlük almanız gereken kalori ihtiyacınızın %15 azını, "
                                "kilo almak için ise %10 fazlasını alabilirsiniz.\nBu hesaplamada Katch-McArdle Formülü kullanılmıştır.",
                                style: TextStyle(fontSize: 15.0, height: 1.5),
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
                  height: 20.0,
                ),
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
                      if (fat_percentageController.text.isNotEmpty &&
                          body_weightController.text.isNotEmpty) {
                        _calculateCalori(
                            setState); // Seçim değiştikçe kontrol et
                      }
                    });
                  },
                ),
                SizedBox(
                  height: 20.0,
                ),
                // Sonuç Gösterimi
                if (maintain_calorie != null)
                  Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text(
                      "BMR Değeriniz: ${(bmr).toStringAsFixed(0)}\n"
                      "Kilonuzu korumak için : ${maintain_calorie!.isNaN ? "Tanımsız" : maintain_calorie!.toStringAsFixed(0)} kcal\n"
                      "Kilo vermek için : ${(maintain_calorie! - maintain_calorie! * 0.15).toStringAsFixed(0)} kcal\n"
                      "Kilo almak için : ${(maintain_calorie! + maintain_calorie! * 0.10).toStringAsFixed(0)} kcal",
                      style: TextStyle(height: 1.5, fontSize: 16.0),
                    ),
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
  bmr = 370 + (21.6 * lean_body_mass);

  // Hata mesajlarını anında güncelle
  setState(() {
    if (fat < 2 || fat > 60) {
      fat_rate_warning = "2 ile 60 arasında olmalı.";
      maintain_calorie = null;
      bw_warning = '';
    } else if (bw < 25 || bw > 300) {
      bw_warning = "En az 25 en fazla 300 olmalı.";
      fat_rate_warning = '';
      maintain_calorie = null;
    } else {
      fat_rate_warning = '';
      bw_warning = '';
      if (fat_percentageController.text.isEmpty ||
          body_weightController.text.isEmpty ||
          selectedIndex == null) {
        maintain_calorie = null; // Sonuç yok
      } else {
        fat_rate_warning = ''; // Yağ oranı hatası yok
        bw_warning = ''; // Vücut ağırlığı hatası yok
        // Aktivite seviyesine göre kalori hesaplama
        if (selectedIndex == 0) {
          maintain_calorie = bmr * 1.2; // Sedanter
        } else if (selectedIndex == 1) {
          maintain_calorie = bmr * 1.375; // Az Aktif
        } else if (selectedIndex == 2) {
          maintain_calorie = bmr * 1.55; // Orta Aktif
        } else if (selectedIndex == 3) {
          maintain_calorie = bmr * 1.725; // Çok Aktif
        } else if (selectedIndex == 4) {
          maintain_calorie = bmr * 1.9; // Atletik
        }
      }
    }
  });
}
