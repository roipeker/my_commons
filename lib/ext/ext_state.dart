import 'package:flutter/material.dart';

extension StateExt<T extends StatefulWidget> on State<T> {
  /// Safe shortcut for setState((){}).
  bool update() {
    if (mounted) {
      // ignore: invalid_use_of_protected_member
      setState(() {});
    }
    return mounted;
  }
}