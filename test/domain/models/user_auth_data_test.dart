import 'package:exe101/domain/models/login_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('updates a cached user snapshot without losing identity fields', () {
    final original = UserAuthData(
      id: 'user-1',
      fullName: 'Old Name',
      email: 'user@example.com',
      phoneNumber: '0900000000',
      roles: const ['Customer'],
    );

    final updated = original.copyWith(
      fullName: 'New Name',
      phoneNumber: '0911111111',
    );

    expect(updated.fullName, 'New Name');
    expect(updated.phoneNumber, '0911111111');
    expect(updated.email, original.email);
    expect(updated.roles, original.roles);
  });

  test('serializes a cached user snapshot for the next app launch', () {
    final original = UserAuthData(
      id: 'user-1',
      fullName: 'Saved User',
      email: 'user@example.com',
      phoneNumber: '0900000000',
      avatarUrl: 'https://example.com/avatar.png',
      roles: const ['Owner'],
    );

    final restored = UserAuthData.fromJson(original.toJson());

    expect(restored.id, original.id);
    expect(restored.fullName, original.fullName);
    expect(restored.email, original.email);
    expect(restored.phoneNumber, original.phoneNumber);
    expect(restored.avatarUrl, original.avatarUrl);
    expect(restored.roles, original.roles);
  });
}
