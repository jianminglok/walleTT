import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;

import '../main.dart';

class PinInputField extends StatelessWidget {
  var color, placeholderColor;
  final String placeholder;

  PinInputField({this.color, this.placeholder, this.placeholderColor});

  var _darkTheme = false;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 1080, height: 2248);

    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                label: Text('5', style: TextStyle(fontFamily: 'Rubik'),),
                backgroundColor: _darkTheme ? Colors.grey.shade800 : Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                onPressed: () {
                  Provider.of<TextEditingController>(context).text = '5';
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                label: Text('10', style: TextStyle(fontFamily: 'Rubik'),),
                backgroundColor: _darkTheme ? Colors.grey.shade800 : Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                onPressed: () {
                  Provider.of<TextEditingController>(context).text = '10';
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                label: Text('20', style: TextStyle(fontFamily: 'Rubik'),),
                backgroundColor: _darkTheme ? Colors.grey.shade800 : Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                onPressed: () {
                  Provider.of<TextEditingController>(context).text = '20';
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                label: Text('50', style: TextStyle(fontFamily: 'Rubik'),),
                backgroundColor: _darkTheme ? Colors.grey.shade800 : Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                onPressed: () {
                  Provider.of<TextEditingController>(context).text = '50';
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                label: Text('100', style: TextStyle(fontFamily: 'Rubik'),),
                backgroundColor: _darkTheme ? Colors.grey.shade800 : Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                onPressed: () {
                  Provider.of<TextEditingController>(context).text = '100';
                },
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(25)),
        ),
        TextField(
          enabled: false,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(12),
              prefixIcon: Padding(
                  padding: EdgeInsets.all(15),
                  child: Text('RM'))),
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.w600),
          controller: Provider.of<TextEditingController>(context),
          keyboardType: TextInputType.numberWithOptions(
            decimal: true,
          ),
        ),
      ],
    );
  }
}
