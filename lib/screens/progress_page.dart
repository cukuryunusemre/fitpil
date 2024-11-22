import 'package:flutter/material.dart';

class ProgressPage extends StatefulWidget {
  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2 Tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PreferredSize(
            preferredSize: Size.fromHeight(300),
            child: Container(
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.green, Colors.greenAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      TabBar(
                          controller: _tabController,
                          isScrollable: false,
                          indicatorColor: Colors.white,
                          tabs: [
                            Tab(
                                icon: Icon(Icons.monitor_weight,
                                    color: Colors.white, size: 40)),
                            Tab(
                                icon: Icon(
                              Icons.show_chart,
                              color: Colors.white,
                              size: 40,
                            )),
                          ])
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
