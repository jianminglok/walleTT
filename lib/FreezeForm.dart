import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Home.dart';
import 'Topup.dart';

// TODO: refactor this monstrosity of a class

class FreezeForm extends StatefulWidget {
  @override
  _FreezeFormState createState() => _FreezeFormState();
}

class _FreezeFormState extends State<FreezeForm> {
  final _formKey = GlobalKey<FormState>();
  final _pageViewController = PageController();
  final _textControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  List<Widget> _pages;
  double _formProgress = 0.33;
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
    loginMap['type'] = 'freeze';

    FormData loginData = new FormData.fromMap(loginMap);

    var map = new Map<String, dynamic>();
    map['agent'] = agentId;
    map['telephone'] = _textControllers[1].text;
    map['name'] = _textControllers[0].text;
    map['type'] = 'freeze';

    FormData regData = new FormData.fromMap(map);

    try {
      Response response =
      await Dio().post(Home.serverUrl + "verify.php", data: loginData);
      var jsonData = json.decode(response.toString());

      String loginStatus = jsonData["status"];
      String status;

      print(loginStatus);

      if (loginStatus == 'ok') {
        //If verification successful
        try {
          Response response =
          await Dio().post(Home.serverUrl + "process.php", data: regData);

          var jsonData  = json.decode(response.toString());

          String freezeStatus = jsonData['status'];
          //Transactions().checkOrderLength();

          if (freezeStatus == 'Successful!') {
            setState(() {
              _textControllers[0].text = '';
              _textControllers[1].text = '';
            });
          }

          print(freezeStatus);

          status = freezeStatus;
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
            style: Theme.of(context).textTheme.display1,
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
                    child: Text(pageIndex == 1 ? 'Submit' : 'Next',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        if (pageIndex == 1) {
                          FocusScope.of(context).unfocus();

                          showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) {
                                return Wrap(children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
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
                                          Text('Confirm Freeze?',
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
                                                  "Name",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subhead
                                                      .copyWith(color: Colors.black54),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                _textControllers[0].text,
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
                                                      .copyWith(color: Colors.black54),
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
                                            padding: EdgeInsets.only(top: 24.0),
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
                                                                  color: Colors.white,
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
                                                                                      'Successful!'
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
                                                                                                Navigator
                                                                                                    .pop(
                                                                                                    context);
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
        title: "Name",
        description: "Enter the name of the account to freeze. Please double check the name according to the user's identity card or passport before proceeding.",
        textField: TextFormField(
          controller: _textControllers[0],
          autofocus: true,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value.isEmpty)
              return 'Please provide a name';
            return null;
          },
        ),
      ),
      buildPage(
        pageIndex: 1,
        title: "Phone Number",
        description: "Enter ${_textControllers[0].text}'s phone number.",
        textField: TextFormField(
          controller: _textControllers[1],
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
      )
    ];
    return _pages;
  }

  @override
  Widget build(BuildContext context) {
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
