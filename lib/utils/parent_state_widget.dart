import 'package:flutter/material.dart';

/// Meant to replace StatelessWidget when you need to consume a State up
/// in the tree.
/// Requires to override [buildWithState] instead of build(BuildContext) to
/// access the state.
abstract class ParentStateWidget<T extends State> extends StatelessWidget {
  const ParentStateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<T>();
    if (state == null) {
      throw "[$runtimeType] requires a parent state [$T] that can't be found.";
    }
    return buildWithState(context, state);
  }

  @protected
  Widget buildWithState(BuildContext context, T state);
}