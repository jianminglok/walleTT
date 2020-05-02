import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:walleTT/Register.dart';
import 'package:walleTT/Transactions.dart';

import 'AppState.dart';
import 'Balance.dart';
import 'Topup.dart';
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
    return MaterialApp(
      title: 'walleTT',
        theme: themeNotifier.getTheme(),
        home: ChangeNotifierProvider<AppState>(
          create: (_) => AppState(),
          child: HomePage(title: 'walleTT Home Page'),
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

  int _page = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    pageList.add(Payment());
    pageList.add(Balance());
    pageList.add(Register());
    pageList.add(Transactions());
    super.initState();
  }

  Widget _bottomNavigationBar(int selectedIndex) => BottomNavigationBar(
    type: BottomNavigationBarType.fixed,//Switch between page
    onTap: (int index) => setState(() => _selectedIndex = index),
    currentIndex: selectedIndex,
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
          icon: Icon(Icons.add), title: Text('Topup')),
      BottomNavigationBarItem(
          icon: Icon(Icons.center_focus_strong), title: Text('Balance')),//Balance Page
      BottomNavigationBarItem(
          icon: Icon(Icons.fiber_new), title: Text('Registration')),
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
