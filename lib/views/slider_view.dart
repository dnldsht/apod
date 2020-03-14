import 'package:apod/views/pic_view.dart';
import 'package:flutter/material.dart';

class SliderView extends StatefulWidget {
  @override
  _SliderViewState createState() => _SliderViewState();
}

class _SliderViewState extends State<SliderView> {
  PageController controller = PageController();

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    return Scaffold(
      body: PageView.builder(
          controller: controller,
          itemCount: 365,
          itemBuilder: (c, i) => PicView(now.subtract(Duration(days: i)),
              imageNotAvailable: () async => await Future.delayed(
                  Duration(milliseconds: 0), () => goPrev(c)))),
    );
  }

  goPrev(c) {
    Scaffold.of(c).showSnackBar(SnackBar(
      content: Text("Todays image is not available yet."),
      behavior: SnackBarBehavior.floating,
    ));
    controller.animateToPage(controller.page.toInt() + 1,
        duration: Duration(milliseconds: 400), curve: Curves.easeIn);
  }
}
