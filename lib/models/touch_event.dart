import 'dart:ui';

enum TouchEventType { END, START, MOVE }

class TouchEvent {
  TouchEventType _eventType;
  Offset _offset;

  TouchEvent(this._eventType, this._offset);

  TouchEventType getEvent() => _eventType;

  double getX() => _offset.dx;
  double getY() => _offset.dy;
}
