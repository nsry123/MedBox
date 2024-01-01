import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:test1/medbox_page.dart';
import 'package:timezone/timezone.dart' as tz;

import 'db/db_manager.dart';



class MedicineIntakePage extends StatefulWidget {

  MedicineIntakePage({super.key, title, this.database, this.time, this.medList, this.whetherTaken, this.isViewOnly, this.payloadFromNotification});
  DBManager? database;
  List<Medicine>? medList;
  String? time;
  List<String>? whetherTaken;
  bool? isViewOnly;
  String? title = "服药";
  String? payloadFromNotification;
  static const String routeName = '/medicineIntakePage';
  @override
  State<MedicineIntakePage> createState() => _MedicineIntakePageState();
}
class FinishIntakeEvent{
  FinishIntakeEvent(this.msg);
  final String msg;
}


class _MedicineIntakePageState extends State<MedicineIntakePage> {
  // late final List<String> _idList;
  // List _medList = [];
  String _title = "";
  List<bool> _checkedMedicine = [];
  // Future<int> loadMedicine() async{
  //   if(_medList.length==0){
  //     List<Medicine> tempMedicineList = [];
  //     _idList.forEach((element) async{
  //       tempMedicineList.add(await widget.database.searchById(int.parse(element)));
  //       _whetherTaken.add(tempMedicineList.last.whetherTakenList[tempMedicineList.last.timesList.indexOf(widget.time)]);
  //     });
  //     setState(() {
  //       _medList = tempMedicineList;
  //     });
  //   }
  //   return 99;
  // }
  bool isAnyChecked(){
    return _checkedMedicine.any((element) => element==true)==true;
  }
  @override
  void initState() {
    if(widget.payloadFromNotification!="none"){
      List<Medicine> _tempMedList = [];
      List<String> _tempWhetherTakenList = [];

      print(widget.payloadFromNotification);
      List<dynamic> jsonResults = jsonDecode(widget.payloadFromNotification!);
      List<dynamic> medList = jsonResults[0];
      List<dynamic> whetherTaken = jsonResults[1];

      whetherTaken.forEach((element) {_tempWhetherTakenList.add(element);});
      String time = jsonResults[2];

      medList.forEach((element) {
        _tempMedList.add(Medicine(
            id: element['id'],
            name: element['name'],
            timesPerDay: element['timesPerDay'],
            dosePerTime: element['dosePerTime'],
            unit: element['unit'],
            taboos: element['taboos'],
            timesList: element['timesList'],
            mode: element['mode'],
            whetherTakenList: element['whetherTakenList']
        ));
      });

      widget.whetherTaken = _tempWhetherTakenList;
      widget.medList = _tempMedList;
      widget.time = time;
      widget.isViewOnly = false;
    }
    _checkedMedicine = List.filled(widget.medList!.length, false);
    _title = "intake_medicine".i18n()+widget.time!;
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child:ListView.builder(
                itemCount: widget.medList!.length,
                itemBuilder: (context, index){
                  return InkWell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 0, 10),
                          child: Column(
                            children: [
                              Text(widget.medList![index].name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                              Text("method:".i18n()+ "every_time".i18n([widget.medList![index].dosePerTime.toString(),
                                  widget.medList![index].unit]),
                                  style: TextStyle(fontSize: 20),
                              ),
                              Text("taboos:".i18n()+widget.medList![index].taboos,
                                  style: TextStyle(fontSize: 20),
                              )
                            ],
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                        ),
                        widget.whetherTaken![index]=="-1"
                        ?  (widget.isViewOnly==false?  Checkbox(
                          value: _checkedMedicine[index],
                          onChanged: (value){}
                        ): Container(child: Text("not_taken".i18n(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),margin: EdgeInsets.fromLTRB(0, 0, 10, 0),))
                        :Container(child: Text("finished_at".i18n([widget.whetherTaken![index]]),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),margin: EdgeInsets.fromLTRB(0, 0, 10, 0),)
                      ],
                    ),
                    onTap: (){
                      if(widget.whetherTaken![index]=="-1"){
                        setState(() {
                          _checkedMedicine[index] = ! _checkedMedicine[index];
                        });
                      }
                    },
                  );
                },
              )
            ),
            // Spacer(),
            Container(
              padding: EdgeInsets.fromLTRB(0, 14, 0, 14),
              child: widget.isViewOnly==false?ElevatedButton(
                onPressed: isAnyChecked()?() async{
                  Medicine _medicine;
                  for(int i=0;i<_checkedMedicine.length;i++){
                    if(_checkedMedicine[i]){
                      _medicine = widget.medList![i];
                      String hh = tz.TZDateTime.now(tz.local).hour<10 ? "0"+tz.TZDateTime.now(tz.local).hour.toString() : tz.TZDateTime.now(tz.local).hour.toString();
                      String mm = tz.TZDateTime.now(tz.local).minute<10 ? "0"+tz.TZDateTime.now(tz.local).minute.toString() : tz.TZDateTime.now(tz.local).minute.toString();
                      _medicine.whetherTakenList[_medicine.timesList.indexOf(widget.time)] = hh+":"+mm;
                      print(_medicine.name);
                      print(_medicine.whetherTakenList);
                      print(_medicine.timesList);
                      await widget.database!.update(widget.database!.medicines).replace(_medicine);
                    }
                  }
                  bus.fire(FinishIntakeEvent("Finish medicine intake"));
                  Navigator.pop(context);
                }:null,
                child: Container(
                  child: Text(style: TextStyle(fontSize: 20),"confirm_intake".i18n()),
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                ),
              ):Container(),
            )
          ],
        )
      ),
    );
  }
}

//finished localization