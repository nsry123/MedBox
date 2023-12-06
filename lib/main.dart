import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:test1/calendar_page.dart';
import 'package:test1/medicine_change.dart';
import 'package:test1/medicine_entry.dart';
import 'package:test1/todo_page.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'db/db_manager.dart';
import 'medbox_page.dart';


void main() {
  runApp(const MyApp());
}
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
NotificationHelper notificationHelper = new NotificationHelper();

class NotificationHelper {

  /// Initialize notification
  initializeNotification() async {
    _configureLocalTimeZone();
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings("@mipmap/ic_launcher");

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

  Future<void> getAllNotifications() async{
    flutterLocalNotificationsPlugin.getActiveNotifications().then((value) {
      print(value);
      print(value.length);
    });
  }

  Future<void> zonedScheduleNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'scheduled title',
        'scheduled body',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails('your channel id', 'your channel name',
                channelDescription: 'your channel description')),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }

  /// Scheduled Notification
  Future<void> scheduledNotification({
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
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          // sound: RawResourceAndroidNotificationSound(sound),
        ),
        iOS: DarwinNotificationDetails(),
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

Future<void> _requestPermissions() async {

  if (Platform.isIOS || Platform.isMacOS) {


    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  } else if (Platform.isAndroid) {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    final bool? grantedNotificationPermission = await androidImplementation?.requestNotificationsPermission();
    print(grantedNotificationPermission);
  }
}

Future<void> _isAndroidPermissionGranted() async {
  if (Platform.isAndroid) {
    final bool granted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled() ??
        false;
    print(granted);

    // setState(() {
    //   _notificationsEnabled = granted;
    // });
  }
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
  void initState(){
    _requestPermissions();
    _isAndroidPermissionGranted();
    notificationHelper.initializeNotification();
    // notificationHelper.scheduledNotification(hour: 22, minutes: 4, id: 12, sound: "123");
    notificationHelper.zonedScheduleNotification();
    notificationHelper.getAllNotifications();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> getPages(){
      return [TodoPage(database: database,anotificationHelper: notificationHelper,), CalendarPage(), MedboxPage(database: database)];
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
