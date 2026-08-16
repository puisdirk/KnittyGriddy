import 'package:fleather/fleather.dart';

// The default indent is limited to 8. We want unlimited
extension CustomIndentAttributeBuilder on IndentAttributeBuilder {
  ParchmentAttribute<int> withInfiniteLevel(int level) {
    if (level == 0) {
      return unset;
    }
    return ParchmentAttribute.indent.withValue(level);
  }
}