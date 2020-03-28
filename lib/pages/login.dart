import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  final FocusNode _loginFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 130),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 300),
                child: Image.asset("assets/logo.png"),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(left: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 50, 
                      top: 5, 
                      bottom: 20
                      ),
                    child: TextField(
                      autocorrect: false,
                      focusNode: _loginFocus,
                      onSubmitted: (term) {
                        _fieldFocusChange(context, _loginFocus, _passwordFocus);
                      },
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: "Username",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 50, 
                      top: 5, 
                      bottom: 30
                      ),
                    // password textfield
                    child: TextField(
                      onChanged: (text) {

                      },
                      focusNode: _passwordFocus,
                      obscureText: true,
                      autocorrect: false,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.vpn_key),
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ),
              Center(
                child: FlatButton(
                onPressed: () {},
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20
                  ),
                ),
                color: Theme.of(context).primaryColor,
                shape: new RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                ),
                padding: EdgeInsets.symmetric(horizontal: 120, vertical: 12),
                )
              )
          ],
        ),
      )
    );
  }
  _fieldFocusChange(BuildContext context, FocusNode currentFocus,FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);  
  }
}