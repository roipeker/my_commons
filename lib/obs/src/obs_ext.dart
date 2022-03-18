part of obs;

extension ObsTExt<T> on T {
  ObsValue<T> obs({
    ValueChanged<T>? onChange,
    ObsMixin? vsync,
  }) {
    final o = ObsValue(this, vsync);
    if (onChange != null) {
      o.addEventListener(onChange);
    }
    return o;
  }
}

/// --- reactive types.

extension ObsValueBoolExt on ObsValue<bool> {
  bool get isTrue => value;

  bool get isFalse => !isTrue;

  void toggle() => value = !value;
}

extension ObsStringExt on String {
  ObsValue<String> obs({
    ValueChanged<String>? onChange,
    ObsMixin? vsync,
  }) {
    final o = ObsValue(this, vsync);
    if (onChange != null) {
      o.addEventListener(onChange);
    }
    return o;
  }
}

