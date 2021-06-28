import 'dart:async';

import 'package:curl_page/curl_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
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
  // final _bKey = GlobalKey();
  // ui.Image _frontImage;
  // ui.Image _backImage;

  // void _captureImage(Duration _) async {
  //   final pixelRatio = MediaQuery.of(context).devicePixelRatio;

  //   final b = _bKey.currentContext.findRenderObject() as RenderRepaintBoundary;

  //   if (b.debugNeedsPaint) {
  //     await Future.delayed(const Duration(milliseconds: 20));
  //     return _captureImage(_);
  //   }

  //   final image = await b.toImage(pixelRatio: pixelRatio);

  //   if (_backImage == null)
  //     setState(() => _backImage = image);
  //   else
  //     setState(() => _frontImage = image);
  // }

  Widget _buildWidget(Widget child) {
    if (widget.vertical)
      child = Transform.rotate(
        angle: -math.pi / 2,
        child: child,
      );

    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: RepaintBoundary(child: child),
    );
  }

  // void capture() {
  //   WidgetsBinding.instance.addPostFrameCallback(_captureImage);
  // }

  @override
  Widget build(BuildContext context) {
    // /* show back widget if not captured already */
    // if (_backImage == null) {
    //   capture();
    //   return _buildWidget(widget.back);
    // }

    // /* back widget is captured by now */

    // /* show front widget if not captured already */
    // if (_frontImage == null) {
    //   capture();
    //   return _buildWidget(widget.front);
    // }

    /* both, front and back widgets are captured by now */
    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: Transform.rotate(
        angle: widget.vertical ? math.pi / 2 : 0,
        child: CurlEffect(
          // frontImage: _frontImage,
          // backImage: _backImage,
          frontWidget: _buildWidget(widget.front),
          backWidget: _buildWidget(widget.back),
          size: widget.size,
        ),
      ),
    );
  }
}
