import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';

class TypewriterText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Duration duration, delay;
  TypewriterText(this.text, {this.style, this.duration, this.delay});

  @override
  Widget build(BuildContext context) {
    return ControlledAnimation(
        duration: duration ?? Duration(milliseconds: 0),
        delay: delay ?? Duration(milliseconds: 0),
        tween: IntTween(begin: 0, end: text.length),
        builder: (context, textLength) {
          return RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: style,
                  text: text.substring(0, textLength),
                  children: [
                    // if (textLength < text.length &&
                    //     textLength != 0 &&
                    //     textLength % 2 == 0)
                    //   TextSpan(text: '_')
                  ]));
        });
  }
}
