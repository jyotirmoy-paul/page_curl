import 'package:flutter/material.dart';

enum TouchEventType { END, START, MOVE, NO }

class TouchEvent {
  TouchEventType _eventType;
  Offset _localOffset;

  TouchEvent(this._eventType, this._localOffset);

  TouchEvent.empty() {
    this._eventType = TouchEventType.NO;
  }

  TouchEventType getEvent() => _eventType;

  double getX() => _localOffset.dx;
  double getY() => _localOffset.dy;
}
