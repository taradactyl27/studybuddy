import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/routes/routes.dart' as routes;
import 'package:studybuddy/services/auth.dart' as auth;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usercontroller = TextEditingController();

  final TextEditingController _passwordcontroller = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email = 'test@gmail.com';

  String _password = 'password';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("theme/sbuddy.png"),
                ),
              ),
            ),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: _usercontroller,
                  decoration: const InputDecoration(labelText: 'Email'),
                )),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: _passwordcontroller,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                )),
            Container(
                padding: const EdgeInsets.all(5.0),
                child: Center(
                    child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(220, 36)),
                  child: const Text('Sign in',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  onPressed: () async {
                    _email = _usercontroller.text;
                    _password = _passwordcontroller.text;
                    // _formKey.currentState!.save();
                    try {
                      await auth.signInEmail(_email, _password);
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          routes.homePage, (route) => false);
                    } catch (e) {
                      print(e);
                    }
                  },
                ))),
            Container(
                padding: const EdgeInsets.all(5.0),
                child: Center(
                    child: SignInButton(Buttons.Google, onPressed: () async {
                  try {
                    await auth.signInGoogle();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        routes.homePage, (route) => false);
                  } catch (e) {
                    print(e);
                  }
                }))),
            Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                        text: 'Sign Up!',
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, routes.registerPage);
                          }),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
