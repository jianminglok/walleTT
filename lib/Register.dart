import 'package:flutter/material.dart';

import 'RegistrationForm.dart';

class Register extends StatelessWidget {
  static const String id = "create_page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
        centerTitle: true,
        title: new Text("Register"),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
      ),
      body: Center(child: CreateForm()),
    );
  }
}
