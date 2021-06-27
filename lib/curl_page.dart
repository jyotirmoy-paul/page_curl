import 'dart:async';

import 'package:curl_page/model/touch_event.dart';
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
  final StreamController<TouchEvent> _touchEventController = StreamController();
  final _boundaryKey = GlobalKey();
  ui.Image _image;

  Stream<TouchEvent> _touchEventStream;

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
    _touchEventStream = _touchEventController.stream;
  }

  @override
  void dispose() {
    _touchEventController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_image != null)
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (_) {
          _touchEventController.add(TouchEvent(TouchEventType.END, null));
        },
        onVerticalDragStart: (DragStartDetails dsd) {
          _touchEventController
              .add(TouchEvent(TouchEventType.START, dsd.localPosition));
        },
        onVerticalDragUpdate: (DragUpdateDetails dud) {
          _touchEventController.add(
            TouchEvent(TouchEventType.MOVE, dud.localPosition),
          );
        },
        child: StreamBuilder<TouchEvent>(
          stream: _touchEventStream,
          initialData: TouchEvent.empty(),
          builder: (_, tes) => CustomPaint(
            painter: CurlPagePainter(
              touchEvent: tes.data,
              image: _image,
            ),
          ),
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
  TouchEvent touchEvent;

  CurlPagePainter({
    @required this.image,
    @required this.touchEvent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final ip = Paint();

    print('touchEvent: ${touchEvent.getEvent()}');

    canvas.drawImage(image, Offset.zero, ip);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
