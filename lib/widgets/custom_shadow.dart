import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class CustomShadow extends SingleChildRenderObjectWidget {
  final List<DropShadow> shadows;

  const CustomShadow({
    Key? key,
    Widget? child,
    required this.shadows,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    var ro = RenderShadowWidget();
    ro.shadows = shadows;
    ro.update();
    return ro;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderShadowWidget renderObject,
  ) {
    renderObject.shadows = shadows;
    renderObject.update();
  }
}

class RenderShadowWidget extends RenderProxyBox {
  List<DropShadow> _shadows = [];
  List<DropShadow> _innerShadows = [];
  List<DropShadow> _outterShadows = [];

  set shadows(List<DropShadow> value) {
    // TODO: add list comparator.
    _shadows = value;
    _innerShadows =
        _shadows.where((element) => element.inner).toList(growable: false);
    _outterShadows =
        _shadows.where((element) => !element.inner).toList(growable: false);
    update();
  }

  @override
  bool get alwaysNeedsCompositing => child != null;

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) {
      return;
    }
    if (child.needsCompositing) {
      print(
          "Some child is using composite layer (repaint boundries) CustomShadow is skipped");
      context.paintChild(child, offset);
      return;
    }
    final canvas = context.canvas;
    final Rect bounds = offset & size;

    if (_innerShadows.isEmpty && _outterShadows.isEmpty) {
      context.paintChild(child, offset);
      return;
    }

    if (_outterShadows.isNotEmpty) {
      for (var shadow in _outterShadows) {
        shadow.paint(canvas, bounds, () => context.paintChild(child, offset));
      }
    }

    context.paintChild(child, offset);

    if (_innerShadows.isNotEmpty) {
      for (var shadow in _innerShadows) {
        shadow.paint(canvas, bounds, () => context.paintChild(child, offset));
      }
    }
  }

  void update() {
    // final bool didNeedCompositing = alwaysNeedsCompositing;
    // if (didNeedCompositing != alwaysNeedsCompositing) {
    //   markNeedsCompositingBitsUpdate();
    // }
    markNeedsPaint();
  }
}

class DropShadow {
  final double x, y, blur, spread;
  final Color color;
  final BlendMode blendMode;
  final bool inner;

  const DropShadow({
    this.color = const Color(0x55000000),
    this.x = 0,
    this.y = 0,
    this.blur = 0,
    this.inner = false,
    this.spread = 0,
    this.blendMode = BlendMode.srcATop,
  });

  void paint(Canvas canvas, Rect bounds, Function painter) {
    if (inner) {
      CanvasUtils.drawInnerShadow(
        painter: (c) => painter(),
        canvas: canvas,
        bounds: bounds,
        blendMode: blendMode,
        x: x,
        y: y,
        blur: blur,
        spread: spread,
        color: color,
      );
    } else {
      CanvasUtils.drawDropShadow(
        blur: blur,
        spread: spread,
        bounds: bounds,
        color: color,
        blendMode: blendMode,
        canvas: canvas,
        painter: (c) => painter(),
        x: x,
        y: y,
      );
    }
  }
}

class CanvasUtils {
  static void drawDropShadow({
    double x = 10,
    double y = 10,
    double spread = 0,
    double blur = 10,
    BlendMode blendMode = BlendMode.srcATop,
    Color color = const Color(0x3F000000),
    Rect? bounds,
    required Canvas canvas,
    required void Function(Canvas canvas) painter,
  }) {
    spread = -spread;
    var fill = Paint();
    if (blur > 0) {
      /// TODO: choose between decal and clamp?
      var mode = TileMode.clamp;
      fill.imageFilter = ImageFilter.blur(
        sigmaX: blur / 2,
        sigmaY: blur / 2,
        tileMode: mode,
      );
    }
    fill.colorFilter =
        ColorFilter.mode(color.withOpacity(1), BlendMode.srcATop);
    fill.color = color;
    fill.blendMode = blendMode;

    /// TODO: recalculate bounds with shadow.
    canvas.saveLayer(null, fill);
    if (bounds != null && spread != 0) {
      /// Bounds are required to scale from center.
      var tw = bounds.width;
      var th = bounds.height;
      var r = 1 - spread / 100;
      var dx = (tw - tw * r) / 2;
      var dy = (th - th * r) / 2;
      canvas.translate(bounds.left, bounds.top);
      canvas.translate(dx, dy);
      canvas.scale(r);
      canvas.translate(-bounds.left, -bounds.top);
    }
    canvas.translate(x, y);
    painter(canvas);
    canvas.restore();
  }

  static void drawInnerShadow({
    double x = 10,
    double y = 10,
    double spread = 0,
    double blur = 10,
    BlendMode blendMode = BlendMode.srcATop,
    Color color = const Color(0x3F000000),
    Rect? bounds,
    required Canvas canvas,
    required void Function(Canvas canvas) painter,
  }) {
    var fill = Paint();
    fill.blendMode = blendMode;
    fill.color = color;
    fill.filterQuality = FilterQuality.high;
    canvas.saveLayer(bounds, fill);

    painter(canvas);

    fill = Paint();
    fill.colorFilter = ColorFilter.mode(
      color.withOpacity(1),
      BlendMode.xor,
    );
    if (blur > 0) {
      /// TODO: choose between decal and clamp
      var mode = TileMode.clamp;
      fill.imageFilter = ImageFilter.blur(
        sigmaX: blur / 2,
        sigmaY: blur / 2,
        tileMode: mode,
      );
    }
    fill.blendMode = BlendMode.srcIn;

    canvas.saveLayer(bounds?.inflate(blur), fill);
    if (bounds != null && spread != 0) {
      /// Bounds is required to scale from center.
      var tw = bounds.width;
      var th = bounds.height;
      var r = 1 - spread / 100;
      var dx = (tw - tw * r) / 2;
      var dy = (th - th * r) / 2;
      canvas.translate(dx, dy);
      canvas.scale(r);
    }
    canvas.translate(x, y);
    painter(canvas);
    // canvas.drawPicture(boxPicture);
    canvas.restore();
    canvas.restore();
  }

  static Picture buildPicture(void Function(Canvas c) drawer) {
    final recorder = PictureRecorder();
    final tempCanvas = Canvas(recorder);
    drawer(tempCanvas);
    return recorder.endRecording();
  }
}
