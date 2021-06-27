import 'package:flutter/material.dart';

enum TouchEventType { END, START, MOVE }

class TouchEvent {
  TouchEventType _eventType;
  Offset _localOffset;

  TouchEvent(this._eventType, this._localOffset);

  TouchEventType getEvent() => _eventType;

  double getX() => _localOffset.dx;
  double getY() => _localOffset.dy;
}
