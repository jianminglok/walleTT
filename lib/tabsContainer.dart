import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:walleTT/providers/filterState.dart';
import 'package:walleTT/widgets/tabsInfoHeader.dart';

import 'AppState.dart';

class TabsContainer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final appState = Provider.of<AppState>(context);

          return Column(
              children: <Widget>[
                Center(
                  child:
                  appState.isFetchingUser
                      ? SizedBox(
                          height: 100.0,
                          child: Center(
                              child: SpinKitDoubleBounce(
                                color: Colors.white,
                                size: 50.0,
                              )
                          )
                      )
                      : appState.getUserResponseJson() != null ?
                  TabsInfoHeader(name: appState.getUserResponseJson()[0], balance: appState.getUserResponseJson()[1].toString()) :
                      Center(
                        child: Text("No response from server. Please try again later.", style: TextStyle(color: Colors.white),),
                      )
                ),
              ],

          );

  }
}
