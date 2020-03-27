import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:walleTT/pages/topup.dart';
import 'package:walleTT/pages/history.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
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


      appBar: AppBar(
        title: Text(
        _name[_page],
          style: TextStyle(
            fontSize: 28,
          ),
          ),
      ),

      //What appears on the screen
      body: _children[_page],

      // Bottom navigation bar
      bottomNavigationBar: CurvedNavigationBar(
        color: Theme.of(context).accentColor,
        buttonBackgroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        animationDuration: Duration(milliseconds: 200),
        animationCurve: Curves.fastLinearToSlowEaseIn,
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
}
