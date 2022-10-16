import 'package:flutter/material.dart';
import 'package:page_curl/clippers/curl_background_clipper.dart';
import 'package:page_curl/clippers/curl_backside_clipper.dart';
import 'package:page_curl/models/touch_event.dart';
import 'dart:math' as math;

import 'package:page_curl/models/vector_2d.dart';
import 'package:page_curl/painters/curl_shadow_painter.dart';

class CurlWidget extends StatefulWidget {
  final Widget frontWidget;
  final Widget backWidget;
  final Size size;
  final bool vertical;
  final bool debugging;

  CurlWidget({
    required this.frontWidget,
    required this.backWidget,
    required this.size,
    required this.vertical,
    this.debugging = false,
  });

  @override
  _CurlWidgetState createState() => _CurlWidgetState();
}

class _CurlWidgetState extends State<CurlWidget> {
  bool get debugging => widget.debugging;
  bool get isVertical => false;

  /* variables that controls drag and updates */

  /* px / draw call */
  int mCurlSpeed = 60;

  /* The initial offset for x and y axis movements */
  late int mInitialEdgeOffset;

  /* Maximum radius a page can be flipped, by default it's the width of the view */
  late double mFlipRadius;

  /* pointer used to move */
  late Vector2D mMovement;

  /* finger position */
  late Vector2D mFinger;

  /* movement pointer from the last frame */
  late Vector2D mOldMovement;

  /* paint curl edge */
  late Paint curlEdgePaint;

  /* vector points used to define current clipping paths */
  late Vector2D mA, mB, mC, mD, mE, mF, mOldF, mOrigin;

  /* vectors that are corners of the entire polygon */
  late Vector2D mM, mN, mO, mP;

  /* ff false no draw call has been done */
  late bool bViewDrawn;

  /* if TRUE we are currently auto-flipping */
  late bool bFlipping;

  /* tRUE if the user moves the pages */
  late bool bUserMoves;

  /* used to control touch input blocking */
  bool bBlockTouchInput = false;

  /* enable input after the next draw event */
  bool bEnableInputAfterDraw = false;

  double abs(double value) {
    if (value < 0) return value * -1;
    return value;
  }

  Vector2D capMovement(Vector2D point, bool bMaintainMoveDir) {
    // make sure we never ever move too much
    if (point.distance(mOrigin) > mFlipRadius) {
      if (bMaintainMoveDir) {
        // maintain the direction
        point = mOrigin.sum(point.sub(mOrigin).normalize().mult(mFlipRadius));
      } else {
        // change direction
        if (point.x > (mOrigin.x + mFlipRadius))
          point.x = (mOrigin.x + mFlipRadius);
        else if (point.x < (mOrigin.x - mFlipRadius))
          point.x = (mOrigin.x - mFlipRadius);
        point.y = math.sin(math.acos(abs(point.x - mOrigin.x) / mFlipRadius)) *
            mFlipRadius;
      }
    }
    return point;
  }

  void doPageCurl() {
    int w = width.toInt();
    int h = height.toInt();

    // F will follow the finger, we add a small displacement
    // So that we can see the edge
    mF.x = w - mMovement.x + 0.1;
    mF.y = h - mMovement.y + 0.1;

    // Set min points
    if (mA.x == 0) {
      mF.x = math.min(mF.x, mOldF.x);
      mF.y = math.max(mF.y, mOldF.y);
    }

    // Get diffs
    double deltaX = w - mF.x;
    double deltaY = h - mF.y;

    double bh = math.sqrt(deltaX * deltaX + deltaY * deltaY) / 2;
    double tangAlpha = deltaY / deltaX;
    double alpha = math.atan(deltaY / deltaX);
    double _cos = math.cos(alpha);
    double _sin = math.sin(alpha);

    mA.x = w - (bh / _cos);
    mA.y = h.toDouble();

    mD.x = w.toDouble();
    // bound mD.y
    mD.y = math.min(h - (bh / _sin), height);

    mA.x = math.max(0, mA.x);
    if (mA.x == 0) {
      mOldF.x = mF.x;
      mOldF.y = mF.y;
    }

    // Get W
    mE.x = mD.x;
    mE.y = mD.y;

    // bouding corrections
    if (mD.y < 0) {
      mD.x = w + tangAlpha * mD.y;

      mE.x = w + math.tan(2 * alpha) * mD.y;

      // modify mD to create newmD by cleaning y value
      Vector2D newmD = Vector2D(mD.x, 0);
      double l = w - newmD.x;

      mE.y = -math.sqrt(abs(math.pow(l, 2).toDouble() -
          math.pow((newmD.x - mE.x), 2).toDouble()));
    }
  }

  double get aspectRatio => width / height;

  double get width => widget.size.width;

  double get height => widget.size.height;

  void resetClipEdge() {
    // set base movement
    mMovement.x = mInitialEdgeOffset.toDouble();
    mMovement.y = mInitialEdgeOffset.toDouble();
    mOldMovement.x = 0;
    mOldMovement.y = 0;

    mA = Vector2D(0, 0);
    mB = Vector2D(width, height);
    mC = Vector2D(width, 0);
    mD = Vector2D(0, 0);
    mE = Vector2D(0, 0);
    mF = Vector2D(0, 0);
    mOldF = Vector2D(0, 0);

    // The movement origin point
    mOrigin = Vector2D(width, 0);
  }

  void resetMovement() {
    if (!bFlipping) return;

    // No input when flipping
    bBlockTouchInput = true;

    double curlSpeed = mCurlSpeed.toDouble();
    curlSpeed *= -1;

    mMovement.x += curlSpeed;
    mMovement = capMovement(mMovement, false);

    resetClipEdge();
    doPageCurl();

    bUserMoves = true;
    bBlockTouchInput = false;
    bFlipping = false;
    bEnableInputAfterDraw = true;

    setState(() {});
  }

  void handleTouchInput(TouchEvent touchEvent) {
    if (bBlockTouchInput) return;

    if (touchEvent.getEvent() != TouchEventType.END) {
      // get finger position if NOT TouchEventType.END
      mFinger.x = touchEvent.getX()!;
      mFinger.y = touchEvent.getY()!;
    }

    switch (touchEvent.getEvent()) {
      case TouchEventType.END:
        bUserMoves = false;
        bFlipping = true;
        resetMovement();
        break;

      case TouchEventType.START:
        mOldMovement.x = mFinger.x;
        mOldMovement.y = mFinger.y;
        break;

      case TouchEventType.MOVE:
        bUserMoves = true;

        // get movement
        mMovement.x -= mFinger.x - mOldMovement.x;
        mMovement.y -= mFinger.y - mOldMovement.y;
        mMovement = capMovement(mMovement, true);

        // make sure the y value get's locked at a nice level
        if (mMovement.y <= 1) mMovement.y = 1;

        // save old movement values
        mOldMovement.x = mFinger.x;
        mOldMovement.y = mFinger.y;

        doPageCurl();

        setState(() {});
        break;
    }
  }

  void init() {
    // init main variables
    mM = Vector2D(0, 0);
    mN = Vector2D(0, height);
    mO = Vector2D(width, height);
    mP = Vector2D(width, 0);

    mMovement = Vector2D(0, 0);
    mFinger = Vector2D(0, 0);
    mOldMovement = Vector2D(0, 0);

    // create the edge paint
    curlEdgePaint = Paint();
    curlEdgePaint.isAntiAlias = true;
    curlEdgePaint.color = Colors.white;
    curlEdgePaint.style = PaintingStyle.fill;

    // mUpdateRate = 1;
    mInitialEdgeOffset = 0;

    // other initializations
    mFlipRadius = width;

    resetClipEdge();
    doPageCurl();
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  Widget boundingBox({required Widget child}) => child;

  double getAngle() {
    double displaceInX = mA.x - mF.x;
    if (displaceInX == 149.99998333333335) displaceInX = 0;

    double displaceInY = height - mF.y;
    if (displaceInY < 0) displaceInY = 0;

    double angle = math.atan(displaceInY / displaceInX);
    if (angle.isNaN) angle = 0.0;

    if (angle < 0) angle = angle + math.pi;

    return angle;
  }

  Offset getOffset() {
    double xOffset = mF.x;
    double yOffset = -abs(height - mF.y);

    return Offset(xOffset, yOffset);
  }

  void onDragCallback(final details) {
    if (details is DragStartDetails) {
      handleTouchInput(TouchEvent(TouchEventType.START, details.localPosition));
    }

    if (details is DragEndDetails) {
      handleTouchInput(TouchEvent(TouchEventType.END, null));
    }

    if (details is DragUpdateDetails) {
      handleTouchInput(TouchEvent(TouchEventType.MOVE, details.localPosition));
    }
  }

  // Widget _buildPoint(Vector2D p, String name) => Positioned(
  //       left: p.x,
  //       top: p.y,
  //       child: Container(
  //         decoration: BoxDecoration(
  //           color: Colors.black,
  //           shape: BoxShape.circle,
  //         ),
  //         padding: const EdgeInsets.all(5.0),
  //         child: Text(name, style: TextStyle(fontSize: 15.0)),
  //       ),
  //     );

  // List<Widget> _buildDebugWidgets() {
  //   if (debugging == false) return [];

  //   return [
  //     _buildPoint(mA, 'A'),
  //     _buildPoint(mB, 'B'),
  //     _buildPoint(mC, 'C'),
  //     _buildPoint(mD, 'D'),
  //     _buildPoint(mE, 'E'),
  //     _buildPoint(mF, 'F'),
  //   ];
  // }

  double getRatio(double a, double x) => a * x + 1;

  Matrix4 getScaleMatrix() {
    // double dy = abs(height - mF.y);
    // double pertDy = dy / height;

    // double dx = abs(width - mF.x);
    // double pertDx = dx / width;

    // print('pertDx: $pertDx');

    /*
    transform: Matrix4.diagonal3Values(
              1.0 / aspectRatio,
              aspectRatio,
              1.0,
            ),
    */

    // return Matrix4.diagonal3Values(
    //   getRatio(aspectRatio, pertDx / pertDy),
    //   getRatio(1 / aspectRatio, pertDx / pertDy),
    //   1.0,
    // );

    return Matrix4.diagonal3Values(
      1.0,
      1.0,
      1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      /* drag start */
      onVerticalDragStart: isVertical ? onDragCallback : null,
      onHorizontalDragStart: isVertical ? null : onDragCallback,

      /* drag end */
      onVerticalDragEnd: isVertical ? onDragCallback : null,
      onHorizontalDragEnd: isVertical ? null : onDragCallback,

      /* drag update */
      onVerticalDragUpdate: isVertical ? onDragCallback : null,
      onHorizontalDragUpdate: isVertical ? null : onDragCallback,
      child: Stack(
        children: [
          // foreground image + custom painter for shadow
          ClipPath(
            clipper: CurlBackgroundClipper(
              mA: mA,
              mD: mD,
              mE: mE,
              mF: mF,
              mM: mM,
              mN: mN,
              mP: mP,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                widget.frontWidget,
                CustomPaint(
                  painter: CurlShadowPainter(mA: mA, mD: mD, mE: mE, mF: mF),
                ),
              ],
            ),
          ),

          // back side - widget
          Transform(
            transform: getScaleMatrix(),
            alignment: Alignment.center,
            child: ClipPath(
              clipper: CurlBackSideClipper(mA: mA, mD: mD, mE: mE, mF: mF),
              clipBehavior: Clip.antiAlias,
              child: Transform.translate(
                offset: getOffset(),
                child: Transform.rotate(
                  alignment: Alignment.bottomLeft,
                  angle: getAngle(),
                  child: widget.backWidget,
                ),
              ),
            ),
          ),

          /* build debug widgets */
          // ..._buildDebugWidgets(),
        ],
      ),
    );
  }
}
