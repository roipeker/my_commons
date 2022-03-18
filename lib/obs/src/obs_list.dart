part of obs;

/// Extend [ObsValue]<List> to forward List methods.
/// The idea is to create a reactive List representation.
/// instead of reassign the [ObsValue.value] property.
extension ObsListExt<E> on ObsValue<List<E>> {
  E operator [](int index) => value[index];

  Iterator<E> get iterator => value.iterator;

  ObsValue<List<E>> operator +(Iterable<E> val) {
    addAll(val);
    notify();
    return this;
  }

  void operator []=(int index, E val) {
    value[index] = val;
    notify();
  }

  void clear() {
    value.clear();
    notify();
  }

  void add(E val) {
    value.add(val);
    notify();
  }

  void addAll(Iterable<E> item) {
    value.addAll(item);
    notify();
  }

  void removeWhere(bool Function(E element) test) {
    value.removeWhere(test);
    notify();
  }

  void retainWhere(bool Function(E element) test) {
    value.retainWhere(test);
    notify();
  }

  bool get isEmpty => value.isEmpty;

  bool get isNotEmpty => value.isNotEmpty;

  int get length => value.length;

  set length(int newLength) {
    value.length = newLength;
    notify();
  }

  void insertAll(int index, Iterable<E> iterable) {
    value.insertAll(index, iterable);
    notify();
  }

  Iterable<E> get reversed => value.reversed;

  Iterable<E> where(bool Function(E) test) {
    return value.where(test);
  }

  Iterable<T> whereType<T>() {
    return value.whereType<T>();
  }

  void sort([int Function(E a, E b)? compare]) {
    value.sort(compare);
    notify();
  }

  set first(E val) {
    value.first = val;
    notify();
  }

  set last(E val) {
    value.last = val;
    notify();
  }

  E get last => value.last;

  E get first => value.first;

  List<E> sublist(int start, [int? end]) {
    return value.sublist(start, end);
  }

  Iterable<E> getRange(int start, int end) {
    return value.getRange(start, end);
  }

  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    value.setRange(start, end, iterable, skipCount);
    notify();
  }

  void removeRange(int start, int end) {
    value.removeRange(start, end);
    notify();
  }

  void fillRange(int start, int end, [E? fillValue]) {
    value.fillRange(start, end, fillValue);
    notify();
  }

  void replaceRange(int start, int end, Iterable<E> replacements) {
    value.replaceRange(start, end, replacements);
    notify();
  }

  Map<int, E> asMap() => value.asMap();

  Iterable<R> mapIndexed<R>(R Function(int index, E element) convert) {
    return value.mapIndexed(convert);
  }

  void forEachIndexed(void Function(int index, E element) action) {
    value.forEachIndexed(action);
  }

  Iterable<T> expand<T>(Iterable<T> Function(E element) toElements) =>
      value.expand(toElements);

  Iterable<R> expandIndexed<R>(
      Iterable<R> Function(int index, E element) expand) {
    return value.expandIndexed(expand);
  }

  bool isLastIndex(int index) {
    if (index >= value.length - 1) {
      return true;
    }
    return false;
  }

// bool operator ==(Object other) {
//   return this.value == other;
// }
}
