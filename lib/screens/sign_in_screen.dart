import 'package:another_flushbar/flushbar.dart';
import 'package:eden_farm_tech_test_hartono/screens/home_screen.dart';
import 'package:eden_farm_tech_test_hartono/screens/sign_up_screen.dart';
import 'package:eden_farm_tech_test_hartono/widgets/radius_button.dart';
import 'package:eden_farm_tech_test_hartono/widgets/slide_transitions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  TextEditingController emailAddress = TextEditingController();
  TextEditingController password = TextEditingController();
  String? errorEmail, errorPassword;
  bool isLoading = false;
  bool isObsecured = true;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void signIn() async {
    setState(() {
      isLoading = true;
    });
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailAddress.text, password: password.text);

      setState(() {
        isLoading = false;
        Navigator.pushReplacement(
            context, SlideToLeftRoute(page: HomeScreen()));
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.code == 'user-not-found') {
        await Flushbar(
          title: 'Sign In Failed',
          message: 'No user found for that email.',
          backgroundColor: Colors.red,
          margin: EdgeInsets.all(15),
          borderRadius: BorderRadius.circular(15),
          duration: Duration(seconds: 3),
        ).show(context);
      } else if (e.code == 'wrong-password') {
        await Flushbar(
          title: 'Sign In Failed',
          message: 'Wrong password provided for that user.',
          backgroundColor: Colors.red,
          margin: EdgeInsets.all(15),
          borderRadius: BorderRadius.circular(15),
          duration: Duration(seconds: 3),
        ).show(context);
      } else {
        await Flushbar(
          title: 'Sign In Failed',
          message: e.message,
          backgroundColor: Colors.red,
          margin: EdgeInsets.all(15),
          borderRadius: BorderRadius.circular(15),
          duration: Duration(seconds: 3),
        ).show(context);
      }
    }
  }

  navigateToSignUp() async {
    var res =
        await Navigator.push(context, SlideToTopRoute(page: SignUpScreen()));

    if (res != null) {
      await Flushbar(
        title: 'Registration success!',
        message: 'Your registration is succes, try to sign in now!',
        backgroundColor: Colors.green,
        margin: EdgeInsets.all(15),
        borderRadius: BorderRadius.circular(15),
        duration: Duration(seconds: 3),
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            margin: EdgeInsets.only(top: 50, bottom: 25),
            width: double.infinity,
            child: FlutterLogo(
              size: 200,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                TextFormField(
                  controller: emailAddress,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Email', errorText: errorEmail),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: password,
                  keyboardType: TextInputType.text,
                  obscureText: isObsecured,
                  decoration: InputDecoration(
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            isObsecured = !isObsecured;
                          });
                        },
                        child: Icon(isObsecured
                            ? Icons.visibility_off
                            : Icons.visibility),
                      ),
                      labelText: 'Password',
                      errorText: errorPassword),
                ),
                SizedBox(
                  height: 25,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      errorEmail = null;
                      errorPassword = null;
                    });
                    if (emailAddress.text.length < 3) {
                      setState(() {
                        errorEmail = 'Please enter correct email!';
                      });
                      return;
                    }

                    if (password.text.length < 3) {
                      setState(() {
                        errorPassword = 'Please enter correct password!';
                      });
                      return;
                    }
                    if (emailAddress.text.length > 3 &&
                        password.text.length > 3) {
                      signIn();
                    }
                  },
                  child: BorderButton(
                    isLoading: isLoading,
                    title: 'Sign In',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Do not have accont?'),
                    InkWell(
                      onTap: () {
                        navigateToSignUp();
                      },
                      child: Text(
                        ' Sign Up',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      )),
    );
  }
}
