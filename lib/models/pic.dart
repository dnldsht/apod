import 'package:intl/intl.dart';

class Pic {
  String copyright, explanation, hdUrl, url, title, type;

  DateTime date;
  Pic.fromJson(Map<String, dynamic> json) {
    copyright = json['copyright'];
    date = DateFormat('yyyy-MM-dd').parse(json['date']);
    explanation = json['explanation'];
    url = json['url'];
    hdUrl = json['hdurl'];
    title = json['title'];
    type = json['media_type'];
  }

  bool isImage() {
    return type == 'image';
  }

  getNasaArchiveUrl() {
    var key = DateFormat('yyMMdd').format(date);
    return "https://apod.nasa.gov/apod/ap$key.html";
  }
}
