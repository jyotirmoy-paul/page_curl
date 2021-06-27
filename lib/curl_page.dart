import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

class CurlPage extends StatefulWidget {
  final Widget back;
  final Widget front;

  CurlPage({
    this.back,
    this.front,
  });

  @override
  _CurlPageState createState() => _CurlPageState();
}

class _CurlPageState extends State<CurlPage> {
  final _boundaryKey = GlobalKey();

  ui.Image _image;

  // @override
  // void didUpdateWidget(CurlPage oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (oldWidget.front != widget.front) {
  //     _image = null;
  //   }
  // }

  void init() {}

  void _captureImage(Duration _) async {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final boundary =
        _boundaryKey.currentContext.findRenderObject() as RenderRepaintBoundary;
    if (boundary.debugNeedsPaint) {
      await Future.delayed(const Duration(milliseconds: 20));
      return _captureImage(_);
    }
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    setState(() => _image = image);
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    if (_image != null)
      return CustomPaint(
        painter: CurlPagePainter(
          image: _image,
        ),
      );

    WidgetsBinding.instance.addPostFrameCallback(_captureImage);
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: constraints.biggest.width,
        height: constraints.biggest.height,
        child: RepaintBoundary(
          key: _boundaryKey,
          child: widget.front,
        ),
      ),
    );
  }
}

class CurlPagePainter extends CustomPainter {
  ui.Image image;

  CurlPagePainter({
    this.image,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final ip = Paint();

    canvas.drawImage(image, Offset.zero, ip);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
