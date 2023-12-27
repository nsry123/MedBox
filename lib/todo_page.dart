import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:test1/main.dart';
import 'package:test1/medicine_intake_page.dart';
import 'package:timezone/timezone.dart' as tz;

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
  Map<String,String> _medList = new Map();
  Map<String,String> _idList = new Map();

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

  Future<void> _zonedScheduleAlarmClockNotification(String payload) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        123,
        'scheduled alarm clock title',
        'scheduled alarm clock body',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails('alarm_clock_channel',
                'Alarm Clock Channel',
                channelDescription: 'Alarm Clock Notification',
                importance: Importance.max,
                priority: Priority.max)),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload
    );

  }

  @override
  Widget build(BuildContext context) {

    _timesList.clear();
    _medList.clear();
    _idList.clear();

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 12,3);

    for(int i=0;i<_medInfo.length;i++){
      for(int j=0;j<_medInfo[i].timesList.length;j++){
        String time = _medInfo[i].timesList[j];
        if(!_medList.keys.toList().contains(time)){
          _medList[time] = _medInfo[i].name;
          _idList[time] = _medInfo[i].id.toString();
        }else{
          _medList[time] = ("${_medList[time]!}, ${_medInfo[i].name}")!;
          _idList[time] = "${_idList[time]!};${_medInfo[i].id}";
        }
      }
    }

    _medList = Map.fromEntries(_medList.entries.toList()..sort((e1,e2) => e1.key.compareTo(e2.key)));

    _timesList.sort();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                child: ListView.builder(
                  itemCount: _medList.length,
                  itemBuilder: (context,index){
                    String _eachTime = _medList.keys.toList()[index];
                    scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, int.parse(_eachTime.substring(0,2)),int.parse(_eachTime.substring(3,5)));
                    String _content = _eachTime+"服用"+_medList[_eachTime]!;
                    String? _idString = _idList[_eachTime];
                    if (scheduledDate.isBefore(now)) {
                      // print("before");
                      _content+=" 时间已过";
                    }
                    // String time = _timesList[index];
                    return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                            onTap: ()  async{
                              // _zonedScheduleAlarmClockNotification("New payload");
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>MedicineIntakePage(database: widget.database, idString: _idString!, nameString: _medList.values.toList()[index], time: _eachTime)));
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              margin: EdgeInsets.fromLTRB(10, 10, 0, 10),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          _content,
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)
                                      ),
                                      Icon(Icons.keyboard_arrow_right,size: 30,)
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
