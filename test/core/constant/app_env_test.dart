import 'package:fin_track_ai/core/constant/app_env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppEnv.isAiConfigValid', () {
    test('empty URL returns false', () {
      expect(AppEnv.isAiConfigValid(proxyUrl: '', secret: 'secret'), false);
    });

    test('http (not https) URL returns false', () {
      expect(
        AppEnv.isAiConfigValid(
          proxyUrl: 'http://example.com/exec',
          secret: 'secret',
        ),
        false,
      );
    });

    test('URL without host returns false', () {
      expect(
        AppEnv.isAiConfigValid(
          proxyUrl: 'https:///path/to/exec',
          secret: 'secret',
        ),
        false,
      );
      expect(
        AppEnv.isAiConfigValid(proxyUrl: 'https://', secret: 'secret'),
        false,
      );
    });

    test('whitespace-only secret returns false', () {
      expect(
        AppEnv.isAiConfigValid(
          proxyUrl: 'https://example.com/exec',
          secret: '   ',
        ),
        false,
      );
      expect(
        AppEnv.isAiConfigValid(
          proxyUrl: 'https://example.com/exec',
          secret: '\t\n',
        ),
        false,
      );
    });

    test('empty secret returns false', () {
      expect(
        AppEnv.isAiConfigValid(
          proxyUrl: 'https://example.com/exec',
          secret: '',
        ),
        false,
      );
    });

    test('valid config returns true', () {
      expect(
        AppEnv.isAiConfigValid(
          proxyUrl: 'https://example.com/exec',
          secret: 'my-secret',
        ),
        true,
      );
      expect(
        AppEnv.isAiConfigValid(
          proxyUrl: 'https://foo.bar/abc',
          secret: '   my-secret  ',
        ),
        true,
      );
    });
  });
}
