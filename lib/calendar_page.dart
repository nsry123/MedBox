import 'package:flutter/material.dart';
import 'package:test1/daily_detail_page.dart';

import 'db/db_manager.dart';

class CalendarPage extends StatefulWidget {
  final DBManager database;
  const CalendarPage({super.key, title, required this.database});
  final String title = "我的药历";
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<DailyLog> _logList = [];


  Future<List<DailyLog>>  getLogInfo() async {
    return await widget.database.select(widget.database.dailyLogs).get();
  }

  void updateLogInfo(){
    getLogInfo().then( (result){
          setState(() {
            _logList = result.reversed.toList();
          });
        }
    );
  }



  @override
  void initState(){
    updateLogInfo();
  }



  @override
  Widget build(BuildContext context) {
    updateLogInfo();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: ListView.builder(
                  itemCount: _logList.length,
                  itemBuilder: (context, index){

                    List<String> _dateInfo = _logList[index].date.split(";");

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        child: Container(
                        margin: EdgeInsets.fromLTRB(10, 10, 0, 10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      _dateInfo[0]+"年"+_dateInfo[1]+"月"+_dateInfo[2]+"日",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)
                                  ),
                                  Icon(Icons.keyboard_arrow_right,size: 30,)
                                ],
                              ),
                            ],
                          ),
                        ),
                        onTap: (){
                          if(_logList[index].log!=""){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context)=>DailyDetailPage(
                                        database: widget.database,
                                        medInfo: _logList[index].log,
                                        title: _dateInfo[0]+"年"+_dateInfo[1]+"月"+_dateInfo[2]+"日"
                                    )
                                )
                            );
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text("当天没有药品数据!"),
                            ));
                          }
                        },
                      ),
                    );
                  }
                )
            )
          ],
        ),
      ),

    );
  }
}
