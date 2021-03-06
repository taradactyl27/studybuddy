import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studybuddy/color_constants.dart';
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
              padding: const EdgeInsets.only(right: 15, left: 15),
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fitHeight,
                  image: MediaQuery.of(context).platformBrightness ==
                          Brightness.light
                      ? const AssetImage("theme/sbuddy.png")
                      : const AssetImage("theme/sbuddy_dark.png"),
                ),
              ),
            ),
            Center(
              child: Container(
                  constraints: const BoxConstraints(maxWidth: 350),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: _usercontroller,
                    decoration: const InputDecoration(labelText: 'Email'),
                  )),
            ),
            Center(
              child: Container(
                  constraints: const BoxConstraints(maxWidth: 350),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: _passwordcontroller,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  )),
            ),
            Container(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(220, 38)),
                  child: Text('Sign in',
                      style: GoogleFonts.nunito(
                        textStyle: const TextStyle(
                            color: kLightTextColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
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
                    TextSpan(
                      text: "Don't have an account? ",
                      style: GoogleFonts.nunito(
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.light
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                    TextSpan(
                        text: 'Sign Up!',
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
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
