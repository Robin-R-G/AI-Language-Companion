import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/utils/string_extensions.dart';

void main() {
  group('StringExtension', () {
    test('capitalize capitalizes first letter', () {
      expect('hello'.capitalize, 'Hello');
      expect('h'.capitalize, 'H');
      expect(''.capitalize, '');
    });

    test('capitalizeAll capitalizes each word', () {
      expect('hello world'.capitalizeAll, 'Hello World');
      expect('hello'.capitalizeAll, 'Hello');
    });

    test('isValidEmail checks email format', () {
      expect('test@example.com'.isValidEmail, true);
      expect('invalid'.isValidEmail, false);
      expect('test@'.isValidEmail, false);
      expect(''.isValidEmail, false);
    });

    test('isValidPassword checks password strength', () {
      expect('Abcdef1!a'.isValidPassword, true);
      expect('short1A'.isValidPassword, false);
      expect('nouppercase1'.isValidPassword, false);
      expect('NOLOWERCASE1'.isValidPassword, false);
      expect('NoDigits!@#'.isValidPassword, false);
    });

    test('truncate shortens long strings', () {
      expect('Hello World'.truncate(5), 'Hello...');
      expect('Hi'.truncate(5), 'Hi');
    });

    test('removeWhitespace removes all whitespace', () {
      expect('a b c'.removeWhitespace, 'abc');
      expect('  hello  '.removeWhitespace, 'hello');
    });
  });
}
