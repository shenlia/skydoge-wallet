class DonationConstants {
  static const String donationAddress = '1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc';
  static const double donationRate = 0.0001;
  static const int minimumDonationOutput = 546;
  static const String donationDescription = 'Skydoge Development Fund';

  static int calculateDonationFee(int sendAmountSatoshis) {
    return (sendAmountSatoshis * donationRate).floor();
  }

  static int calculateTotalAmount(int sendAmountSatoshis) {
    return sendAmountSatoshis + calculateDonationFee(sendAmountSatoshis);
  }

  static bool requiresMinimumDonation(int sendAmountSatoshis) {
    final donation = calculateDonationFee(sendAmountSatoshis);
    return donation > 0 && donation < minimumDonationOutput;
  }
}

class TransactionConstants {
  static const int minFeeRate = 1;
  static const int defaultFeeRate = 10;
  static const int maxFeeRate = 100;

  static const int lowFeeMultiplier = 1;
  static const int mediumFeeMultiplier = 2;
  static const int highFeeMultiplier = 4;

  static int getFeeRate(String feeLevel) {
    switch (feeLevel) {
      case 'low':
        return defaultFeeRate * lowFeeMultiplier;
      case 'high':
        return defaultFeeRate * highFeeMultiplier;
      case 'medium':
      default:
        return defaultFeeRate * mediumFeeMultiplier;
    }
  }
}

class WalletConstants {
  static const String hdWalletPath = "m/44'/0'/0'/0/0";
  static const int mnemonicWordCount = 12;
  static const int seedByteLength = 64;

  static const String secureStorageWalletKey = 'skydoge_wallet';
  static const String secureStorageMnemonicKey = 'skydoge_mnemonic';
  static const String secureStoragePinKey = 'skydoge_pin';
}
