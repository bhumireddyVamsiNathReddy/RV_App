/// API Constants
class ApiConstants {
  // Base URL - Update this with your actual backend URL
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  
  // Dashboard Endpoints
  static const String dashboardStats = '/dashboard/stats';
  static const String topServices = '/dashboard/top-services';
  
  // Services Endpoints
  static const String services = '/services';
  
  // Products Endpoints
  static const String products = '/products';
  
  // Customers Endpoints
  static const String customers = '/customers';
  static const String searchCustomers = '/customers/search';
  
  // Bills Endpoints
  static const String bills = '/bills';
  static const String billHistory = '/bills/history';
  
  // Employees Endpoints
  static const String employees = '/employees';
}

/// App Constants
class AppConstants {
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String userRoleKey = 'user_role';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleReceptionist = 'receptionist';
}

/// UI Constants
class UIConstants {
  // Padding & Spacing
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircle = 999.0;
  
  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  
  // Elevation
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
}
