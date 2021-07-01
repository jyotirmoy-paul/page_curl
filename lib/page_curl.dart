import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:page_curl/widgets/curl_widget.dart';

class PageCurl extends StatefulWidget {
  final Widget back;
  final Widget front;
  final Size size;
  final bool vertical;
  final bool debugging;

  PageCurl({
    Key key,
    @required this.back,
    @required this.front,
    @required this.size,
    this.vertical = false,
    this.debugging = false,
  }) : super(key: key) {
    assert(back != null && front != null && size != null);
  }

  @override
  _PageCurlState createState() => _PageCurlState();
}

class _PageCurlState extends State<PageCurl> {
  bool get debugging => widget.debugging ?? false;

  double get width => widget.size.width;
  double get height => widget.size.height;

  double get aspectRatio => width / height;

  Widget _buildWidget(Widget child) => Transform.rotate(
        angle: pi / 2,
        child: SizedBox(
          width: width,
          height: height,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(
              1.0 / aspectRatio,
              aspectRatio,
              1.0,
            ),
            child: child,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          aspectRatio,
          1.0 / aspectRatio,
          1.0,
        ),
        child: Transform.rotate(
          angle: pi / 2,
          child: Container(
            height: height,
            width: width,
            child: CurlWidget(
              frontWidget: _buildWidget(widget.front),
              backWidget: _buildWidget(widget.back),
              size: widget.size,
              vertical: widget.vertical ?? false,
              debugging: debugging,
            ),
          ),
        ),
      );
}
