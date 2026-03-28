import 'package:flutter_test/flutter_test.dart';
import 'package:skydoge_wallet/core/constants/donation_constants.dart';

void main() {
  group('DonationConstants', () {
    test('calculates 0.01 percent donation', () {
      expect(DonationConstants.calculateDonationFee(100000000), 10000);
    });

    test('flags too-small donation outputs', () {
      expect(DonationConstants.requiresMinimumDonation(100000), isTrue);
      expect(DonationConstants.requiresMinimumDonation(100000000), isFalse);
    });

    test('includes donation in total amount', () {
      expect(
        DonationConstants.calculateTotalAmount(100000000),
        100010000,
      );
    });
  });
}
