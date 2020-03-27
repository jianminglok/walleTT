import 'package:flutter/material.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        //example data for illustration
        transacrion(id: '69420', time: "27-3-2020 20:24", amount: '30'),
        transacrion(id: '88888', time: "27-3-2020 20:24", amount: '200')
      ],
    );
  }

  // The transaction widget
  Widget transacrion({id, time, amount}) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        child: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[Text(
                id,
                style: TextStyle(
                  fontSize: 26,
                  fontFamily: 'Poppins'
                ),
              ),
                
                SizedBox(height: 6),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    color: Colors.grey[500]
                  ),
                ),
              ],
            ),
            SizedBox(width: 110,),
            Text(
              "RM",
              style: TextStyle(
                fontSize: 30,
                fontFamily: "Poppins"
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 27,
                fontFamily: "Poppins"
              ),
            )
        ],
        ),
        )
    );
  }
}
