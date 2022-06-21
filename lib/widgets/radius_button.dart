import 'package:flutter/material.dart';

class BorderButton extends StatelessWidget {
  BorderButton(
      {Key? key, required this.isLoading, this.title, this.backgroundColor})
      : super(key: key);
  Color? backgroundColor;
  bool isLoading;
  String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
          child: isLoading
              ? Container(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              )
              : Text(
                  title ?? ' ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white),
                )),
    );
  }
}
