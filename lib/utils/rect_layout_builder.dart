import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

typedef RectChangedCallback = void Function(Rect rect);

/// Builder gets called initially with Rect.empty, and get called everytime the
/// child changes it's sizes. Or if [useGlobalPosition] is true, every time it
/// changes its layout position in the global space.
class RectLayoutChangedBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, Rect rect, Widget? child) builder;
  final Widget? child;
  final bool useGlobalPosition;

  const RectLayoutChangedBuilder({
    Key? key,
    required this.builder,
    this.useGlobalPosition = false,
    this.child,
  }) : super(key: key);

  @override
  State<RectLayoutChangedBuilder> createState() => _RectLayoutChangedBuilderState();
}

class _RectLayoutChangedBuilderState extends State<RectLayoutChangedBuilder> {
  Rect rect = Rect.zero;
  late Widget cachedChild;

  /// used for cachedChild.
  bool rebuildChild = true;

  @override
  void reassemble() {
    setState(() {
      rebuildChild = true;
    });
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    if (rebuildChild) {
      rebuildChild = false;
      cachedChild = widget.builder(
        context,
        rect,
        widget.child,
      );
    }
    return ChangedRectLayoutBuilder(
      calculateGlobalPosition: widget.useGlobalPosition,
      onChanged: (newRect) {
        if (newRect != rect && mounted) {
          setState(() {
            rebuildChild = true;
            rect = newRect;
          });
        }
      },
      child: cachedChild,
    );
  }
}

class ChangedRectLayoutBuilder extends SingleChildRenderObjectWidget {
  /// Callback dispatched when the internal Size of this Widget changes.
  /// Also dispatches when [calculateGlobalPosition] is true, and the
  /// Widget position changes in the screen.
  final RectChangedCallback onChanged;

  /// Will return the Rect left/top calculated by the Screen position.
  /// This step has to be calculated on the next frame.
  final bool calculateGlobalPosition;

  const ChangedRectLayoutBuilder({
    this.calculateGlobalPosition = false,
    required this.onChanged,
    required Widget child,
    Key? key,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderChangedRectLayoutBuilder(onChanged, calculateGlobalPosition);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderChangedRectLayoutBuilder renderObject,
  ) {
    renderObject.globalPosition = calculateGlobalPosition;
    renderObject.onSizeChanged = onChanged;
  }
}

class RenderChangedRectLayoutBuilder extends RenderProxyBox {
  RectChangedCallback onSizeChanged;
  bool globalPosition;

  Offset currentPosition = Offset.zero;
  Size currentSize = Size.zero;

  RenderChangedRectLayoutBuilder(this.onSizeChanged, this.globalPosition);

  @override
  void paint(context, offset) {
    /// by now layout ran, so we should access the callback data.
    final _child = child;
    if (_child == null) {
      return;
    }

    if (_child.hasSize) {
      try {
        var changedValues = false;
        var newSize = _child.size;
        if (currentSize != newSize) {
          currentSize = newSize;
          changedValues = true;
        }
        if (globalPosition) {
          var newPosition = _child.localToGlobal(Offset.zero);
          if (newPosition != currentPosition) {
            currentPosition = newPosition;
            changedValues = true;
          }
        }
        if (changedValues) {
          SchedulerBinding.instance?.addPostFrameCallback((_) {
            onSizeChanged(currentPosition & currentSize);
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error accessing child size: $e");
        }
      }
    }
    super.paint(context, offset);
  }
}
