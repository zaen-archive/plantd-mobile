import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plant_d/home-new.dart';
import 'package:plant_d/scoped.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<Scoped>(
      model: Scoped(),
      child: MaterialApp(
        title: 'Plant-D',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          appBarTheme: AppBarTheme(
            elevation: 0,
            color: Colors.transparent,
            actionsIconTheme: IconThemeData(
              color: Colors.black,
              opacity: 0.64
            ),
            iconTheme: IconThemeData(
              color: Colors.black,
              opacity: 0.64
            ),
            textTheme: TextTheme(
              title: TextStyle(
                color: Colors.black87,
                fontSize: 22,
              )
            )
          )
        ),
        home: _PermissionPage(),
      ),
    );
  }
}


class _PermissionPage extends StatefulWidget {
  @override
  __PermissionPageState createState() => __PermissionPageState();
}

class __PermissionPageState extends State<_PermissionPage> {
  var _permission = false;
  var _text = '';

  init() async {
    final pers = PermissionHandler();
    final status = await pers.requestPermissions([PermissionGroup.storage]);
    
    if (status[PermissionGroup.storage] == PermissionStatus.granted) {
      return Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          _permission = true;
        });
      });
    }
    _text = 'Application need Storage Permission';
  }

  @override
  void initState() {
    super.initState();
    
    init();
  }

  @override
  Widget build(BuildContext context) {
    if (!_permission) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/icon/splash.png', fit: BoxFit.fitWidth),
            Padding(
              padding: EdgeInsets.only(
                top: 16
              ),
              child: Text(_text, style: TextStyle(
                color: Colors.black54,
                fontSize: 18
              ), textAlign: TextAlign.center),
            )
          ],
        )
      );
    }
    // return HomeScreen();
    return HomeNewPage();
  }
}
