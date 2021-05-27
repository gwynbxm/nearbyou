import 'package:flutter/material.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: LoginAuth(),
      ),
    );
  }
}

class LoginAuth extends StatefulWidget {
  const LoginAuth({Key key}) : super(key: key);

  @override
  _LoginAuthState createState() => _LoginAuthState();
}

class _LoginAuthState extends State<LoginAuth> {
  TextEditingController _emailCon = TextEditingController();
  TextEditingController _pwdCon = TextEditingController();

  void _validateCred() {}

  void _signIn() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
            child: Column(
          children: [
            TextFormField(
              controller: _emailCon,
              decoration: const InputDecoration(labelText: 'Email Address'),
              validator: (value) =>
                  value.isEmpty ? 'Email cannot be blank' : null,
            ),
            SizedBox(
              height: 15.0,
            ),
            TextFormField(
              controller: _pwdCon,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) =>
                  value.isEmpty ? 'Password cannot be blank' : null,
            ),
            ElevatedButton(
              onPressed: _validateCred,
              child: Text('LOGIN'),
            )
          ],
        )),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _emailCon.dispose();
    _pwdCon.dispose();
    super.dispose();
  }
}
