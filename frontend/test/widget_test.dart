import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';
import 'package:frontend/services/api_rider_service.dart';

void main() {
  testWidgets('Reflex app starts', (WidgetTester tester) async {
    final riderService = ApiRiderService(baseUrl: 'http://localhost:3000');

    await tester.pumpWidget(ReflexApp(riderService: riderService));

    expect(find.text('My Deliveries'), findsOneWidget);
  });
}
