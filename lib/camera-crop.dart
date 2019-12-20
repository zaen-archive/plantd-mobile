import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:plant_d/disease-detail.dart';
import 'package:plant_d/scoped.dart';
import 'package:scoped_model/scoped_model.dart';


class CameraCrop extends StatefulWidget {
  final String imagePath;
  final File image;

  const CameraCrop({Key key, this.imagePath, this.image}) : super(key: key);

  @override
  _CameraCropState createState() => _CameraCropState();
}

class _CameraCropState extends State<CameraCrop> {
  final _cropKey = GlobalKey<CropState>();
  File _originalImg;

  _onUpload() async {
    final crop = _cropKey.currentState;
    final sample = await ImageCrop.sampleImage(
      file: _originalImg,
      preferredHeight: (1280 / crop.scale).round(),
      preferredWidth: (1280 / crop.scale).round()
    );
    final cropped = await ImageCrop.cropImage(
      file: sample,
      area: crop.area,
    );

    final model = ScopedModel.of<Scoped>(context);
    final detection = await model.detectDisease(cropped);
    await model.saveDetection(detection);
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) {
        return DiseaseDetail(
          item: detection,
        );
      }
    ));
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      if (widget.image != null) _originalImg = widget.image;
      else _originalImg = File(widget.imagePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_originalImg == null) {
      return Scaffold(
        body: Center(
          child: Text('Load Image'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        leading: IconButton(
          onPressed: () { Navigator.pop(context); },
          icon: Icon(CupertinoIcons.back, color: Colors.white),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Crop(
              key: _cropKey,
              aspectRatio: 1,
              alwaysShowGrid: true,
              image: FileImage(_originalImg),
            ),
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
                          child: Icon(Icons.cloud_upload,
                            color: Colors.white70,
                            size: 54,
                          ),
                          onPressed: _onUpload
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
    );
  }
}
