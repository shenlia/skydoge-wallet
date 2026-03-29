class TxPreview {
  final String toAddress;
  final int sendAmount;
  final int donationAmount;
  final String donationAddress;
  final int fee;
  final int totalCost;
  final int changeAmount;
  final String network;

  const TxPreview({
    required this.toAddress,
    required this.sendAmount,
    required this.donationAmount,
    required this.donationAddress,
    required this.fee,
    required this.totalCost,
    required this.changeAmount,
    required this.network,
  });
}
