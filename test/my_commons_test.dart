import 'package:flutter_test/flutter_test.dart';
import 'package:my_commons/my_commons.dart';

void main() {
  test('waits 1 second to show output', () {
    2.seconds.delay(() {
      trace('output');
    });
  });
}
