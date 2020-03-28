import 'package:flutter/material.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemBuilder: (context, position) {
        return transacrion(
          id: position.toString(), //user id here
          time: "27-3-2020 20:24", //Top up time
          amount: (position * 9).toString() //Top up amount
          );
      }
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
