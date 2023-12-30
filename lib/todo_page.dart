import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:test1/main.dart';
import 'package:test1/medbox_page.dart';
import 'package:test1/medicine_intake_page.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/timezone.dart';

import 'db/db_manager.dart';

Future<void> _cancelAllNotifications() async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

class TodoPage extends StatefulWidget {
  final DBManager database;
  final NotificationHelper anotificationHelper;
  TodoPage({super.key, title, required this.database, required this.anotificationHelper});
  String title = "今日待服";
  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Medicine> _medInfo = [];
  List<String> _timesList = [];
  Map<String,String> _medList = new Map();
  Map<String,String> _idList = new Map();
  Map<String, bool> _whetherTakenDisplayed = new Map();
  int temp = 0;
  late StreamSubscription finishIntakeSubscription;

  Future<List<Medicine>>  getMedInfo() async {
    List<Medicine> _medicines = await widget.database.select(widget.database.medicines).get();
    List<DailyLog> _logList = [];
    TZDateTime now = tz.TZDateTime.now(tz.local);
    String _currentDate = now.year.toString()+";"+now.month.toString()+";"+now.day.toString();
    _logList = await widget.database.searchLogByDate(_currentDate);

    if(_logList.isEmpty){
      print("current date undetected");
      _medicines.forEach((element) async {
        for (int i = 0; i < element.whetherTakenList.length; i++) {
          element.whetherTakenList[i] = "-1";
        }
        await widget.database.update(widget.database.medicines).replace(element);
        print("finished refreshing");
      });
      await widget.database.into(widget.database.dailyLogs).insert(DailyLogsCompanion.insert(date: _currentDate, log: ""));
    }else{
      String _logToday = "";
      for(int i=0;i<_medicines.length;i++){
        if(i==0){
          _logToday+=jsonEncode(_medicines[i]);
        }else{
          _logToday+=";"+jsonEncode(_medicines[i]);
        }
      }
      DailyLog _log = new DailyLog(
          id: _logList[0].id,
          date: _logList[0].date,
          log: _logToday
      );
      await widget.database.update(widget.database.dailyLogs).replace(_log);
      // print("update today completed!");
      // print(_log.log);
    }

    return _medicines;
  }

  void updateMedInfo(){
    getMedInfo().then((result){
          setState(() {
            _medInfo = result;
            // print(packMedicineIntoString(_medInfo[0]));
          });
        }
    );
  }

  void updateinfo(){
    setState(() {
    });
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour,minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }


  Future<void> setNotification (String idString, String eachTime, String title, String body, int id)async{
    // await _cancelAllNotifications();
    List results = [];
    results = await _getMedicineListById(idString!.split(";"), eachTime);
    results.add(eachTime);
    await zonedScheduleNotification(title, body, jsonEncode(results), 5,id,int.parse(eachTime.split(":")[0]),int.parse(eachTime.split(":")[1]));
    // print(jsonDecode(jsonEncode(results))[0][0].runtimeType);
    // print("123");
    print("alarm for"+eachTime+"set");
  }

  @override
  void initState(){
    updateMedInfo();
    finishIntakeSubscription = bus.on<FinishIntakeEvent>().listen((event) {
      print("finish intake event received");
      updateMedInfo();
    });

  }


  Future<void> zonedScheduleNotification(String title, String body, String payload, int seconds, int id, int hour, int minute) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'your channel id',
                'your channel name',
                channelDescription: 'your channel description',
                importance: Importance.max,
                priority: Priority.max)
        ),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload
    );
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

  Future<List> _getMedicineListById(List<String> idList, String time) async{
    List list = [];
    List<Medicine> medList = [];
    List<String> whetherTakenList = [];

    for(int i=0;i<idList.length;i++){
      medList.add(await widget.database.searchMedicineById(int.parse(idList[i])));
      whetherTakenList.add(medList.last.whetherTakenList[medList.last.timesList.indexOf(time)]);
    }
    list.add(medList);
    list.add(whetherTakenList);
    return list;
  }

  @override
  Widget build(BuildContext context) {

    _timesList.clear();
    _medList.clear();
    _idList.clear();
    _whetherTakenDisplayed.clear();

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 12,3);

    for(int i=0;i<_medInfo.length;i++){
      for(int j=0;j<_medInfo[i].timesList.length;j++){
        String time = _medInfo[i].timesList[j];
        if(!_medList.keys.toList().contains(time)){
          _medList[time] = _medInfo[i].name;
          _idList[time] = _medInfo[i].id.toString();
          _whetherTakenDisplayed[time] = true;
          if(_medInfo[i].whetherTakenList[j]=="-1"){
            _whetherTakenDisplayed[time] = false;
          }
        }else{
          _medList[time] = ("${_medList[time]!}, ${_medInfo[i].name}")!;
          _idList[time] = "${_idList[time]!};${_medInfo[i].id}";
          if(_medInfo[i].whetherTakenList[j]=="-1"){
            _whetherTakenDisplayed[time] = false;
          }
        }
      }
    }

    _medList = Map.fromEntries(_medList.entries.toList()..sort((e1,e2) => e1.key.compareTo(e2.key)));

    _timesList.sort();
    _cancelAllNotifications();
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

                    if (_whetherTakenDisplayed[_eachTime]==true){
                      _content+=", 已完成";
                    }
                    else if (scheduledDate.isBefore(now)) {
                      // print("before");
                      _content+=", 已过期";
                    }
                    setNotification(_idString!, _eachTime,_eachTime+"服药提醒","您计划了"+_eachTime+"的服药，请点击查看",index);
                    // String time = _timesList[index];
                    return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                            onTap: ()  async{
                              // _zonedScheduleAlarmClockNotification("New payload");
                              List results = [];
                              results = await _getMedicineListById(_idString!.split(";"), _eachTime);
                              updateMedInfo();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context)=>MedicineIntakePage(
                                        database: widget.database,
                                        // idList: _idString!.split(";"),
                                        time: _eachTime,
                                        medList: results[0],
                                        whetherTaken: results[1],
                                        isViewOnly: false,
                                        payloadFromNotification: "none",
                                      )
                                  )
                              );
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
