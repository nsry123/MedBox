import 'package:flutter/material.dart';
import 'package:test1/calendar_page.dart';
import 'package:test1/medicine_change.dart';
import 'package:test1/medicine_entry.dart';
import 'package:test1/ocr_page.dart';
import 'package:test1/todo_page.dart';
import 'db/db_manager.dart';
import 'medbox_page.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      routes:{
      }
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _bnvPos = 0;
  final List titles = ["今日待服","我的药历","全部药品"];
  final database = DBManager();

  final List pages = [];
  // @override
  // Widget build(BuildContext context){
  //   return Scaffold(
  //     resizeToAvoidBottomInset: false,
  //     appBar: AppBar(
  //       backgroundColor: Theme.of(context).colorScheme.inversePrimary,
  //       title: Text("OCR"),
  //     ),
  //     body: OcrPage(),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    List<Widget> getPages(){
      return [TodoPage(database: database,), CalendarPage(), MedboxPage(database: database)];
    }
    return NotificationListener<CustomNotification>(
      onNotification: (notification){
        switch(notification.msg){
          case "to_medicine_entry":
            // Navigator.pushNamed(context, "medicine_entry",arguments: database);
            Navigator.push(context, MaterialPageRoute(builder: (context)=>MedicineEntry(database: database)));
            return true;
        }
        if(notification.msg.startsWith("to_change_medicine_")){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>MedicineChange(database: database,medNum: int.parse(notification.msg.split("_").last),)));
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(titles[_bnvPos]),
        ),
        body: getPages()[_bnvPos],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _bnvPos,
          fixedColor: Colors.blue,
          items:  [
            BottomNavigationBarItem(
                label: "待服",
                icon: _bnvPos==0 ? const Icon(Icons.fact_check_rounded) : const Icon(Icons.fact_check_outlined),
            ),
            BottomNavigationBarItem(
                label: "药历",
                icon: _bnvPos==1 ? const Icon(Icons.today_rounded) : const Icon(Icons.today_outlined),
            ),
            BottomNavigationBarItem(
                label: "药盒",
                icon: _bnvPos==2 ? const Icon(Icons.medical_services_rounded) : const Icon(Icons.medical_services_outlined),
            ),
            // Icons.med
          ],
          onTap: (index){
            setState(() {
              _bnvPos = index;
            });
          },
        ),
      )
    );
  }
}
