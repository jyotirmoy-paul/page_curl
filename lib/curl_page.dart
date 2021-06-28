import 'package:curl_page/curl_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

class CurlPage extends StatefulWidget {
  final Widget back;
  final Widget front;
  final Size size;
  final bool vertical;

  CurlPage({
    @required this.back,
    @required this.front,
    @required this.size,
    this.vertical = false,
  }) : assert(back != null && front != null && size != null);

  @override
  _CurlPageState createState() => _CurlPageState();
}

class _CurlPageState extends State<CurlPage> {
  Widget _buildWidget(Widget child, {bool isBack = false}) {
    if (widget.vertical)
      child = Transform.rotate(
        angle: isBack ? math.pi / 2 : -math.pi / 2,
        child: child,
      );

    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: RepaintBoundary(child: child),
    );
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.size.width,
        height: widget.size.height,
        child: Transform.rotate(
          angle: widget.vertical ? math.pi / 2 : 0,
          child: CurlEffect(
            frontWidget: _buildWidget(widget.front),
            backWidget: _buildWidget(widget.back, isBack: true),
            size: widget.size,
          ),
        ),
      );
}
