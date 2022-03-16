import 'package:flutter/material.dart';
class RoundIconButton extends StatelessWidget {

  final IconData iconData;
  final Function() onTap;
  final Function(LongPressStartDetails)? onLongPressStart;
  final Function(LongPressEndDetails)? onLongPressEnd;

  RoundIconButton({required this.iconData, required this.onTap, this.onLongPressStart, this.onLongPressEnd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: onLongPressStart,
      onLongPressEnd: onLongPressEnd,
      child: RawMaterialButton(
        onPressed: onTap,
        child: Icon(iconData),
        elevation: 6,
        constraints: BoxConstraints.tightFor(
          width: 75,
          height: 75
        ),
        shape: CircleBorder(),
        fillColor: Colors.white70//Color(0xFF4C4F5E)
      ),
    );
  }
}