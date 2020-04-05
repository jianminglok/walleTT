import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:walleTT/tabsContainer.dart';
import 'package:intl/intl.dart';

import 'Transactions.dart';
import 'package:http/http.dart' as http;

import 'Product.dart';

class Payment extends StatefulWidget {
  Payment({Key key}) : super(key: key);

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  var totalAmount = 0;

  @override
  bool get wantKeepAlive => true;

  bool makingPayment = false;
  bool success = false;

  Future<List<Product>> _future;
  Future<String> _paymentResult;
  Future<String> _verifyResult;

  var quantities = [];
  var quantitiesString = [];
  var productsList = [];
  var productsNameList = [];

  TextEditingController _amountController = TextEditingController();

  Future<String> _verify(formData, paymentData) async {
    try {
      Response response = await Dio().post("http://10.0.88.178/verify.php", data: formData);
      var jsonData = json.decode(response.toString());

      String loginStatus = jsonData["status"];
      String status;

      if(loginStatus == 'ok') {
        try {
          Response response = await Dio().post("http://10.0.88.178/process.php", data: paymentData);
          var jsonData = json.decode(response.toString());

          String paymentStatus = jsonData["status"];

          //Transactions().checkOrderLength();

          if(paymentStatus == 'successful') {
            setState(() {
              totalAmount = 0;
              for (var i = 0; i < quantities.length; i++) {
                quantitiesString[i] = '0';
                quantities[i] = 0;
                _amountController.text = '0';
              }
            });
          }

          status = paymentStatus;
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

  Future<String> _doPayment(formData) async {
    try {
      Response response = await Dio().post("http://10.0.88.178/process.php", data: formData);
      var jsonData = json.decode(response.toString());

      String status = jsonData["status"];

      //Transactions().checkOrderLength();

      return status;
    } catch (e) {
        print(e);
    }
  }

  Future<List<Product>> _getProducts() async {
    //Get list of users from server

    var map = new Map<String, dynamic>();
    map['id'] = 'S001';
    map['type'] = 'products';

    FormData formData = new FormData.fromMap(map);

    try {
      Response response = await Dio().post("http://10.0.88.178/process.php", data: formData);

      var jsonData = json.decode(response.toString());

      List<Product> products = [];

      for (var i in jsonData) {
        Product product = Product(
            i["id"], i["name"], double.parse(i["price"]));

        products.add(product);

        quantities.add(0);
        quantitiesString.add("0");
        productsNameList.add(i["name"]);
        productsList.add(i["id"]);
      }

      return products;
    } catch (e) {
      print(e);
    }
  }

  Future<List<Product>> _refresh() async { //Refresh list of users from server
    setState(() {
      totalAmount = 0;
      for (var i = 0; i < quantities.length; i++) {
        quantitiesString[i] = '0';
        quantities[i] = 0;
        _amountController.text = '0';
      }
      _future = _getProducts();
    });
  }

  @override
  void initState() {
    super.initState();
    _future = _getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: <Widget>[
          Container(
            height: 185,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [0.1, 0.6],
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor,
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.elliptical(
                    MediaQuery.of(context).size.width * 0.50, 18),
                bottomRight: Radius.elliptical(
                    MediaQuery.of(context).size.width * 0.50, 18),
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 5,
            child: IconButton(
              color: Colors.white,
              icon: Icon(Icons.exit_to_app),
              onPressed: () {

              },
            ),
          ),
          Positioned(
            top: 30,
            right: 5,
            child: IconButton(
              color: Colors.white,
              icon: Icon(Icons.settings),
              onPressed: () {

              },
            ),
          ),
          Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 65.0),
                child: TabsContainer(),
              ),
              Expanded(
                  child: Container(
                      margin: EdgeInsets.only(top: 40.0),
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Text('How much?', style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.w700)),
                        ),
                        TextField(
                          enabled: false,
                          decoration: InputDecoration(contentPadding: EdgeInsets.all(12), prefixIcon: Padding(padding: EdgeInsets.all(15), child: Text('RM'))),
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                          controller: _amountController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        FutureBuilder<List<Product>>(
                            future: _future,
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                case ConnectionState.waiting: //Display progress circle while loading
                                  return Container(
                                      padding: EdgeInsets.only(top: 30.0),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      )
                                  );
                                default: //Display card when loaded
                                  return Expanded(
                                      child: Container(
                                          child:
                                          RefreshIndicator(
                                              key: _refreshIndicatorKey,
                                              onRefresh: _refresh,
                                              child:
                                              ListView.builder(
                                                  itemCount: snapshot.data.length,
                                                  itemBuilder: (BuildContext context, int index) =>
                                                      Container(
                                                          child: Container(
                                                            padding: EdgeInsets.fromLTRB(0, 1.25, 0, 1.25),
                                                            child: SizedBox(
                                                                width: double.infinity,
                                                                child: Card(
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(18),
                                                                  ),
                                                                  child: InkWell(
                                                                    borderRadius: BorderRadius.circular(18),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(15.0),
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: <Widget>[
                                                                          Expanded(
                                                                            child: (
                                                                                Column(
                                                                                  children: <Widget>[
                                                                                    ListTile(
                                                                                      title: Text(
                                                                                        snapshot.data[index].name,
                                                                                        style: Theme.of(context).textTheme.title,
                                                                                      ),
                                                                                      subtitle:
                                                                                          Container(
                                                                                            padding: EdgeInsets.only(top: 10.0),
                                                                                            child: Text(
                                                                                              'RM ' + FlutterMoneyFormatter(amount:snapshot.data[index].price).output.nonSymbol,
                                                                                              style: Theme.of(context).textTheme.subhead,
                                                                                            ),
                                                                                          )
                                                                                    ),
                                                                                  ],
                                                                                )
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child: (
                                                                                Row(
                                                                                    mainAxisAlignment: MainAxisAlignment
                                                                                        .spaceEvenly,
                                                                                    crossAxisAlignment: CrossAxisAlignment
                                                                                        .center,
                                                                                    children: [
                                                                                      SizedBox(
                                                                                        width: 30.0,
                                                                                        child: (
                                                                                            FlatButton(
                                                                                              child: const Text(
                                                                                                  '-', style: TextStyle(
                                                                                                  fontSize: 50.0,
                                                                                                  fontWeight: FontWeight
                                                                                                      .w200)),
                                                                                              padding: EdgeInsets
                                                                                                  .fromLTRB(0, 0, 0, 0),
                                                                                              onPressed: () {
                                                                                                setState(() {
                                                                                                  if (quantities[index] -
                                                                                                      1 >= 0) {
                                                                                                    quantities[index] -=
                                                                                                    1;
                                                                                                    totalAmount = totalAmount - snapshot.data[index].price.toInt();
                                                                                                    quantitiesString[index] =
                                                                                                        quantities[index]
                                                                                                            .toString();
                                                                                                    _amountController.text = totalAmount.toString();
                                                                                                  } else {
                                                                                                    Scaffold.of(context)
                                                                                                        .showSnackBar(
                                                                                                        SnackBar(
                                                                                                            content: Text(
                                                                                                                "Minimum quantity is 0")));
                                                                                                  }
                                                                                                });
                                                                                              },
                                                                                            )
                                                                                        ),
                                                                                      ),
                                                                                      Text(
                                                                                        quantitiesString[index],
                                                                                        style: TextStyle(
                                                                                            fontSize: 25.0,
                                                                                            fontWeight: FontWeight
                                                                                                .w400),
                                                                                      ),
                                                                                      SizedBox(
                                                                                          width: 30.0,
                                                                                          child: (
                                                                                              FlatButton(
                                                                                                child: const Text('+',
                                                                                                    style: TextStyle(
                                                                                                        fontSize: 30.0,
                                                                                                        fontWeight: FontWeight
                                                                                                            .w300)),
                                                                                                padding: EdgeInsets
                                                                                                    .fromLTRB(
                                                                                                    0, 0, 0, 0),
                                                                                                onPressed: () {
                                                                                                  setState(() {
                                                                                                    quantities[index] += 1;
                                                                                                    totalAmount = totalAmount + snapshot.data[index].price.toInt();
                                                                                                    quantitiesString[index] =
                                                                                                        quantities[index]
                                                                                                            .toString();
                                                                                                    _amountController.text = totalAmount.toString();
                                                                                                  });
                                                                                                },
                                                                                              )
                                                                                          )
                                                                                      ),
                                                                                    ]
                                                                                )
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                            ),
                                                          )
                                                      )
                                              )
                                          )
                                      )
                                  );
                              }
                            }
                        ),
                      ],
                    )
                  ),
              )
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _scan(_amountController.text, quantities, productsList, productsNameList, context);
          },
          label: Text("Scan QR Code", style: TextStyle(color: Colors.white, fontSize: 18.0)),
          icon: Icon(Icons.center_focus_strong)),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
  }


  static Future<String> scan(BuildContext context) async {
    try {
      return await BarcodeScanner.scan();
    } catch (e) {
      if (e is PlatformException) {
        if (e.code == BarcodeScanner.CameraAccessDenied) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Camera permission not obtained!"),
          ));
        }
      }
    }
    return null;
  }

  void _scan(String _amount, quantities, products, names, BuildContext context) async {

    final idList = [];
    final quantitiesList = [];
    final nameList = [];

    if(_amount.isNotEmpty && int.parse(_amount) > 0) {
      for (var i = 0; i < quantities.length; i++) {
        if (quantities[i] != 0) {
          idList.add('"' + products[i].toString() + '"');
          quantitiesList.add(quantities[i]);
          nameList.add(names[i]);
        }
      }

      String id = await scan(context);
      String displayAmount =
          FlutterMoneyFormatter(amount: double.parse(_amount)).output.nonSymbol;
      if (id != null) {
        showModalBottomSheet(
            isScrollControlled:true,
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return Wrap(
                children: <Widget>[
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
                          Text(
                              'Confirm Payment?',
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
                                  "Time",
                                  style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
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
                                  "ID",
                                  style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                id,
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
                                  "Product",
                                  style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.black54),
                                ),
                                Text(
                                  "Quantity",
                                  style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                  child: ListView.builder
                                    (
                                      shrinkWrap: true,
                                      itemCount: nameList.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              nameList[index],
                                              style: Theme.of(context).textTheme.title,
                                            ),
                                            Text(
                                              quantitiesList[index].toString(),
                                              style: Theme.of(context).textTheme.title,
                                            ),
                                          ],
                                        );
                                      }
                                  )
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 24.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Amount (RM)",
                                  style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                displayAmount,
                                style: TextStyle(fontSize: 60.0, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              FlatButton(
                                child: Text("Cancel", style: TextStyle(fontSize: 18.0)),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              RaisedButton(
                                child:
                                Text("Confirm", style: TextStyle(color: Colors.white, fontSize: 18.0)),
                                onPressed: () {
                                  var map = new Map<String, dynamic>();
                                  map['userId'] = id;
                                  map['storeId'] = 'S001';
                                  map['time'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
                                  map['amount'] = _amount;
                                  map['products'] = idList.toString();
                                  map['numbers'] = quantitiesList.toString();
                                  map['type'] = 'payment';

                                  FormData paymentData = new FormData.fromMap(map);

                                  var loginMap = new Map<String, dynamic>();
                                  loginMap['USER'] = 'A001';
                                  loginMap['PASS'] = 'A001';
                                  loginMap['type'] = 'payment';

                                  FormData loginData = new FormData.fromMap(loginMap);

                                  if(makingPayment == false) {
                                    _verifyResult = _verify(loginData, paymentData);
                                    Navigator.pop(context);

                                    showModalBottomSheet(
                                        isScrollControlled:true,
                                        context: context,
                                        isDismissible: false,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) {
                                          return Wrap(
                                              children: <Widget>[
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
                                                        child: Center(
                                                                child: FutureBuilder<String>(
                                                                  future: _verifyResult,
                                                                  builder: (context, snapshot) {
                                                                    switch (snapshot.connectionState) {
                                                                      case ConnectionState.none:
                                                                      case ConnectionState.waiting: //Display progress circle while loading
                                                                        return Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                            mainAxisSize: MainAxisSize.max,
                                                                            children: <Widget>[
                                                                                Center(
                                                                                  child: CircularProgressIndicator(),
                                                                                )
                                                                              ]
                                                                          );
                                                                      default: //Display card when loaded
                                                                        return snapshot.data == 'successful' ?
                                                                            Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                children: <Widget>[
                                                                                  Center(
                                                                                    child: Icon(
                                                                                      Icons.check,
                                                                                      color: Color(0xff03da9d),
                                                                                      size: 60.0,
                                                                                    ),
                                                                                  ),
                                                                                  Center(
                                                                                    child: Text(
                                                                                      'Successful',
                                                                                      style: Theme
                                                                                          .of(context)
                                                                                          .textTheme
                                                                                          .title,
                                                                                    ),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(top: 24.0),
                                                                                  ),
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment
                                                                                        .spaceAround,
                                                                                    children: <Widget>[
                                                                                      RaisedButton(
                                                                                        child:
                                                                                        Text("Confirm", style: TextStyle(
                                                                                            color: Colors.white, fontSize: 18.0)),
                                                                                        onPressed: () {
                                                                                          setState(() {
                                                                                            makingPayment = false;
                                                                                          });
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                      )
                                                                                    ],
                                                                                  )
                                                                                ]
                                                                            ) : Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  children: <Widget>[
                                                                                    Center(
                                                                                      child: Icon(
                                                                                        Icons.clear,
                                                                                        color: Theme.of(context).primaryColor,
                                                                                        size: 60.0,
                                                                                      ),
                                                                                    ),
                                                                                    Center(
                                                                                      child: Text(
                                                                                        snapshot.data.toString(),
                                                                                        style: Theme
                                                                                            .of(context)
                                                                                            .textTheme
                                                                                            .title,
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 24.0),
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment
                                                                                          .spaceAround,
                                                                                      children: <Widget>[
                                                                                        RaisedButton(
                                                                                          child:
                                                                                          Text("Confirm", style: TextStyle(
                                                                                              color: Colors.white, fontSize: 18.0)),
                                                                                          onPressed: () {
                                                                                            setState(() {
                                                                                              makingPayment = false;
                                                                                            });
                                                                                            Navigator.pop(context);
                                                                                          },
                                                                                        )
                                                                                      ],
                                                                                    )
                                                                                  ]
                                                                              );
                                                                      }
                                                                    }
                                                                )
                                                        )
                                                    )
                                                )
                                              ]
                                          );
                                        }
                                    );

                                  } else {
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text("Please wait for the previous transaction to finish first"),
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
                ]
              );
            });
      } else {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Please try again"),
        ));
      }
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Amount must be larger than 0!"),
      ));
    }
  }
}

