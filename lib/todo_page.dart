import 'package:flutter/material.dart';
import 'package:test1/main.dart';

import 'db/db_manager.dart';


class TodoPage extends StatefulWidget {
  final DBManager database;
  final NotificationHelper anotificationHelper;
  const TodoPage({super.key, title, required this.database, required this.anotificationHelper});
  final String title = "今日待服";
  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Medicine> _medInfo = [];
  List<String> _timesList = [];

  Future<List<Medicine>>  getMedInfo() async {
    return await widget.database.select(widget.database.medicines).get();
  }

  void updateMedInfo(){
    getMedInfo().then((result){
          setState(() {
            _medInfo = result;
          });
        }
    );
  }

  @override
  void initState(){
    updateMedInfo();
  }

  @override
  Widget build(BuildContext context) {
    _timesList = [];
    for(int i=0;i<_medInfo.length;i++){
      for(int j=0;j<_medInfo[i].timesList.length;j++){
        _timesList.add(_medInfo[i].timesList[j]+_medInfo[i].name);
      }
    }
    _timesList.sort();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                child: ListView.builder(
                  itemCount: _timesList.length,
                  itemBuilder: (context,index){
                    String time = _timesList[index];
                    return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                            onTap: ()  async{
                              await notificationHelper.zonedScheduleNotification();
                              await notificationHelper.getAllNotifications();
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              margin: EdgeInsets.fromLTRB(10, 10, 0, 10),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                          time.substring(0,5)+"服用"+time.substring(5,time.length),
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )
                        )
                    );
                  }
                )
              )
            )
          ],
        ),
      ),
    );
  }
}
