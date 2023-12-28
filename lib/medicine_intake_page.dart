import 'package:flutter/material.dart';
import 'package:test1/medbox_page.dart';
import 'package:timezone/timezone.dart' as tz;

import 'db/db_manager.dart';



class MedicineIntakePage extends StatefulWidget {
  final DBManager database;
  final List<Medicine> medList;
  final String time;
  final List<String> whetherTaken;
  final bool isViewOnly;
  const MedicineIntakePage({super.key, title, required this.database, required this.time, required this.medList, required this.whetherTaken, required this.isViewOnly});
  final String title = "服药";
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
    _checkedMedicine = List.filled(widget.medList.length, false);
    _title = "服药: "+widget.time;
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
                itemCount: widget.medList.length,
                itemBuilder: (context, index){
                  return InkWell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 0, 10),
                          child: Column(
                            children: [
                              Text(widget.medList[index].name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                              Text("服用方式: 一次"+
                                  widget.medList[index].dosePerTime.toString()+
                                  widget.medList[index].unit,
                                  style: TextStyle(fontSize: 20),
                              ),
                              Text("禁忌: "+widget.medList[index].taboos,
                                  style: TextStyle(fontSize: 20),
                              )
                            ],
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                        ),
                        widget.whetherTaken[index]=="-1"
                        ?  (widget.isViewOnly==false?  Checkbox(
                          value: _checkedMedicine[index],
                          onChanged: (value){}
                        ): Container(child: Text("未服用",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),margin: EdgeInsets.fromLTRB(0, 0, 10, 0),))
                        :Container(child: Text("已于"+widget.whetherTaken[index]+"\n服用",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),margin: EdgeInsets.fromLTRB(0, 0, 10, 0),)
                      ],
                    ),
                    onTap: (){
                      if(widget.whetherTaken[index]=="-1"){
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
                      _medicine = widget.medList[i];
                      _medicine.whetherTakenList[_medicine.timesList.indexOf(widget.time)] = tz.TZDateTime.now(tz.local).hour.toString()+":"+tz.TZDateTime.now(tz.local).minute.toString();
                      print(_medicine.name);
                      print(_medicine.whetherTakenList);
                      print(_medicine.timesList);
                      await widget.database.update(widget.database.medicines).replace(_medicine);
                    }
                  }
                  bus.fire(FinishIntakeEvent("Finish medicine intake"));
                  Navigator.pop(context);
                }:null,
                child: Container(
                  child: Text(style: TextStyle(fontSize: 20),"确定服用"),
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