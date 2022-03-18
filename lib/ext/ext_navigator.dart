import 'package:flutter/material.dart';

extension NavigatorExt on BuildContext {
  NavigatorState navigator([bool rootNavigator = false]) {
    return Navigator.of(this, rootNavigator: rootNavigator);
  }

  void pop<T>({
    bool rootNavigator = false,
    T? result,
  }) {
    navigator(rootNavigator).pop<T>(result);
  }

  void popUntil(
    RoutePredicate callback, {
    bool rootNavigator = false,
  }) {
    navigator(rootNavigator).popUntil(callback);
  }

  bool canPop({bool rootNavigator = false}) {
    return navigator(rootNavigator).canPop();
  }

  void popToFirst({bool rootNavigator = false}) {
    popUntil((route) => route.isFirst, rootNavigator: rootNavigator);
  }

  Future<T?> push<T>(
    Widget page, {
    bool rootNavigator = false,
    bool isDialog = false,
    String? name,
    Object? args,
  }) {
    /// TODO: allow CupertinoPageRoute, and other Route transitions.
    name ??= page.toString();
    final route = MaterialPageRoute<T>(
      builder: (_) => page,
      settings: RouteSettings(name: name, arguments: args),
      fullscreenDialog: isDialog,
    );
    return navigator(rootNavigator).push<T>(route);
  }

  Future<T?> replace<T extends Object?, TO extends Object?>(
    Widget page, {
    TO? result,
    bool rootNavigator = false,
    bool isDialog = false,
    String? name,
    Object? args,
  }) {
    /// TODO: allow CupertinoPageRoute, and other Route transitions.
    name ??= page.toString();
    final route = MaterialPageRoute<T>(
      builder: (_) => page,
      settings: RouteSettings(name: name, arguments: args),
      fullscreenDialog: isDialog,
    );
    return navigator(rootNavigator).pushReplacement<T, TO>(
      route,
      result: result,
    );
  }

  ///
  /// TODO: add customization code.
  ///
  // Future<T?> modal<T>(
  //   Widget widget, {
  //   T? orElse,
  //   bool barrierDismissible = true,
  //
  // }) {
  // return showModal<T>(
  //   context: this,
  //   configuration: FadeScaleTransitionConfiguration(
  //     // barrierColor: Colors.black.withOpacity(.81),
  //     barrierColor: Color(0xff6C8388).withOpacity(.65),
  //     barrierDismissible: barrierDismissible,
  //     reverseTransitionDuration: const Duration(milliseconds: 180),
  //     transitionDuration: const Duration(milliseconds: 260),
  //   ),
  //   builder: (_) => widget,
  // ).then((value) => value ?? orElse);
  // }

  Future<T?> dialog<T>(
    Widget widget, {
    bool useRootNavigator = false,
    Color? color,
    bool dismissible = true,
    Object? args,
    String? name,
  }) {
    name ??= '$widget';
    return showDialog<T>(
      context: this,
      builder: (_) => widget,
      useRootNavigator: useRootNavigator,
      barrierColor: color,
      barrierDismissible: dismissible,
      routeSettings: RouteSettings(arguments: args, name: name),
    );
  }
}
