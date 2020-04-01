import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:walleTT/pages/topup.dart';
import 'package:walleTT/pages/history.dart';
import 'package:walleTT/pages/login.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
        title: 'walleTT',
        theme: ThemeData(
          primarySwatch: Colors.red,
          primaryColor: const Color(0xFFef4c3c),
          accentColor: const Color(0xFFd84b3d),
          canvasColor: Colors.grey[100],
          fontFamily: 'Source Sans Pro'
        ),
        home: App(),
    );
  }
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  int _page = 0;
  final List<Widget> _children = [
    TopUP(),
    History()
  ];

  final List<String> _name = [
    'Top up',
    'History'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      //App bar lies here
      appBar: AppBar(
        title: Text(
        _name[_page],
          style: TextStyle(
            fontSize: 28,
          ),
          ),
        
        actions: <Widget>[
          PopupMenuButton(
            onSelected: popupSelected,
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          new PopupMenuItem(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.exit_to_app,
                                    color: Colors.grey.shade700,
                                  ),
                                  Text("Logout")
                                ],
                              ),
                            ), 
                            value: "logout",)
                        ]
                        )
                    ],
                  ),
            
                  //What appears on the screen
                  body: _children[_page],
            
                  // Bottom navigation bar
                  bottomNavigationBar: CurvedNavigationBar(
                    color: Theme.of(context).accentColor,
                    buttonBackgroundColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.white,
                    animationDuration: Duration(milliseconds: 250),
                    animationCurve: Curves.bounceOut,
                    height: 60,
                    index: 0,
                    
                    items: <Widget>[
                      Icon(
                        Icons.add_circle,
                        size: 30,
                        color: Colors.white,
                        semanticLabel: "Top up",
                      ),
                      Icon(
                        Icons.history,
                        size: 30,
                        color: Colors.white,
                        semanticLabel: "History",
                      ),
                    ],
                    onTap: (index) {
                      setState(() {
                        _page = index;
                      });
                    },
                  
                  ),
                );
              }
            
  void popupSelected(String value) {
    Navigator.push(context, 
    MaterialPageRoute(
      builder: (context) => Login()
      )
      );
  }
}
