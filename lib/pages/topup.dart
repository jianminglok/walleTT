import 'package:flutter/material.dart';

class TopUP extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return new Scaffold(
        
        body:new Container(
          margin: EdgeInsets.only(top:50),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(
                  left: 20,
                  bottom: 80
                ),
                child:new Text(
                  "How much?",
                  style: new TextStyle(fontSize:40.0,
                  color: const Color(0xFF000000),
                  fontWeight: FontWeight.w500,
                  fontFamily: "SourceSansPro"),
                ),
              ),
    
              new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.only(
                      left: 10, 
                      right: 15,
                      top: 28),
                    child: new Text(
                      "RM",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w400
                      ),
                    ),
                  ),

                  new Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: new TextField(
                      obscureText: false,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 30
                      ),
                      decoration: InputDecoration(
                        labelText: "Amount",
                      ),
                  ),
                    ))
                ],
              ),
              new Container(
                margin: EdgeInsets.only(
                  top:80
                  ),
                child: new FlatButton.icon(
                  onPressed: (){}, 
                  
                  label: Text(
                    "Scan",
                    textScaleFactor: 1.3,
                  ),
                  icon: Icon(Icons.center_focus_strong),
                  shape: new RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  color: Theme.of(context).primaryColor,
                  splashColor: Theme.of(context).accentColor,
                  textColor: Colors.white,
                ),
              )
            ]
    
          ),
        ),
      );
    }
}