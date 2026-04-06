import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:my_app/core/network/api_client.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late ApiClient apiClient;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    apiClient = ApiClient(client: mockHttpClient);
  });

  group('ApiClient', () {
    test('setAuthToken stores token correctly', () {
      apiClient.setAuthToken('test_token');
      expect(apiClient, isNotNull);
    });

    test('clearAuthToken removes token', () {
      apiClient.setAuthToken('test_token');
      apiClient.clearAuthToken();
      expect(apiClient, isNotNull);
    });

    test('post sends JSON request with correct headers', () async {
      final response = http.Response('{"id": 1}', 200);
      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => response);

      final result = await apiClient.post(
        '/test',
        body: {'key': 'value'},
      );

      expect(result.isSuccess, true);
      expect(result.data['id'], 1);
    });

    test('postForm sends form-urlencoded request', () async {
      final response = http.Response('{"token": "abc123"}', 200);
      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => response);

      final result = await apiClient.postForm(
        '/auth/login',
        body: {'username': 'test', 'password': 'pass'},
      );

      expect(result.isSuccess, true);
      expect(result.data['token'], 'abc123');
    });

    test('handles 401 unauthorized error', () async {
      final response = http.Response('{"message": "Unauthorized"}', 401);
      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => response);

      final result = await apiClient.post('/test', body: {});

      expect(result.isError, true);
      expect(result.statusCode, 401);
    });

    test('handles network error', () async {
      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenThrow(Exception('Network error'));

      final result = await apiClient.post('/test', body: {});

      expect(result.isError, true);
    });
  });
}
