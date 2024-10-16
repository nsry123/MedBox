import 'dart:async';

// import 'package:drift/drift.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import 'db/db_manager.dart';


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
      title: Text("whether_delete_medicine".i18n()),
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
              child: Text("yes".i18n())),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("no".i18n()))
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
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                              margin: EdgeInsets.fromLTRB(20, 20, 0, 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          medicine.name,
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)
                                      ),
                                      Text(
                                          "every_day".i18n([medicine.timesPerDay.toString()])+", "+"every_time".i18n([medicine.dosePerTime.toString(),medicine.unit]),
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
                                      )
                                    ],
                                  ),
                                  Icon(Icons.keyboard_arrow_right,size: 30,)
                                ],
                              )
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
