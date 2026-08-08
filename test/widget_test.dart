import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_keeper/app/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: HealthKeeperApp()),
    );
    await tester.pump();
    expect(find.text('Health Keeper'), findsAny);
  });
}
