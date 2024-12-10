import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'blog_page.dart';

class ffmiCalculate extends StatefulWidget {
  const ffmiCalculate({super.key});

  @override
  State<ffmiCalculate> createState() => _ffmiCalculateState();
}

class _ffmiCalculateState extends State<ffmiCalculate> {
  final List<double> _sliderValues = [178.0, 80.0, 16.4];
  final List<double> _sliderMins = [100, 30, 2];
  final List<double> _sliderMaxs = [250, 200, 60];
  final List<TextEditingController> _textControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  double? _ffmiResult;
  double? _leanMassResult;

  final List<String> _sliderLabels = [
    'Boy',
    'Vücut Kütlesi',
    'Yağ Oranı',
  ];

  final List<String> _sliderSuffix = [
    'cm',
    'kg',
    '%',
  ];

  @override
  void initState() {
    super.initState();
    // Başlangıç değerlerini TextField'lara yazıyoruz
    for (int i = 0; i < _sliderValues.length; i++) {
      _textControllers[i].text = _sliderValues[i].toStringAsFixed(1);
    }
  }

  void _updateSliderFromText(int index, String value) {
    final double? parsedValue = double.tryParse(value);
    if (parsedValue != null &&
        parsedValue >= _sliderMins[index] &&
        parsedValue <= _sliderMaxs[index]) {
      setState(() {
        _sliderValues[index] = parsedValue;
      });
    } else {
      // Hatalı giriş için bir mesaj göstermek isteyebilirsiniz.
    }
  }

  void _updateTextFieldFromSlider(int index, double value) {
    setState(() {
      _sliderValues[index] = value;
      _textControllers[index].text = value.toStringAsFixed(1);
    });
  }

  void _calculateFFMI() {
    double height = double.tryParse(_textControllers[0].text) ?? 0;
    double weight = double.tryParse(_textControllers[1].text) ?? 0;
    double bodyFatPercentage = double.tryParse(_textControllers[2].text) ?? 0;
    double leanMass = weight * (1 - bodyFatPercentage / 100);
    _ffmiResult = leanMass / ((height / 100) * (height / 100));
    _leanMassResult = leanMass;
    setState(() {}); // Değişikliği güncelle
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.greenAccent],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white54,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "FFMI Hesaplayıcı",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        // fontFamily: 'Pacifico',
                        color: Colors.white70),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                              "Açıklama",
                              style: TextStyle(color: Colors.lightGreen),
                            ),
                            content: const Text(
                              "Vücuttaki yağsız kütleyi boy uzunluğuna oranlayarak değendirilir.\n"
                              "Standart BMI'dan farklı olarak yağ ve kas oranını ayırt edebilir, "
                              "bu nedenle sporcular ve aktif bireyler için daha doğru sonuçlar sunar.",
                              style: TextStyle(fontSize: 15.0, height: 1.5),
                            ),
                            actions: [
                              TextButton(
                                onPressed: Navigator.of(context).pop,
                                child: const Text(
                                  "Anladım",
                                  style: TextStyle(
                                      color: Colors.lightGreen, fontSize: 18.0),
                                ),
                              )
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(
                      Icons.info_outline,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 16,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: _sliderValues.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Text(
                        '${_sliderLabels[index]}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      // Slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Slider(
                                activeColor: Colors.lightGreen,
                                value: _sliderValues[index],
                                min: _sliderMins[index],
                                max: _sliderMaxs[index],
                                divisions:
                                    (_sliderMaxs[index] - _sliderMins[index])
                                        .toInt(),
                                label: _sliderValues[index].toStringAsFixed(1),
                                onChanged: (value) {
                                  _updateTextFieldFromSlider(index, value);
                                  _calculateFFMI();
                                }),
                          ),
                          SizedBox(width: 10),
                          Container(
                            width: 100,
                            child: Expanded(
                              child: TextField(
                                controller: _textControllers[index],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  suffixText: _sliderSuffix[index],
                                  isDense: true, // Daha kompakt bir alan için
                                ),
                                onSubmitted: (value) {
                                  double? parsedValue = double.tryParse(value);
                                  if (parsedValue != null) {
                                    if (parsedValue >= _sliderMins[index] &&
                                        parsedValue <= _sliderMaxs[index]) {
                                      // Geçerli bir değer girilmişse slider güncellenir
                                      setState(() {
                                        _sliderValues[index] = parsedValue;
                                      });
                                    } else {
                                      // Sınır dışı değer varsa, eski değeri geri yükle
                                      _textControllers[index].text =
                                          _sliderValues[index]
                                              .toStringAsFixed(1);
                                    }
                                  } else {
                                    // Geçersiz bir giriş varsa eski değeri geri yükle
                                    _textControllers[index].text =
                                        _sliderValues[index].toStringAsFixed(1);
                                  }
                                  // Kullanıcının imlecini doğru yere koymak için
                                  _textControllers[index].selection =
                                      TextSelection.fromPosition(
                                    TextPosition(
                                        offset: _textControllers[index]
                                            .text
                                            .length),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25), // TextField
                    ],
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                if (_leanMassResult != null)
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.green.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Yağsız Kütle',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[300],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  if (_leanMassResult != null)
                                    Text(
                                      ('${_leanMassResult!.toStringAsFixed(2)} kg'),
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.green.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'FFMI',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[300],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  if (_ffmiResult != null)
                                    Text(
                                      _ffmiResult!.toStringAsFixed(2),
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                Expanded(
                    child: Column(
                  children: [
                    if (_leanMassResult != null && _ffmiResult != null)
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[300],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BloggerPostsPage(
                                          initialTitle: "FFMI Skor Tablosu"),
                                    ),
                                  );
                                },
                                child: Text(
                                  "FFMI Skorunu Değerlendir",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                  ],
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
