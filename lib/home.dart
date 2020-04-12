import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:code_executor/code_edit.dart';
import 'package:code_executor/service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  CameraController cameraController;
  String imagePath;

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void logError(String code, String message) =>
      print('Error: $code\nError Message: $message');

  @override
  void initState() {
    super.initState();
    availableCameras().then((cameras) {
      cameraController = CameraController(cameras[0], ResolutionPreset.high);
      cameraController.initialize().then((_) {
        setState(() {});
      });
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Widget _cameraPreviewWidget =
        (cameraController == null || !cameraController.value.isInitialized)
            ? const Text(
                'Tap a camera',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w900,
                ),
              )
            : AspectRatio(
                aspectRatio: cameraController.value.aspectRatio,
                child: CameraPreview(cameraController),
              );

    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'CODE EXECUTOR',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Container(
                  child: this.imagePath == null
                      ? _cameraPreviewWidget
                      : Card(
                          elevation: 6,
                          child: Image.file(File(imagePath)),
                        ) // Show picture
                  ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(20),
            child: this.imagePath == null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                        color: Colors.blue,
                        onPressed: cameraController != null &&
                                cameraController.value.isInitialized
                            ? onTakePictureButtonPressed
                            : null,
                        child: Text('Take Picture',
                            style: TextStyle(color: Colors.white)),
                      ),
                      RaisedButton(
                        color: Colors.blueGrey,
                        onPressed: getImage,
                        child: Text('Choose Image',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                        color: Colors.blueGrey,
                        onPressed: () async {
                          // catch execpetions here
                          // await File(imagePath).delete();
                          setState(() {
                            this.imagePath = null;
                          });
                        },
                        child: Text('Take New', style: TextStyle(color: Colors.white)),
                      ),
                      RaisedButton(
                        color: Colors.blue,
                        onPressed: () async {
                          httpService
                              .postImageAndExtractCode(imagePath)
                              .then((value) {
                                var lines = value.split("\n").length + 1;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CodeEdit(
                                    maxLines: lines,
                                    code: value,
                                  ))
                                );
                              });
                        },
                        child: Text('Upload', style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
          )
        ],
      ),
    );
  }

  void onTakePictureButtonPressed() {
    takePicture().then((filePath) {
      if (mounted) {
        setState(() {
          this.imagePath = filePath;
        });
      }
      //if (filePath != null) showInSnackBar('Image Taken');
    });
  }

  getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      imagePath = image?.path;
    });
  }

  Future<String> takePicture() async {
    if (!cameraController.value.isInitialized) {
      print('Camera not initialized');
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      await cameraController.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}
