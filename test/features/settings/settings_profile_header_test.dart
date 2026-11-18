import 'package:fin_track_ai/features/auth/domain/models/user_model.dart';
import 'package:fin_track_ai/features/auth/presentation/state/auth_controller.dart';
import 'package:fin_track_ai/features/settings/presentation/widgets/settings_profile_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Widget createHeaderTestWidget({UserModel? user}) {
  return ProviderScope(
    overrides: [currentUserProvider.overrideWithValue(user)],
    child: const MaterialApp(home: Scaffold(body: SettingsProfileHeader())),
  );
}

void main() {
  testWidgets(
    '1. Pumping header with user shows ClipOval with Image fit cover and no CircleAvatar',
    (tester) async {
      const user = UserModel(
        uid: 'u1',
        email: 'john@example.com',
        fullName: 'John Doe',
      );

      await tester.pumpWidget(createHeaderTestWidget(user: user));

      expect(find.byType(CircleAvatar), findsNothing);

      final clipOvalFinder = find.byType(ClipOval);
      expect(clipOvalFinder, findsOneWidget);

      final imageFinder = find.descendant(
        of: clipOvalFinder,
        matching: find.byType(Image),
      );
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      expect(imageWidget.fit, BoxFit.cover);

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
    },
  );

  testWidgets('2. Pumping header with null user does not throw', (
    tester,
  ) async {
    await tester.pumpWidget(createHeaderTestWidget(user: null));

    expect(tester.takeException(), isNull);
    expect(find.byType(CircleAvatar), findsNothing);
    expect(find.byType(ClipOval), findsOneWidget);
  });
}
