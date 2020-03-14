import 'dart:async';
import 'dart:io';

import 'package:apod/models/download_progress.dart';
import 'package:apod/models/pic.dart';
import 'package:apod/services/constants.dart';
import 'package:apod/services/storage.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class Api {
  Dio _http = Dio();

  Future<Pic> getPic([DateTime date]) async {
    date ??= DateTime.now();
    var dateKey = DateFormat('yyyy-MM-dd').format(date);
    var cacheKey = "pic_$dateKey";

    var cache = await Storage.getMap(cacheKey, defaultValue: null);

    if (cache == null) {
      var params = {'api_key': API_KEY, 'date': dateKey};

      var res = await _http.get('https://api.nasa.gov/planetary/apod',
          queryParameters: params);
      cache = res.data;
      await Storage.setMap(cacheKey, cache);
    }

    return Pic.fromJson(cache);
  }

  Future<String> _getFilePath(String url) async {
    Directory ext = await getExternalStorageDirectory();
    String name = url.split('/').last;
    return "${ext.path}/$name";
  }

  Stream<dynamic> getFileAsStream(Pic p) async* {
    StreamController controller = StreamController();

    var url = p.hdUrl ?? p.url;

    String fileLocalPath = await _getFilePath(url);

    File f = File(fileLocalPath);

    if (!await f.exists()) {
      String tmpPath = "$fileLocalPath.tmp";
      _http
          .download(url, tmpPath, onReceiveProgress: (r, t) {
            controller.add(DownloadProgress(r, t));
          })
          .then((v) async {
            await File(tmpPath).rename(fileLocalPath);
            controller.add(f);
          })
          .catchError((e) => controller.addError(e))
          .whenComplete(() => controller.close());
    } else {
      controller.add(f);
    }

    yield* controller.stream;
  }

  Future<File> getFile(Pic p, {Function(int, int) onProgress}) async {
    var url = p.hdUrl ?? p.url;

    String fileLocalPath = await _getFilePath(url);

    File f = File(fileLocalPath);

    if (!await f.exists()) {
      String tmpPath = "$fileLocalPath.tmp";
      await _http.download(url, tmpPath);
      await File(tmpPath).rename(fileLocalPath);
    }

    return f;
  }
}

Api api = Api();
