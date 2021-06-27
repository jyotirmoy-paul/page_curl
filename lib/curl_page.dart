import 'dart:async';

import 'package:curl_page/curl_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

class CurlPage extends StatefulWidget {
  final Widget back;
  final Widget front;
  final Size size;

  CurlPage({
    @required this.back,
    @required this.front,
    @required this.size,
  }) : assert(back != null && front != null && size != null);

  @override
  _CurlPageState createState() => _CurlPageState();
}

class _CurlPageState extends State<CurlPage> {
  final _bKey = GlobalKey();
  ui.Image _image;

  void _captureImage(Duration _) async {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    final b = _bKey.currentContext.findRenderObject() as RenderRepaintBoundary;
    if (b.debugNeedsPaint) {
      await Future.delayed(const Duration(milliseconds: 20));
      return _captureImage(_);
    }

    final image = await b.toImage(pixelRatio: pixelRatio);
    setState(() => _image = image);
  }

  @override
  Widget build(BuildContext context) {
    if (_image != null)
      return CurlEffect(
        image: _image,
        size: widget.size,
      );

    WidgetsBinding.instance.addPostFrameCallback(_captureImage);

    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: RepaintBoundary(key: _bKey, child: widget.front),
    );
  }
}
