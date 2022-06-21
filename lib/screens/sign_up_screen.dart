import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eden_farm_tech_test_hartono/widgets/radius_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/user_model.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  TextEditingController emailAddressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController birthdayController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  String? errorEmail,
      errorPassword,
      errorPasswordConfirm,
      selectedGender,
      errorName,
      errorBirthday,
      errorGender,
      errorWeight;
  bool isLoading = false;
  bool isObsecured = true;
  bool isObsecuredConfirm = true;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  DateTime selectedBirthdate = DateTime(2000);
  List<String> genders = ['Male', 'Female'];

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

  void submitData(uid) async {
    List<Weight> weightData = [
      Weight(date: DateTime.now(), data: int.parse(weightController.text))
    ];
    UserData userData = UserData(
        name: nameController.text,
        gender: selectedGender ?? '',
        birthday: selectedBirthdate,
        email: emailAddressController.text,
        height: int.parse(heightController.text));

    users.doc(uid).set(userData.toJson());
    users.doc(uid).update(
        {'weight': List<dynamic>.from(weightData.map((x) => x.toJson()))});
    Navigator.pop(context, 'success');
  }

  void signUp() async {
    setState(() {
      isLoading = true;
    });
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddressController.text,
        password: passwordController.text,
      );

      submitData(credential.user?.uid ?? '-');
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  birthDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedBirthdate,
        firstDate: DateTime(1945),
        lastDate: DateTime.now(),
        initialDatePickerMode: DatePickerMode.day);
    if (picked != null && picked != selectedBirthdate) {
      setState(() {
        selectedBirthdate = picked;
        birthdayController.text =
            DateFormat('EEE, dd-MMM-yyyy').format(selectedBirthdate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
        automaticallyImplyLeading: false,
        actions: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.close),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                TextFormField(
                  controller: emailAddressController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Email', errorText: errorEmail),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: passwordController,
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
                  height: 15,
                ),
                TextFormField(
                  controller: passwordConfirmController,
                  keyboardType: TextInputType.text,
                  obscureText: isObsecuredConfirm,
                  decoration: InputDecoration(
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            isObsecuredConfirm = !isObsecuredConfirm;
                          });
                        },
                        child: Icon(isObsecuredConfirm
                            ? Icons.visibility_off
                            : Icons.visibility),
                      ),
                      labelText: 'Confirm Password',
                      errorText: errorPasswordConfirm),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: nameController,
                  keyboardType: TextInputType.text,
                  decoration:
                      InputDecoration(labelText: 'Name', errorText: errorName),
                ),
                SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () {
                    birthDate();
                  },
                  child: TextFormField(
                    controller: birthdayController,
                    keyboardType: TextInputType.text,
                    enabled: false,
                    decoration: InputDecoration(
                        labelText: 'Birthday', errorText: errorBirthday),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black38),
                      borderRadius: BorderRadius.circular(15)),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: DropdownButton<String?>(
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                    value: selectedGender,
                    hint: Text(
                      'Select Gender',
                      style: TextStyle(fontSize: 16),
                    ),
                    onChanged: (newValue) => setState(() {
                      selectedGender = newValue;
                    }),
                    items: genders.map((String value1) {
                      return new DropdownMenuItem<String>(
                        value: value1,
                        child: new Text(
                          value1,
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                    borderRadius: BorderRadius.circular(15),
                    isExpanded: true,
                    underline: SizedBox.shrink(),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      suffixText: 'cm',
                      labelText: 'Height',
                      errorText: errorWeight),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      suffixText: 'kg',
                      labelText: 'Weight',
                      errorText: errorWeight),
                ),
                SizedBox(
                  height: 25,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      errorBirthday = null;
                      errorEmail = null;
                      errorGender = null;
                      errorWeight = null;
                      errorName = null;
                      errorPassword = null;
                      errorPasswordConfirm = null;
                    });
                    if (passwordConfirmController.text !=
                        passwordController.text) {
                      setState(() {
                        errorPassword = 'Password didnt match';
                        errorPasswordConfirm = 'Password didnt match';
                      });
                    } else {
                      signUp();
                    }
                  },
                  child: BorderButton(
                    isLoading: isLoading,
                    title: 'Sign Up',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          )
        ],
      )),
    );
  }
}
