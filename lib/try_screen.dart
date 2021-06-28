import 'package:flutter/material.dart';

class TryScreen extends StatelessWidget {
  Widget _buildChild(String text, {Color color = Colors.teal}) => Container(
        width: 200,
        height: 200,
        alignment: Alignment.center,
        color: color,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      );

  Matrix4 getMatrix() {
    return Matrix4(
      1, 1, 0, 0, //
      0, 1, 0, 0, //
      0, 0, 1, 0, //
      0, 0, 0, 1, //
    );
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: getMatrix(),
      child: _buildChild("Begu, this is me"),
    );
  }
}
