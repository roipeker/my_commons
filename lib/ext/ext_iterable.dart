extension IterableExt<E> on List<E> {
  /// Takes an action for each element.
  ///
  /// Calls [action] for each element along with the index in the
  /// iteration order.
  void forEachIndexed(void Function(int index, E element) action) {
    var index = 0;
    for (var element in this) {
      action(index++, element);
    }
  }

  List<R> mapIndexed2<R>(R Function(int index, E element) convert,
      {bool growable = false}) {
    return mapIndexed(convert).toList(growable: growable);
  }

  Iterable<R> mapIndexed<R>(R Function(int index, E element) convert) sync* {
    for (var index = 0; index < length; index++) {
      yield convert(index, this[index]);
    }
  }

  List<T> map2<T>(
    T Function(E e) toElement, {
    bool growable = false,
  }) =>
      map(toElement).toList(
        growable: growable,
      );

  /// The elements whose value and index satisfies [test].
  Iterable<E> whereIndexed(
    bool Function(int index, E element) test,
  ) sync* {
    for (var index = 0; index < length; index++) {
      var element = this[index];
      if (test(index, element)) yield element;
    }
  }

  List<E> where2(bool Function(E element) test, {bool growable = false}) {
    return where(test).toList(growable: growable);
  }

  List<E> sorted(Comparator<E> compare) {
    return [...this]..sort(compare);
  }

  Iterable<R> expandIndexed<R>(
    Iterable<R> Function(int index, E element) expand,
  ) sync* {
    for (var index = 0; index < length; index++) {
      yield* expand(index, this[index]);
    }
  }

  List<R> expandIndexed2<R>(
    Iterable<R> Function(int index, E element) expand, {
    bool growable = false,
  }) {
    return expandIndexed(expand).toList(growable: growable);
  }
}
