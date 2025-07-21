import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:commeowment/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our app loads without crashing
    expect(find.text('Monthly Commitment Tracker'), findsOneWidget);
  });
}