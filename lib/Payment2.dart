import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:walleTT/tabsContainer.dart';

class Payment2 extends StatefulWidget {
  Payment2({Key key}) : super(key: key);

  @override
  _Payment2State createState() => _Payment2State();
}

class _Payment2State extends State<Payment2> {

  TextEditingController _amountController = TextEditingController();

  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
  }

  var _list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 0, 0];

  Widget _buildButton(int index) {
    return Material(
      color: Colors.grey[50],
      child: InkWell(
        child: Center(
          child: index == 11 ? Icon(Icons.backspace) : index == 9 ? Semantics() : Text(_list[index].toString(), style: TextStyle(fontSize: 26.0)),
        ),
        onLongPress: () {
          if (index == 11) {
            if (_amountController.text.length == 0) {
              return;
            }
            else {
              _amountController.text = _amountController.text.substring(0, _amountController.text.length - _amountController.text.length);
            }
          }
        },
        onTap: () {
          if (index == 9) {
            return;
          }
          else if (index == 11) {
            if (_amountController.text.length == 0) {
              return;
            }
            else {
              _amountController.text = _amountController.text.substring(0, _amountController.text.length - 1);
            }
          }
          else {
            if (_amountController.text.length == 0) {
              if (index == 10) {

                return;
              } else {
                _amountController.text = _amountController.text == '' ? _list[index].toString() : _amountController.text + _list[index].toString();
              }
            }
            else {
              _amountController.text = _amountController.text == '' ? _list[index].toString() : _amountController.text + _list[index].toString();
            }
          }
          setState(() {
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(top: 40.0),
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text('How much?', style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.w700)),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 20.0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ActionChip(
                                label: Text('5'),
                                backgroundColor: Colors.white,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  _amountController.text = '5';
                                },
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ActionChip(
                                label: Text('10'),
                                backgroundColor: Colors.white,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  _amountController.text = '10';
                                },
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ActionChip(
                                label: Text('20'),
                                backgroundColor: Colors.white,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  _amountController.text = '20';
                                },
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ActionChip(
                                label: Text('50'),
                                backgroundColor: Colors.white,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  _amountController.text = '50';
                                },
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ActionChip(
                                label: Text('100'),
                                backgroundColor: Colors.white,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  _amountController.text = '100';
                                },
                              ),
                            ),
                          ],
                        ),
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
                      Container(
                        padding: EdgeInsets.only(top: 1.0, bottom: 30.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 2,
                                      mainAxisSpacing: 0.6,
                                      crossAxisSpacing: 0.6
                                  ),
                                  itemCount: 12,
                                  itemBuilder: (_, index) => _buildButton(index)
                              ),
                            ]
                        ),
                      )
                    ],
                  )
              )
            ],
          ),
        ],
      ),
    );
  }
}