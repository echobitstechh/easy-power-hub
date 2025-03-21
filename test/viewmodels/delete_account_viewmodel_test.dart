import 'package:flutter_test/flutter_test.dart';
import 'package:easyph/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('DeleteAccountViewModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}

