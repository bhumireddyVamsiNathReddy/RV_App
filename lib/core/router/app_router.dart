import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/billing/screens/billing_screen.dart';
import '../../features/billing/screens/pending_bills_screen.dart';
import '../../features/billing/screens/billing_history_screen.dart';
import '../../features/admin/screens/services_management_screen.dart';
import '../../features/admin/screens/products_management_screen.dart';
import '../../features/admin/screens/employees_management_screen.dart';
import '../../features/reports/screens/reports_screen.dart';

/// App Router Configuration
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    // Auth Routes
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const LoginScreen(),
      ),
    ),
    
    // Dashboard (Admin Only)
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const DashboardScreen(),
      ),
    ),
    
    // Billing
    GoRoute(
      path: '/billing',
      name: 'billing',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const BillingScreen(),
      ),
    ),
    
    // Pending Bills
    GoRoute(
      path: '/pending-bills',
      name: 'pendingBills',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const PendingBillsScreen(),
      ),
    ),
    
    // Billing History
    GoRoute(
      path: '/billing-history',
      name: 'billingHistory',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const BillingHistoryScreen(),
      ),
    ),
    
    // Admin Management Screens
    GoRoute(
      path: '/manage-services',
      name: 'manageServices',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const ServicesManagementScreen(),
      ),
    ),
    GoRoute(
      path: '/manage-products',
      name: 'manageProducts',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const ProductsManagementScreen(),
      ),
    ),
    GoRoute(
      path: '/manage-employees',
      name: 'manageEmployees',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const EmployeesManagementScreen(),
      ),
    ),

    // Reports
    GoRoute(
      path: '/reports',
      name: 'reports',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const ReportsScreen(),
      ),
    ),
  ],
);

CustomTransitionPage _buildPageWithTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
        child: child,
      );
    },
  );
}
