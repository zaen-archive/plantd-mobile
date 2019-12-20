import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_d/camera-crop.dart';
import 'package:plant_d/disease-detail.dart';
import 'package:plant_d/disease.dart';
import 'package:plant_d/helper.dart';
import 'package:plant_d/scoped.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<dynamic> _plants = [];

  final List<Tab> _tabs = <Tab>[
    Tab(text: "Penyakit"),
    Tab(text: "Riwayat"),
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: _tabs.length);
    final scoped = ScopedModel.of<Scoped>(context);
    scoped.getPlants()
    .then((val) {
      setState(() {
        _plants = val['data']; 
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        title: Text('Plant-D', style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w300,
          fontSize: 26
        )),
        bottom: TabBar(
          isScrollable: true,
          labelStyle: TextStyle(
            fontSize: 16
          ),
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BubbleTabIndicator(
            indicatorRadius: 12,
            indicatorHeight: 25.0,
            indicatorColor: Colors.green[400],
            tabBarIndicatorSize: TabBarIndicatorSize.tab,
          ),
          tabs: _tabs,
          controller: _tabController,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _Plant(
              plants: _plants,
            ),
            _History()
          ]
        ),
      ),
      floatingActionButton: SpeedDial(
          // both default to 16
          marginRight: 18,
          marginBottom: 20,
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: IconThemeData(size: 22.0),
          visible: true,
          closeManually: false,
          curve: Curves.bounceIn,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          tooltip: 'Speed Dial',
          heroTag: 'speed-dial-hero-tag',
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 8.0,
          shape: CircleBorder(),
          children: [
            SpeedDialChild(
              child: Icon(Icons.camera),
              backgroundColor: Colors.blue,
              label: 'Detect using Camera',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () async {
                final image = await ImagePicker.pickImage(source: ImageSource.camera);
                if (image == null) return;
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return CameraCrop(
                      image: image,
                    );
                  }
                ));
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.photo_library),
              backgroundColor: Colors.amber,
              label: 'Detect from Gallery',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () async {
                final image = await ImagePicker.pickImage(source: ImageSource.gallery);
                if (image == null) return;
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return CameraCrop(
                      image: image,
                    );
                  }
                ));
              },
            ),
          ],
        ),
    );
  }
}


/////////////////////// DISEASES ////////////////////
class _Plant extends StatelessWidget {
  final List<dynamic> plants;

  const _Plant({Key key, this.plants}) : super(key: key);

  onTapDisease(BuildContext context, dynamic item) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return Disease(
          plantId: item['_id'],
          title: item['name'],
        );
      }
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: plants.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16
      ),
      itemBuilder: (context, i) {
        final item = plants[i];

        return _Item(
          label: item['name'],
          diseaseCount: item['diseases_count'],
          imgUrl: item['imgUrl'],
          onTap: () => onTapDisease(context, item),
        );
      },
    );
  }
}

class _Item extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final String imgUrl;
  final int diseaseCount;

  const _Item({Key key, this.onTap, this.label, this.diseaseCount, this.imgUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                top: 8,
                bottom: 8
              ),
              alignment: Alignment.topCenter,
              child: CircleAvatar(
                radius: 36,
                backgroundColor: Color(0x190AC4BA),
                child: CachedNetworkImage(
                  imageUrl: getImageUrl(imgUrl),
                  height: 54,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: 3
              ),
              child: Text(label, style: TextStyle(
                fontSize: 15
              )),
            ),
            Text('$diseaseCount Penyakit', style: TextStyle(
              color: Colors.black38,
              fontSize: 12
            ))
          ],
        ),
      ),
    );
  }
}


//////////////////// HISTORY ////////////////////////
class _History extends StatefulWidget {
  @override
  __HistoryState createState() => __HistoryState();
}

class __HistoryState extends State<_History> {
  var _items = [];

  init() async {
    final model = ScopedModel.of<Scoped>(context);
    _items = await model.getHistory();
    setState(() { });
  }

  @override
  void initState() {
    super.initState();

    init();
  }

  @override
  Widget build(BuildContext context) {
    final model = ScopedModel.of<Scoped>(context);

    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 18
      ),
      child: ListView.separated(
        itemCount: _items.length,
        padding: EdgeInsets.symmetric(
          horizontal: 8,
        ),
        separatorBuilder: (context, i) {
          return Divider(
            indent: 96,
            height: 1,
          );
        },
        itemBuilder: (context, i) {
          final item = _items[i];
          final diseaseName = item['disease_name'];
          final causeType = item['cause_type'];
          final imgPath = item['img_path'];

          return ListTile(
            onTap: () async {
              final uuid = item['disease_uuid'];
              final result = await model.getDisease(uuid);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return DiseaseDetail(
                    item: result,
                  );
                }
              ));
            },
            title: Text(diseaseName),
            subtitle: Text(causeType),
            leading: Padding(
              padding: EdgeInsets.only(
                right: 8
              ),
              child: CircleAvatar(
                backgroundImage: FileImage(File(imgPath)),
                radius: 28,
              ),
            ),
          );
        },
      ),
    );
  }
}
