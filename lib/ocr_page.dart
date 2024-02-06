import 'dart:async';
import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localization/localization.dart';

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

class MyTextRecognizer {
  late TextRecognizer recognizer;

  MyTextRecognizer(this.script) {
    recognizer = TextRecognizer(script: script);
  }
  late TextRecognitionScript script;

  void dispose() {
    recognizer.close();
  }

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
    title: Text(
      "please_select_image".i18n(),
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.camera_alt),
          title:  Text(
            "camera".i18n(),
          ),
          onTap: onCameraPressed,
        ),
        ListTile(
          leading: const Icon(Icons.image),
          title:  Text(
            "gallery".i18n(),
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
  TextRecognitionScript _script = TextRecognitionScript.chinese;
  // List<TextRecognitionScript> _scriptOptions = [TextRecognitionScript.chinese,TextRecognitionScript.latin];

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
    _recognizer = MyTextRecognizer(_script);
  }

  Widget deleteImageAlert(int index) {
    return AlertDialog(
      title: Text("ask_delete_image".i18n()),
      content: Row(
        children: [
          TextButton(
              onPressed: () {
                setState(() {
                  _imagePaths.removeAt(index);
                });
                Navigator.of(context).pop();
              },

              child: Text("confirm".i18n())),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("cancel".i18n()))
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
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(
          content: Text("too_many_images".i18n()),
        ));
      }
    } else {
      if (_imagePaths.length <= 8) {
        final file = await _imagePicker.pickImage(source: source);
        setState(() {
          _imagePaths.add(file!.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(
          content: Text("too_many_images".i18n()),
        ));
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
              child: Text(""),
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
          title: Text('medicine_ocr'.i18n()),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: ListTile(
                            title: Text("chinese".i18n()),
                            leading: Radio<TextRecognitionScript>(
                              value: TextRecognitionScript.chinese,
                              onChanged: (value){
                                setState(() {
                                  _script = value!;
                                  _recognizer = MyTextRecognizer(_script);
                                });
                              },
                              groupValue: _script,
                            ),
                          ),
                      ),
                      Expanded(
                        child:ListTile(
                          title: Text("english".i18n()),
                          leading: Radio<TextRecognitionScript>(
                            value: TextRecognitionScript.latin,
                            onChanged: (value){
                              setState(() {
                                _script = value!;
                                _recognizer = MyTextRecognizer(_script);
                              });
                            },
                            groupValue: _script,
                          ),
                        )
                      )
                    ],
                  ),
                  buildImageGrid(),
                  TextButton(
                      onPressed: () async{
                        if(_imagePaths.length==0){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("image_not_uploaded".i18n()),
                          ));
                          return;
                        }
                        setState(() {
                          _result = "";
                          _isLoading = 1;
                        });
                        String _tempResult = "";

                        for(int i=0;i<_imagePaths.length;i++){
                          final _singleResult = await _recognizer.processImage(_imagePaths.elementAt(i));
                          _tempResult += _singleResult;
                        }
                        print("scan completed");
                        print(_tempResult);
                        OpenAIChatCompletionModel chatCompletion;

                        if(_script==TextRecognitionScript.chinese){
                          chatCompletion = await OpenAI.instance.chat.create(
                              model: "gpt-4",
                              messages: [
                                OpenAIChatCompletionChoiceMessageModel(
                                    role: OpenAIChatMessageRole.user,
                                    content: [
                                      OpenAIChatCompletionChoiceMessageContentItemModel.text("你好! 以下文本："+_tempResult+" 是药品包装或说明书的OCR结果。 请根据OCR结果将药物的基本信息汇总为{\"name\":\${name}, \"timesPerDay\":\${timesPerDay}, \"numberOfMedicineEntityPerTime\":\${numberOfMedicineEntityPerTime}, \"typeOfMedicineEntity\":\${typeOfMedicineEntity}, \"taboos\":\${taboos}}的格式, 不要在你的回答中包含任何其他词语。"
                                          +"刚刚提到的\"typeOfMedicineEntity\"指的是药品的形式，比如胶囊、片剂、喷雾等等"
                                          +"如果您认为OCR结果并非来自药品包装或关于药品，请直接回复 \"ERROR\" 并且不要在你的回答中包含其他词语，这很重要。请严格遵守此规定。"
                                          +"如果有多个禁忌，请将它们写在一个字符串中，而不是json列表中。"
                                          +"在\"timesPerDay\"和\"numberOfMedicineEntityPerTime\"中，请以数字的方式回答。"
                                          +"对于\"typeOfMedicineEntity\", 请仅使用最少的描述, 例如\"胶囊\", \"片\"等等。 请不要在这里增加任何的修饰词及其他内容。")]
                                )]
                          );
                        }else{
                          chatCompletion = await OpenAI.instance.chat.create(
                              model: "gpt-4",
                              messages: [
                                OpenAIChatCompletionChoiceMessageModel(
                                    role: OpenAIChatMessageRole.user,
                                    content: [
                                      OpenAIChatCompletionChoiceMessageContentItemModel.text("Hello! The following disordered text: "+_tempResult+" is the OCR result of the package of a medicine. Please summarize based on the OCR result the basic information of a medicine in the format of {\"name\":\${name}, \"timesPerDay\":\${timesPerDay}, \"numberOfMedicineEntityPerTime\":\${numberOfMedicineEntityPerTime}, \"typeOfMedicineEntity\":\${typeOfMedicineEntity}, \"taboos\":\${taboos}}, do not include any other words in your response. "
                                          "The field \"typeOfMedicine\" refers to how the medicine "
                                          +"If you think the OCR result is not from the container of a medicine, please directly rely \"ERROR\" in your response and DO NOT INCLUDE ANY OTHER WORDS IN YOUR RESPONSE. Please follow these rules strictly."
                                          +"If there are multiple taboos, write them in one string instead of a json list."
                                          +"Please translate the information in each field to chinese, but do not alter the structure of the response."
                                          +"Please only give number in the field \"timesPerDay\" and \"numberOfMedicineEntityPerTime\"."
                                          +"For the field \"typeOfMedicineEntity\", please only use minimal description, for example, \"tablet\", \"pill\", etc. Do not add modifier word any before this description.")]
                                )]
                          );
                        }


                        String? response = chatCompletion.choices.first.message.content?[0].text;
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
                                  title: Text("scan_failed".i18n()),
                                  content: Text("scan_failed_detail".i18n()),
                                  actions: [
                                    TextButton(
                                      onPressed: (){
                                        if (Navigator.canPop(context)) {
                                          Navigator.pop(context);
                                        } else {
                                          SystemNavigator.pop();
                                        }
                                      },
                                      child: Text("confirm".i18n())
                                    )
                                  ],
                                )
                            );
                          });
                        }else{
                          setState(()  {
                            // _result = response;
                            response = response?.replaceAll("\n", "");
                            response = response?.replaceAll("`", "");
                            print(response?[response!.length-1]);
                            print(response?[response!.length-2]);
                            if(response?[response!.length-1]!="}" && response?[response!.length-2]!="\""){
                              response = (response!+ "\"}")!;
                            }
                            bus.fire(OCREvent("OCR_finished;"+response!));

                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              SystemNavigator.pop();
                            }
                          });
                        }
                      },
                      child: Text("start_scanning".i18n())
                  ),

                  _isLoading==1
                  ? Container(
                      child:SpinKitFoldingCube(
                        color: Colors.blue,
                      ),
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                    )
                  : Text(""),
                  _isLoading==1?Text("loading".i18n()):Text("")
                ],
              ),
            )
        )
    );
  }
}

//finished localization
