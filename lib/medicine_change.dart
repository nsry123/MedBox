import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:localization/localization.dart';

import 'db/db_manager.dart';
import 'medbox_page.dart';

class MedicineChange extends StatefulWidget {
  final DBManager database;
  final int medNum;
  const MedicineChange({super.key, required this.title, required this.database, required this.medNum});

  final String title;

  @override
  State<MedicineChange> createState() => _MedicineChangeState();
}

class _MedicineChangeState extends State<MedicineChange> {


  final _form4 = GlobalKey<FormState>();
  final _medNameController = TextEditingController();
  final _medDoseController = TextEditingController();
  final _medUnitController = TextEditingController();
  final _medTabooController = TextEditingController();
  final _dosePerDayController = TextEditingController();
  late Medicine medicine;
  late String _medName, _medDose, _medUnit, _medTaboo;
  String _chosen = "everyday_x_times".i18n();
  final choices = ["everyday_x_times".i18n()];
  List times = [];

  Future<List<Medicine>>  getMedInfo() async {
    return await widget.database.select(widget.database.medicines).get();
  }

  @override
  void initState(){
    getMedInfo().then((result){
      setState(() {
        medicine = result.elementAt(widget.medNum);
        _medNameController.text = medicine.name;
        _medDoseController.text = medicine.dosePerTime.toString();
        _medUnitController.text = medicine.unit;
        _medTabooController.text = medicine.taboos;
        _dosePerDayController.text = medicine.timesPerDay.toString();
        times = medicine.timesList;
      });
    });
  }

  void _buildNewTimeList(len){
    setState(() {
      times.clear();
      for(int i=1;i<=len;i++){
        times.add("00:00");
      }
    });
  }

  Widget _getTimeWidget(index,time){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: Text("nth_time".i18n([index.toString()]),style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
        ),
        Listener(
            onPointerDown: (PointerDownEvent event) {
              _showDatePicker(index-1);
            },
            child:
            Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Text(time,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20,fontStyle: FontStyle.italic)),
            )
        ),
      ],
    );
  }

  void _showDatePicker(index){
    Future<TimeOfDay?> t = showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
      useRootNavigator: true,
      helpText: "select_time_help".i18n(),
      errorInvalidText: "time_input_illegal".i18n(),
      hourLabelText: "hour_label".i18n(), // 小时 提示语
      minuteLabelText: "minute_label".i18n(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    ).then((value){
      if (value == null) {
        return;
      }
      setState(() {
        String hh = value.hour.toString();
        String mm = value.minute.toString();
        if(value.minute<10){
          mm = "0$mm";
        }
        if(value.hour<10){
          hh = "0$hh";
        }
        times[index] = "$hh:$mm";
        times.sort();
      });
    });
  }

  List <Widget> _getWidgetList(){
    List <Widget> timeWidgets = [];
    for(int i=0;i<times.length;i++){
      timeWidgets.add(_getTimeWidget(i+1, times[i]));
    }
    return timeWidgets;
  }

  void _updateDatabase() async{
    Medicine newMedicine = Medicine(
        id: medicine.id,
        name: _medNameController.text,
        timesPerDay: int.parse(_dosePerDayController.text),
        dosePerTime: int.parse(_medDoseController.text),
        unit: _medUnitController.text,
        taboos: _medTabooController.text,
        timesList: times,
        mode: choices.indexOf(_chosen),
        whetherTakenList: medicine.whetherTakenList,
    );
    await widget.database.update(widget.database.medicines).replace(newMedicine);
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("modify_medicine".i18n()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: (){
                if(_form4.currentState!.validate()) {
                  _updateDatabase();
                  bus.fire(CustomEvent("finish_add_medicine"));
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    SystemNavigator.pop();
                  }
                }
              },
              icon: Icon(Icons.save)
          )
        ],
      ),
      body: SingleChildScrollView(
            child: Form(
              key: _form4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                    child: Text("basic_information".i18n(),style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    padding:const EdgeInsets.fromLTRB(10, 10, 0, 0),
                  ),

                  //First row
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                            padding:const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: TextFormField(
                              decoration:  InputDecoration(labelText: "medicine_name".i18n()),
                              controller: _medNameController,
                              validator: (text){
                                if(text!.isEmpty){
                                  return "cannot_be_empty".i18n(["medicine_name".i18n()]);
                                }
                                return null;
                              },
                            ),
                          )
                      ),
                    ],
                  ),


                  //Second Row
                  Row(
                    children: [
                      Expanded(
                          flex: 4,
                          child: Container(
                              padding:const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: TextFormField(
                                decoration:  InputDecoration(labelText: "dose_per_time".i18n()),
                                controller: _medDoseController,
                                validator: (text){
                                  if(text!.isEmpty){
                                    return "cannot_be_empty".i18n(["dose_per_time".i18n()]);
                                  }
                                  return null;
                                },
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                keyboardType: TextInputType.number,
                              )
                          )
                      ),


                      Expanded(
                          flex: 2,
                          child: Container(
                              padding:const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: TextFormField(
                                decoration: InputDecoration(labelText: "unit".i18n()),
                                controller: _medUnitController,
                                validator: (text){
                                  if(text!.isEmpty){
                                    return "cannot_be_empty".i18n(["unit".i18n()]);
                                  }
                                  return null;
                                },
                              )
                          )
                      ),
                    ],
                  ),


                  //Third Row
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: TextFormField(
                                decoration: InputDecoration(labelText: "taboos".i18n()),
                                controller: _medTabooController,
                                validator: (text){
                                  if(text!.isEmpty){
                                    return "cannot_be_empty".i18n(["taboos".i18n()]);
                                  }
                                  return null;
                                },
                              )
                          )
                      ),
                    ],
                  ),

                  Container(
                    child: Text("intake_schedule".i18n(),style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    padding:const EdgeInsets.fromLTRB(10, 15, 0, 0),
                  ),

                  RadioGroup<String>.builder(
                    groupValue: _chosen,
                    onChanged: (value){

                      //TODO: implement different choices, can be difficult
                      // setState(() {
                      //   _chosen = value!;
                      // });
                    },
                    items: choices,
                    itemBuilder: (item) => RadioButtonBuilder(
                      item,
                    ),
                    fillColor: Colors.blue,
                  ),
                  Container(
                      padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                      child: Text("please_set_specific_times".i18n(),style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),)
                  ),
                  Row(
                    children: [
                      Expanded(
                        child:Container(
                          padding:const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: TextFormField(
                            decoration: InputDecoration(labelText: "times_per_day".i18n()),
                            maxLength: 1,

                            validator: (text){
                              if(text!.isEmpty){

                                return "cannot_be_empty".i18n(["times_per_day".i18n()]);
                              }
                              if(int.parse(text)==0){
                                return "tpd_cannot_be_0".i18n();
                              }
                              return null;
                            },
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            keyboardType: TextInputType.number,
                            controller: _dosePerDayController,
                            onChanged: (text){
                              if(text.isNotEmpty) {
                                _buildNewTimeList(int.parse(text));
                                //print(times.length);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 30),
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        itemExtent: 30,
                        shrinkWrap: true,
                        children: _getWidgetList(),
                      ),
                  ),
                ],
              ),
            ),
          )
    );
  }
}

//finished localization