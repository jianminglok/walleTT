import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';

import 'package:provider/provider.dart';
import 'dart:math';
import 'package:vector_math/vector_math_64.dart' as vector_math;
import 'package:flutter/services.dart';

import './pin_input_field.dart';
import './numpad_keyboard.dart';
import './numpad_controller.dart';

/* Numpad widget */
class NumPad extends StatefulWidget {
  /* Constructor Parameters. */
  final TextEditingController controller;

  NumPad({
    @required this.controller,
  });

  @override
  _NumPadState createState() => _NumPadState();
}

class _NumPadState extends State<NumPad> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;
  TextEditingController inputController;
  /* Listeners */
  Function inputControllerListener,
      animControllerListener,
      animationStatusListener;

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    animationController.removeListener(animControllerListener);
    inputController.removeListener(inputControllerListener);
    //animation.removeListener(animationStatusListener);
    super.dispose();
  }

  @override
  void initState() {
    print("initializing numpad");
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    inputController = widget.controller;
  }



  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 1080, height: 2248);
    return Scaffold(
        body: Container(
            /* Input text field at the top where the PIN input is displayed. */
            child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: ListenableProvider<TextEditingController>.value(
                    value: widget.controller,
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        /* Pin Input Field Container */
                        Container(
                            child: PinInputField(
                        )),
                        Padding(
                          padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(35)),
                        ),
                        /* Numpad Keyboard Container. */
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: NumPadKeyboard(
                            pinInputController: widget.controller,
                          ),
                        )
                      ],
                    ))))));
  }
}
