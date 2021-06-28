import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

import 'package:page_curl/widgets/curl_widget.dart';

class PageCurl extends StatefulWidget {
  final Widget back;
  final Widget front;
  final Size size;
  final bool vertical;

  PageCurl({
    @required this.back,
    @required this.front,
    @required this.size,
    this.vertical = false,
  }) : assert(back != null && front != null && size != null);

  @override
  _PageCurlState createState() => _PageCurlState();
}

class _PageCurlState extends State<PageCurl> {
  double get width => widget.vertical ? widget.size.height : widget.size.width;
  double get height => widget.vertical ? widget.size.width : widget.size.height;

  Widget _buildWidget(Widget child, {bool isBack = false}) {
    if (widget.vertical)
      child = Transform.rotate(
        angle: isBack ? math.pi / 2 : -math.pi / 2,
        child: Transform.scale(
          scale: width / height,
          child: child,
        ),
      );

    return SizedBox(
      width: width,
      height: height,
      child: RepaintBoundary(child: child),
    );
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: height,
        child: Transform.rotate(
          angle: widget.vertical ? math.pi / 2 : 0,
          child: CurlWidget(
            frontWidget: _buildWidget(widget.front),
            backWidget: _buildWidget(widget.back, isBack: true),
            size: Size(width, height),
          ),
        ),
      );
}
