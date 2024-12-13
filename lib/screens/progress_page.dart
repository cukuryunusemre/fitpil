import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:fitpil/utils/progress_db.dart';
import 'package:fitpil/utils/snackbar_helper.dart';


class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> measurementData = [];
  String selectedMetric = "Kilo";

  final List<String> metrics = [
    "Kilo",
    "Kol",
    "Omuz",
    "Göğüs",
    "Bel",
    "Kalça",
    "Boyun",
    "Bacak",
    "Kalf"
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _loadMeasurements();

    _tabController.addListener(() {
      if (_tabController.index == 1) { // 1, GraphPage'in olduğu tab
        _loadMeasurements(); // Verileri yeniden yükle
      }
    });
  }



  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void addMeasurement(String metric, double value, DateTime date) async{
    await ProgressDB.instance.addOrUpdateMeasurement(metric, value, date);
    setState(() {
      measurementData.add({
        "metric": metric,
        "value": value,
        "date": date,
      });
    });
  }

  void _loadMeasurements() async {
    final data = await ProgressDB.instance.fetchAllMeasurements();
    setState(() {
      measurementData = data.map((e){
        return{
          "metric": e['metric'],
          "value": e['value'],
          "date": e['date'],
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.greenAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.monitor_weight, color: Colors.white, size: 40),
                    ),
                    Tab(
                      icon: Icon(Icons.show_chart, color: Colors.white, size: 40),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                DataInputPage(
                  metrics: metrics,
                  onSave: addMeasurement,
                ),
                GraphPage(data: measurementData),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Veri Takip Sayfası
class DataInputPage extends StatefulWidget {
  final List<String> metrics;
  final Function(String, double, DateTime) onSave;

  const DataInputPage({required this.metrics, required this.onSave, super.key});

  @override
  _DataInputPageState createState() => _DataInputPageState();
}

class _DataInputPageState extends State<DataInputPage> {
  String? selectedMetric;
  final TextEditingController _valueController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _saveData(String metric) async {

    final value = double.tryParse(_valueController.text);
    if (value != null && value >0) {
      // Veriyi veritabanına kaydet
      await ProgressDB.instance.addOrUpdateMeasurement(metric, value, selectedDate);

      // Veriyi listeye ekleyip UI'ı güncelle
      widget.onSave(metric, value, selectedDate);

      // TextField temizle
      _valueController.clear();

      FocusScope.of(context).unfocus();

      SnackbarHelper.show(context, message: "$metric Başarıyla kaydedildi");
    } else {
      // Geçersiz değer girilmişse hata mesajı göster
      SnackbarHelper.show(context, message:"Lütfen geçerli bir değer giriniz.",backgroundColor: Colors.red);
    }

  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (String metric in widget.metrics)
            ExpansionTile(
              title: Text(metric),
              children: [
                SizedBox(height: 11),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Elemanları sola ve sağa yerleştir
                  children: [
                    // Sola yaslanmış TextField
                    Expanded(
                        child: TextField(
                          controller: _valueController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: "$metric Değeri",
                            counterText: "",
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 4, // Karakter uzunluğu sınırlaması,
                        ),
                    ),
                    IconButton(onPressed: () => _selectDate(context), icon: const Icon(Icons.date_range)),
                    ElevatedButton(
                      onPressed: () => _saveData(metric),
                      child: const Text("Kaydet"),
                    ),
                  ],
                )
              ],
            ),
           ElevatedButton(
              onPressed: () async {
                await ProgressDB.instance.resetTable();
                SnackbarHelper.show(
                  context,
                  message: "Tüm veriler silindi",
                  backgroundColor: Colors.red,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text("Tüm Verileri Sil",style: TextStyle(fontSize: 16,color: Colors.white),),
            ),
        ],
      ),
    );
  }
}

class GraphPage extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const GraphPage({required this.data, super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  String selectedMetric = "Kilo";

  @override
  Widget build(BuildContext context) {
    // Seçilen metrik için filtrelenmiş ve sıralanmış veriler
    final filteredData = widget.data
        .where((d) => d['metric'] == selectedMetric)
        .toList()
      ..sort((a, b) => a['date'].compareTo(b['date']));

    // Grafikte kullanılacak veri
    final chartData = filteredData
        .map((entry) => ChartData(
      date: entry['date'] as DateTime,
      value: entry['value'] as double,
    ))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // DropdownButton her zaman görünür, sadece metrik değiştiğinde grafiği güncelle
          DropdownButton<String>(
            value: selectedMetric,
            items: ["Kilo", "Kol", "Omuz", "Göğüs", "Bel", "Kalça", "Boyun", "Bacak", "Kalf"]
                .map((metric) =>
                DropdownMenuItem(value: metric, child: Text(metric)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedMetric = value!;
              });
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: filteredData.isEmpty
                ? const Center(child: Text("Bu metrik için henüz veri yok."))
                : SfCartesianChart(
              primaryXAxis: DateTimeAxis(
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                dateFormat: DateFormat('d MMM'), // Tarih formatı
                intervalType: DateTimeIntervalType.days,
              ),
              primaryYAxis: const NumericAxis(
                labelFormat: '{value}', // Y ekseni değer formatı
                interval: 5, // Dinamik olarak artırılabilir
              ),
              tooltipBehavior: TooltipBehavior(enable: true), // Nokta üstünde bilgi
              series: <CartesianSeries<ChartData, DateTime>>[
                LineSeries<ChartData, DateTime>(
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.date,
                  yValueMapper: (ChartData data, _) => data.value,
                  markerSettings: const MarkerSettings(isVisible: true), // Noktaları belirgin yap
                  dataLabelSettings: const DataLabelSettings(isVisible: true), // Değer etiketleri
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final DateTime date;
  final double value;

  ChartData({required this.date, required this.value});
}