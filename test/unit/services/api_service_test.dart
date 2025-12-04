import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:rv_salon_manager/core/services/api_service.dart';
import 'dart:convert';

// Generate mocks
@GenerateMocks([http.Client])
import 'api_service_test.mocks.dart';

void main() {
  late MockClient mockClient;
  late ApiService apiService;

  setUp(() {
    mockClient = MockClient();
    apiService = ApiService(client: mockClient);
  });

  group('ApiService Tests', () {
    test('GET request returns data on 200 OK', () async {
      final mockData = {'message': 'Success'};
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response(jsonEncode(mockData), 200));

      final result = await apiService.get('/test');

      expect(result, mockData);
      verify(mockClient.get(any)).called(1);
    });

    test('GET request throws exception on error', () async {
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(() => apiService.get('/test'), throwsException);
    });

    test('POST request sends data and returns response', () async {
      final requestData = {'name': 'Test'};
      final responseData = {'id': '123', 'name': 'Test'};
      
      when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(jsonEncode(responseData), 201));

      final result = await apiService.post('/test', requestData);

      expect(result, responseData);
      verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
    });
  });
}
