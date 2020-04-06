import 'package:flutter/material.dart';
import 'package:walleTT/FreezeForm.dart';

class Freeze extends StatelessWidget {
  static const String id = "create_page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
        centerTitle: true,
        title: new Text("Freeze"),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
      ),
      body: Center(child: FreezeForm()),
    );
  }
}
