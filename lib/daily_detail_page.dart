import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:test1/medicine_intake_page.dart';
import 'package:timezone/timezone.dart' as tz;

import 'db/db_manager.dart';



class DailyDetailPage extends StatefulWidget {
  final DBManager database;
  final String medInfo;
  final String title;
  DailyDetailPage({super.key, required this.database, required this.medInfo, required this.title});

  @override
  State<DailyDetailPage> createState() => _DailyDetailPageState();
}

class _DailyDetailPageState extends State<DailyDetailPage> {
  List<Medicine> _medInfo = [];
  List<String> _timesList = [];
  Map<String,String> _medList = new Map();
  Map<String,String> _idList = new Map();
  Map<String, bool> _whetherTakenDisplayed = new Map();
  int temp = 0;
  late StreamSubscription finishIntakeSubscription;

  void updateMedInfo(){
    _medInfo = [];
    widget.medInfo.split(";").forEach((element) {
      Map _tempMap = jsonDecode(element);
      _medInfo.add(new Medicine(
          id: _tempMap['id'],
          name: _tempMap['name'],
          timesPerDay: _tempMap['timesPerDay'],
          dosePerTime: _tempMap['dosePerTime'],
          unit: _tempMap['unit'],
          taboos: _tempMap['taboos'],
          timesList: _tempMap['timesList'],
          mode: _tempMap['mode'],
          whetherTakenList: _tempMap['whetherTakenList']
      ));
    });
  }


  @override
  void initState(){
    updateMedInfo();
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
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary
      ),
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
                    String _content = "intake_at".i18n([_eachTime,_medList[_eachTime]!]);
                    String? _idString = _idList[_eachTime];
                    if (_whetherTakenDisplayed[_eachTime]==true){
                      _content+=", "+"finished".i18n();
                    }
                    else {
                      // print("before");
                      _content+=", "+"expired".i18n();
                    }
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
                                        isViewOnly: true,
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
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)
                                      ),
                                      Icon(Icons.keyboard_arrow_right,size: 30)
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
