import 'package:eden_farm_tech_test_hartono/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/radius_button.dart';

class AddWeightScreen extends StatefulWidget {
  AddWeightScreen({Key? key, this.data}) : super(key: key);
  Weight? data;
  @override
  State<AddWeightScreen> createState() => _AddWeightScreenState();
}

class _AddWeightScreenState extends State<AddWeightScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  TextEditingController birthdayController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  DateTime selectedBirthdate = DateTime.now();
  String? errorBirthday, errorWeight;

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
  void initState() {
    super.initState();
    if (widget.data == null) {
      birthdayController.text =
          DateFormat('EEE, dd-MMM-yyyy').format(selectedBirthdate);
    } else {
      selectedBirthdate = widget.data!.date;
      birthdayController.text =
          DateFormat('EEE, dd-MMM-yyyy').format(widget.data!.date);
      heightController.text = widget.data!.data.toString();
    }
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data == null ? 'Add Weight' : 'Edit Weight'),
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
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            SizedBox(
              height: 25,
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
                    labelText: 'Date', errorText: errorBirthday),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            TextFormField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration:
                  InputDecoration(labelText: 'Weight', errorText: errorWeight),
            ),
            SizedBox(
              height: 25,
            ),
            InkWell(
              onTap: () {
                if (birthdayController.text.length < 3) {
                  setState(() {
                    errorBirthday = 'Please select date first';
                  });
                } else if (birthdayController.text.length < 3) {
                  setState(() {
                    errorWeight = 'Enter your height';
                  });
                } else {
                  Weight data = Weight(
                      data: int.parse(heightController.text),
                      date: selectedBirthdate);
                  Navigator.pop(context, data);
                }
              },
              child: BorderButton(
                isLoading: false,
                title: 'Submit',
              ),
            ),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      )),
    );
  }
}
