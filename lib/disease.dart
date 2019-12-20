import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plant_d/disease-detail.dart';
import 'package:plant_d/helper.dart';
import 'package:plant_d/scoped.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cached_network_image/cached_network_image.dart';


class Disease extends StatefulWidget {
  final String title;
  final String plantId;

  const Disease({Key key, this.title, this.plantId}) : super(key: key);

  @override
  _DiseaseState createState() => _DiseaseState();
}

class _DiseaseState extends State<Disease> {
  List<dynamic> _diseases = [];

  @override
  void initState() {
    super.initState();

    final model = ScopedModel.of<Scoped>(context);
    model.getDiseases(widget.plantId)
    .then((val) {
      setState(() {
       _diseases = val['data']; 
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = ScopedModel.of<Scoped>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () { Navigator.pop(context); },
          icon: Icon(CupertinoIcons.back),
          color: Colors.black54,
        ),
        title: Text(widget.title)
      ),
      body: ListView.separated(
        itemCount: _diseases.length,
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
          final item = _diseases[i];

          return ListTile(
            onTap: () async {
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
      ),
    );
  }
}
