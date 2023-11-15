import 'package:flutter/material.dart';


class MedicineEntryPage2 extends StatefulWidget {
  const MedicineEntryPage2({super.key, title});
  final String title = "今日待服";
  @override
  State<MedicineEntryPage2> createState() => _PageState();
}

class _PageState extends State<MedicineEntryPage2> {
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
