part of obs;

/// Shortcut for [ObsBuilder], only takes a builder. Detects any [ObsValue]
/// internally.
///
/// ```dart
/// final toggle = false.obs();
///
/// Obs(() => Switch( value: toggle(), onChanged: toggle );
///
/// ```
class Obs extends StatelessWidget {
  final Widget Function() builder;

  const Obs(this.builder, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ObsBuilder(
      builder: (_, __) => builder(),
    );
  }
}

/// Behaves like an AnimatedBuilder, but requires no value parameter.
/// Detects any [ObsValue] inside the [builder] method.
/// Throws if none is detected.
///
/// Warning: [ObsValue] needs to be CONSUMED inside the Function closure.
/// Using it as method obsValue(), or reading [ObsValue.value].
///
/// the value should NOT be modified during the build() cycle.
class ObsBuilder extends StatefulWidget {
  final TransitionBuilder builder;
  final Widget? child;

  const ObsBuilder({
    Key? key,
    this.child,
    required this.builder,
  }) : super(key: key);

  @override
  createState() => _ObsBuilderState();
}

class _ObsBuilderState extends State<ObsBuilder> {
  late final notifier = _ObsNotifier(update);

  void update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    // notifier.dispose();
    super.reassemble();
  }

  Widget notifyChild(BuildContext context, Widget? child) {
    final prev = ObsValue._proxy;
    ObsValue._proxy = notifier;
    final result = widget.builder(context, child);
    ObsValue._proxy = prev;
    if (!notifier.canUpdate) {
      throw """
      [ObsValue] improper use of Obs() or ObsBuilder() detected.
      Use [ObsValue](s) directly in the scope of the builder().
      If you need to update a parent widget and a child widget, wrap them separately in Obs() or ObsBuilder().
      """;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: notifier.listenable,
      builder: notifyChild,
      child: widget.child,
    );
  }
}

/// This mixin can be applied to any [State].
/// Keeps an internal registry of all [ObsValue] properties to be automatically
/// disposed when the Widget is unmounted.
///
/// You have to pass `this` as the 2nd parameter in Constructor ([late] is
/// required to declare as final).
///
///
/// ```dart
/// late final firstName = ObsValue<String>( 'Roi', this )
///
/// ```
///
/// or using the [obs] extension:
///
/// ```dart
/// class SampleState extends State<SampleWidget> with ObsMixin {
///
///   late final firstName = 'Your name'.obs( vsync: this );
///
/// ```
///
mixin ObsMixin<T extends StatefulWidget> on State<T> {
  final _observables = <ObsValue>[];

  @override
  void dispose() {
    final safeList = List.of(_observables);
    for (final r in safeList) {
      r.dispose();
    }
    safeList.clear();
    _observables.clear();
    super.dispose();
  }
}

/// GetX definitions aliases.
typedef Rx<T> = ObsValue<T>;
typedef Rxn<T> = ObsValueNull<T?>;

/// Takes an empty constructor.
/// `final u = ObsValue<User?>(null);`
/// becomes:
/// `final u = ObsValueNull<User>();`
class ObsValueNull<T> extends ObsValue<T?> {
  ObsValueNull([T? value]) : super(value);
}

class ObsValue<T> extends ValueNotifier<T> {
  final ObsMixin? _creator;
  bool _debugDisposed = false;

  ObsValue(T value, [this._creator]) : super(value) {
    _creator?._observables.add(this);
  }

  bool get disposed => _debugDisposed;

  @override
  void dispose() {
    _creator?._observables.remove(this);
    _listeners.forEach((key, value) {
      removeListener(value);
    });
    _listeners.clear();

    for (var sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();

    final callbacks = _buildContextSubscriptions.values;
    for (var callback in callbacks) {
      removeListener(callback);
    }
    /// Will only allow to dispose once.
    _debugDisposed = true;
    super.dispose();
  }

  static _ObsNotifier? _proxy;

  void notify() {
    notifyListeners();
  }

  T call([T? val]) {
    if (val != null && val != value) {
      value = val;
    }
    return value;
  }

  @override
  set value(T val) {
    if (val != super.value) {
      super.value = val;
    }
  }

  @override
  T get value {
    _proxy?.add(this);
    return super.value;
  }

  @override
  String toString() {
    return '$value';
  }

  /// Returns the json representation of `value`.
  dynamic toJson() {
    try {
      return (value as dynamic)?.toJson();
    } catch (error) {
      if (kDebugMode) {
        print("ERROR: $error");
      }
    }
    return null;
  }

  // @overrideyield
  // bool operator ==(Object other) {
  //   if (other is T) return value == other;
  //   if (other is ObsValue<T>) return value == other.value;
  //   return false;
  // }
  // @override
  // int get hashCode => value.hashCode;

  // Like `addListener` but sends the value as argument.
  final _listeners = <ValueChanged<T>, VoidCallback>{};

  bool removeEventListener(ValueChanged<T> callback) {
    if (!_listeners.containsKey(callback)) {
      return false;
    }
    removeListener(_listeners.remove(callback)!);
    return true;
  }

  void addEventListener(ValueChanged<T> callback) {
    if (_listeners.containsKey(callback)) {
      return;
    }
    _listeners[callback] = () => callback(value);
    addListener(_listeners[callback]!);
  }

  // --- stream

  final _subscriptions = <Stream, StreamSubscription>{};

  void bindStream(Stream<T> stream) {
    late StreamSubscription subscription;
    subscription = stream.asBroadcastStream().listen(
      (event) => value = event,
      onDone: () {
        _subscriptions.remove(subscription);
        subscription.cancel();
      },
    );
    _subscriptions[stream] = subscription;
  }

  Future<void> closeStream(Stream<T> stream) async {
    if (!_subscriptions.containsKey(stream)) {
      return;
    }
    await _subscriptions.remove(stream)?.cancel();
  }

  final _buildContextSubscriptions = <ComponentElement, VoidCallback>{};

  /// Special case to subscribe a context rebuild to this ValueNotifier.
  /// Implementation is a little "hacky" as we rely on capture Exception
  /// to notify the Element is defunct.
  T subscribeContext(BuildContext context) {
    if (context is! ComponentElement) {
      throw "Can not subscribe to $context";
    }
    final r = _buildContextSubscriptions;
    if (r.containsKey(context)) {
      return value;
    }

    void _listener() {
      try {
        context.markNeedsBuild();
      } catch (e) {
        /// Throws cause the Element is dead (deactivated or unmounted).
        /// but we can not check the status externally.
        final selfCallback = r.remove(context);
        if (selfCallback != null) {
          removeListener(selfCallback);
        }
      }
    }

    r[context] = _listener;
    addListener(_listener);
    return value;
  }
}

/// This class is the hook between [ObsValue] (ValueNotifier) and the widget.
class _ObsNotifier {
  final VoidCallback updateState;
  final _notifiers = <ObsValue>{};
  static final _emptyListenable = ChangeNotifier();
  Listenable listenable = _emptyListenable;

  _ObsNotifier(this.updateState);

  bool get canUpdate => _notifiers.isNotEmpty;

  void add(ObsValue value) {
    if (_notifiers.contains(value)) {
      return;
    }
    _notifiers.add(value);
    _updateListenable();
  }

  void remove(ObsValue value) {
    _notifiers.remove(value);
    _updateListenable();
  }

  void _updateListenable() {
    if (_notifiers.isEmpty) {
      listenable = _emptyListenable;
    } else {
      listenable = Listenable.merge(_notifiers.toList());
    }

    /// TODO: post frame callback ?
    Future.microtask(() => updateState());
  }

  void dispose() {
    listenable = _emptyListenable;
    _notifiers.clear();
  }
}
