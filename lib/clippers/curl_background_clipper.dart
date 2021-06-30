import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:page_curl/models/vector_2d.dart';

class CurlBackgroundClipper extends CustomClipper<Path> {
  final Vector2D mA, mD, mE, mF, mM, mN, mP;

  CurlBackgroundClipper({
    @required this.mA,
    @required this.mD,
    @required this.mE,
    @required this.mF,
    @required this.mM,
    @required this.mN,
    @required this.mP,
  });

  Path createBackgroundPath() {
    Path path = Path();

    path.moveTo(mM.x, mM.y);
    path.lineTo(mP.x, mP.y);
    path.lineTo(mD.x, math.max(0, mD.y));
    path.lineTo(mA.x, mA.y);
    path.lineTo(mN.x, mN.y);
    if (mF.x < 0) path.lineTo(mF.x, mF.y);
    path.lineTo(mM.x, mM.y);

    return path;
  }

  @override
  Path getClip(Size size) {
    return createBackgroundPath();
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return true;
  }
}
