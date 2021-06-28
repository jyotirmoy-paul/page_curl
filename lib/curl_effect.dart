import 'package:curl_page/model/touch_event.dart';
import 'package:curl_page/model/vector_2d.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class CurlEffect extends StatefulWidget {
  final ui.Image frontImage;
  final ui.Image backImage;
  final Size size;

  CurlEffect({
    @required this.frontImage,
    @required this.backImage,
    @required this.size,
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

    mA = new Vector2D(0, 0);
    mB = new Vector2D(getWidth(), getHeight());
    mC = new Vector2D(getWidth(), 0);
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

  double convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }

  void init() {
    // init main variables

    mMovement = Vector2D(0, 0);
    mFinger = Vector2D(0, 0);
    mOldMovement = Vector2D(0, 0);

    // create the edge paint
    curlEdgePaint = Paint();
    curlEdgePaint.isAntiAlias = true;
    curlEdgePaint.color = Colors.white;
    curlEdgePaint.style = PaintingStyle.fill;

    mUpdateRate = 1;
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

  double getDisplacementAngle() {
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

  double getAngle() {
    return getDisplacementAngle();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (_) {
        handleTouchInput(TouchEvent(TouchEventType.END, null));
      },
      onHorizontalDragStart: (DragStartDetails dsd) {
        handleTouchInput(TouchEvent(TouchEventType.START, dsd.localPosition));
      },
      onHorizontalDragUpdate: (DragUpdateDetails dud) {
        handleTouchInput(
          TouchEvent(TouchEventType.MOVE, dud.localPosition),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // foreground - custom painter
          boundingBox(
            child: ClipPath(
              clipper: CurlBackgroundClipper(mA: mA, mD: mD, mE: mE, mF: mF),
              clipBehavior: Clip.antiAlias,
              child: CustomPaint(
                painter: CurlPagePainter(
                  frontImage: widget.frontImage,
                  backImage: widget.backImage,
                  mA: mA,
                  mD: mD,
                  mE: mE,
                  mF: mF,
                  mCurlEdgePaint: curlEdgePaint,
                ),
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
                  child: CustomPaint(
                    painter: ImagePainter(image: widget.backImage),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CurlBackSideClipper extends CustomClipper<Path> {
  final Vector2D mA, mD, mE, mF;

  CurlBackSideClipper({
    @required this.mA,
    @required this.mD,
    @required this.mE,
    @required this.mF,
  });

  Path createCurlEdgePath() {
    Path path = new Path();
    path.moveTo(mA.x, mA.y);
    path.lineTo(mD.x, math.max(0, mD.y));
    path.lineTo(mE.x, mE.y);
    path.lineTo(mF.x, mF.y);
    path.lineTo(mA.x, mA.y);

    return path;
  }

  @override
  Path getClip(Size size) {
    return createCurlEdgePath();
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return true;
  }
}

class CurlBackgroundClipper extends CustomClipper<Path> {
  final Vector2D mA, mD, mE, mF;

  CurlBackgroundClipper({
    @required this.mA,
    @required this.mD,
    @required this.mE,
    @required this.mF,
  });

  Path createBackgroundPath(Size size) {
    Path path = Path();

    path.moveTo(0, 0);
    if (mE.x != size.width)
      path.lineTo(mE.x, mE.y);
    else
      path.lineTo(size.width, 0);
    path.lineTo(mD.x, math.max(0, mD.y));
    path.lineTo(mA.x, mA.y);
    path.lineTo(0, size.height);
    if (mF.x < 0) path.lineTo(mF.x, mF.y);
    path.lineTo(0, 0);

    return path;
  }

  @override
  Path getClip(Size size) {
    return createBackgroundPath(size);
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return true;
  }
}

class CurlPagePainter extends CustomPainter {
  ui.Image frontImage;
  ui.Image backImage;
  Vector2D mA, mD, mE, mF;
  Paint mCurlEdgePaint;

  final Paint _paint = Paint();

  CurlPagePainter({
    @required this.frontImage,
    @required this.backImage,
    @required this.mA,
    @required this.mD,
    @required this.mE,
    @required this.mF,
    @required this.mCurlEdgePaint,
  });

  void drawForeground(Canvas canvas) {
    canvas.drawImage(frontImage, Offset.zero, _paint);
  }

  Path createCurlEdgePath() {
    Path path = new Path();
    path.moveTo(mA.x, mA.y);
    path.lineTo(mD.x, math.max(0, mD.y));
    path.lineTo(mE.x, mE.y);
    path.lineTo(mF.x, mF.y);
    path.lineTo(mA.x, mA.y);

    return path;
  }

  Path getShadowPath(int t) {
    Path path = new Path();
    path.moveTo(mA.x - t, mA.y);
    path.lineTo(mD.x, math.max(0, mD.y - t));
    path.lineTo(mE.x, mE.y - t);
    path.lineTo(mF.x - t, mF.y - t);
    path.moveTo(mA.x - t, mA.y);

    return path;
  }

  void drawCurlEdge(Canvas canvas) {
    // final Path path = createCurlEdgePath();

    if (mF.x != 0.0) {
      // only draw shadow when pulled
      final double shadowElev = 20.0;
      canvas.drawShadow(
        getShadowPath(shadowElev.toInt()),
        Colors.black,
        shadowElev,
        true,
      );
    }

    // canvas.clipPath(path);
    // // canvas.drawPath(path, mCurlEdgePaint);

    // // mCurlEdgePaint.blendMode = BlendMode.dstATop;
    // // canvas.drawImage(backImage, Offset.zero, mCurlEdgePaint);

    // // canvas.drawPicture()
    // canvas.drawPaint(mCurlEdgePaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawForeground(canvas);
    drawCurlEdge(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ImagePainter extends CustomPainter {
  ImagePainter({
    this.image,
  });

  final _paint = Paint();
  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
