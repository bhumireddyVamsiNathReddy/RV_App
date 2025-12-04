import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rv_salon_manager/features/auth/providers/auth_provider.dart';
import 'package:rv_salon_manager/core/services/api_service.dart';

// Generate mocks
@GenerateMocks([ApiService])
import 'auth_provider_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late AuthNotifier authNotifier;

  setUp(() {
    mockApiService = MockApiService();
    SharedPreferences.setMockInitialValues({});
    authNotifier = AuthNotifier(mockApiService);
  });

  group('AuthNotifier Tests', () {
    test('Initial state should be unauthenticated', () {
      expect(authNotifier.state.isAuthenticated, false);
      expect(authNotifier.state.user, null);
    });

    test('Login success updates state correctly', () async {
      final mockUserResponse = {
        'id': '123',
        'name': 'Test User',
        'email': 'test@example.com',
        'role': 'admin',
        'token': 'mock_token',
      };

      when(mockApiService.post('/auth/login', any))
          .thenAnswer((_) async => mockUserResponse);

      await authNotifier.login('test@example.com', 'password');

      expect(authNotifier.state.isAuthenticated, true);
      expect(authNotifier.state.user?.email, 'test@example.com');
      expect(authNotifier.state.isLoading, false);
      expect(authNotifier.state.error, null);
    });

    test('Login failure updates state with error', () async {
      when(mockApiService.post('/auth/login', any))
          .thenThrow(Exception('Invalid credentials'));

      await authNotifier.login('test@example.com', 'wrong_password');

      expect(authNotifier.state.isAuthenticated, false);
      expect(authNotifier.state.error, contains('Login failed'));
      expect(authNotifier.state.isLoading, false);
    });

    test('Logout clears state and preferences', () async {
      // Simulate logged in state first
      SharedPreferences.setMockInitialValues({'auth_token': 'token'});
      
      await authNotifier.logout();

      expect(authNotifier.state.isAuthenticated, false);
      expect(authNotifier.state.user, null);
    });
  });
}
