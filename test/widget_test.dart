// Basic smoke test for Files Claw.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:files_claw/features/splash/splash_screen.dart';

void main() {
  testWidgets('Splash screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const SplashScreen(),
          routes: {
            '/home': (context) => const Scaffold(body: Text('Home')),
          },
        ),
      ),
    );
    // Splash should at least pump a frame without throwing.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pumpAndSettle(const Duration(milliseconds: 2000));
    expect(find.text('Home'), findsOneWidget);
  });
}
