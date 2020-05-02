import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';

import '../main.dart';
class NumPadKeyboard extends StatelessWidget {
  var clearKeyBackgroundColor, backKeyBackgroundColor, keyColor, keyFontColor;
  var backKeyFontColor, clearKeyFontColor;
  final int pinInputLength;
  final TextEditingController pinInputController;

  var _darkTheme = false;

  NumPadKeyboard({
    this.pinInputLength = 5,
    this.clearKeyBackgroundColor,
    this.backKeyBackgroundColor = Colors.black38,
    this.keyColor = Colors.black26,
    this.keyFontColor = Colors.white,
    this.backKeyFontColor = Colors.white,
    this.clearKeyFontColor = Colors.white,
    @required this.pinInputController,
  });

  @override
  Widget build(BuildContext context) {

    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              NumPadKey(
                digit: '1',
                keyBackgrounColor: keyColor,
                keyContentColor: keyFontColor,
                onPressed: () {
                    pinInputController.text += '1';
                },
              ),
              NumPadKey(
                digit: '2',
                keyBackgrounColor: keyColor,
                keyContentColor: keyFontColor,
                onPressed: () {
                    pinInputController.text += '2';
                },
              ),
              NumPadKey(
                digit: '3',
                keyBackgrounColor: keyColor,
                keyContentColor: keyFontColor,
                onPressed: () {
                    pinInputController.text += '3';
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              NumPadKey(
                digit: '4',
                keyBackgrounColor: keyColor,
                keyContentColor: keyFontColor,
                onPressed: () {
                    pinInputController.text += '4';
                },
              ),
              NumPadKey(
                digit: '5',
                keyBackgrounColor: keyColor,
                keyContentColor: keyFontColor,
                onPressed: () {
                    pinInputController.text += '5';
                },
              ),
              NumPadKey(
                digit: '6',
                keyBackgrounColor: keyColor,
                keyContentColor: keyFontColor,
                onPressed: () {
                    pinInputController.text += '6';
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              NumPadKey(
                digit: '7',
                keyBackgrounColor: keyColor,
                keyContentColor: keyFontColor,
                onPressed: () {
                    pinInputController.text += '7';
                },
              ),
              NumPadKey(
                digit: '8',
                keyBackgrounColor: keyColor,
                keyContentColor: keyFontColor,
                onPressed: () {
                    pinInputController.text += '8';
                },
              ),
              NumPadKey(
                digit: '9',
                keyBackgrounColor: keyColor,
                keyContentColor: keyFontColor,
                onPressed: () {
                    pinInputController.text += '9';
                    print(pinInputController.text);
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              NumPadKey(
                  digit: '',
                  keyBackgrounColor: backKeyBackgroundColor,
                  onPressed: () {
                    return;
                  }),
              NumPadKey(
                digit: '0',
                keyBackgrounColor: keyColor,
                keyContentColor: keyFontColor,
                onPressed: () {
                  if (pinInputController.text.length > 0)
                    pinInputController.text += '0';
                },
              ),
              NumPadKey(
                  digit: Icon(
                    Icons.backspace,
                    size: 20,
                  ),
                  keyBackgrounColor: backKeyBackgroundColor,
                  onPressed: () {
                    String text = pinInputController.text;
                    int length = text.length;
                    if(length > 0) {
                      pinInputController.text = text.substring(0, length - 1);
                    } else {
                      return;
                    }
                  },
                  onLongPressed: () {
                    if(pinInputController.text.length > 0) {
                      pinInputController.clear();
                    } else {
                      return;
                    }
                  },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class NumPadKeyContent extends StatelessWidget {
  var content, color;

  NumPadKeyContent({this.content, this.color});

  @override
  Widget build(BuildContext context) {
    if (content is String) {
      return Center(
        child: Text(
          content,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.normal),
        ),
      );
    } else if (content is Icon) {
      return Center(
        child: content,
      );
    }
    return null;
  }
}

class NumPadKey extends StatelessWidget {
  var digit;
  var keyBackgrounColor, keyContentColor;
  final Function onPressed;
  final Function onLongPressed;

  NumPadKey(
      {this.digit,
      this.keyBackgrounColor,
      this.keyContentColor,
      this.onPressed,
      this.onLongPressed});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 1080, height: 2248);
    double margin = 15.0;

    return Container(
        margin: EdgeInsets.fromLTRB(margin - 3, 1, margin, 0),
        height: (ScreenUtil().setHeight(420))/2.5,
        width: (ScreenUtil().setWidth(420))/1.75,
        child: Material(
            color: Colors.transparent,
            child: InkWell(
              child: NumPadKeyContent(content: digit),
              /* Append new digit to current text string. */
              onTap: onPressed,
              onLongPress: onLongPressed,
            )));
  }
}
