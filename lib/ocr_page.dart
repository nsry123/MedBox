import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OcrPage extends StatefulWidget {
  const OcrPage({super.key});

  @override
  State<OcrPage> createState() => _OcrState();
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

  List<String> _imagePaths = [];
  String _result = "";

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
    _recognizer = MyTextRecognizer();
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
              child: Text("123123"),
              onTap: () {
                  //tap to add images
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
                      // _result = "";
                      await obtainImage(ImageSource.camera);
                      // for (String element in _imagePaths) {
                      //   _recognizer.processImage(element).then((value) {
                      //     setState(() {
                      //       _result += value;
                      //     });
                      //   });
                      // }
                      Navigator.of(context).pop();
                    }, onGalleryPressed: () async {
                      // _result = "";

                      await obtainImage(ImageSource.gallery);
                      // for (String element in _imagePaths) {
                      //   _recognizer.processImage(element).then((value) {
                      //     setState(() {
                      //       _result += value;
                      //     });
                      //   });
                      // }
                      Navigator.of(context).pop();
                    }));
          },
          child: const Icon(Icons.add),
        ),
        body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Container(
                    child: Text("Result: " + _result),
                  ),
                  buildImageGrid(),
                  TextButton(
                      onPressed: () async{
                        if(_imagePaths.length==0){
                          return;
                        }
                        String _tempResult = "";

                        for(int i=0;i<_imagePaths.length;i++){
                          final _singleResult = await _recognizer.processImage(_imagePaths.elementAt(i));
                          _tempResult += _singleResult;
                        }
                        setState(() {
                          _result = _tempResult;
                        });
                        print("scan completed");
                      },
                      child: Text("Scan the uploaded images")
                  )
                ],
              ),
            )
        )
    );
  }
}
