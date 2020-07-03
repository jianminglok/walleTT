import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'AppState.dart';
import 'Home.dart';
import 'main.dart';

// TODO: refactor this monstrosity of a class

class CreateForm extends StatefulWidget {
  @override
  _CreateFormState createState() => _CreateFormState();
}

class _CreateFormState extends State<CreateForm> {

  var _darkTheme = false;

  String scanResult;

  final _formKey = GlobalKey<FormState>();
  final _pageViewController = PageController();
  final _textControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];
  List<Widget> _pages;
  double _formProgress = 0.2;
  bool userOwesFriend = false;
  bool suggestionsRemovable = false;

  bool makingPayment = false;

  Future _future;
  Future<String> _verifyResult;

  @override
  void initState() {
    super.initState();
    _future = _getUserData();
  }

  Future<void> _getUserData() async {
    //Get store id, name etc
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    agentId = prefs.getString('id');
    agentSecret = prefs.getString('secret');
  }



  var agentId;
  var agentSecret;

  Future<String> _verify() async {
    //Do verification when submitting payment

    var loginMap = new Map<String, dynamic>();
    loginMap['USER'] = agentId; //Change to storeId later
    loginMap['PASS'] = agentSecret; //Change to storeSecret later
    loginMap['type'] = 'login';

    FormData loginData = new FormData.fromMap(loginMap);

    var map = new Map<String, dynamic>();
    map['reg'] = scanResult;
    map['agentId'] = agentId; //change to storeId later
    map['money'] = int.parse(_textControllers[3].text);
    map['agent'] = agentSecret;
    map['phone'] = _textControllers[2].text;
    map['username'] = _textControllers[1].text;
    map['typ'] = 'buyer';
    map['type'] = 'registration';

    FormData regData = new FormData.fromMap(map);

    try {
      Response response =
          await Dio().post(Home.serverUrl + "verify.php", data: loginData);
      var jsonData = json.decode(response.toString());

      String loginStatus = jsonData["status"];
      String status;

      if (loginStatus == 'agent') {
        //If verification successful
        try {
          Response response =
              await Dio().post(Home.serverUrl + "reg.php", data: regData);

          String regStatus = response.toString();

          if (regStatus == 'ok') {
            setState(() {
              _textControllers[0].text = '';
              _textControllers[1].text = '';
              _textControllers[2].text = '';
              _textControllers[3].text = '';
            });
          }

          _refreshBalance();
          _refreshHistory();

          status = regStatus;
        } catch (e) {
          print(e);
        }
      } else {
        status = loginStatus;
      }
      return status;
    } catch (e) {
      print(e);
    }
  }

  void _refreshBalance() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.refreshUserData();
  }

  Future<void> _refreshHistory() async {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.refreshUserHistory();
  }

  void goBack() {
    _formProgress -= 1 / _pages.length;
    _pageViewController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
    suggestionsRemovable = false;
    FocusScope.of(context).unfocus();
  }

  void goNext() {
    _formProgress += 1 / _pages.length;
    _pageViewController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
    suggestionsRemovable = false;
    FocusScope.of(context).unfocus();
  }

  void _scan() async {
    scanResult = await scan();
    if(scanResult.isNotEmpty) {
      _textControllers[0].text = scanResult.split('U')[1].split(';')[0];
    } else {
      _textControllers[0].text = 'Please try again';
    }
  }

  static Future<String> scan() async {
    //Scan QR code
    try {
      return await BarcodeScanner.scan();
    } catch (e) {
      if (e is PlatformException) {
      }
    }
    return null;
  }

  Widget buildPage({
    @required String title,
    @required String description,
    @required Widget textField,
    @required int pageIndex,
    Widget option,
  }) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.display1.copyWith(color: _darkTheme ? Colors.white : Colors.black),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16.0),
          ),
          Text(
            description,
            style: Theme.of(context).textTheme.body1.copyWith(fontSize: 18.0),
          ),
          Padding(
            padding: EdgeInsets.only(top: 24.0),
          ),
          Row(
            children: <Widget>[
              Flexible(child: textField),
            ],
          ),
          pageIndex == 0
              ? Padding(
                  padding: EdgeInsets.only(top: 24.0),
                  child: Center(
                      child: SizedBox(
                          width: double.infinity,
                          height: 50.0,
                          child: RaisedButton.icon(
                            icon: Icon(
                              Icons.center_focus_strong,
                              color: Colors.white,
                            ),
                            label: Text("Scan QR Code",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 54.ssp)),
                            onPressed: () {
                              _scan();
                            },
                          ))),
                )
              : Padding(
                  padding: EdgeInsets.only(top: 0.0),
                ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  pageIndex == 0
                      ? Padding(
                          padding: EdgeInsets.only(top: 0.0),
                        )
                      : FlatButton(
                          child: Text("Back"),
                          onPressed: () {
                            if (pageIndex != 0) goBack();
                          },
                        ),
                  RaisedButton(
                    child: Text(pageIndex == 3 ? 'Submit' : 'Next',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        if (pageIndex == 3) {
                          FocusScope.of(context).unfocus();

                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  return Wrap(children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        color: _darkTheme ? Colors.grey.shade800 : Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(18),
                                          topRight: Radius.circular(18),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(26.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Text('Confirm Registration?',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline
                                                    .copyWith(fontWeight: FontWeight.bold)),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 24.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    "ID",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subhead
                                                        .copyWith(color: _darkTheme ? Colors.white54 : Colors.black54),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  scanResult.split('U')[1].split(';')[0],
                                                  style: Theme.of(context).textTheme.title,
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 24.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    "Name",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subhead
                                                        .copyWith(color: _darkTheme ? Colors.white54 : Colors.black54),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  _textControllers[1].text,
                                                  style: Theme.of(context).textTheme.title,
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 24.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    "Phone Number",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subhead
                                                        .copyWith(color: _darkTheme ? Colors.white54 : Colors.black54),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  _textControllers[2].text,
                                                  style: Theme.of(context).textTheme.title,
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 24.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    "Initial Topup Amount (RM)",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subhead
                                                        .copyWith(color: _darkTheme ? Colors.white54 : Colors.black54),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  FlutterMoneyFormatter(amount: double.parse(_textControllers[3].text)).output.nonSymbol,
                                                  style: TextStyle(
                                                      fontSize: 60.0, fontWeight: FontWeight.w800),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: <Widget>[
                                                FlatButton(
                                                  child: Text("Cancel",
                                                      style: TextStyle(fontSize: 18.0)),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                RaisedButton(
                                                  child: Text("Confirm",
                                                      style: TextStyle(
                                                          color: Colors.white, fontSize: 18.0)),
                                                  onPressed: () {

                                                    if (makingPayment == false) {
                                                      Navigator.pop(context);
                                                      _verifyResult = _verify();
                                                      showModalBottomSheet(
                                                          isScrollControlled: true,
                                                          context: context,
                                                          isDismissible: false,
                                                          backgroundColor: Colors.transparent,
                                                          builder: (context) {
                                                            return Wrap(children: <Widget>[
                                                              Container(
                                                                  decoration: BoxDecoration(
                                                                    color: _darkTheme ? Colors.grey.shade800 : Colors.white,
                                                                    borderRadius: BorderRadius.only(
                                                                      topLeft: Radius.circular(18),
                                                                      topRight: Radius.circular(18),
                                                                    ),
                                                                  ),
                                                                  child: Padding(
                                                                      padding:
                                                                      const EdgeInsets.all(26.0),
                                                                      child: Center(
                                                                          child: FutureBuilder<
                                                                              String>(
                                                                              future: _verifyResult,
                                                                              builder:
                                                                                  (context,
                                                                                  snapshot) {
                                                                                switch (snapshot
                                                                                    .connectionState) {
                                                                                  case ConnectionState
                                                                                      .none:
                                                                                  case ConnectionState
                                                                                      .waiting: //Display progress circle while loading
                                                                                    return Column(
                                                                                        crossAxisAlignment:
                                                                                        CrossAxisAlignment
                                                                                            .stretch,
                                                                                        mainAxisSize:
                                                                                        MainAxisSize
                                                                                            .max,
                                                                                        children: <
                                                                                            Widget>[
                                                                                          Center(
                                                                                              child: SpinKitDoubleBounce(
                                                                                                color: Theme.of(context).primaryColor,
                                                                                                size: 50.0,
                                                                                              )
                                                                                          )
                                                                                        ]);
                                                                                  default: //Display card when loaded
                                                                                    return snapshot
                                                                                        .data ==
                                                                                        'ok'
                                                                                        ? Column(
                                                                                        crossAxisAlignment:
                                                                                        CrossAxisAlignment
                                                                                            .stretch,
                                                                                        mainAxisSize:
                                                                                        MainAxisSize
                                                                                            .max,
                                                                                        children: <
                                                                                            Widget>[
                                                                                          Center(
                                                                                            child:
                                                                                            Icon(
                                                                                              Icons
                                                                                                  .check,
                                                                                              color:
                                                                                              Color(
                                                                                                  0xff03da9d),
                                                                                              size:
                                                                                              60.0,
                                                                                            ),
                                                                                          ),
                                                                                          Center(
                                                                                            child:
                                                                                            Text(
                                                                                              'Successful',
                                                                                              style:
                                                                                              Theme
                                                                                                  .of(
                                                                                                  context)
                                                                                                  .textTheme
                                                                                                  .title,
                                                                                              textAlign:
                                                                                              TextAlign
                                                                                                  .center,
                                                                                            ),
                                                                                          ),
                                                                                          Padding(
                                                                                            padding:
                                                                                            const EdgeInsets
                                                                                                .only(
                                                                                                top: 24.0),
                                                                                          ),
                                                                                          Row(
                                                                                            mainAxisAlignment:
                                                                                            MainAxisAlignment
                                                                                                .spaceAround,
                                                                                            children: <
                                                                                                Widget>[
                                                                                              RaisedButton(
                                                                                                child: Text(
                                                                                                    "Confirm",
                                                                                                    style: TextStyle(
                                                                                                        color: Colors
                                                                                                            .white,
                                                                                                        fontSize: 18.0)),
                                                                                                onPressed: () {
                                                                                                  setState(() {
                                                                                                    makingPayment =
                                                                                                    false;
                                                                                                  });
                                                                                                  Navigator
                                                                                                      .pop(
                                                                                                      context);
                                                                                                  _formProgress -= 3 / _pages.length;
                                                                                                  _pageViewController.jumpToPage(_pageViewController.initialPage);
                                                                                                  FocusScope.of(context).unfocus();

                                                                                                },
                                                                                              )
                                                                                            ],
                                                                                          )
                                                                                        ])
                                                                                        : Column(
                                                                                        crossAxisAlignment:
                                                                                        CrossAxisAlignment
                                                                                            .stretch,
                                                                                        mainAxisSize:
                                                                                        MainAxisSize
                                                                                            .max,
                                                                                        children: <
                                                                                            Widget>[
                                                                                          Center(
                                                                                            child:
                                                                                            Icon(
                                                                                              Icons
                                                                                                  .clear,
                                                                                              color:
                                                                                              Theme
                                                                                                  .of(
                                                                                                  context)
                                                                                                  .primaryColor,
                                                                                              size:
                                                                                              60.0,
                                                                                            ),
                                                                                          ),
                                                                                          Center(
                                                                                            child:
                                                                                            Text(
                                                                                              snapshot
                                                                                                  .data
                                                                                                  .toString(),
                                                                                              style:
                                                                                              Theme
                                                                                                  .of(
                                                                                                  context)
                                                                                                  .textTheme
                                                                                                  .title,
                                                                                              textAlign:
                                                                                              TextAlign
                                                                                                  .center,
                                                                                            ),
                                                                                          ),
                                                                                          Padding(
                                                                                            padding:
                                                                                            const EdgeInsets
                                                                                                .only(
                                                                                                top: 24.0),
                                                                                          ),
                                                                                          Row(
                                                                                            mainAxisAlignment:
                                                                                            MainAxisAlignment
                                                                                                .spaceAround,
                                                                                            children: <
                                                                                                Widget>[
                                                                                              RaisedButton(
                                                                                                child: Text(
                                                                                                    "Confirm",
                                                                                                    style: TextStyle(
                                                                                                        color: Colors
                                                                                                            .white,
                                                                                                        fontSize: 18.0)),
                                                                                                onPressed: () {
                                                                                                  setState(() {
                                                                                                    makingPayment =
                                                                                                    false;
                                                                                                  });
                                                                                                  Navigator
                                                                                                      .pop(
                                                                                                      context);
                                                                                                },
                                                                                              )
                                                                                            ],
                                                                                          )
                                                                                        ]);
                                                                                }
                                                                              }))))
                                                            ]);
                                                          });
                                                    } else {
                                                      Scaffold.of(context).showSnackBar(SnackBar(
                                                        content: Text(
                                                            "Please wait for the previous registration to finish first"),
                                                      ));
                                                    }
                                                  },
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ]);
                                });
                        } else {
                          goNext();
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildPages(
    BuildContext context,
  ) {
    _pages = [
      buildPage(
        pageIndex: 0,
        title: "ID",
        description: "Scan an unregistered QR code to begin.",
        textField: TextFormField(
          controller: _textControllers[0],
          autofocus: false,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.center_focus_strong),
          ),
          validator: (value) {
            if (value.isEmpty)
              return 'Please enter a valid ID by scanning a QR code.';
            return null;
          },
        ),
      ),
      buildPage(
        pageIndex: 1,
        title: "Name",
        description:
            "Enter the name of the person who you're registering this QR code for.",
        textField: TextFormField(
          controller: _textControllers[1],
          autofocus: true,
          decoration: InputDecoration(prefixIcon: Icon(Icons.person)),
          validator: (value) {
            if (value.isEmpty) return 'Please provide a name';
            return null;
          },
        ),
      ),
      buildPage(
        pageIndex: 2,
        title: "Phone Number",
        description: "Enter ${_textControllers[1].text}'s phone number.",
        textField: TextFormField(
          controller: _textControllers[2],
          autofocus: true,
          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(prefixIcon: Icon(Icons.phone)),
          validator: (value) {
            if (value.isEmpty) return 'Please enter the initial top up amount.';
            if (value.length > 11) return 'Please enter a valid phone number';
            return null;
          },
        ),
      ),
      buildPage(
        pageIndex: 3,
        title: "Amount",
        description:
            "Enter ${_textControllers[1].text}'s initial top up amount.",
        textField: TextFormField(
          controller: _textControllers[3],
          autofocus: true,
          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(prefixIcon: Icon(Icons.attach_money)),
          validator: (value) {
            if (value.isEmpty) return 'Please enter the initial top up amount.';
            if (int.tryParse(value) == null)
              return "Please enter a valid number without decimals.";
            return null;
          },
        ),
      ),
    ];
    return _pages;
  }

  @override
  Widget build(BuildContext context) {

    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);

    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState
                .waiting: //Display progress circle while loading
              return Container(
                  child: Center(
                      child: SpinKitDoubleBounce(
                color: Theme.of(context).primaryColor,
                size: 50.0,
              )));
            default:
              return Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    LinearProgressIndicator(
                        value: _formProgress,
                        backgroundColor: Colors.transparent,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xff03da9d))),
                    Expanded(
                      child: PageView(
                        controller: _pageViewController,
                        physics: NeverScrollableScrollPhysics(),
                        children: buildPages(
                          context,
                        ),
                      ),
                    ),
                  ],
                ),
              );
          }
        });
  }
}
