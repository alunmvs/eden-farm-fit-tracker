import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eden_farm_tech_test_hartono/models/user_model.dart';
import 'package:eden_farm_tech_test_hartono/screens/add_height_screen.dart';
import 'package:eden_farm_tech_test_hartono/screens/edit_screen.dart';
import 'package:eden_farm_tech_test_hartono/widgets/slide_transitions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  User? user;
  late AnimationController _controller;
  TextEditingController birthdayController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  bool showAddHeight = false;
  DateTime selectedBirthdate = DateTime(2000);

  List<LineChartBarData> _lineChartData = <LineChartBarData>[];
  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  navigateToAddHeight() async {
    Weight res = await Navigator.push(
        context, SlideToRightRoute(page: AddWeightScreen()));

    if (res != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          print('Document data: ${documentSnapshot.data()}');
        } else {
          print('Document does not exist on the database');
        }
        List<Weight> dataTemp = List<Weight>.from(
            documentSnapshot['weight'].map((x) => Weight.fromJson(x)));
        dataTemp.add(res);

        FirebaseFirestore.instance.collection('users').doc(user!.uid).update(
            {'weight': List<dynamic>.from(dataTemp.map((x) => x.toJson()))});
        setState(() {});
      });
    }
  }

  navigateToEditHeight(index, Weight data) async {
    Weight res = await Navigator.push(
        context, SlideToRightRoute(page: AddWeightScreen(data: data)));

    if (res != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          print('Document data: ${documentSnapshot.data()}');
        } else {
          print('Document does not exist on the database');
        }
        List<Weight> dataTemp = List<Weight>.from(
            documentSnapshot['weight'].map((x) => Weight.fromJson(x)));
        dataTemp[index] = res;

        FirebaseFirestore.instance.collection('users').doc(user!.uid).update(
            {'weight': List<dynamic>.from(dataTemp.map((x) => x.toJson()))});
        setState(() {});
      });
    }
  }

  deleteEntry(index) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      List<Weight> dataTemp = List<Weight>.from(
          documentSnapshot['weight'].map((x) => Weight.fromJson(x)));
      dataTemp.removeAt(index);

      FirebaseFirestore.instance.collection('users').doc(user!.uid).update(
          {'weight': List<dynamic>.from(dataTemp.map((x) => x.toJson()))});
      setState(() {});
    });
  }

  navigateToEdit() async {
    var res =
        await Navigator.push(context, SlideToRightRoute(page: EditScreen()));

    if (res != null) {
      await Flushbar(
        title: 'Update success!',
        message: 'Your data is updated!',
        backgroundColor: Colors.green,
        margin: EdgeInsets.all(15),
        borderRadius: BorderRadius.circular(15),
        duration: Duration(seconds: 3),
      ).show(context);
      setState(() {});
    }
  }

  Future<void> showDeleteDialog(index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure to delete this entry?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                deleteEntry(index);
                Navigator.pop(context);
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

  FlTitlesData generateLineTitle(data) {
    FlTitlesData _data = FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, a) {
                  if (value == 0) {
                    return Text('');
                  } else if (value == 1) {
                    return Text(
                        DateFormat('MMM dd').format(data[value.toInt()].date));
                  } else if (value == 1 + 2) {
                    return Text(
                        DateFormat('MMM dd').format(data[value.toInt()].date));
                  } else if (value % 2 == 0) {
                    return Text(
                        DateFormat('MMM dd').format(data[value.toInt()].date));
                  } else if (value == data.length - 1) {
                    return Text(
                        DateFormat('MMM dd').format(data[value.toInt()].date));
                  } else {
                    return Text('');
                  }
                })),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)));

    return _data;
  }

  List<LineChartBarData> generateLineChartData(data) {
    List<LineChartBarData> _data = <LineChartBarData>[];
    LineChartBarData temp = LineChartBarData(
        spots: generateLineSpotData(data),
        isCurved: true,
        dotData: FlDotData(show: false),
        barWidth: 3,
        color: Colors.blue);
    _data.add(temp);

    return _data;
  }

  List<FlSpot> generateLineSpotData(data) {
    List<FlSpot> _list = <FlSpot>[];
    for (var j = 0; j < data.length; j++) {
      _list.add(FlSpot(
        j.toDouble(),
        data[j].data.toDouble(),
      ));
    }

    return _list;
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              title: Text('Fit Tracker - Eden Farm'),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            body: FutureBuilder<DocumentSnapshot>(
              future: users.doc(user!.uid).get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text("Something went wrong");
                }

                if (snapshot.hasData && !snapshot.data!.exists) {
                  return Text("Document does not exist");
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  Map<String, dynamic> data =
                      snapshot.data!.data() as Map<String, dynamic>;
                  List<Weight> weights = List<Weight>.from(
                      data['weight'].map((x) => Weight.fromJson(x)));

                  List<Weight> sorted = List<Weight>.from(
                      data['weight'].map((x) => Weight.fromJson(x)));
                  sorted.sort((a, b) => a.date.compareTo(b.date));
                  _lineChartData = generateLineChartData(sorted);

                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 25,
                          ),
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: Offset(5, 5))
                                ]),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: data['gender'] == 'Female'
                                          ? Colors.pink
                                          : Colors.blue),
                                  child: data['gender'] == 'Female'
                                      ? Icon(
                                          Icons.female,
                                          size: 40,
                                          color: Colors.white,
                                        )
                                      : Icon(
                                          Icons.male,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['name'],
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                            color: Colors.blue),
                                      ),
                                      Text(
                                        data['email'],
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                      Text(
                                        '${data['birthday']} - ${data['height']}cm',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    navigateToEdit();
                                  },
                                  child: Container(
                                    height: 75,
                                    width: 75,
                                    child: Center(
                                        child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 50,
                                    )),
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Color.fromARGB(
                                                      255, 20, 141, 54)
                                                  .withOpacity(0.4),
                                              blurRadius: 5,
                                              offset: Offset(3, 3))
                                        ]),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Container(
                            height: 350,
                            padding: EdgeInsets.only(right: 25),
                            child: Center(
                              child: LineChart(
                                LineChartData(
                                    borderData: FlBorderData(show: false),
                                    gridData: FlGridData(),
                                    lineBarsData: _lineChartData,
                                    titlesData: generateLineTitle(sorted)),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Records',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    navigateToAddHeight();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 17,
                                    ),
                                  ),
                                )
                              ]),
                          Container(
                            margin: EdgeInsets.only(top: 15),
                            child: ListView.builder(
                              itemCount: weights.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  padding: EdgeInsets.all(15),
                                  margin: EdgeInsets.only(bottom: 15),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: Offset(5, 5))
                                      ]),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${weights[index].data.toString()} kg',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 50),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      navigateToEditHeight(
                                                          index,
                                                          weights[index]);
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 3),
                                                      decoration: BoxDecoration(
                                                          color: Colors.blue,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      30)),
                                                      child: Center(
                                                          child: Text(
                                                        'Edit',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 10),
                                                      )),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      showDeleteDialog(index);
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 3),
                                                      decoration: BoxDecoration(
                                                          color: Colors.red,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      30)),
                                                      child: Center(
                                                          child: Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 10),
                                                      )),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                DateFormat('MMMM dd, yyyy')
                                                    .format(
                                                        weights[index].date),
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              )
                                            ],
                                          ),
                                        )
                                      ]),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'By: Hartono - alunmvs@gmail.com',
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                          SizedBox(
                            height: 40,
                          )
                        ],
                      ),
                    ),
                  );
                }

                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            )),
      ],
    );
  }
}
