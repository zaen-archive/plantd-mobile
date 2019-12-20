import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plant_d/helper.dart';


class DiseaseDetail extends StatefulWidget {
  final Map item;
  final String assetImg;

  const DiseaseDetail({Key key, this.item, this.assetImg}) : super(key: key);

  @override
  _DiseaseDetailState createState() => _DiseaseDetailState();
}

class _DiseaseDetailState extends State<DiseaseDetail> {


  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final features = item['features'];
    final featureCount = features != null ? features.length : 0;
    final prevents = item['prevents'];
    final preventCount = prevents != null ? prevents.length : 0;
    
    Widget img;

    if (widget.assetImg != null) {
      img = Image.asset(widget.assetImg, fit: BoxFit.cover);
    } else {
      img = CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl: getImageUrl(item['imgUrl']),
      );
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          ListView(
            padding: EdgeInsets.only(
              bottom: 16
            ),
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  bottom: 16
                ),
                child: AspectRatio(
                  aspectRatio: 1.2,
                  child: img,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4
                ),
                child: Text(item['disease'], style: TextStyle(
                  color: Colors.black45,
                  fontSize: 24
                )),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 8,
                  bottom: 16
                ),
                child: Text(item['cause_type'] ?? '-', style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16
                )),
              ),
              _Subheader(
                label: 'Penyebab',
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: Text(item['cause_explanation'] ?? '-', style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54
                )),
              ),
              _Subheader(
                label: 'Penjelasan',
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: Text(item['explanation'] ?? '-', style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54
                )),
              ),
              _Subheader(
                label: 'Ciri-ciri',
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: featureCount,
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                itemBuilder: (context, i) {
                  final feature = features[i];

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 4
                    ),
                    child: Text('${i + 1}. $feature', style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54
                    )),
                  );
                },
              ),
              _Subheader(
                label: 'Perawatan',
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: Text(item['treat_organic'] ?? '-', style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54
                )),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: Text(item['treat_nonorganic'] ?? '-', style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54
                )),
              ),
              _Subheader(
                label: 'Pencegahan',
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: preventCount,
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                itemBuilder: (context, i) {
                  final prevent = prevents[i];

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 4
                    ),
                    child: Text('${i + 1}. $prevent', style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54
                    )),
                  );
                },
              ),
            ],
          ),
          Positioned(
            top: 32,
            left: 0,
            child: IconButton(
              onPressed: () { Navigator.pop(context); },
              iconSize: 36,
              icon: Icon(CupertinoIcons.back),
              color: Colors.black54,
            ),
          )
        ],
      )
    );
  }
}


class _Subheader extends StatelessWidget {
  final String label;

  const _Subheader({Key key, this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 8,
        bottom: 12,
        top: 24
      ),
      child: Text(label, style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600
      )),
    );
  }
}
