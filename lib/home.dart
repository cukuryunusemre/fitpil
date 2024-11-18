import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _showCenteredDialog() {
    TextEditingController fat_percentage = TextEditingController();
    TextEditingController body_weight = TextEditingController();
    List<String> activity_level = [
      "Sedanter (Az veya hiç egzersiz)",
      "Az Hareketli (Haftada 1-3 kez egzersiz)",
      "Orta Hareketli (Haftada 3-5 gün egzersiz.)",
      "Çok Hareketli (Haftada 6-7 gün egzersiz)",
      "Aşırı Hareketli (Profesyonel Sporcu)"
    ];
    int? selectedIndex;
    double? result;

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: fat_percentage,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Yağ Oranı"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: body_weight,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Vücut Ağırlığı"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
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
                      });
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      double fat = double.tryParse(fat_percentage.text) ?? 0;
                      double bw = double.tryParse(body_weight.text) ?? 0;
                      double lean_body_mass = bw * (1 - (fat / 100));
                      double bmr = 370 + (21.6 * lean_body_mass);
                      setState(() {
                        if (selectedIndex == 0) {
                          result = bmr * 1.2;
                        } else if (selectedIndex == 1) {
                          result = bmr * 1.375;
                        } else if (selectedIndex == 2) {
                          result = bmr * 1.55;
                        } else if (selectedIndex == 3) {
                          result = bmr * 1.725;
                        } else if (selectedIndex == 4) {
                          result = bmr * 1.9;
                        }
                      });
                    },
                    child: Text("Hesapla"),
                  ),
                  if (result != null)
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: (Text(
                          "Günlük almanız gereken kalori : ${result!.isNaN ? "Tanımsız" : result!.toStringAsFixed(2)}")),
                    ),
                ],
              ),
            ),
          );
        });

        // Dialog(
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(16),
        //   ),
        //   child: Container(
        //     padding: EdgeInsets.all(16),
        //     height: MediaQuery.of(context).size.height *
        //         0.6, // İstediğiniz yüksekliği ayarlayın
        //     width: MediaQuery.of(context).size.width *
        //         0.95, // Ekranın %80'i kadar genişlik
        //     child: Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         Text(
        //           "Kalori Hesaplayıcı",
        //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        //         ),
        //         SizedBox(height: 20),
        //         TextField(
        //           controller: fat_percentage,
        //           decoration: InputDecoration(labelText: "Yağ Oranı"),
        //         ),
        //         SizedBox(
        //           height: 10.0,
        //         ),
        //         TextField(
        //           controller: body_weight,
        //           decoration: InputDecoration(labelText: "Vücut Ağırlığı"),
        //         ),
        //         DropdownButton<int>(
        //             value: selectedIndex,
        //             hint: Text("Aktiviye Seviyenizi Seçin."),
        //             isExpanded: true,
        //             items: activity_level.asMap().entries.map((entry) {
        //               int index = entry.key;
        //               String value = entry.value;
        //
        //               return DropdownMenuItem<int>(
        //                 value: index,
        //                 child: Text(value),
        //               );
        //             }).toList(),
        //             onChanged: (int? value) {
        //               setState(() {
        //                 selectedIndex = value;
        //               });
        //             })
        //       ],
        //     ),
        //   ),
        // );
      },
    );
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
                  onPressed: _showCenteredDialog,
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
