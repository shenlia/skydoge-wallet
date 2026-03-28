# Skydoge Wallet

Skydoge Wallet 是一个基于 Flutter 的第三方非托管移动钱包，面向 `skydogenet/mainchain`，优先支持 Android。

## 当前能力

- 基于 Flutter + Dart 继续开发，没有迁移到 React Native
- 支持创建钱包、12 词助记词恢复、WIF 私钥导入
- 集中维护 Skydoge mainnet/testnet 链参数，见 `lib/core/chain/chain_config.dart`
- 发送流程内置强制 donation 规则
- 交易确认页展示收款金额、donation 金额、donation 地址、fee 和 total cost
- 支持 mainnet/testnet 切换与自定义 RPC 节点保存

## 强制 donation 规则

- donation 地址：`1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc`
- donation 比例：每笔主转账金额的 `0.01%`
- donation 由交易核心自动注入，不能在 UI 中关闭
- donation 低于最小输出阈值时会阻止交易

## 项目结构

```text
lib/
├─ app.dart
├─ main.dart
├─ blocs/
├─ core/
│  ├─ chain/
│  ├─ constants/
│  ├─ theme/
│  └─ utils/
├─ data/
│  ├─ models/
│  └─ repositories/
├─ services/
└─ ui/
   ├─ screens/
   └─ widgets/
```

## 关键设计说明

- `lib/core/chain/chain_config.dart`
  - 统一管理 network id、prefix、genesis、message start、RPC、explorer、derivation path
- `lib/services/address_service.dart`
  - 提供助记词派生、WIF 导入、地址校验与地址生成
- `lib/services/transaction_service.dart`
  - 在交易核心中计算 donation、校验最小 donation 输出、选择 UTXO、生成预览，并在广播前执行本地授权签名校验
- `lib/services/local_signer_service.dart`
  - 使用本地 secp256k1 ECDSA 对待广播的原始交易负载做授权签名与验签
- `lib/services/secure_storage_service.dart`
  - 使用 `flutter_secure_storage` 保存敏感数据，并对持久化内容再做应用层混淆处理

## 已知限制

- 当前已加入本地授权签名与验签流程，用于保证待广播负载在端上完成授权，但完整的 Bitcoin-like input 级原始交易签名仍需继续下沉实现
- Android release 仍使用 debug signing 配置，正式分发前需补充签名配置
- 依赖 Flutter SDK 与 Android SDK，本仓库本身不携带这些系统依赖

## 开发环境

- Flutter SDK 3.24.0
- Dart 3.x
- Java OpenJDK 17
- Android SDK Platform 34

## 本地运行

```bash
# 获取依赖
flutter pub get

# 运行测试
flutter test

# 调试运行
flutter run
```

## 构建 APK

```bash
# 构建 debug APK
flutter build apk --debug

# 构建 release APK
flutter build apk --release
```

默认输出位置：

- `build/app/outputs/flutter-apk/app-debug.apk`
- `build/app/outputs/flutter-apk/app-release.apk`

## 测试说明

当前补充了以下单元测试：

- `test/core/donation_constants_test.dart`
- `test/services/address_service_test.dart`
- `test/services/transaction_service_test.dart`

建议在具备 Flutter 环境后执行：

```bash
flutter test
```

## Android 发布说明

当前 `android/app/build.gradle` 仍是开发态配置：

- `release` 仍使用 debug signing
- 正式发布前请补充 keystore 和 release signingConfig

## 安全说明

- 助记词、私钥、WIF 仅保存在设备端
- 不上传 seed 或私钥到服务端
- 发送确认页明确展示 donation 与 total cost
