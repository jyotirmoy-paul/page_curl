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

  CurlWidget({
    @required this.frontWidget,
    @required this.backWidget,
    @required this.size,
    @required this.vertical,
  });

  @override
  _CurlWidgetState createState() => _CurlWidgetState();
}

class _CurlWidgetState extends State<CurlWidget> {
  bool get isVertical => widget.vertical;

  /* variables that controls drag and updates */

  /* px / draw call */
  int mCurlSpeed = 60;

  /* The initial offset for x and y axis movements */
  int mInitialEdgeOffset;

  /* Maximum radius a page can be flipped, by default it's the width of the view */
  double mFlipRadius;

  /* pointer used to move */
  Vector2D mMovement;

  /* finger position */
  Vector2D mFinger;

  /* movement pointer from the last frame */
  Vector2D mOldMovement;

  /* paint curl edge */
  Paint curlEdgePaint;

  /* vector points used to define current clipping paths */
  Vector2D mA, mB, mC, mD, mE, mF, mOldF, mOrigin;

  /* vectors that are corners of the entire polygon */
  Vector2D mM, mN, mO, mP;

  /* ff false no draw call has been done */
  bool bViewDrawn;

  /* if TRUE we are currently auto-flipping */
  bool bFlipping;

  /* tRUE if the user moves the pages */
  bool bUserMoves;

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
    int width = getWidth().toInt();
    int height = getHeight().toInt();

    // F will follow the finger, we add a small displacement
    // So that we can see the edge
    mF.x = width - mMovement.x + 0.1;
    mF.y = height - mMovement.y + 0.1;

    // Set min points
    if (mA.x == 0) {
      mF.x = math.min(mF.x, mOldF.x);
      mF.y = math.max(mF.y, mOldF.y);
    }

    // Get diffs
    double deltaX = width - mF.x;
    double deltaY = height - mF.y;

    double bh = math.sqrt(deltaX * deltaX + deltaY * deltaY) / 2;
    double tangAlpha = deltaY / deltaX;
    double alpha = math.atan(deltaY / deltaX);
    double _cos = math.cos(alpha);
    double _sin = math.sin(alpha);

    mA.x = width - (bh / _cos);
    mA.y = height.toDouble();

    mD.x = width.toDouble();
    // bound mD.y
    mD.y = math.min(height - (bh / _sin), getHeight());

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
      mD.x = width + tangAlpha * mD.y;

      mE.x = width + math.tan(2 * alpha) * mD.y;

      // modify mD to create newmD by cleaning y value
      Vector2D newmD = Vector2D(mD.x, 0);
      double l = width - newmD.x;

      mE.y = -math.sqrt(abs(math.pow(l, 2) - math.pow((newmD.x - mE.x), 2)));
    }
  }

  double getWidth() => widget.size.width;

  double getHeight() => widget.size.height;

  void resetClipEdge() {
    // set base movement
    mMovement.x = mInitialEdgeOffset.toDouble();
    mMovement.y = mInitialEdgeOffset.toDouble();
    mOldMovement.x = 0;
    mOldMovement.y = 0;

    mA = Vector2D(0, 0);
    mB = Vector2D(getWidth(), getHeight());
    mC = Vector2D(getWidth(), 0);
    mD = Vector2D(0, 0);
    mE = Vector2D(0, 0);
    mF = Vector2D(0, 0);
    mOldF = Vector2D(0, 0);

    // The movement origin point
    mOrigin = Vector2D(getWidth(), 0);
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
      mFinger.x = touchEvent.getX();
      mFinger.y = touchEvent.getY();
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
    mN = Vector2D(0, getHeight());
    mO = Vector2D(getWidth(), getHeight());
    mP = Vector2D(getWidth(), 0);

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
    mFlipRadius = getWidth();

    resetClipEdge();
    doPageCurl();
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  Widget boundingBox({Widget child}) => SizedBox(
        width: getWidth(),
        height: getHeight(),
        child: child,
      );

  double getAngle() {
    double displaceInX = mA.x - mF.x;
    if (displaceInX == 149.99998333333335) displaceInX = 0;

    double displaceInY = getHeight() - mF.y;
    if (displaceInY < 0) displaceInY = 0;

    double angle = math.atan(displaceInY / displaceInX);
    if (angle.isNaN) angle = 0.0;

    if (angle < 0) angle = angle + math.pi;

    return angle;
  }

  Offset getOffset() {
    double xOffset = mF.x;
    double yOffset = -abs(getHeight() - mF.y);

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
        alignment: Alignment.center,
        children: [
          // foreground image + custom painter for shadow
          boundingBox(
            child: ClipPath(
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
          ),

          // back side - widget
          boundingBox(
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
        ],
      ),
    );
  }
}
