import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'PersonCard.dart';
import 'Swipe.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

List<MyCard> cardStack = [
  MyCard('assets/images/model.jpeg'),
  MyCard('assets/images/freedom_0.jpeg'),
  MyCard('assets/images/freedom_1.jpeg'),
  MyCard('assets/images/freedom_2.jpeg'),
  MyCard('assets/images/freedom_3.jpeg'),
  MyCard('assets/images/freedom_4.jpeg'),
  MyCard('assets/images/freedom_5.jpeg'),
  MyCard('assets/images/freedom_6.jpeg'),
];

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    final swipeWidget = Swipe(GlobalKey(), cardStack);
    return Container(child: swipeWidget);
  }

}
