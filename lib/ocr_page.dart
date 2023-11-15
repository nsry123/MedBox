import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';



class OcrPage extends StatefulWidget {
  const OcrPage({super.key});

  @override
  State<OcrPage> createState() => _OcrState();
}

abstract class ITextRecognizer{
  Future<String> processImage(String imgPath);
}

class MyTextRecognizer extends ITextRecognizer{
  late TextRecognizer recognizer;

  MyTextRecognizer(){
    recognizer = TextRecognizer(script: TextRecognitionScript.chinese);
  }

  void dispose(){
    recognizer.close();
  }

  @override
  Future<String> processImage(String imgPath) async{
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
  late String _imagePath;
  late String _result;

  @override
  void initState(){
    super.initState();
    _imagePicker = ImagePicker();
    _recognizer = MyTextRecognizer();
    _imagePath = "";
    _result = "";
  }

  Future<String?> obtainImage(ImageSource source) async {
    final file = await _imagePicker.pickImage(source: source);
    return file?.path;
  }

  @override
  void dispose() {
    super.dispose();
    if (_recognizer is MyTextRecognizer) {
      (_recognizer as MyTextRecognizer).dispose();
    }
  }

      @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Recognition'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder:(context) => imagePickAlert(
                onCameraPressed: () async{
                  final String? imgPath = await obtainImage(ImageSource.camera);
                  if(imgPath==null) return;
                  setState(() {
                    _imagePath = imgPath!;
                  });
                  _recognizer.processImage(imgPath!).then((value) {
                    setState(() {
                      _result = value;
                    });
                  });
                  Navigator.of(context).pop();

                },
                onGalleryPressed: () async{
                  final imgPath = await obtainImage(ImageSource.gallery);
                  if(imgPath==null) return;
                  setState(() {
                    _imagePath = imgPath!;
                  });
                  _recognizer.processImage(imgPath!).then((value) {
                    setState(() {
                      _result = value;
                    });
                  });
                  Navigator.of(context).pop();
                }
              ));
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Center(
          child:Column(
            children: [
              _imagePath != ""
                  ? Container(
                  child: Image.file(File(_imagePath),width: 200,)
              )
                  : Container(
                child: Text("Please choose an image to continue"),
              ),
              Container(
                child:Text("Result: "+_result),
              )
            ],
          ),
        )
      )
    );
  }
}