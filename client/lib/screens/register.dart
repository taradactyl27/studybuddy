import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studybuddy/color_constants.dart';
import 'package:studybuddy/routes/routes.dart' as routes;
import 'package:studybuddy/services/auth.dart' as auth;

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
              height: 250,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fitHeight,
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
                  child: Text(
                    'Sign up',
                    style: GoogleFonts.nunito(
                      textStyle: const TextStyle(color: kLightTextColor),
                    ),
                  ),
                  onPressed: () async {
                    _email = _usercontroller.text;
                    _password = _passwordcontroller.text;
                    try {
                      await auth.signUpEmail(_email, _password);
                      await Navigator.of(context).pushNamedAndRemoveUntil(
                          routes.homePage, (route) => false);
                    } catch (e) {
                      print(e);
                    }
                  },
                ))),
          ],
        ));
  }
}
