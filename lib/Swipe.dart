import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';

import 'PersonCard.dart';
import 'package:flutter/material.dart';

enum Direction { left, right, none }

class Swipe extends StatefulWidget {
  final GlobalKey<_SwipeState> _key;
  List<MyCard> cardStack;
  Swipe(this._key, cardStack): super(key: _key) {
    this.cardStack = cardStack;
  }

  @override
  _SwipeState createState() => _SwipeState();
}

class _SwipeState extends State<Swipe> with TickerProviderStateMixin {
  AnimationController animationController;
  static Direction direction;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    animationController..addListener(() {setState(() {});});
  }

  Alignment alignment = Alignment(0.0, 0.0);
  bool isLiked;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(children: [
        Center(child: widget.cardStack[1],),
        GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              alignment = Alignment(
                  alignment.x + details.delta.dx * 20 / MediaQuery.of(context).size.width,
                  alignment.y
              );

              // update status based on alignment
              isLiked = alignment.x>0;
            });
          },
          onPanEnd: (DragEndDetails details) {
            animateCards(Direction.none);
          },
          child: Align(
            alignment: animationController.status == AnimationStatus.forward
                ? alignment = CardAnimation.frontCardAlign(animationController, alignment, Alignment.center, 9.0).value
                : alignment,
            child: Transform.rotate(
                angle: (pi / 45.0) *
                    (animationController.status == AnimationStatus.forward ? CardAnimation.rotation(animationController, alignment.x).value : alignment.x),
                child: widget.cardStack[0]),
          ),
        )
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF0000FF),
        onPressed: (){
          setState(() => moveCardBack());
          showToast("You have superliked the person");
        },
        child: Icon(
          Icons.star,
          size: 30,
          color: Colors.lightBlueAccent,
        ),
      ),
    );
  }

  void animateCards(Direction direc) {
    animationController.value = 0.0;
    animationController.forward().whenComplete(() {
      if (alignment.x.abs() > 5) {
        setState(() {
          moveCardBack();
          alignment = Alignment(0.0, 0.0);
          String status = isLiked ? "liked" : 'disliked';
          showToast("You have " + status + " the person");
        });
      }
    });
    direction = direc;
  }

  void moveCardBack(){
    MyCard firstCard = widget.cardStack[0];
    widget.cardStack = widget.cardStack.sublist(1, widget.cardStack.length);
    widget.cardStack.add(firstCard); // add the first card to the end of stack. For testing purpose only
  }

  Future<bool> showToast(message){
    return Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

}

class CardAnimation {
  static Animation<Alignment> frontCardAlign(
      AnimationController controller,
      Alignment beginAlign,
      Alignment baseAlign,
      double swipeEdge,
      ) {
    double endX, endY;

    if (_SwipeState.direction == Direction.none) {
      endX = beginAlign.x > 0
          ? (beginAlign.x > swipeEdge ? beginAlign.x + 12.0 : baseAlign.x)
          : (beginAlign.x < -swipeEdge ? beginAlign.x - 12.0 : baseAlign.x);
      endY = beginAlign.x > swipeEdge || beginAlign.x < -swipeEdge
          ? beginAlign.y
          : baseAlign.y;
    } else if (_SwipeState.direction == Direction.left) {
      endX = beginAlign.x - swipeEdge;
      endY = beginAlign.y + 0.5;
    } else {
      endX = beginAlign.x + swipeEdge;
      endY = beginAlign.y + 0.5;
    }

    return AlignmentTween(begin: beginAlign, end: Alignment(endX, endY))
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
  }

  static Animation<double> rotation(
      AnimationController controller, double beginRot) {
    return Tween(begin: beginRot, end: 0.0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
  }
}