import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

import 'db/db_manager.dart';



class MedicineIntakePage extends StatefulWidget {
  final DBManager database;
  final String idString;
  final String nameString;
  final String time;
  const MedicineIntakePage({super.key, title, required this.database, required this.idString, required this.nameString, required this.time});
  final String title = "服药";
  @override
  State<MedicineIntakePage> createState() => _MedicineIntakePageState();
}

class _MedicineIntakePageState extends State<MedicineIntakePage> {
  late final List<String> _idList;
  late final List<String> _nameList;
  List _medList = [];
  String _title = "";
  List _checkedMedicine = [];
  List _whetherTaken = [];
  Future<int> loadMedicine() async{
    if(_medList.length==0){
      List<Medicine> tempMedicineList = [];
      _idList.forEach((element) async{
        tempMedicineList.add(await widget.database.searchById(int.parse(element)));
        _whetherTaken.add(tempMedicineList.last.whetherTakenList[tempMedicineList.last.timesList.indexOf(widget.time)]);
      });
      setState(() {
        _medList = tempMedicineList;
      });
    }
    return 99;
  }
  bool isAnyChecked(){
    return _checkedMedicine.any((element) => element==true)==true;
  }
  @override
  void initState() {
    List temp = [];
    _idList = widget.idString.split(";");
    _nameList = widget.nameString.split(", ");
    _idList.forEach((element) { _checkedMedicine.add(false);});
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
              child:FutureBuilder<int>(
                future: loadMedicine(),
                initialData: 0,
                builder: (context, snapshot){
                  if(!snapshot.hasData){
                    return Text("Loading");
                  }
                  return ListView.builder(
                      // shrinkWrap: true,
                      itemCount: _medList.length,
                      itemBuilder: (context, index){
                        return InkWell(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 10, 0, 10),
                                child: Column(
                                  children: [
                                    Text(_medList[index].name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                                    Text("服用方式: 一次"+
                                        _medList[index].dosePerTime.toString()+
                                        _medList[index].unit,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Text("禁忌: "+_medList[index].taboos,
                                      style: TextStyle(fontSize: 20),
                                    )
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                              ),
                              _whetherTaken[index]=="-1"?
                              Checkbox(
                                  value: _checkedMedicine[index],
                                  onChanged: (value){
                                  }
                              ):Text("已于"+_whetherTaken[index]+"服用")
                            ],),
                          onTap: (){
                            if(_whetherTaken[index]=="-1"){
                              setState(() {
                                _checkedMedicine[index] = ! _checkedMedicine[index];
                              });
                            }
                          },
                        );
                      },
                  );
                },
              )
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 14),
              child: ElevatedButton(
                onPressed: isAnyChecked()?() async{
                  Medicine _medicine;
                  for(int i=0;i<_checkedMedicine.length;i++){
                    if(_checkedMedicine[i]){
                      _medicine = await widget.database.searchById(int.parse(_idList[i]));
                      _medicine.whetherTakenList[_medicine.timesList.indexOf(widget.time)] = tz.TZDateTime.now(tz.local).hour.toString()+":"+tz.TZDateTime.now(tz.local).minute.toString();
                      print(_medicine.name);
                      print(_medicine.whetherTakenList);
                      print(_medicine.timesList);
                      await widget.database.update(widget.database.medicines).replace(_medicine);
                    }
                  }
                  Navigator.pop(context);
                }:null,
                child: Container(
                  child: Text(style: TextStyle(fontSize: 20),"确定服用"),
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}