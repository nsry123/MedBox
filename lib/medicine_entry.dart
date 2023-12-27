import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:test1/db/db_manager.dart';
import 'package:test1/ocr_page.dart';

import 'medbox_page.dart';


class MedicineEntry extends StatefulWidget {
  final DBManager database;
  const MedicineEntry({super.key, title, required this.database});

  final String title = "添加药物";

  @override
  State<MedicineEntry> createState() => _MedicineEntryState();
}


class CustomNotification2 extends Notification {
  CustomNotification2(this.msg);
  final String msg;
}


class _MedicineEntryState extends State<MedicineEntry> {

  final _form = GlobalKey<FormState>();
  final _form2 = GlobalKey<FormState>();
  final _medNameController = TextEditingController();
  final _medDoseController = TextEditingController();
  final _medUnitController = TextEditingController();
  final _medTabooController = TextEditingController();
  final _dosePerDayController = TextEditingController();
  final choices = ["每天服用X次", "每隔X天服用Y次", "按周规划", "按月规划"];
  late StreamSubscription OCRsubscription;
  String _chosen = "每天服用X次";
  late Widget _buttons;
  List pages = [];
  List times = [];
  List whetherTaken = [];

  double _progress = 0;
  int _pos = 0;

  void _updateDatabase() async{
    await widget.database.into(widget.database.medicines).insert(MedicinesCompanion.insert(
        name: _medNameController.text,
        timesPerDay: int.parse(_dosePerDayController.text),
        unit: _medUnitController.text,
        taboos: _medTabooController.text,
        timesList: times,
        // dosePerTime: 123
        dosePerTime:  int.parse(_medDoseController.text),
        mode: choices.indexOf(_chosen),
        whetherTakenList: whetherTaken
    ));
  }

  void _onNextButtonPressed() {
    if(_pos==0){
      if(_form.currentState!.validate()){
        print("Page 1 Correct Input!");
        setState(() {
          _pos++;
          _progress = (_pos+1)/(pages.length);
        });
      }else{
        print("Page 1 Wrong Input!");
      }
    }
    else if(_pos==1) {
      setState(() {
        _pos++;
        _progress = (_pos + 1) / (pages.length);
      });
    }
    else if(_pos==2){
      if(_form2.currentState!.validate()) {
        // widget.database.delete(widget.database.medicines).go();
        _updateDatabase();
        // print(await widget.database.select(widget.database.medicines).get());
        setState(() {
          _pos++;
          _progress = (_pos + 1) / (pages.length);
          _buttons = buildFinishButtons();
          //print(_pos);
        });
      }
    }
    else if(_pos==3){
      // CustomNotification2("finish_medicine_entry").dispatch(context);
      bus.fire(CustomEvent("finish_add_medicine"));
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        SystemNavigator.pop();
      }
    }
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
          child: Text("第$index次",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
        ),
        Listener(
          onPointerDown: (PointerDownEvent event) {
            _showDatePicker(index-1);
          },
          child:
          Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: Text(time+"▼",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20,fontStyle: FontStyle.italic)),
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
      helpText: "请选择时间(24小时制)",
      errorInvalidText: "输入时间不合法",
      hourLabelText: "时", // 小时 提示语
      minuteLabelText: "分",
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
    whetherTaken = [];
    for(int i=0;i<times.length;i++){
      timeWidgets.add(_getTimeWidget(i+1, times[i]));
      whetherTaken.add("-1");
    }
    return timeWidgets;
  }

  void _onBackButtonPressed(){
    if(_pos>0){
      setState(() {
        _pos--;
        _progress = (_pos + 1) / (pages.length);
      });
    }
  }

  List _getPages(){
    _progress = (_pos+1)/(pages.length);
    pages = [buildPage1(),buildPage2(), buildPage3(), buildPage4()];
    return pages;
  }

  Widget buildPage3(){
    return Form(
      key: _form2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child:const Text("请设置具体时间",style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),)
          ),
          Row(
            children: [
              Expanded(
                child:Container(
                    padding:const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: "服用次数"),
                      maxLength: 1,

                      validator: (text){
                        if(text!.isEmpty){
                          return "服用次数不能为空!";
                        }
                        if(int.parse(text)==0){
                          return "服用次数不能为0!";
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
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: ListView(
                scrollDirection: Axis.vertical,
                itemExtent: 30,
                children: _getWidgetList(),
              ),
            ),
          )

        ],
      ),
    );
  }

  Widget buildPage2(){
    return Form(
      key: _form,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child:Text("您想如何服用 ${_medNameController.text}?",style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),)
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
          )
        ],
      ),
    );
  }

  Widget buildPage1(){
    return Form(
      key: _form,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child:const Text("您想添加什么药品？",style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              )
          ),

          //First row
          Row(
            children: [
              Expanded(
                  child: Container(
                    padding:const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: "药品名称"),
                      controller: _medNameController,
                      validator: (text){
                        if(text!.isEmpty){
                          return "药品名称不能为空!";
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
                        decoration: const InputDecoration(labelText: "单次剂量"),
                        controller: _medDoseController,
                        validator: (text){
                          if(text!.isEmpty){
                            return "单次剂量不能为空!";
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
                        decoration: const InputDecoration(labelText: "单位"),
                        controller: _medUnitController,
                        validator: (text){
                          if(text!.isEmpty){
                            return "单位不能为空!";
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
                        decoration: const InputDecoration(labelText: "药品禁忌"),
                        controller: _medTabooController,
                        validator: (text){
                          if(text!.isEmpty){
                            return "禁忌不能为空!";
                          }
                          return null;
                        },
                      )
                  )
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget buildPage4(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text("添加完成！",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))],
    );
  }

  Widget buildStepButtons(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[

        Expanded(
            flex: 1,
            child: Container(
                padding: const EdgeInsets.fromLTRB(10.0,12.0,10.0,12.0),
                child: ElevatedButton(
                  onPressed: _onBackButtonPressed,
                  child: const Text("上一步"),
                )
            )
        ),

        Expanded(
            flex: 1,
            child:Container(
                padding: const EdgeInsets.fromLTRB(10.0,12.0,10.0,12.0),
                child:
                ElevatedButton(
                  onPressed: _onNextButtonPressed,
                  child: Text("下一步"),
                )
            )
        ),
      ],

    );
  }

  Widget buildFinishButtons(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
            flex: 1,
            child:Container(
                padding: const EdgeInsets.fromLTRB(10.0,12.0,10.0,12.0),
                child:
                ElevatedButton(
                  onPressed: _onNextButtonPressed,
                  child: Text("完成"),
                )
            )
        ),
      ],
    );
  }

  @override
  void initState(){
    _getPages();
    _buttons = buildStepButtons();
    OCRsubscription = bus.on<OCREvent>().listen((event) {
      String OCR_result = event.msg.split(";").elementAt(1);
      print(OCR_result);
      var jsonData = jsonDecode(OCR_result);
      setState(() {
        _medNameController.text = jsonData['name'];
        _medUnitController.text = jsonData['typeOfMedicineEntity'];
        _medTabooController.text = jsonData['taboos'].toString();
        _medDoseController.text = jsonData['numberOfMedicineEntityPerTime'].toString();
        _dosePerDayController.text = jsonData['timesPerDay'].toString();
        _buildNewTimeList(int.parse(jsonData['timesPerDay'].toString()));
      });
      _buildNewTimeList(int.parse(jsonData['timesPerDay'].toString()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => OcrPage()));
              },
              icon: Icon(Icons.add),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: _getPages().elementAt(_pos),
            flex: 10,
          ),

          _buttons,

          Container(
            padding: const EdgeInsets.fromLTRB(10.0,12.0,10.0,12.0),
            child: LinearProgressIndicator(
              value: _progress,
            )
          )
        ],
      ),
    );
  }
}
