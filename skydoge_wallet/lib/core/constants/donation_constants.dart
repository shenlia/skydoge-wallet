import 'network_constants.dart';

class DonationConstants {
  static const String donationAddress = '1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc';
  static const double donationRate = 0.0001;
  static const String donationDescription = 'Skydoge Development Fund';
  static const int dustThreshold = NetworkConstants.dustThreshold;

  static int calculateDonationFee(int amountSatoshis) {
    return (amountSatoshis * donationRate).floor();
  }

  static bool isDonationBelowDust(int amountSatoshis) {
    final fee = calculateDonationFee(amountSatoshis);
    return fee > 0 && fee < dustThreshold;
  }

  static String getDonationBelowDustWarning() {
    return 'Donation amount (${dustThreshold} satoshis minimum) is below the dust threshold. Please increase the send amount.';
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
