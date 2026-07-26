
abstract class SameAs {
  bool isSameAs(Object other);
}

class CollectionUtilities {

  static bool listSameAs<T extends SameAs>(List<T>? a, List<T>? b) {
    if (a == null) return false;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for(int index = 0; index < a.length; index += 1) {
      if (!a[index].isSameAs(b[index])) {
        return false;
      }
    }
    return true;
  }
}