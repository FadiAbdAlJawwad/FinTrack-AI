import 'dart:async';

import 'package:flutter/foundation.dart';

/// Waits for [write] to complete within [timeout].
///
/// Firestore applies writes to its local cache immediately, but the write
/// Future completes only on server acknowledgement, which never happens
/// offline. Fast failures (invalid data, auth) still surface as typed
/// errors; a timeout means the write is queued locally and will sync.
Future<void> awaitWriteAck(
  Future<void> Function() write, {
  required Duration timeout,
  required Object Function(Object error) translateError,
  required String logTag,
}) async {
  try {
    await write().timeout(
      timeout,
      onTimeout: () {
        if (kDebugMode) {
          debugPrint(
            '[$logTag] write not acknowledged within ${timeout.inSeconds}s; queued locally',
          );
        }
      },
    );
  } catch (e, st) {
    Error.throwWithStackTrace(translateError(e), st);
  }
}
