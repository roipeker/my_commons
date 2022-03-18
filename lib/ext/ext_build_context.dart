import 'package:flutter/material.dart';
import 'package:my_commons/obs/obs.dart';
import 'package:my_commons/utils/context_notifications.dart';

/// Notifications that bubbles up the Widget tree.
///
/// ```dart
/// // Type <T> ([int] in this case)
/// context.notifyData( 123 );
///
/// // Type <EventNotification>
/// context.notifyEvent('hello', data: "Greeting from here");
///
/// ```
/// Capture in the widget tree with:
///
/// ```dart
/// NotificationListener<int>(
///    child: Text('The Notification is down the tree'),
///    onNotification: ( int data ){
///       /// do something with the data.
///    },
/// ),
///
/// ```
///
extension ContextNotificationExt on BuildContext {

  // Send a <EventNotification> up to the widget tree.
  // has to be consumed with [NotificationListener<EventNotification>].
  EventNotification notifyEvent(String type, {Object? data}) {
    return EventNotification.get(type, data: data)..dispatch(this);
  }

  // Send a Notification <T> up to the widget tree.
  // has to be consumed with [NotificationListener].
  void notifyData<T>(T data) {
    DataNotification(data).dispatch(this);
  }
}

extension ContextObsValueExt on BuildContext {
  T obs<T>(ObsValue<T> observer) {
    return observer.subscribeContext(this);
  }
}


///-----
extension BuildContextExt on BuildContext {
  ThemeData get theme {
    return Theme.of(this);
  }

  MediaQueryData get mediaQuery {
    return MediaQuery.of(this);
  }

  EdgeInsets get viewInsets {
    return mediaQuery.viewInsets;
  }

  Size get size {
    return mediaQuery.size;
  }

  double get paddingTop {
    return mediaQuery.padding.top;
  }

  double get paddingBottom {
    return mediaQuery.padding.bottom;
  }


  bool get isDarkMode => (theme.brightness == Brightness.dark);

  Orientation get orientation => MediaQuery.of(this).orientation;

  bool get isLandscape => orientation == Orientation.landscape;

  bool get isPortrait => orientation == Orientation.portrait;
}
