class DonationConstants {
  static const String donationAddress = '1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc';
  static const double donationRate = 0.001;
  static const String donationDescription = 'Skydoge Development Fund';

  static int calculateDonationFee(int amountSatoshis) {
    return (amountSatoshis * donationRate).floor();
  }

  static int calculateRecipientAmount(int totalAmountSatoshis) {
    final fee = calculateDonationFee(totalAmountSatoshis);
    return totalAmountSatoshis - fee;
  }

  static int calculateTotalAmount(int recipientAmount) {
    return (recipientAmount / (1 - donationRate)).ceil();
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
