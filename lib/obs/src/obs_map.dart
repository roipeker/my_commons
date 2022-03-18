part of obs;

/// Extend ObsValue<Map> to forward basic Map operations.
/// The idea is to create a reactive Map representation
/// instead of reassign the [ObsValue.value] property.
extension ObsMapExt<K, V> on ObsValue<Map<K, V>> {
  /// add features.
  V? operator [](Object? key) => value[key];

  void operator []=(K key, V val) {
    value[key] = val;
    notify();
  }
  void clear() {
    value.clear();
    notify();
  }

  Iterable<K> get keys => value.keys;

  V? remove(Object? key) {
    final val = value.remove(key);
    notify();
    return val;
  }

}
