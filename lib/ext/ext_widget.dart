import 'package:flutter/material.dart';

/// Extensions to generate common Widgets from methods.
///
/// Example:
/// ```dart
/// Text('Hello').visible( false )
/// ```
extension WidgetExt on Widget {
  Widget visible(bool visible) => Visibility(
        child: this,
        visible: visible,
      );

  Widget opacity(double opacity) => Opacity(
        child: this,
        opacity: opacity,
      );

  Widget ignorePointer(bool ignoring) => IgnorePointer(
        child: this,
        ignoring: ignoring,
      );
}

/// Extension for Padding.
extension WidgetPaddingExt on Widget {
  Widget paddingOnly({
    double left = 0.0,
    double right = 0.0,
    double top = 0.0,
    double bottom = 0.0,
  }) =>
      Padding(
        padding: EdgeInsets.only(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
        ),
        child: this,
      );

  Widget padding(double all) => Padding(
        padding: EdgeInsets.all(all),
        child: this,
      );

  Widget paddingSymmetric({
    double horizontal = 0.0,
    double vertical = 0.0,
  }) =>
      Padding(
        padding: EdgeInsets.symmetric(
          vertical: vertical,
          horizontal: horizontal,
        ),
        child: this,
      );
}

/// List extensions meant to be consumed by Widgets.
extension IteratorWidgetExt on Iterable<Widget> {
  Widget columnSeparated({
    Widget separator = const Divider(thickness: 0, height: 0),
    bool maxSize = true,
    MainAxisAlignment main = MainAxisAlignment.start,
    CrossAxisAlignment cross = CrossAxisAlignment.stretch,
  }) {
    return Column(
      mainAxisAlignment: main,
      crossAxisAlignment: cross,
      mainAxisSize: maxSize ? MainAxisSize.max : MainAxisSize.min,
      children: [
        for (var i = 0; i < length; ++i) ...[
          elementAt(i),
          if (i < length - 1) separator
        ]
      ],
    );
  }

  Widget rowSeparated({
    Widget separator = const VerticalDivider(thickness: 0, width: 0),
    bool maxSize = true,
    MainAxisAlignment main = MainAxisAlignment.start,
    CrossAxisAlignment cross = CrossAxisAlignment.center,
  }) {
    return Row(
      mainAxisAlignment: main,
      crossAxisAlignment: cross,
      mainAxisSize: maxSize ? MainAxisSize.max : MainAxisSize.min,
      children: [
        for (var i = 0; i < length; ++i) ...[
          elementAt(i),
          if (i < length - 1) separator
        ]
      ],
    );
  }

  Widget column({
    bool maxSize = true,
    MainAxisAlignment main = MainAxisAlignment.start,
    CrossAxisAlignment cross = CrossAxisAlignment.stretch,
  }) {
    return Column(
      mainAxisAlignment: main,
      crossAxisAlignment: cross,
      mainAxisSize: maxSize ? MainAxisSize.max : MainAxisSize.min,
      children: [...this],
    );
  }

  Widget row({
    bool maxSize = true,
    MainAxisAlignment main = MainAxisAlignment.start,
    CrossAxisAlignment cross = CrossAxisAlignment.center,
  }) {
    return Row(
      mainAxisAlignment: main,
      crossAxisAlignment: cross,
      mainAxisSize: maxSize ? MainAxisSize.max : MainAxisSize.min,
      children: [...this],
    );
  }

  /// adds a separator widget between items.
  List<Widget> separator(Widget separator) {
    return [
      for (var i = 0; i < length; ++i) ...[
        elementAt(i),
        if (i < length - 1) separator
      ]
    ];
  }
}
