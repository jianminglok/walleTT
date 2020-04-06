import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walleTT/colors.dart';

import 'Home.dart';

class Login extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'walleTT',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
        primaryColor: const Color(0xFFef4c3c),
        accentColor: const Color(0xFFd84b3d),
        canvasColor: Colors.white,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(color: Colors.white),
        fontFamily: 'Rubik',
        textTheme: TextTheme(
          display1: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          display2: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          button: TextStyle(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: EdgeInsets.all(8),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(style: BorderStyle.none),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: primaryColor,
          textTheme: ButtonTextTheme.normal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      home: LoginPage(title: 'walleTT Home Page'),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  static const String id = "/login";

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool loading = false;
  String errorMessage = "";

  void _submitForm() async {
    if (_formKey.currentState.validate()) {
      try {
        setState(() {
          loading = true;
        });

        var loginMap = new Map<String, dynamic>();
        loginMap['USER'] = _userController.text;
        loginMap['PASS'] = _passwordController.text;
        loginMap['type'] = 'login';

        FormData loginData = new FormData.fromMap(loginMap);

        Response response = await Dio().post("http://10.0.88.178/verify.php", data: loginData);
        var jsonData = json.decode(response.toString());

        String loginStatus = jsonData["status"];

        print(loginStatus);

        setState(() {
          loading = false;
        });

        if(loginStatus.isNotEmpty) { //If response received from server
          switch(loginStatus) {
            case "Server error":
              errorMessage = "Server error";
              break;
            case "ID or password incorrect":
              errorMessage = "Username or password is incorrect";
              break;
            case "User does not exist":
              errorMessage = "User does not exist";
              break;
            case "agent": //Save user data and go to Home
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('id', _userController.text);
              prefs.setString('secret', _passwordController.text);
              prefs.setString('name', jsonData["name"]);
              prefs.setString('status', jsonData["status"]);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (BuildContext ctx) => Home()));
              break;
          }
        } else {
          errorMessage = "Something went wrong.";
        }


      } catch (e) {
        setState(() {
          loading = false;
          print(e);
          switch (e) {
            case "ERROR_INVALID_EMAIL":
              errorMessage = "Your email address appears to be malformed.";
              break;
            case "ERROR_WRONG_PASSWORD":
              errorMessage = "Incorrect password.";
              break;
            case "ERROR_USER_NOT_FOUND":
              errorMessage = "User with this email doesn't exist.";
              break;
            case "ERROR_USER_DISABLED":
              errorMessage = "User with this email has been disabled.";
              break;
            case "ERROR_TOO_MANY_REQUESTS":
              errorMessage = "Too many requests. Try again later.";
              break;
            default:
              errorMessage = "Something went wrong.";
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? Center(
        child: SpinKitDoubleBounce(
          color: Theme.of(context).primaryColor,
          size: 50.0,
        ),
      )
          : Stack(
        fit: StackFit.expand,
        children: <Widget>[
          SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding (
                    padding: EdgeInsets.only(top: 25.0),
                  ),
                  ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300),
                      child: Image.asset("assets/graphics/logo.png"),
                  ),
                  Padding (
                    padding: EdgeInsets.only(top: 25.0),
                  ),
                  Text(
                    "Welcome Back",
                    style: Theme.of(context)
                        .textTheme
                        .display1
                        .copyWith(color: Theme.of(context).primaryColor),
                  ),
                  SizedBox(height: 36),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          controller: _userController,
                          validator: (value) {
                            if (value.length == 0)
                              return "Username must not be empty";
                            return null;
                          },
                          onFieldSubmitted: (v) {
                            FocusScope.of(context).nextFocus();
                          },
                          decoration: InputDecoration(
                            labelText: "Username",
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _passwordController,
                          validator: (value) {
                            if (value.length == 0)
                              return "Password must not be empty";
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                        ),
                        if (errorMessage.length > 0) SizedBox(height: 12),
                        Text(errorMessage,
                            style: TextStyle(color: Colors.red)),
                        if (errorMessage.length > 0) SizedBox(height: 12),
                        Padding (
                          padding: EdgeInsets.only(top: 24.0),
                        ),
                        SizedBox(
                            width: double.infinity,
                            height: 50.0,
                            child: RaisedButton(
                              child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 18.0)),
                              onPressed: () {
                                _submitForm();
                              },
                            )
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
