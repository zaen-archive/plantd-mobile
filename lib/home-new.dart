import 'dart:io';

import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_d/about.dart';
import 'package:plant_d/advice.dart';
import 'package:plant_d/camera-crop.dart';
import 'package:plant_d/disease-detail.dart';
import 'package:plant_d/helper.dart';
import 'package:plant_d/scoped.dart';
import 'package:scoped_model/scoped_model.dart';


class HomeNewPage extends StatefulWidget {
  @override
  _HomeNewPageState createState() => _HomeNewPageState();
}

class _HomeNewPageState extends State<HomeNewPage> with TickerProviderStateMixin {
  TabController _tabController;
  List<dynamic> _plants = [];
  List<dynamic> _diseases = [];
  
  // TODO: Change it as fast as possible
  // For Testing Only Variable
  var _isTomato = true;


  final List<Tab> _tabs = <Tab>[
    Tab(text: "Deteksi"),
    Tab(text: "Riwayat"),
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: _tabs.length);
    final model = ScopedModel.of<Scoped>(context);
    model.getPlants()
    .then((val) async{
      _plants = val['data'];
      setState(() { });
      model.getDiseases(_plants[0]['_id'])
      .then((val) {
        setState(() {
        _diseases = val['data']; 
        });
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
        centerTitle: true,
        title: Text('Plant-D'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (val) {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  if (val == 'advice') {
                    return AdvicePage();
                  } else {
                    return AboutPage();
                  }
                }
              ));
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text('Saran'),
                  value: 'advice',
                ),
                PopupMenuItem(
                  child: Text('Tentang'),
                  value: 'about',
                ),
              ];
            },
            child: Padding(
              padding: EdgeInsets.only(
                right: 16
              ),
              child: Icon(Icons.more_vert),
            ),
          )
        ],
        bottom: TabBar(
          isScrollable: true,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: TextStyle(
            fontSize: 16
          ),
          indicator: BubbleTabIndicator(
            indicatorRadius: 12,
            indicatorHeight: 25.0,
            indicatorColor: Colors.green[400],
            tabBarIndicatorSize: TabBarIndicatorSize.tab,
          ),
          tabs: _tabs,
          controller: _tabController,
        )
      ),
      body: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              _HeadLine(
                plants: _plants,
                onChanged: (id) {
                  _isTomato = '5dd6c573aa3cd5187425eedf' == id;
                  final model = ScopedModel.of<Scoped>(context);
                  model.getDiseases(id)
                  .then((val) {
                    setState(() {
                    _diseases = val['data']; 
                    });
                  });
                },
              ),
              Container(
                margin: EdgeInsets.only(
                  right: 32,
                  left: 32,
                  top: 8,
                  bottom: 16
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 8
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(4)
                ),
                child: Text('Penyakit yang dapat di deteksi', textAlign: TextAlign.center),
              ),
              _Content(
                diseases: _diseases,
                isTomato: _isTomato,
              )
            ],
          ),
          _History()
        ],
      ),
      floatingActionButton: SpeedDial(
          // both default to 16
          marginRight: 24,
          marginBottom: 36,
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


// Content
class _Content extends StatelessWidget {
  final List diseases;
  final bool isTomato;

  const _Content({Key key, this.diseases, this.isTomato}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: diseases.length,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: 12,
      ),
      separatorBuilder: (context, i) {
        return Divider(
          indent: 96,
          height: 1,
        );
      },
      itemBuilder: (context, i) {
        final item = diseases[i];

        return ListTile(
          onTap: () async {

            if (!isTomato) {
              return showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Failed'),
                    content: Text('Data belum di support secara penuh.'),
                    actions: <Widget>[
                      FlatButton(
                        color: Colors.blue,
                        child: Text('Close', style: TextStyle(color: Colors.white)),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  );
                }
              );
            }

            final model = ScopedModel.of<Scoped>(context);
            var data = await model.getDisease(item['_id']);

            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return DiseaseDetail(
                  item: data,
                );
              }
            ));
          },
          title: Text(item['disease']),
          subtitle: Text(item['cause_type'] ?? '-'),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(getImageUrl(item['imgUrl'])),
            radius: 28,
          ),
        );
      },
    );
  }
}


// HeadLine
class _HeadLine extends StatelessWidget {
  final List plants;
  final ValueChanged<String> onChanged;

  const _HeadLine({Key key, this.plants, this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (plants.length == 0) {
      return Container(
        height: 300,
      );
    }
    return Container(
      height: 300,
      child: Swiper(
        scrollDirection: Axis.horizontal,
        itemCount: plants.length,
        containerHeight: 250,
        containerWidth: 250,
        viewportFraction: .6,
        scale: .8,
        loop: true,
        onIndexChanged: (index) {
          final item = plants[index];
          onChanged(item['_id']);
        },
        pagination: SwiperCustomPagination(
          builder: (context, plugin) {
            final count = plugin.itemCount;
            
            List<Widget> rows = [];

            for (var i = 0; i < count; i++) {
              final flip = i == plugin.activeIndex;

              rows.add(Container(
                height: 12,
                width: 12,
                margin: EdgeInsets.symmetric(
                  horizontal: 4
                ),
                decoration: BoxDecoration(
                  color: flip ? Theme.of(context).primaryColor : null,
                  border: flip ? null : Border.all(color: Colors.black54),
                  shape: BoxShape.circle
                ),
              ));
            }

            return Positioned(
              bottom: 16,
              right: 0,
              left: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: rows,
              ),
            );
          }
        ),
        itemBuilder: (context, i) {
          final item = plants[i];
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                  getImageUrl(item['imgUrl'])
                )
              )
            ),
          );
        },
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
                    assetImg: imgPath,
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
