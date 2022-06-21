import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eden_farm_tech_test_hartono/models/user_model.dart';
import 'package:eden_farm_tech_test_hartono/screens/sign_in_screen.dart';
import 'package:eden_farm_tech_test_hartono/widgets/slide_transitions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/radius_button.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({Key? key}) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  TextEditingController emailAddressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController birthdayController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  String? errorEmail,
      errorPassword,
      errorPasswordConfirm,
      selectedGender,
      errorName,
      errorBirthday,
      errorGender,
      errorHeight;
  bool isLoading = false;
  bool isObsecured = true;
  bool isObsecuredConfirm = true;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  DateTime selectedBirthdate = DateTime(2000);
  List<String> genders = ['Male', 'Female'];
  User? user;
  UserData? userData;
  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    getData();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void getData() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
      } else {
        print('Document does not exist on the database');
      }

      setState(() {
        nameController.text = documentSnapshot['name'];
        emailAddressController.text = documentSnapshot['email'];
        heightController.text = documentSnapshot['height'].toString();
        selectedBirthdate = DateTime.parse(documentSnapshot['birthday']);
        birthdayController.text =
            DateFormat('EEE, dd-MMM-yyyy').format(selectedBirthdate);
        selectedGender = documentSnapshot['gender'];
      });
    });
  }

  void updateData() async {
    UserData userData = UserData(
      name: nameController.text,
      gender: selectedGender ?? '',
      birthday: selectedBirthdate,
      email: emailAddressController.text,
      height: int.parse(heightController.text),
    );

    users.doc(user!.uid).update(userData.toJson());
    Navigator.pop(context, 'success');
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

  Future<void> showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure to sign out?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                FirebaseAuth.instance.signOut().then((value) {
                  Navigator.pop(context);
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                      context, SlideToLeftRoute(page: SignInScreen()));
                });
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                  enabled: false,
                  decoration: InputDecoration(
                      labelText: 'Email', errorText: errorEmail),
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
                      errorText: errorHeight),
                ),
                SizedBox(
                  height: 25,
                ),
                InkWell(
                  onTap: () {
                    updateData();
                  },
                  child: BorderButton(
                    isLoading: isLoading,
                    title: 'Update',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () {
                    showLogoutDialog();
                  },
                  child: BorderButton(
                    isLoading: isLoading,
                    backgroundColor: Colors.red,
                    title: 'Sign Out',
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
