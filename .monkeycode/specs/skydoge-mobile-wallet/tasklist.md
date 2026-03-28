# Skydoge Mobile Wallet 实施计划

- [x] 1. 项目初始化与基础结构搭建
  - [x] 1.1 创建 Flutter 项目并配置 pubspec.yaml 依赖
  - [x] 1.2 创建目录结构 (core, data, services, blocs, ui)
  - [x] 1.3 配置网络常量 (mainnet/testnet RPC endpoints)
  - [x] 1.4 创建应用主题和基础组件

- [x] 2. 核心数据模型实现
  - [x] 2.1 实现 Wallet 数据模型
  - [x] 2.2 实现 Transaction 数据模型
  - [x] 2.3 实现 TxInput 和 TxOutput 数据模型
  - [x] 2.4 实现 SidechainInfo 数据模型

- [x] 3. 服务层实现
  - [x] 3.1 实现 SecureStorageService (加密存储服务)
  - [x] 3.2 实现 AddressService (地址服务)
  - [x] 3.3 实现 RpcService (RPC 通信服务)
  - [x] 3.4 实现 TransactionService (交易服务)
  - [x] 3.5 实现 DrivechainService (侧链服务)

- [x] 4. 业务逻辑层 (BLoC) 实现
  - [x] 4.1 实现 WalletBloc
  - [x] 4.2 实现 TransactionBloc
  - [x] 4.3 实现 NetworkBloc

- [x] 5. UI 层实现
  - [x] 5.1 实现 HomeScreen (首页)
  - [x] 5.2 实现 SendScreen (发送页)
  - [x] 5.3 实现 ReceiveScreen (收款页)
  - [x] 5.4 实现 SettingsScreen (设置页)
  - [x] 5.5 实现 SidechainScreen (侧链页)

- [x] 6. 0.1% 手续费功能实现
  - [x] 6.1 创建 DonationCalculator 工具类
  - [x] 6.2 集成 DonationCalculator 到 TransactionBloc
  - [x] 6.3 添加捐赠开关到 SettingsScreen

- [x] 7. 检查点 - 基础功能验证
  - [x] 钱包创建/恢复流程
  - [x] 余额查询功能

- [x] 8. 安全性实现
  - [x] 8.1 集成 local_auth 生物识别认证
  - [x] 8.2 实现钱包锁定/解锁逻辑
  - [x] 8.3 敏感数据内存清理

- [x] 9. 集成测试
  - [x] 9.1 RPC 通信测试 (需连接测试网节点)
  - [x] 9.2 交易构建-签名-广播全流程测试
  - [x] 9.3 钱包从助记词恢复测试

- [x] 10. 最终检查与打包
  - [x] 10.1 Android APK 构建配置
  - [x] 10.2 iOS 构建配置 (如果需要)
  - [x] 10.3 最终功能验证

## v1.0.2 更新 (2026-03-28)

- [x] Bug 修复: WalletWrapper 在 initState 中发送 CheckWalletExistsEvent
- [x] 新增: 中文界面国际化支持 (Settings 页面可切换语言)
- [x] 新增: flutter_localizations 依赖配置
- [x] 新增: LocaleProvider 语言切换管理
