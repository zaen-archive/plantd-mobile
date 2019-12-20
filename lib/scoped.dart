import 'dart:io';

import 'package:image/image.dart' as imgs;
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:path/path.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart' show Uuid;
import 'package:sqflite/sqflite.dart';
import 'package:plant_d/helper.dart' as helper;


class Scoped extends Model {
  final _dio = Dio(BaseOptions(
    baseUrl: helper.baseUrl,
    connectTimeout: 15000,
    receiveTimeout: 15000,
    sendTimeout: 15000,
  ));
  final _uuid = Uuid();
  
  var _dbPath = '';
  var _imgPath = '';
  Database _db;

  Scoped() {
    getExternalStorageDirectory()
    .then((val) async {
      _dbPath = val.path + '/db';
      _imgPath = val.path + '/pictures';

      final db = await openDatabase(_dbPath, version: 1, onCreate: _onCreateDb, singleInstance: true);
      _db = db;
    });
  }

  _onCreateDb(Database db, int version) {
    db.execute('''
    create table history(
      id integer primary key,
      img_path text,
      disease_uuid text,
      disease_name text,
      cause_type text
    )
    ''');
  }

  // Get Plants Data
  Future<Map<String, dynamic>> getPlants() async{
    final resp = await _dio.get('/plants');
    return resp.data;
  }

  // Get Diseases Data
  Future<Map<String, dynamic>> getDiseases(String plantId) async{
    final res = await _dio.get('/diseases', queryParameters: {
      'plantid': plantId
    });
    return res.data;
  }

  Future<Map> getDisease(String id) async {
    final res = await _dio.get('/disease', queryParameters: {
      'id': id
    });
    return res.data;
  }

  // Detect Disease
  Future<Map> detectDisease(File file) async {
    try {
      final img = imgs.decodeImage(file.readAsBytesSync());
      final imgResize = imgs.copyResize(img, height: 256, width: 256);
      final imgBytes = imgs.encodeJpg(imgResize);
      final filename = _uuid.v4() + '.jpg'; 
      
      // Upload File
      final formData = FormData();
      final photo = MultipartFile.fromBytes(imgBytes, filename: filename);
      formData.files.add(MapEntry('file', photo));
      final result = await _dio.post('/detect', data: formData);

      // Save Image
      final path = join(_imgPath, filename);
      await File(path).writeAsBytes(imgBytes);

      return {
        'img_path': path,
        ...result.data
      };
    } catch (e) {
      print('Erro Ocurred');
      print(e);
      return null;
    }
  }

  // Save Detection
  Future<int> saveDetection(dynamic detection) async {
    if (detection == null) return 0;
    final imgPath = detection['img_path'];
    final diseaseUuid = detection['_id'];
    final diseaseName = detection['disease'];
    final causeType = detection['cause_type'] ?? '-';

    return _db.rawInsert('''
    insert into history(disease_uuid, disease_name, img_path, cause_type)
    values (?, ?, ?, ?)
    ''', [ diseaseUuid, diseaseName, imgPath, causeType ]);
  }

  // Get Diseases History
  Future<List<Map>> getHistory() async{
    return _db.rawQuery('''
    select * from history
    ''');
  }
}
