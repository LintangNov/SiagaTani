import 'package:flutter/material.dart';
class ExampleWidget extends StatelessWidget {
  final String text;

  ExampleWidget({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Text(text, style: TextStyle(fontSize: 18)),
    );
  }
}
