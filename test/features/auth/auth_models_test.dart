import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/auth/data/models/auth_models.dart';

void main() {
  group('LoginRequest', () {
    test('toFormData returns correct map', () {
      final request = LoginRequest(
        username: 'testuser',
        password: 'testpass',
      );

      final formData = request.toFormData();

      expect(formData['username'], 'testuser');
      expect(formData['password'], 'testpass');
      expect(formData['grant_type'], 'password');
    });
  });

  group('LoginResponse', () {
    test('fromJson parses access_token correctly', () {
      final json = {
        'access_token': 'abc123',
        'token_type': 'bearer',
        'refresh_token': 'refresh456',
      };

      final response = LoginResponse.fromJson(json);

      expect(response.accessToken, 'abc123');
      expect(response.tokenType, 'bearer');
      expect(response.refreshToken, 'refresh456');
    });

    test('fromJson handles accessToken camelCase', () {
      final json = {
        'accessToken': 'abc123',
        'tokenType': 'bearer',
      };

      final response = LoginResponse.fromJson(json);

      expect(response.accessToken, 'abc123');
      expect(response.tokenType, 'bearer');
    });

    test('fromJson handles token field', () {
      final json = {
        'token': 'abc123',
      };

      final response = LoginResponse.fromJson(json);

      expect(response.accessToken, 'abc123');
    });

    test('fromJson uses defaults for missing fields', () {
      final json = <String, dynamic>{};

      final response = LoginResponse.fromJson(json);

      expect(response.accessToken, '');
      expect(response.tokenType, 'bearer');
      expect(response.refreshToken, null);
    });
  });

  group('RegisterRequest', () {
    test('toJson returns correct map', () {
      final request = RegisterRequest(
        email: 'test@test.com',
        username: 'testuser',
        fullName: 'Test User',
        password: 'testpass',
      );

      final json = request.toJson();

      expect(json['email'], 'test@test.com');
      expect(json['username'], 'testuser');
      expect(json['full_name'], 'Test User');
      expect(json['password'], 'testpass');
      expect(json['is_active'], true);
      expect(json['is_superuser'], false);
      expect(json['roles'], 'user');
    });
  });

  group('RegisterResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 1,
        'email': 'test@test.com',
        'username': 'testuser',
        'full_name': 'Test User',
        'is_active': true,
        'is_superuser': false,
        'roles': 'user',
      };

      final response = RegisterResponse.fromJson(json);

      expect(response.id, 1);
      expect(response.email, 'test@test.com');
      expect(response.username, 'testuser');
      expect(response.fullName, 'Test User');
      expect(response.isActive, true);
      expect(response.isSuperuser, false);
      expect(response.roles, 'user');
    });
  });

  group('UserResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 1,
        'email': 'test@test.com',
        'username': 'testuser',
        'full_name': 'Test User',
        'is_active': true,
      };

      final response = UserResponse.fromJson(json);

      expect(response.id, 1);
      expect(response.email, 'test@test.com');
      expect(response.username, 'testuser');
      expect(response.fullName, 'Test User');
      expect(response.isActive, true);
    });
  });
}
