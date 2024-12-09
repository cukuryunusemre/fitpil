import 'package:flutter/material.dart';

class ffmiCalculate extends StatefulWidget {
  const ffmiCalculate({super.key});

  @override
  State<ffmiCalculate> createState() => _ffmiCalculateState();
}

class _ffmiCalculateState extends State<ffmiCalculate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FFMI HESAPLAYICI"),
      ),
    );
  }
}
