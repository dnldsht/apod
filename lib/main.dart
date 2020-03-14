import 'package:apod/views/slider_view.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nasa - Pic of the day',
      theme: ThemeData(),
      home: SliderView(),
    );
  }
}
