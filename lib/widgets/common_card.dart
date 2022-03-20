import 'dart:io' show File;
import 'package:flutter/material.dart';

class CommonCardThemeData {
  final EdgeInsets? margin;
  final EdgeInsets padding;
  final Color? color;
  final List<BoxShadow>? shadow;
  final BorderRadius? radius;
  final Border? border;
  final bool clip;
  final bool borderOnForeground;

  /// --- Inherited by any child Text widget.
  final TextStyle? textStyle;
  final Color? splashColor;
  final MouseCursor? mouseCursor;
  final BoxFit? backgroundFit;
  final double backgroundOpacity;

  final double backgroundScale;
  final Alignment backgroundAlign;
  final ImageRepeat? backgroundRepeat;
  final FilterQuality backgroundQuality;
  final ColorFilter? backgroundColorFilter;

  /// background blendMode for Card's color or gradient.
  final BlendMode? colorBlendMode;
  final Gradient? gradient;

  const CommonCardThemeData({
    this.margin,
    this.padding = EdgeInsets.zero,
    this.gradient,
    this.color,
    this.shadow,
    this.radius,
    this.border,
    this.clip = false,
    this.borderOnForeground = true,
    this.textStyle,
    this.splashColor,
    this.mouseCursor,
    this.backgroundFit,
    this.backgroundOpacity = 1.0,
    this.backgroundScale = 1.0,
    this.backgroundAlign = Alignment.center,
    this.backgroundRepeat,
    this.backgroundQuality = FilterQuality.low,
    this.backgroundColorFilter,
    this.colorBlendMode,
  });

  factory CommonCardThemeData.fallback(BuildContext context) {
    final theme = Theme.of(context);
    return CommonCardThemeData(
      color: theme.cardColor,
      splashColor: theme.splashColor,

      /// todo: fill with the defaults.
    );
  }
}

class CommonCardTheme extends InheritedWidget {
  final CommonCardThemeData data;

  const CommonCardTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  static CommonCardThemeData of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<CommonCardTheme>();
    return result?.data ?? CommonCardThemeData.fallback(context);
  }

  @override
  bool updateShouldNotify(CommonCardTheme oldWidget) {
    return data != oldWidget.data;
  }
}

class CommonCard extends StatelessWidget {
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Widget? child;
  final Color? color;
  final List<BoxShadow>? shadow;
  final BorderRadius? radius;
  final Border? border;
  final bool? clip;
  final bool? borderOnForeground;

  /// --- Inherited by any child Text widget.
  final TextStyle? textStyle;

  /// --- button properties
  final Color? splashColor;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onFocusChange;
  final ValueChanged<bool>? onHighlightChanged;
  final ValueChanged<bool>? onHover;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final GestureTapDownCallback? onTapDown;
  final GestureTapCancelCallback? onTapCancel;
  final MouseCursor? mouseCursor;
  final FocusNode? focusNode;

  /// interprets NetworkImage (http), FileImage (file://) and defaults
  /// to AssetImage.
  final String? backgroundUrl;
  final ImageErrorListener? onBackgroundError;
  final BoxFit? backgroundFit;
  final double? backgroundOpacity;

  /// When `backgroundFit=BoxFit.none` this value scales the image.
  /// backgroundScale=2 is 50% of the actual image size.
  final double? backgroundScale;
  final Alignment? backgroundAlign;
  final ImageRepeat? backgroundRepeat;
  final FilterQuality? backgroundQuality;
  final ColorFilter? backgroundColorFilter;

  /// background blendMode for Card's color or gradient.
  final BlendMode? colorBlendMode;

  const CommonCard({
    Key? key,

    /// -- button properties
    this.splashColor,
    this.onTap,
    this.onFocusChange,
    this.onHighlightChanged,
    this.onHover,
    this.onTapDown,
    this.onTapCancel,
    this.onDoubleTap,
    this.onLongPress,
    this.mouseCursor,
    this.focusNode,

    /// --- card properties.
    /// background
    this.backgroundUrl,
    this.onBackgroundError,
    this.backgroundQuality,
    this.backgroundFit,
    this.backgroundAlign,
    this.backgroundScale,
    this.backgroundOpacity,
    this.backgroundColorFilter,
    this.backgroundRepeat,

    /// default TextStyle
    this.textStyle,
    this.margin,
    this.padding,
    this.clip,
    this.borderOnForeground,
    this.child,
    this.colorBlendMode,
    this.color,
    this.shadow,
    this.radius,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = CommonCardTheme.of(context);

    return LayoutBuilder(
      builder: (_, constraints) {
        /// to avoid exceptions with InkWell button / background image.
        /// We have to check that the card has some constrains available
        /// (Size is not infinite) as fallback when no padding nor child
        /// is provided.
        var hasInfiniteBound =
            !constraints.hasBoundedHeight || !constraints.hasBoundedWidth;

        final _clip = clip ?? theme.clip;
        final _borderOnForeground =
            borderOnForeground ?? theme.borderOnForeground;
        final _backgroundAlign = backgroundAlign ?? theme.backgroundAlign;
        final _backgroundColorFilter =
            backgroundColorFilter ?? theme.backgroundColorFilter;
        final _backgroundFit = backgroundFit ?? theme.backgroundFit;
        final _backgroundOpacity = backgroundOpacity ?? theme.backgroundOpacity;
        final _backgroundQuality = backgroundQuality ?? theme.backgroundQuality;
        final _backgroundScale = backgroundScale ?? theme.backgroundScale;
        final _backgroundRepeat = backgroundRepeat ?? theme.backgroundRepeat;
        final _padding = padding ?? theme.padding;
        final _margin = margin ?? theme.margin;

        BoxDecoration? deco2, deco1;
        DecorationImage? image;

        if (backgroundUrl != null) {
          image = DecorationImage(
            image: _resolveImageProvider(),
            onError: onBackgroundError,
            alignment: _backgroundAlign,
            colorFilter: _backgroundColorFilter,
            fit: _backgroundFit,
            opacity: _backgroundOpacity,
            isAntiAlias: true,
            filterQuality: _backgroundQuality,
            scale: _backgroundScale,
            repeat: _backgroundRepeat ?? ImageRepeat.noRepeat,
          );
        }

        final _color = color ?? theme.color;
        final _radius = radius ?? theme.radius;
        final _shadow = shadow ?? theme.shadow;
        final _colorBlendMode = colorBlendMode ?? theme.colorBlendMode;
        final _splashColor = splashColor ?? theme.splashColor;
        final _mouseCursor = mouseCursor ?? theme.mouseCursor;

        deco1 = BoxDecoration(
          color: _color,
          border: _borderOnForeground ? null : border,
          borderRadius: _radius,
          boxShadow: _shadow,
          image: image,
          gradient: theme.gradient,
          backgroundBlendMode: _colorBlendMode,
        );

        if (_borderOnForeground) {
          deco2 = BoxDecoration(
            border: border,
            borderRadius: radius,
          );
        }

        Widget? _child = child;
        final _textStyle = theme.textStyle?.merge(textStyle);
        if (_child != null) {
          /// apply the default style.
          if (_textStyle != null) {
            _child = DefaultTextStyle(
              style: DefaultTextStyle.of(context).style.merge(_textStyle),
              child: _child,
            );
          }
        }

        /// Avoid padding the InkWell.
        if (_padding != EdgeInsets.zero) {
          _child = Padding(
            padding: _padding,
            child: _child,
          );
        }

        /// To avoid InkWell exception when no padding, nor child,
        /// nor PARENT constraints exists. Basically should render empty.
        final canRenderButton =
            _padding != EdgeInsets.zero || child != null || !hasInfiniteBound;
        if (canRenderButton && usesButton()) {
          _child = Material(
            type: MaterialType.transparency,
            borderRadius: _radius,
            child: InkWell(
              focusNode: focusNode,
              borderRadius: _radius,
              enableFeedback: true,
              splashColor: _splashColor,
              onTap: onTap,
              onFocusChange: onFocusChange,
              onHighlightChanged: onHighlightChanged,
              onHover: onHover,
              onDoubleTap: onDoubleTap,
              onLongPress: onLongPress,
              onTapDown: onTapDown,
              onTapCancel: onTapCancel,
              mouseCursor: _mouseCursor,
              child: _child,
            ),
          );
        }

        final clipBehaviour = (_clip == true) ? Clip.antiAlias : Clip.none;

        return Container(
          margin: _margin,
          decoration: deco1,
          foregroundDecoration: deco2,
          clipBehavior: clipBehaviour,
          child: _child,
        );
      },
    );
  }

  bool usesButton() {
    return onHighlightChanged != null ||
        onTap != null ||
        onFocusChange != null ||
        onHighlightChanged != null ||
        onHover != null ||
        onDoubleTap != null ||
        onLongPress != null ||
        onTapDown != null ||
        onTapCancel != null;
  }

  ImageProvider _resolveImageProvider() {
    final _url = backgroundUrl!;
    if (_url.contains('://')) {
      if (_url.startsWith('http')) {
        return NetworkImage(_url);
      } else if (_url.startsWith('file')) {
        return FileImage(File(_url));
      }
    }
    return AssetImage(_url);
  }
}
