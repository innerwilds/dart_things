import 'package:dart_things/coliseum.dart';
import 'package:test/test.dart';

void main() {
  test('String.toLowerCamelCase', () {
    expect('Hello, Mario! How are you? Are you 28yo old?'.toLowerCamelCase(), 'helloMarioHowAreYouAreYou28yoOld');
  });
  test('String.isOnlyDigits', () {
    expect('231287318923'.isOnlyDigits, true);
  });
  test('String.isOnlyDigits returns false for -0', () {
    expect('-0'.isOnlyDigits, false);
  });
  test('String.isOnlyDigits returns false for an empty string', () {
    expect(''.isOnlyDigits, false);
  });
  test('String.isOnlyDigits returns false for an string with whitespaces', () {
    expect('123123 213123 123123'.isOnlyDigits, false);
  });
  test('String.isOnlyDigits returns false for a9️⃣', () {
    expect('9️⃣'.isOnlyDigits, false);
  });
}
