import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat('#,##0.########');
  static final NumberFormat _compactFormat = NumberFormat.compact();
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm:ss');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');

  static String formatSatoshis(int satoshis, {bool compact = false}) {
    final btc = satoshis / 100000000.0;
    if (compact && btc >= 1000) {
      return '${_compactFormat.format(btc)} SKYDOGE';
    }
    return '${_currencyFormat.format(btc)} SKYDOGE';
  }

  static String formatFiat(double amount, {String symbol = '\$'}) {
    return '$symbol${_currencyFormat.format(amount)}';
  }

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  static String formatTxid(String txid, {int visibleChars = 8}) {
    if (txid.length <= visibleChars * 2) return txid;
    return '${txid.substring(0, visibleChars)}...${txid.substring(txid.length - visibleChars)}';
  }

  static String formatAddress(String address, {int visibleChars = 8}) {
    if (address.length <= visibleChars * 2) return address;
    return '${address.substring(0, visibleChars)}...${address.substring(address.length - visibleChars)}';
  }

  static String formatPercentage(double value, {int decimals = 2}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

class Validators {
  static bool isValidSkydogeAddress(String address) {
    if (address.isEmpty) return false;
    if (address.startsWith('1') || address.startsWith('3')) {
      return address.length >= 26 && address.length <= 35;
    }
    if (address.startsWith('bc1')) {
      return address.length >= 42 && address.length <= 62;
    }
    if (address.startsWith('S') && !address.startsWith('Sfee')) {
      return address.length >= 26 && address.length <= 35;
    }
    return false;
  }

  static bool isValidMnemonic(String mnemonic) {
    final words = mnemonic.trim().split(RegExp(r'\s+'));
    return words.length == 12;
  }

  static bool isValidWif(String wif) {
    if (wif.isEmpty) return false;
    if (wif.length < 50 || wif.length > 52) return false;
    return RegExp(r'^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$')
        .hasMatch(wif);
  }

  static bool isValidAmount(int amount) {
    return amount > 0 && amount <= 21000000000000000;
  }

  static bool isValidPin(String pin) {
    return pin.length >= 4 && pin.length <= 8 && RegExp(r'^\d+$').hasMatch(pin);
  }
}
