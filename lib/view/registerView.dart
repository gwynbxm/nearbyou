import 'package:flutter/material.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: RegisterAcc(),
      ),
    );
  }
}

class RegisterAcc extends StatefulWidget {
  const RegisterAcc({Key key}) : super(key: key);

  @override
  _RegisterAccState createState() => _RegisterAccState();
}

class _RegisterAccState extends State<RegisterAcc> {
  TextEditingController _emailCon = TextEditingController();
  TextEditingController _pwdCon = TextEditingController();

  void _validateCred() {}

  void _register() async {}
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
                child: Text('SUBMIT'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
