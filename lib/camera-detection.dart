import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plant_d/camera-crop.dart';



class CameraDetection extends StatefulWidget {
  @override
  _CameraDetectionState createState() => _CameraDetectionState();
}

class _CameraDetectionState extends State<CameraDetection> {
  CameraController _controller;
  List<CameraDescription> _cameras;
  int _selectedCamera;

  _onCapturePressed(BuildContext context) async {
    try {
      final folder = await getTemporaryDirectory();
      final filename = '${DateTime.now()}.jpeg';
      final path = join(folder.path, filename);

      await _controller.takePicture(path);

      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return CameraCrop(imagePath: path);
        }
      ));
    } catch (e) {
      print('Error Take Picture');
      print(e);
    }
  }

  Future _initCameraController(CameraDescription camDesc) async {
    if (_controller != null) {
      await _controller.dispose();
    }

    _controller = CameraController(camDesc, ResolutionPreset.high);

    _controller.addListener(() {
      if (mounted) {
        setState(() { });
      }

      if (_controller.value.hasError) {
        print('Camera Error');
        print(_controller.value.errorDescription);
      }
    });

    try {
      await _controller.initialize();
    } on CameraException catch (e) {
      print('exception');
      print(e);
    }

    if (mounted) {
      setState(() { });
    }
  }

  Widget _cameraPreviewWidget() {
    if (_controller == null || !_controller.value.isInitialized) {
      return Center(
        child: Text(
          'Loading',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }
    
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: CameraPreview(_controller),
    );
  }

  @override
  void initState() {
    super.initState();

    availableCameras().then((val) {
      _cameras = val;
      if (_cameras.length > 0) {
        setState(() {
         _selectedCamera = 0;
        });
        _initCameraController(_cameras[_selectedCamera]);
      } else {
        print('No Camera Detected');
      }
    }).catchError((err) {
      print("Error Occured");
      print(err);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        leading: IconButton(
          onPressed: () { Navigator.pop(context); },
          icon: Icon(CupertinoIcons.back, color: Colors.white),
        ),
      ),
      body: Container(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: _cameraPreviewWidget(),
              ),
              Container(
                color: Colors.black87,
                padding: EdgeInsets.only(
                  top: 12,
                  bottom: 12
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Spacer(),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            FloatingActionButton(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              child: Icon(Icons.radio_button_checked,
                                color: Colors.white70,
                                size: 54,
                              ),
                              onPressed: () => _onCapturePressed(context)
                            )
                          ],
                        ),
                      ),
                    ),
                    Spacer()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
