import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:studybuddy/route/route.dart' as route;

class LoginPage extends StatefulWidget {
  
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usercontroller = TextEditingController();

  final TextEditingController _passwordcontroller = TextEditingController();

    Future<UserCredential> signInWithGoogle() async {
        // Trigger the authentication flow
        final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
        );

        // Once signed in, return the UserCredential
        return await FirebaseAuth.instance.signInWithCredential(credential);
    }

    final FirebaseAuth auth = FirebaseAuth.instance;

    Future<User> handleSignInEmail(String email, String password) async {
    UserCredential result = await auth.signInWithEmailAndPassword(email: _email, password: _password);
    final User user = result.user!;

    return user;
  }

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    String _email = 'test@gmail.com';

    String _password = 'password';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Study Buddy'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
              
              children: [
           
                  TextFormField(
                    controller: _usercontroller,
                    decoration: InputDecoration(
                      labelText: 'Email'
                    ),
                    
                  ),
                  TextFormField(
              controller: _passwordcontroller,
              decoration: InputDecoration(
                labelText: 'Password'
              ),
              
              obscureText: true,
            ),
            RaisedButton(
              onPressed: () async{
                _email = _usercontroller.text;
                _password = _passwordcontroller.text;
                if(_email != null && _password != null){
                  User user = await handleSignInEmail(_email,_password);
                }
              },
              child: Text('Sign in')
              

            ),
                  ElevatedButton(
                    child: Text("Google Sign In"),
                    onPressed: () async{
                      UserCredential user = await signInWithGoogle();
                      if (user != null) {
                        Navigator.pushNamed(context,route.landingPage);
                      }
                    }
                  ),
              ],
        
        )
    );
  }
}
