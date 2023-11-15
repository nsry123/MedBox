import 'package:flutter/material.dart';

class MedicineEntryPage3 extends StatefulWidget {
  const MedicineEntryPage3({super.key, title});
  final String title = "今日待服";
  @override
  State<MedicineEntryPage3> createState() => _PageState();
}

class _PageState extends State<MedicineEntryPage3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('page1',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
