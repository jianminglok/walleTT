import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:walleTT/Transactions.dart';

import 'AppState.dart';
import 'Payment.dart';
import 'main.dart';

class Home extends StatelessWidget {
  // This widget is the root of your application.

  static String serverUrl = 'https://wallett.gq/';

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'walleTT',
        theme: themeNotifier.getTheme(),
        home:  HomePage(title: 'walleTT Home Page'),
      )
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> pageList = List<Widget>();

  int _selectedIndex = 0;

  @override
  void initState() {
    pageList.add(Payment());
    pageList.add(Transactions());
    super.initState();
  }

  Widget _bottomNavigationBar(int selectedIndex) => BottomNavigationBar( //Switch between page
    onTap: (int index) => setState(() => _selectedIndex = index),
    currentIndex: selectedIndex,
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
          icon: Icon(Icons.add), title: Text('Payment')), //Payment Page
      BottomNavigationBarItem(
          icon: Icon(Icons.list), title: Text('Transactions')), //Transactions Record Page
    ],
  );

  @override
  Widget build(BuildContext context) { //Bottom Navigation Widget

    return Scaffold(
      bottomNavigationBar: _bottomNavigationBar(_selectedIndex),
      body: IndexedStack(
        index: _selectedIndex,
        children: pageList,
      ),
    );
  }
}
