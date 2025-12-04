import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rv_salon_manager/features/dashboard/screens/dashboard_screen.dart';
import 'package:rv_salon_manager/features/dashboard/widgets/stats_card.dart';
import 'package:rv_salon_manager/features/dashboard/widgets/top_services_chart.dart';
import 'package:rv_salon_manager/features/dashboard/widgets/revenue_breakdown_chart.dart';

void main() {
  testWidgets('DashboardScreen renders all main widgets', (WidgetTester tester) async {
    // We need to provide a dummy implementation or mock for the providers if they are accessed in build
    // Since we are doing a simple render test, we can try pumping the widget with a ProviderScope
    // Ideally we should override the providers with mocks that return dummy data.
    
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // Allow animations to settle
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Dashboard'), findsOneWidget);

    // Verify Stats Cards (we expect multiple)
    expect(find.byType(StatsCard), findsWidgets);

    // Verify Charts
    expect(find.byType(TopServicesChart), findsOneWidget);
    expect(find.byType(RevenueBreakdownChart), findsOneWidget);
  });
}
