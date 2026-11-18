import 'dart:async';

import 'package:fin_track_ai/core/utils/acknowledged_write.dart';
import 'package:flutter_test/flutter_test.dart';

class CustomMarkerException implements Exception {
  CustomMarkerException(this.original);
  final Object original;
}

const shortTimeout = Duration(milliseconds: 50);

void main() {
  group('awaitWriteAck', () {
    test(
      'A write that never completes finishes normally after the timeout',
      () async {
        final completer = Completer<void>();
        await awaitWriteAck(
          () => completer.future,
          timeout: shortTimeout,
          translateError: (e) => CustomMarkerException(e),
          logTag: 'TestTag',
        );
      },
    );

    test('A write that completes before the timeout works as before', () async {
      final completer = Completer<void>()..complete();
      await awaitWriteAck(
        () => completer.future,
        timeout: shortTimeout,
        translateError: (e) => CustomMarkerException(e),
        logTag: 'TestTag',
      );
    });

    test(
      'An error before the timeout is rethrown through translateError',
      () async {
        final completer = Completer<void>()
          ..completeError(StateError('original error'));
        await expectLater(
          awaitWriteAck(
            () => completer.future,
            timeout: shortTimeout,
            translateError: (e) => CustomMarkerException(e),
            logTag: 'TestTag',
          ),
          throwsA(isA<CustomMarkerException>()),
        );
      },
    );

    test(
      'An error arriving after the timeout is NOT an uncaught error',
      () async {
        final uncaught = <Object>[];
        await runZonedGuarded(() async {
          final completer = Completer<void>();
          await awaitWriteAck(
            () => completer.future,
            timeout: shortTimeout,
            translateError: (e) => CustomMarkerException(e),
            logTag: 'TestTag',
          );
          completer.completeError(StateError('late error'));
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }, (error, stack) => uncaught.add(error));

        expect(uncaught, isEmpty);
      },
    );
  });
}
