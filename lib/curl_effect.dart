import 'package:curl_page/model/touch_event.dart';
import 'package:curl_page/model/vector_2d.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class CurlEffect extends StatefulWidget {
  final ui.Image image;

  CurlEffect({
    this.image,
  });

  @override
  _CurlEffectState createState() => _CurlEffectState();
}

class _CurlEffectState extends State<CurlEffect> {
  /* variables that controls drag and updates */

  /* px / draw call */
  int mCurlSpeed = 62;

  /* fixed update time used to create a smooth curl animation */
  int mUpdateRate;

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

  /* ff false no draw call has been done */
  bool bViewDrawn;

  /* defines the flip direction that is currently considered */
  bool bFlipRight;

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

    mD.y = height - (bh / _sin);
    mD.x = width.toDouble();

    mA.x = math.max(0, mA.x);
    if (mA.x == 0) {
      mOldF.x = mF.x;
      mOldF.y = mF.y;
    }

    // Get W
    mE.x = mD.x;
    mE.y = mD.y;

    // Correct
    if (mD.y < 0) {
      mD.x = width + tangAlpha * mD.y;
      mE.y = 0;
      mE.x = width + math.tan(2 * alpha) * mD.y;
    }
  }

  double getWidth() => widget.image.height.toDouble();

  double getHeight() => widget.image.width.toDouble();

  void resetClipEdge() {
    // set base movement
    mMovement.x = mInitialEdgeOffset.toDouble();
    mMovement.y = mInitialEdgeOffset.toDouble();
    mOldMovement.x = 0;
    mOldMovement.y = 0;

    mA = new Vector2D(0, 0);
    mB = new Vector2D(this.getWidth(), this.getHeight());
    mC = new Vector2D(this.getWidth(), 0);
    mD = new Vector2D(0, 0);
    mE = new Vector2D(0, 0);
    mF = new Vector2D(0, 0);
    mOldF = new Vector2D(0, 0);

    // The movement origin point
    mOrigin = new Vector2D(this.getWidth(), 0);
  }

  void resetMovement() {
    if (!bFlipping) return;

    // No input when flipping
    bBlockTouchInput = true;

    double curlSpeed = mCurlSpeed.toDouble();
    if (!bFlipRight) curlSpeed *= -1;

    mMovement.x += curlSpeed;
    mMovement = capMovement(mMovement, false);

    resetClipEdge();
    doPageCurl();

    bUserMoves = true;
    bBlockTouchInput = false;
    bFlipping = false;
    bEnableInputAfterDraw = true;

    // TODO: how to force a new draw?
    setState(() {});
  }

  void handleTouchInput(TouchEvent touchEvent) {
    if (bBlockTouchInput) return;

    // get finger position
    mFinger.x = touchEvent.getX();
    mFinger.y = touchEvent.getY();

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

        // Get movement
        mMovement.x -= mFinger.x - mOldMovement.x;
        mMovement.y -= mFinger.y - mOldMovement.y;
        mMovement = capMovement(mMovement, true);

        // make sure the y value get's locked at a nice level
        if (mMovement.y <= 1) mMovement.y = 1;

        // save old movement values
        mOldMovement.x = mFinger.x;
        mOldMovement.y = mFinger.y;

        doPageCurl();

        // TODO: how to force a new draw?
        setState(() {});
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragEnd: (_) {
        handleTouchInput(TouchEvent(TouchEventType.END, null));
      },
      onVerticalDragStart: (DragStartDetails dsd) {
        handleTouchInput(TouchEvent(TouchEventType.START, dsd.localPosition));
      },
      onVerticalDragUpdate: (DragUpdateDetails dud) {
        handleTouchInput(
          TouchEvent(TouchEventType.MOVE, dud.localPosition),
        );
      },
      child: CustomPaint(
        painter: CurlPagePainter(
          image: widget.image,
        ),
      ),
    );
  }
}

class CurlPagePainter extends CustomPainter {
  ui.Image image;

  CurlPagePainter({
    @required this.image,
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
