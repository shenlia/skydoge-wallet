import 'package:flutter_test/flutter_test.dart';
import 'package:skydoge_wallet/core/constants/donation_constants.dart';

void main() {
  test('donation uses 0.001 percent rate', () {
    expect(DonationConstants.calculateDonationAmount(100000000), 1000);
  });

  test('dust donation is blocked for low amount', () {
    expect(DonationConstants.isDonationDust(1000000), true);
    expect(DonationConstants.isDonationDust(60000000), false);
  });

  test('donation address switches by network', () {
    expect(
      DonationConstants.donationAddressForNetwork(false),
      DonationConstants.mainnetDonationAddress,
    );
    expect(
      DonationConstants.donationAddressForNetwork(true),
      DonationConstants.testnetDonationAddress,
    );
  });
}
