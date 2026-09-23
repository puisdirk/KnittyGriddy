
import 'dart:math';
import 'dart:ui';

extension RectEx on Rect {
  Rect naturalize() {
    if (height < 0) {
      return Rect.fromLTRB(left, bottom, right, top);
    }
    return this;
  }
}