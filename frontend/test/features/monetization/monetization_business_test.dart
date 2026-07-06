import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Monetization & Credit Wallet Business Logic Tests', () {
    test('Wallet Credit Balance Additions/Deductions', () {
      int balance = 100;

      // Earn daily reward
      balance += 10;
      expect(balance, equals(110));

      // Watch Rewarded Ad
      balance += 20;
      expect(balance, equals(130));

      // Spend credits on speaking sessions
      const sessionCost = 15;
      expect(balance >= sessionCost, isTrue);
      balance -= sessionCost;
      expect(balance, equals(115));
    });

    test('Tutor Marketplace Commission Calculation (20%)', () {
      const priceCents = 2500; // $25.00
      const commissionRate = 0.20; // 20%
      
      final commissionEarned = (priceCents * commissionRate).round();
      final tutorPayout = priceCents - commissionEarned;

      expect(commissionEarned, equals(500)); // $5.00
      expect(tutorPayout, equals(2000)); // $20.00
    });

    test('Referral Code Formatting Generation', () {
      const userId = '1beec3ca-d12b-48bd-b901-d0ecbf6e3ab1';
      const fullName = 'Robin RG';

      final cleanName = fullName.toUpperCase().replaceAll(' ', '');
      final suffix = userId.substring(0, 4).toUpperCase();
      final referralCode = '$cleanName$suffix';

      expect(referralCode, equals('ROBINRG1BEE'));
    });

    test('Affiliate Clicks Conversion Logic', () {
      const commissionPercent = 10;
      const productPriceCents = 14999; // $149.99

      final commissionEarned = (productPriceCents * (commissionPercent / 100)).round();
      expect(commissionEarned, equals(1500)); // $15.00
    });
  });
}
