import 'package:flutter/material.dart';

class DataNotification<T> extends Notification {
  final T data;

  const DataNotification(this.data);

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.add('$data');
  }
}

class EventNotification extends Notification {
  static final _map = <String?, EventNotification>{};

  static EventNotification get(String id, {Object? data}) {
    if (!_map.containsKey(id)) {
      _map[id] = EventNotification(id, data: data);
    }
    return _map[id]!..data = data;
  }

  String type;
  Object? data;

  EventNotification(this.type, {this.data});

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.addAll([type, if (data != null) '$data']);
  }
}
