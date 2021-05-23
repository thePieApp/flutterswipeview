import 'dart:math';
import 'PersonCard.dart';
import 'package:flutter/material.dart';

const double stopEdge = 2;
const double alignEdge = 0.2;
const maxIconSize = 60;
const maxIconContainerSize = 80;

enum Direction { left, right, none }
typedef DirectionListener = void Function(Direction trigger);

class SwipeByButtonController {
  DirectionListener _listener;

  void triggerLeft() {
    if (_listener != null) {
      _listener(Direction.left);
    }
  }

  void triggerRight() {
    if (_listener != null) {
      _listener(Direction.right);
    }
  }

  void addListener(listener) {
    _listener = listener;
  }

  void dispose() {
    _listener = null;
  }
}

class Swipe extends StatefulWidget {
  final GlobalKey<_SwipeState> _key;
  Swipe(this._key): super(key: _key);

  @override
  _SwipeState createState() => _SwipeState();
}

class _SwipeState extends State<Swipe> with TickerProviderStateMixin {
  AnimationController animationController;
  SwipeByButtonController swipeByButtonController;
  static Direction direction;

  List<MyCard> cardStack = [
    MyCard('assets/images/model.jpeg'),
    MyCard('assets/images/freedom_0.jpeg'),
    MyCard('assets/images/freedom_1.jpeg'),
    MyCard('assets/images/freedom_2.jpeg'),
  ];

  @override
  void initState() {
    super.initState();
    swipeByButtonController = SwipeByButtonController();
    swipeByButtonController.addListener((direction) => animateCards(direction));
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    animationController
      ..addListener(() {
        setState(() {});
      });
  }

  Alignment alignment = Alignment(0.0, 0.0);

  bool allowVerticalMovement = true;
  double angle = 0.0;
  int selectedIcon = -1;

  @override
  Widget build(BuildContext context) {
    final double rightAlign = -stopEdge - (alignment.x);
    final double leftAlign = stopEdge - (alignment.x);
    double iconSize = alignment.x.abs() >= stopEdge
        ? stopEdge * maxIconSize
        : alignment.x.abs() * maxIconSize;
    double containerSize = alignment.x.abs() >= stopEdge
        ? stopEdge * maxIconContainerSize
        : alignment.x.abs() * maxIconContainerSize;

    return Stack(children: [
      Center(child: cardStack[1],),
      GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          setState(() {

            if (alignment.x<0){
              selectedIcon = 0;
            } else if (alignment.x > 0) {
              if (details.globalPosition.dy < MediaQuery.of(context).size.height/3){
                selectedIcon = 1;
              } else if (details.globalPosition.dy < MediaQuery.of(context).size.height/3*2) {
                selectedIcon = 2;
              } else {
                selectedIcon = 3;
              }
            }

            if (allowVerticalMovement == true) {
              alignment = Alignment(
                  alignment.x + details.delta.dx * 20 / MediaQuery.of(context).size.width,
                  alignment.y
              );
            } else {
              alignment = Alignment(
                0,
                alignment.y + details.delta.dy * 30 / MediaQuery.of(context).size.height,
              );
            }
          });
        },
        onPanEnd: (DragEndDetails details) {
          animateCards(Direction.none, leftAlign: leftAlign, rightAlign: rightAlign);
        },
        child: Align(
          alignment: animationController.status == AnimationStatus.forward
              ? alignment = CardAnimation.frontCardAlign(
              animationController, alignment, Alignment.center, 4)
              .value
              : alignment,
          child: Transform.rotate(
              angle: (pi / 45.0) *
                  (animationController.status == AnimationStatus.forward
                      ? CardAnimation.rotation(animationController, alignment.x)
                      .value
                      : alignment.x),
              child: cardStack[0]),
        ),
      ),
      alignIcon(
          Alignment(rightAlign >= (-alignEdge) ? -alignEdge : rightAlign, 0),
          Icons.close,
          0xFF000000,
          selectedIcon == 0 ? iconSize * 1.2 : iconSize,
          selectedIcon == 0 ? containerSize * 1.2 : containerSize
      ),
      alignIcon(
          Alignment(leftAlign <= (alignEdge) ? alignEdge : leftAlign, leftAlign <= (alignEdge) ? (alignEdge - 1.2) * 0.7 : (leftAlign - 1.2) * 0.7),
          Icons.star,
          0xFF66BB6A,
          selectedIcon == 1 ? iconSize * 1.2 : iconSize,
          selectedIcon == 1 ? containerSize * 1.2 : containerSize
      ),
      alignIcon(
          Alignment(leftAlign <= (alignEdge) ? alignEdge : leftAlign, 0),
          Icons.favorite_border,
          0xFFFFC107,
          selectedIcon == 2 ? iconSize * 1.2 : iconSize,
          selectedIcon == 2 ? containerSize * 1.2 : containerSize
      ),
      alignIcon(
          Alignment(leftAlign <= (alignEdge) ? alignEdge : leftAlign, leftAlign <= (alignEdge) ? -(alignEdge - 1.2) * 0.7 : -(leftAlign - 1.2) * 0.7),
          Icons.mail_outline_rounded,
          0xFFA1887F,
          selectedIcon == 3 ? iconSize * 1.2 : iconSize,
          selectedIcon == 3 ? containerSize * 1.2 : containerSize
      ),
    ]);
  }

  Widget alignIcon(AlignmentGeometry alignmentWidget, IconData icon, int color, double iconSize, double containerSize) {
    return Align(
      alignment: alignmentWidget,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(
              alignment.x.abs() >= stopEdge ? 1 : alignment.x.abs() / 2),
          border: Border.all(
              color: Color(color).withOpacity(
                  alignment.x.abs() >= stopEdge ? 1 : alignment.x.abs() / 2),
              width: 4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Color(color).withOpacity(
              alignment.x.abs() >= stopEdge ? 1 : alignment.x.abs() / 2),
          size: iconSize,
        ),
        width: containerSize,
        height: containerSize,
      ),
    );
  }

  void animateCards(Direction direc, {double leftAlign, double rightAlign}) {
    animationController.value = 0.0;
    animationController.forward().whenComplete(() {

      print(animationController.status);
      // print('completed');
      if (leftAlign != null && rightAlign != null){
        if ( leftAlign <= (alignEdge) || rightAlign >= (-alignEdge)) {
          // print('next');
          // setState(() {
          //   cardStack = cardStack.sublist(1, cardStack.length);
          // });
        } else {
          selectedIcon = -1;
        }
      }
    });
    direction = direc;
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
          ? (beginAlign.x > swipeEdge ? beginAlign.x + 10.0 : baseAlign.x)
          : (beginAlign.x < -swipeEdge ? beginAlign.x - 10.0 : baseAlign.x);
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