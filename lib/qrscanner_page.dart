import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localization/localization.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wifi_iot/wifi_iot.dart';

import 'db/db_manager.dart';

Future<void> showLoadingDialog(
    BuildContext context,
    ) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );
}

// to hide our current dialog
void hideLoadingDialog(BuildContext context) {
  Navigator.of(context).pop();
}

class QrScanner extends StatefulWidget {
  final DBManager database;
  const QrScanner({super.key, title, required this.database});

  final String title = "qr_scanner_title";
  @override
  State<QrScanner> createState() => _QrscannerPageState();
}

class _QrscannerPageState extends State<QrScanner> with WidgetsBindingObserver{

  // final MobileScannerController controller = MobileScannerController(
  //   autoStart: false,
  //   torchEnabled: false,
  //   useNewCameraSelector: false,
  // );
  Barcode? _barcode;
  StreamSubscription<Object?>? _subscription;
  String ssid = "";
  String pwd = "";

  bool _isEnabled = false;
  int _remainingRetry = 5;
  bool _isConnected = false;
  bool _isWiFiAPEnabled = false;
  bool _isWiFiAPSSIDHidden = false;
  bool _isWifiAPSupported = true;
  bool _isWifiEnableOpenSettings = false;
  bool _isWifiDisableOpenSettings = false;
  bool isSynched = false;
  late Future<bool> _isSyncSuccessful;

  Future<bool> _syncWithRetry(int remainingRetries) async {
    bool success = await _trySyncJsonWithESP32();
    if (success) {
      return true;
    } else {
      if (remainingRetries > 0) {
        await Future.delayed(Duration(seconds: 2));
        print("-----------------------Remaining retries left: $remainingRetries--------------------");
        return _syncWithRetry(remainingRetries - 1);
      } else {
        return false;
      }
    }
  }


  Future<bool> _trySyncJsonWithESP32()async {
    // controller.stop();
    print("Start synchronising");
    List<Medicine> medicine_list = await widget.database.select(widget.database.medicines).get();
    List<Map<String,dynamic>> json_list = [];
    medicine_list.forEach((element){
      var medicine_info = {
        "name":element.name,
        "unit":element.unit,
        "dose_per_time":element.dosePerTime,
        "taboos":element.taboos,
        "times_per_day":element.timesPerDay,
        "times_list":element.timesList
      };
      // print(medicine_info.toString());
      json_list.add(medicine_info);
      // var single_medicine_view = await widget.database.select(widget.database.medicines).get();
    });

    Map<String, dynamic> mapFinal = {
      "medicine":json_list,
      "hour":14,
      "minute":14
    };
    var jsonObject = jsonEncode(mapFinal);
    print(jsonObject.toString());

    // print("created json string:");
    // print(jsonObject.toString());
    // await Future.delayed(Duration(seconds: 5));
    // showLoadingDialog(context);
    // await Future.delayed(const Duration(seconds: 10));
    try{
      // setState(() {
      //   _isSyncSuccessful = sendJsonData(jsonObject);
      // });
      return sendJsonData(jsonObject);
    } catch (e) {
      print("error during sync");
      return false;
    }
  }

  Widget _buildBarcode(Barcode? value) {
    if (value == null) {
      return const Text(
        'Scan something!',
        overflow: TextOverflow.fade,
        style: TextStyle(color: Colors.white),
      );
    }
    if(_barcode?.type == BarcodeType.wifi){
      ssid = _barcode!.wifi!.ssid!;
      pwd = _barcode!.wifi!.password!;
      // controller.stop();

      WiFiForIoTPlugin.connect(ssid, password: pwd, security:NetworkSecurity.WPA,joinOnce: true).then(
              (onValue){
                if(onValue==true){
                  setState(() {
                    _isSyncSuccessful = _syncWithRetry(_remainingRetry);
                  });
                }
              });
      // WifiConnector.connectToWifi(ssid: ssid, password: pwd).then((onValue){print("success");});
    }
    return Text(
      value.displayValue ?? 'No display value.',
      overflow: TextOverflow.fade,
      style: const TextStyle(color: Colors.white),
    );
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted) {
      setState(() {
        _barcode = barcodes.barcodes.firstOrNull;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // _subscription = controller.barcodes.listen(_handleBarcode);

    // unawaited(controller.start());

    WiFiForIoTPlugin.isEnabled().then((val) {
      setState(() {
        _isEnabled = val;
      });

    });
    setState(() {
      _isConnected = true;
      setState(() {
        _isSyncSuccessful = _syncWithRetry(_remainingRetry);
      });
    });
    WiFiForIoTPlugin.getSSID().then((val) {
      // if(val=="MedMinder"){
        setState(() {
          _isConnected = true;
          setState(() {
            _isSyncSuccessful = _syncWithRetry(_remainingRetry);
          });
        });
      // }
    });
    WiFiForIoTPlugin.isWiFiAPEnabled().then((val) {
      _isWiFiAPEnabled = val;
    }).catchError((val) {
      _isWifiAPSupported = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // if (!controller.value.isInitialized) {
    //   return;
    // }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        // _subscription = controller.barcodes.listen(_handleBarcode);

        // unawaited(controller.start());
      case AppLifecycleState.inactive:
        unawaited(_subscription?.cancel());
        _subscription = null;
        // unawaited(controller.stop());
    }
  }

  Future<bool> sendJsonData(var jsonData) async {
    var url = Uri.parse('http://192.168.4.1/store_json');  // Replace with ESP32 IP
    var jsonBody = jsonEncode({
      'user_id': 'example_user',
      'user_code': '12345'
    });
    var response = await http.post(url, body: jsonData, headers: {
      'Content-Type': 'application/json',
    });
    if (response.statusCode == 200) {
      print("sync success");
      return true;
    } else {
      print("sync failed");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title.i18n()),backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
      // backgroundColor: Colors.black,f
      body:
          Column(
            children: [
              Row(
                children: [
                  _isConnected ? FutureBuilder(
                    future: _isSyncSuccessful,
                    builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      if (!snapshot.hasData) {
                        // while data is loading:
                        return Text("syncing".i18n(), style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ));
                      } else {
                        // data loaded:
                        if(snapshot.data!){
                          return Text("sync_success".i18n(), style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ));
                        }else{
                          return Text("sync_failed".i18n(["5"]), style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ));
                        }
                      }
                    },):

                  Flexible(
                      child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Text(
                            "wifi_incorrect".i18n(),
                            overflow: TextOverflow.clip,softWrap: true,
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,
                            )
                        )
                      )
                  )
                ],
              )
            ],
          )

      // ):Stack(
      //   children: [
      //     MobileScanner(
      //       controller: controller,
      //       errorBuilder: (context, error, child) {
      //         return ScannerErrorWidget(error: error);
      //       },
      //       fit: BoxFit.cover,
      //     ),
      //     Align(
      //       alignment: Alignment.bottomCenter,
      //       child: Container(
      //         alignment: Alignment.bottomCenter,
      //         height: 100,
      //         color: Colors.black.withOpacity(0.4),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //           children: [
      //             ToggleFlashlightButton(controller: controller),
      //             StartStopMobileScannerButton(controller: controller),
      //             Expanded(child: Center(child: _buildBarcode(_barcode))),
      //             SwitchCameraButton(controller: controller),
      //             AnalyzeImageFromGalleryButton(controller: controller),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
    // await controller.dispose();
  }
}






