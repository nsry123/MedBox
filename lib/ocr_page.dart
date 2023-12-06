import 'dart:async';
import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import 'medbox_page.dart';

class OcrPage extends StatefulWidget {
  const OcrPage({super.key});

  @override
  State<OcrPage> createState() => _OcrState();
}

class OCREvent{
  OCREvent(this.msg);
  final String msg;
}

abstract class ITextRecognizer {
  Future<String> processImage(String imgPath);
}

class MyTextRecognizer extends ITextRecognizer {
  late TextRecognizer recognizer;

  MyTextRecognizer() {
    recognizer = TextRecognizer();
  }

  void dispose() {
    recognizer.close();
  }

  @override
  Future<String> processImage(String imgPath) async {
    final image = InputImage.fromFilePath(imgPath);
    final recognized = await recognizer.processImage(image);
    return recognized.text;
  }
}

Widget imagePickAlert({
  void Function()? onCameraPressed,
  void Function()? onGalleryPressed,
}) {
  return AlertDialog(
    title: const Text(
      "请选择图片",
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.camera_alt),
          title: const Text(
            "相机",
          ),
          onTap: onCameraPressed,
        ),
        ListTile(
          leading: const Icon(Icons.image),
          title: const Text(
            "相册",
          ),
          onTap: onGalleryPressed,
        ),
      ],
    ),
  );
}

class _OcrState extends State<OcrPage> {
  late ImagePicker _imagePicker;
  late MyTextRecognizer _recognizer;
  int _isLoading = 0;

  List<String> _imagePaths = [];
  String _result = "";
  late StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
    _recognizer = MyTextRecognizer();
    OpenAI.apiKey = "sk-OY6LgQtwdh4zK7yyB7689e39259849B8A1D23a5dF507555c";
    OpenAI.baseUrl = "https://api.132999.xyz";

  }

  Widget deleteImageAlert(int index) {
    return AlertDialog(
      title: const Text("是否删除该图片？"),
      content: Row(
        children: [
          TextButton(
              onPressed: () {
                setState(() {
                  _imagePaths.removeAt(index);
                });
                Navigator.of(context).pop();
              },

              child: Text("确定")),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("取消"))
        ],
      ),
    );
  }

  Future<void> obtainImage(ImageSource source) async {
    if (source == ImageSource.gallery) {
      final files = await _imagePicker.pickMultiImage(imageQuality: 100, maxHeight: 1000, maxWidth: 1000);

      if (files.length + _imagePaths.length <= 9) {
        setState(() {
          files.forEach((element) {
            _imagePaths.add(element.path);

          });
        });
      } else {
        print("选择图片过多！最大图片数量为9张！");
      }
    } else {
      if (_imagePaths.length <= 8) {
        final file = await _imagePicker.pickImage(source: source);
        setState(() {
          _imagePaths.add(file!.path);
        });
      } else {
        print("选择图片过多！最大图片数量为9张！");

      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_recognizer is MyTextRecognizer) {
      (_recognizer as MyTextRecognizer).dispose();
    }
  }

  Widget buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: _imagePaths.length+1,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0
      ),
      itemBuilder: (context, index) {
        if (_imagePaths.length <= 8) {
          if (index < _imagePaths.length) {
            return GestureDetector(
              child: Image.file(File(_imagePaths[index]), fit: BoxFit.cover),
              onLongPress: () {
                showDialog(context: context, builder: (context) => deleteImageAlert(index));
              },
            );
          } else {
            // print(index);
            return GestureDetector(
              child: Text("加号"),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => imagePickAlert(onCameraPressed: () async {
                        await obtainImage(ImageSource.camera);
                        Navigator.of(context).pop();

                      }, onGalleryPressed: () async {
                        await obtainImage(ImageSource.gallery);
                        Navigator.of(context).pop();

                      }
                    )
                );
              },
            );
          }
        } else {
          if(index<9){
            return GestureDetector(
              child: Image.file(File(_imagePaths[index]), fit: BoxFit.cover),
              onLongPress: () {
                //long press to delete functions
                showDialog(context: context, builder: (context) => deleteImageAlert(index));
              },
            );
          }
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Text Recognition'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => imagePickAlert(onCameraPressed: () async {
                      await obtainImage(ImageSource.camera);
                      Navigator.of(context).pop();

                    }, onGalleryPressed: () async {
                      await obtainImage(ImageSource.gallery);
                      Navigator.of(context).pop();

                    }
                )
            );
          },
          child: const Icon(Icons.add),
        ),
        body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  // Container(
                  //   child: Text("Result: " + _result),
                  // ),
                  buildImageGrid(),
                  TextButton(
                      onPressed: () async{
                        if(_imagePaths.length==0){
                          return;
                        }
                        setState(() {
                          _result = "";
                          _isLoading = 1;
                        });
                        String _tempResult = "";
                        print("scan completed");

                        for(int i=0;i<_imagePaths.length;i++){
                          final _singleResult = await _recognizer.processImage(_imagePaths.elementAt(i));
                          _tempResult += _singleResult;
                        }

                        OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
                            model: "gpt-4",
                            messages: [
                              OpenAIChatCompletionChoiceMessageModel(
                                  role: OpenAIChatMessageRole.user,
                                  content: "Hello! The following disordered text: "+_tempResult+" is the OCR result of the package of a medicine. Please summarize based on the OCR result the basic information of a medicine in the format of {\"name\":\${name}, \"timesPerDay\":\${timesPerDay}, \"numberOfMedicineEntityPerTime\":\${numberOfMedicineEntityPerTime}, \"typeOfMedicineEntity\":\${typeOfMedicineEntity}, \"taboos\":\${taboos}}, do not include any other words in your response. "
                                      "The field \"typeOfMedicine\" refers to how the medicine "
                                      "If you think the OCR result is not from the container of a medicine, please directly rely \"ERROR\" in your response and DO NOT INCLUDE ANY OTHER WORDS IN YOUR RESPONSE. Please follow these rules strictly."
                                      "If there are multiple taboos, write them in one string instead of a json list."
                                      "Please translate the information in each field to chinese, but do not alter the structure of the response."
                                      "Please only give number in the field \"timesPerDay\" and \"numberOfMedicineEntityPerTime\"."
                                      "For the field \"typeOfMedicineEntity\", please only use minimal description, for example, \"tablet\", \"pill\", etc. Do not add modifier word any before this description.")
                            ]
                        );
                        String response = chatCompletion.choices.first.message.content;
                        print("gpt4 result generated!");
                        setState(() {
                          _isLoading = 0;
                        });
                        if(response == "ERROR"){
                          setState(() {
                            _result = "未识别到药品包装信息，请正确拍摄药品包装并重试。";
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("扫描失败"),
                                  content: Text("未识别到药品包装信息，请正确拍摄药品包装并重试。"),
                                  actions: [
                                    TextButton(
                                      onPressed: (){
                                        if (Navigator.canPop(context)) {
                                          Navigator.pop(context);
                                        } else {
                                          SystemNavigator.pop();
                                        }
                                      },
                                      child: Text("确定")
                                    )
                                  ],
                                )
                            );
                          });
                        }else{
                          setState(()  {
                            // _result = response;
                            response = response.replaceAll("\n", "");
                            print(response[response.length-1]);
                            print(response[response.length-2]);
                            if(response[response.length-1]!="}" && response[response.length-2]!="\""){
                              response += "\"}";
                            }
                            bus.fire(OCREvent("OCR_finished;"+response));

                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              SystemNavigator.pop();
                            }
                          });
                        }
                      },
                      child: Text("开始扫描")
                  ),

                  _isLoading==1
                  ? Container(
                      child:SpinKitFoldingCube(
                        color: Colors.blueAccent,
                      ),
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                    )
                  : Text(""),
                  _isLoading==1?Text("加载中..."):Text("")
                ],
              ),
            )
        )
    );
  }
}
