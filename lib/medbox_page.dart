import 'dart:async';

// import 'package:drift/drift.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'db/db_manager.dart';

class NotificationHelper {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Initialize notification
  initializeNotification() async {
    _configureLocalTimeZone();
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings("ic_launcher");

    const InitializationSettings initializationSettings = InitializationSettings(
      iOS: initializationSettingsIOS,
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// Set right date and time for notifications
  tz.TZDateTime _convertTime(int hour, int minutes) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minutes,
    );
    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }
    return scheduleDate;
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZone));
  }

  /// Scheduled Notification
  scheduledNotification({
    required int hour,
    required int minutes,
    required int id,
    required String sound,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'It\'s time to drink water!',
      'After drinking, touch the cup to confirm',
      _convertTime(hour, minutes),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id $sound',
          'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound(sound),
        ),
        iOS: DarwinNotificationDetails(sound: '$sound.mp3'),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'It could be anything you pass',
    );
  }

  /// Request IOS permissions
  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  cancelAll() async => await flutterLocalNotificationsPlugin.cancelAll();
  cancel(id) async => await flutterLocalNotificationsPlugin.cancel(id);
}


class MedboxPage extends StatefulWidget {
  final DBManager database;
  const MedboxPage({super.key, title, required this.database});

  final String title = "全部药品";
  @override
  State<MedboxPage> createState() => _MedboxPageState();
}

EventBus bus = new EventBus();

class CustomNotification extends Notification {
  CustomNotification(this.msg);
  final String msg;
}
class CustomEvent{
  String msg;
  CustomEvent(this.msg);
}

class _MedboxPageState extends State<MedboxPage> {

  // final database = DBManager();
  List<Medicine> _medInfo = [];

  late StreamSubscription subscription;


  Future<List<Medicine>>  getMedInfo() async {
    return await widget.database.select(widget.database.medicines).get();
  }

  void updateMedInfo(){
    getMedInfo().then(
            (result){
          setState(() {
            _medInfo = result;
          });
        }
    );
  }

  @override
  void initState(){
    super.initState();
    subscription = bus.on<CustomEvent>().listen((event) {
      print(event.msg);
      if(event.msg=="finish_add_medicine"){
        updateMedInfo();
      }
    });
    updateMedInfo();
  }

  Widget deleteMedicineAlert(int index) {
    return AlertDialog(
      title: const Text("是否删除该药品？"),
      content: Row(
        children: [
          TextButton(
              onPressed: () {
                setState(() {
                  widget.database.deleteMedicineById(_medInfo[index].id);
                  updateMedInfo();
                });
                Navigator.of(context).pop();
              },
              child: Text("确定")),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("取消"))
        ],
      ),
    );
  }

  @override
  void dispose(){
    super.dispose();
    subscription.cancel();
  }



  @override
  Widget build(BuildContext context){

    return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: ListView.builder(
                      itemCount: _medInfo.length,
                      itemBuilder: (context,index){
                        Medicine medicine = _medInfo.elementAt(index);
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: (){
                              CustomNotification("to_change_medicine_$index").dispatch(context);

                            },
                            onLongPress: (){
                              showDialog(context: context, builder: (context) => deleteMedicineAlert(index));
                            },
                            child: Container(
                              margin: EdgeInsets.fromLTRB(10, 10, 0, 10),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                          medicine.name,
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                          "每日${medicine.timesPerDay}次, 每次${medicine.dosePerTime}${medicine.unit}",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          )
                        );
                      },
                    )
                  ),
                )
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: (){
              CustomNotification("to_medicine_entry").dispatch(context);
            }
          ),
      );
  }
}
