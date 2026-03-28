import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

abstract class S {
  S(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  String get appTitle;
  String get home;
  String get sidechains;
  String get settings;
  String get send;
  String get receive;
  String get createNewWallet;
  String get createNewWalletDesc;
  String get recoverExistingWallet;
  String get recoverExistingWalletDesc;
  String get mnemonicPhrase;
  String get enterMnemonicHint;
  String get recoverWallet;
  String get back;
  String get network;
  String get mainnet;
  String get testnet;
  String get skydogeWallet;
  String get yourGatewayToSkydoge;
  String get enterPin;
  String get unlock;
  String get invalidPin;
  String get retry;
  String get confirmBackupTitle;
  String get backupWarning;
  String get doNotShareWarning;
  String get iHaveWrittenDown;
  String get continueText;
  String get recentTransactions;
  String get noTransactionsYet;
  String get confirmed;
  String get unconfirmed;
  String get address;
  String get copyAddress;
  String get addressCopied;
  String get scanQrCode;
  String get recipientAddress;
  String get enterRecipientAddress;
  String get amount;
  String get enterAmount;
  String get fee;
  String get low;
  String get medium;
  String get high;
  String get donation;
  String get donationDesc;
  String get donationEnabled;
  String get donationDisabled;
  String get total;
  String get confirmTransaction;
  String get cancel;
  String get sendTransaction;
  String get transactionSent;
  String get transactionFailed;
  String get txId;
  String get viewOnExplorer;
  String get balance;
  String get deposit;
  String get withdraw;
  String get sidechainBalance;
  String get pendingDeposits;
  String get pendingWithdrawals;
  String get estimatedTime;
  String get language;
  String get english;
  String get chinese;
  String get biometricAuth;
  String get enableBiometric;
  String get changePin;
  String get backupWallet;
  String get viewMnemonic;
  String get deleteWallet;
  String get deleteWalletWarning;
  String get delete;
  String get walletDeleted;
  String get about;
  String get version;
  String get pleaseEnterValidMnemonic;
  String get walletNotFound;
  String get walletLoading;
  String get failedToCheckWallet;
  String get failedToCreateWallet;
  String get failedToRecoverWallet;
  String get failedToUnlockWallet;
  String get failedToRefreshBalance;
  String get insufficientBalance;
  String get invalidAddress;
  String get pleaseEnterValidAddress;
  String get pleaseEnterValidAmount;
  String get custom;
  String get donationFee;
  String get pleaseConfirmBackup;
  String get importantSaveMnemonic;
  String get mnemonicDescription;
  String get yourMnemonicPhrase;
  String get tapToReveal;
  String get copyToClipboard;
  String get mnemonicCopied;
  String get iUnderstandContinue;
  String get sendSkydoge;
  String get scanQrToReceive;
  String get yourAddress;
  String get onlySendSkydoge;
  String get share;
  String get confirmSend;
  String get continueBtn;
  String get transactionFee;
  String get includeDonation;
  String get donationAmount;
  String get lowFee;
  String get mediumFee;
  String get highFee;
  String get customFee;
  String get customNode;
  String get defaultNode;
  String get resetToDefault;
  String get customNodeConfig;
  String get host;
  String get port;
  String get rpcUsername;
  String get rpcPassword;
  String get pleaseFillAllFields;
  String get customNodeSaved;
  String get blockExplorer;
  String get openBlockExplorer;
  String get viewTransaction;
  String get switchNetwork;
  String get switchNetworkConfirm;
  String get switchToMainnet;
  String get switchToTestnet;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'zh':
      return SZh();
  }
  return SEn();
}

class SEn extends S {
  SEn() : super('en');

  @override
  String get appTitle => 'Skydoge Wallet';
  @override
  String get home => 'Home';
  @override
  String get sidechains => 'Sidechains';
  @override
  String get settings => 'Settings';
  @override
  String get send => 'Send';
  @override
  String get receive => 'Receive';
  @override
  String get createNewWallet => 'Create New Wallet';
  @override
  String get createNewWalletDesc => 'Generate a new wallet with a secure mnemonic phrase';
  @override
  String get recoverExistingWallet => 'Recover Existing Wallet';
  @override
  String get recoverExistingWalletDesc => 'Restore your wallet using a 12-word mnemonic phrase';
  @override
  String get mnemonicPhrase => 'Mnemonic Phrase';
  @override
  String get enterMnemonicHint => 'Enter your 12-word mnemonic phrase';
  @override
  String get recoverWallet => 'Recover Wallet';
  @override
  String get back => 'Back';
  @override
  String get network => 'Network';
  @override
  String get mainnet => 'Mainnet';
  @override
  String get testnet => 'Testnet';
  @override
  String get skydogeWallet => 'Skydoge Wallet';
  @override
  String get yourGatewayToSkydoge => 'Your gateway to the Skydoge ecosystem';
  @override
  String get enterPin => 'Enter PIN';
  @override
  String get unlock => 'Unlock';
  @override
  String get invalidPin => 'Invalid PIN';
  @override
  String get retry => 'Retry';
  @override
  String get confirmBackupTitle => 'Backup Your Wallet';
  @override
  String get backupWarning => 'Write down these words in order and store them safely. Anyone with access to your mnemonic phrase can access your funds.';
  @override
  String get doNotShareWarning => 'Never share your mnemonic phrase with anyone!';
  @override
  String get iHaveWrittenDown => 'I have written down my mnemonic phrase';
  @override
  String get continueText => 'Continue';
  @override
  String get recentTransactions => 'Recent Transactions';
  @override
  String get noTransactionsYet => 'No transactions yet';
  @override
  String get confirmed => 'Confirmed';
  @override
  String get unconfirmed => 'Unconfirmed';
  @override
  String get address => 'Address';
  @override
  String get copyAddress => 'Copy Address';
  @override
  String get addressCopied => 'Address copied to clipboard';
  @override
  String get scanQrCode => 'Scan QR Code';
  @override
  String get recipientAddress => 'Recipient Address';
  @override
  String get enterRecipientAddress => 'Enter recipient address';
  @override
  String get amount => 'Amount';
  @override
  String get enterAmount => 'Enter amount';
  @override
  String get fee => 'Fee';
  @override
  String get low => 'Low';
  @override
  String get medium => 'Medium';
  @override
  String get high => 'High';
  @override
  String get donation => 'Donation';
  @override
  String get donationDesc => '0.1% will be donated to support Skydoge development';
  @override
  String get donationEnabled => 'Donation enabled';
  @override
  String get donationDisabled => 'Donation disabled';
  @override
  String get total => 'Total';
  @override
  String get confirmTransaction => 'Confirm Transaction';
  @override
  String get cancel => 'Cancel';
  @override
  String get sendTransaction => 'Send Transaction';
  @override
  String get transactionSent => 'Transaction sent successfully';
  @override
  String get transactionFailed => 'Transaction failed';
  @override
  String get txId => 'Transaction ID';
  @override
  String get viewOnExplorer => 'View on Explorer';
  @override
  String get balance => 'Balance';
  @override
  String get deposit => 'Deposit';
  @override
  String get withdraw => 'Withdraw';
  @override
  String get sidechainBalance => 'Sidechain Balance';
  @override
  String get pendingDeposits => 'Pending Deposits';
  @override
  String get pendingWithdrawals => 'Pending Withdrawals';
  @override
  String get estimatedTime => 'Estimated Time';
  @override
  String get language => 'Language';
  @override
  String get english => 'English';
  @override
  String get chinese => 'Chinese (Simplified)';
  @override
  String get biometricAuth => 'Biometric Authentication';
  @override
  String get enableBiometric => 'Enable biometric authentication';
  @override
  String get changePin => 'Change PIN';
  @override
  String get backupWallet => 'Backup Wallet';
  @override
  String get viewMnemonic => 'View Recovery Phrase';
  @override
  String get deleteWallet => 'Delete Wallet';
  @override
  String get deleteWalletWarning => 'Are you sure you want to delete your wallet? This action cannot be undone.';
  @override
  String get delete => 'Delete';
  @override
  String get walletDeleted => 'Wallet deleted';
  @override
  String get about => 'About';
  @override
  String get version => 'Version';
  @override
  String get pleaseEnterValidMnemonic => 'Please enter a valid 12-word mnemonic';
  @override
  String get walletNotFound => 'Wallet not found';
  @override
  String get walletLoading => 'Loading wallet...';
  @override
  String get failedToCheckWallet => 'Failed to check wallet';
  @override
  String get failedToCreateWallet => 'Failed to create wallet';
  @override
  String get failedToRecoverWallet => 'Failed to recover wallet';
  @override
  String get failedToUnlockWallet => 'Failed to unlock wallet';
  @override
  String get failedToRefreshBalance => 'Failed to refresh balance';
  @override
  String get insufficientBalance => 'Insufficient balance';
  @override
  String get invalidAddress => 'Invalid address';
  @override
  String get pleaseEnterValidAddress => 'Please enter a valid address';
  @override
  String get pleaseEnterValidAmount => 'Please enter a valid amount';
  @override
  String get custom => 'Custom';
  @override
  String get donationFee => 'Donation Fee';
  @override
  String get pleaseConfirmBackup => 'Please confirm that you have backed up your mnemonic phrase';
  @override
  String get importantSaveMnemonic => 'Important: Save Your Mnemonic';
  @override
  String get mnemonicDescription => 'Write down these 12 words in order and store them safely. This is the only way to recover your wallet if you lose access to your device.';
  @override
  String get yourMnemonicPhrase => 'Your Mnemonic Phrase';
  @override
  String get tapToReveal => 'Tap the eye icon to reveal';
  @override
  String get copyToClipboard => 'Copy to Clipboard';
  @override
  String get mnemonicCopied => 'Mnemonic copied to clipboard';
  @override
  String get iUnderstandContinue => 'I Understand, Continue';
  @override
  String get sendSkydoge => 'Send SKYDOGE';
  @override
  String get scanQrToReceive => 'Scan QR code to receive SKYDOGE';
  @override
  String get yourAddress => 'Your Address';
  @override
  String get onlySendSkydoge => 'Only send SKYDOGE to this address. Sending other assets may result in permanent loss.';
  @override
  String get share => 'Share';
  @override
  String get confirmSend => 'Confirm & Send';
  @override
  String get continueBtn => 'Continue';
  @override
  String get transactionFee => 'Transaction Fee';
  @override
  String get includeDonation => 'Include 0.1% Donation';
  @override
  String get donationAmount => 'Donation Amount:';
  @override
  String get lowFee => 'Low Fee';
  @override
  String get mediumFee => 'Medium Fee';
  @override
  String get highFee => 'High Fee';
  @override
  String get customFee => 'Custom Fee';
  @override
  String get customNode => 'Custom Node';
  @override
  String get defaultNode => 'Default Node';
  @override
  String get resetToDefault => 'Reset to Default';
  @override
  String get customNodeConfig => 'Custom Node Configuration';
  @override
  String get host => 'Host';
  @override
  String get port => 'Port';
  @override
  String get rpcUsername => 'RPC Username';
  @override
  String get rpcPassword => 'RPC Password';
  @override
  String get pleaseFillAllFields => 'Please fill in all fields';
  @override
  String get customNodeSaved => 'Custom node saved. Restart app to apply.';
  @override
  String get blockExplorer => 'Block Explorer';
  @override
  String get openBlockExplorer => 'Open Block Explorer';
  @override
  String get viewTransaction => 'View Transaction';
  @override
  String get switchNetwork => 'Switch Network';
  @override
  String get switchNetworkConfirm => 'Are you sure you want to switch networks? This will clear cached data.';
  @override
  String get switchToMainnet => 'Switch to Mainnet';
  @override
  String get switchToTestnet => 'Switch to Testnet';
}

class SZh extends S {
  SZh() : super('zh');

  @override
  String get appTitle => 'Skydoge 钱包';
  @override
  String get home => '首页';
  @override
  String get sidechains => '侧链';
  @override
  String get settings => '设置';
  @override
  String get send => '发送';
  @override
  String get receive => '收款';
  @override
  String get createNewWallet => '创建新钱包';
  @override
  String get createNewWalletDesc => '生成一个带有安全助记词的新钱包';
  @override
  String get recoverExistingWallet => '恢复已有钱包';
  @override
  String get recoverExistingWalletDesc => '使用12位助记词恢复您的钱包';
  @override
  String get mnemonicPhrase => '助记词';
  @override
  String get enterMnemonicHint => '请输入您的12位助记词';
  @override
  String get recoverWallet => '恢复钱包';
  @override
  String get back => '返回';
  @override
  String get network => '网络';
  @override
  String get mainnet => '主网';
  @override
  String get testnet => '测试网';
  @override
  String get skydogeWallet => 'Skydoge 钱包';
  @override
  String get yourGatewayToSkydoge => '您的 Skydoge 生态系统入口';
  @override
  String get enterPin => '输入PIN码';
  @override
  String get unlock => '解锁';
  @override
  String get invalidPin => 'PIN码无效';
  @override
  String get retry => '重试';
  @override
  String get confirmBackupTitle => '备份您的钱包';
  @override
  String get backupWarning => '请按顺序写下这些单词并妥善保管。任何获得您助记词的人都可以访问您的资金。';
  @override
  String get doNotShareWarning => '切勿与任何人分享您的助记词！';
  @override
  String get iHaveWrittenDown => '我已经记下了我的助记词';
  @override
  String get continueText => '继续';
  @override
  String get recentTransactions => '最近交易';
  @override
  String get noTransactionsYet => '暂无交易记录';
  @override
  String get confirmed => '已确认';
  @override
  String get unconfirmed => '未确认';
  @override
  String get address => '地址';
  @override
  String get copyAddress => '复制地址';
  @override
  String get addressCopied => '地址已复制到剪贴板';
  @override
  String get scanQrCode => '扫描二维码';
  @override
  String get recipientAddress => '收款地址';
  @override
  String get enterRecipientAddress => '输入收款地址';
  @override
  String get amount => '金额';
  @override
  String get enterAmount => '输入金额';
  @override
  String get fee => '手续费';
  @override
  String get low => '低';
  @override
  String get medium => '中';
  @override
  String get high => '高';
  @override
  String get donation => '捐赠';
  @override
  String get donationDesc => '0.1%将捐赠给Skydoge开发团队';
  @override
  String get donationEnabled => '已启用捐赠';
  @override
  String get donationDisabled => '已禁用捐赠';
  @override
  String get total => '总计';
  @override
  String get confirmTransaction => '确认交易';
  @override
  String get cancel => '取消';
  @override
  String get sendTransaction => '发送交易';
  @override
  String get transactionSent => '交易发送成功';
  @override
  String get transactionFailed => '交易失败';
  @override
  String get txId => '交易ID';
  @override
  String get viewOnExplorer => '在浏览器中查看';
  @override
  String get balance => '余额';
  @override
  String get deposit => '充值';
  @override
  String get withdraw => '提现';
  @override
  String get sidechainBalance => '侧链余额';
  @override
  String get pendingDeposits => '待处理充值';
  @override
  String get pendingWithdrawals => '待处理提现';
  @override
  String get estimatedTime => '预计时间';
  @override
  String get language => '语言';
  @override
  String get english => 'English';
  @override
  String get chinese => '简体中文';
  @override
  String get biometricAuth => '生物识别认证';
  @override
  String get enableBiometric => '启用生物识别认证';
  @override
  String get changePin => '修改PIN码';
  @override
  String get backupWallet => '备份钱包';
  @override
  String get viewMnemonic => '查看助记词';
  @override
  String get deleteWallet => '删除钱包';
  @override
  String get deleteWalletWarning => '您确定要删除钱包吗？此操作无法撤销。';
  @override
  String get delete => '删除';
  @override
  String get walletDeleted => '钱包已删除';
  @override
  String get about => '关于';
  @override
  String get version => '版本';
  @override
  String get pleaseEnterValidMnemonic => '请输入有效的12位助记词';
  @override
  String get walletNotFound => '未找到钱包';
  @override
  String get walletLoading => '正在加载钱包...';
  @override
  String get failedToCheckWallet => '检查钱包失败';
  @override
  String get failedToCreateWallet => '创建钱包失败';
  @override
  String get failedToRecoverWallet => '恢复钱包失败';
  @override
  String get failedToUnlockWallet => '解锁钱包失败';
  @override
  String get failedToRefreshBalance => '刷新余额失败';
  @override
  String get insufficientBalance => '余额不足';
  @override
  String get invalidAddress => '地址无效';
  @override
  String get pleaseEnterValidAddress => '请输入有效地址';
  @override
  String get pleaseEnterValidAmount => '请输入有效金额';
  @override
  String get custom => '自定义';
  @override
  String get donationFee => '捐赠手续费';
  @override
  String get pleaseConfirmBackup => '请确认您已备份助记词';
  @override
  String get importantSaveMnemonic => '重要提示：请保存您的助记词';
  @override
  String get mnemonicDescription => '请按顺序写下这12个单词并妥善保管。这是您恢复钱包的唯一方式。';
  @override
  String get yourMnemonicPhrase => '您的助记词';
  @override
  String get tapToReveal => '点击眼睛图标显示';
  @override
  String get copyToClipboard => '复制到剪贴板';
  @override
  String get mnemonicCopied => '助记词已复制到剪贴板';
  @override
  String get iUnderstandContinue => '我已知晓，继续';
  @override
  String get sendSkydoge => '发送 SKYDOGE';
  @override
  String get scanQrToReceive => '扫描二维码收款';
  @override
  String get yourAddress => '您的地址';
  @override
  String get onlySendSkydoge => '请只向此地址发送SKYDOGE。发送其他资产可能导致永久丢失。';
  @override
  String get share => '分享';
  @override
  String get confirmSend => '确认并发送';
  @override
  String get continueBtn => '继续';
  @override
  String get transactionFee => '交易手续费';
  @override
  String get includeDonation => '包含0.1%捐赠';
  @override
  String get donationAmount => '捐赠金额：';
  @override
  String get lowFee => '低手续费';
  @override
  String get mediumFee => '中手续费';
  @override
  String get highFee => '高手续费';
  @override
  String get customFee => '自定义手续费';
  @override
  String get customNode => '自定义节点';
  @override
  String get defaultNode => '默认节点';
  @override
  String get resetToDefault => '恢复默认';
  @override
  String get customNodeConfig => '自定义节点配置';
  @override
  String get host => '主机';
  @override
  String get port => '端口';
  @override
  String get rpcUsername => 'RPC用户名';
  @override
  String get rpcPassword => 'RPC密码';
  @override
  String get pleaseFillAllFields => '请填写所有字段';
  @override
  String get customNodeSaved => '自定义节点已保存。重启应用以生效。';
  @override
  String get blockExplorer => '区块浏览器';
  @override
  String get openBlockExplorer => '打开区块浏览器';
  @override
  String get viewTransaction => '查看交易';
  @override
  String get switchNetwork => '切换网络';
  @override
  String get switchNetworkConfirm => '您确定要切换网络吗？这将清除缓存数据。';
  @override
  String get switchToMainnet => '切换到主网';
  @override
  String get switchToTestnet => '切换到测试网';
}
