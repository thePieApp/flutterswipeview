import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {

  const MyCard(this.resource);
  final String resource;

  @override
  Widget build(BuildContext context) {

    return Card(
      child: Container(
        decoration: BoxDecoration(
            border: new Border.all(
              width: 5.0,
              color: Colors.grey.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(20)),
        height: MediaQuery.of(context).size.height * 0.9,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Image.asset(resource),
      ),
    );
  }
}