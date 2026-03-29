# Skydoge Wallet

Skydoge Wallet 是一个基于 Flutter 的第三方非托管移动钱包，面向 `skydogenet/mainchain`，优先支持 Android，兼容 iOS 架构。

## 当前能力

- 创建 12 词助记词钱包
- 助记词恢复钱包
- 展示收款地址与二维码
- 查询余额与最近交易
- 构造转账并附加强制 donation 输出
- 构建 Android debug/release APK

## 关键业务规则

- 每笔发送交易都会自动附加 donation 输出
- donation 地址固定为 `1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc`
- donation 比例为发送金额的 `0.01%`
- 当 donation 低于最小输出阈值时，交易会被阻止

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
│  ├─ transaction/
│  └─ utils/
├─ data/
├─ services/
└─ ui/
```

## 开发环境

- Flutter 3.24.0
- Dart 3.x
- Android SDK Platform 34+
- Java 17

## 本地运行

```bash
flutter pub get
flutter run
```

## 测试

```bash
flutter test
```

## 构建 APK

```bash
flutter build apk --debug
flutter build apk --release
```

根目录工作流 `.github/workflows/build.yml` 也会在 GitHub Actions 中自动构建 APK 并上传产物。
