# Skydoge Mobile Wallet 实施计划

- [ ] 1. 项目初始化与基础结构搭建
  - [ ] 1.1 创建 Flutter 项目并配置 pubspec.yaml 依赖
    - flutter create skydoge_wallet
    - 添加 flutter_coinector, bip39, bip32, http, flutter_secure_storage, provider, local_auth, qr_flutter, shared_preferences, equatable, intl
  - [ ] 1.2 创建目录结构 (core, data, services, blocs, ui)
  - [ ] 1.3 配置网络常量 (mainnet/testnet RPC endpoints)
  - [ ] 1.4 创建应用主题和基础组件

- [ ] 2. 核心数据模型实现
  - [ ] 2.1 实现 Wallet 数据模型
    - 包含 mnemonic, seed, privateKey, publicKey, receivingAddress, network
  - [ ] 2.2 实现 Transaction 数据模型
    - 包含 txid, inputs, outputs, fee, donationFee, isBroadcasted
  - [ ] 2.3 实现 TxInput 和 TxOutput 数据模型
  - [ ] 2.4 实现 SidechainInfo 数据模型

- [ ] 3. 服务层实现
  - [ ] 3.1 实现 SecureStorageService (加密存储服务)
    - iOS Keychain / Android Keystore 集成
    - AES-256 加密 mnemonic
  - [ ] 3.2 实现 AddressService (地址服务)
    - BIP39 助记词生成
    - BIP32 HD 钱包派生
    - BIP84 Bech32 地址生成
    - 地址格式验证 (Legacy/P2SH-SegWit/Bech32)
  - [ ] 3.3 实现 RpcService (RPC 通信服务)
    - Bitcoin Core 兼容 JSON-RPC 调用
    - getbalance, listtransactions, sendtoaddress, getblockchaininfo
  - [ ] 3.4 实现 TransactionService (交易服务)
    - 交易构建 (UTXO 选择)
    - 交易签名
    - 交易广播
  - [ ] 3.5 实现 DrivechainService (侧链服务)
    - getsidechaininfo, getdepositlist, getwithdrawallist
    - simpleDrivechainDeposit, simpleDrivechainWithdraw

- [ ] 4. 业务逻辑层 (BLoC) 实现
  - [ ] 4.1 实现 WalletBloc
    - CreateWallet / RecoverWallet / UnlockWallet / LockWallet / RefreshBalance events
    - 状态管理: Initial / Loading / Loaded / Locked / Error
  - [ ] 4.2 实现 TransactionBloc
    - BuildTransaction / SignTransaction / BroadcastTransaction events
    - 0.001% 强制捐赠计算集成
    - 状态管理: Ready / Built / Broadcasted / Error
  - [ ] 4.3 实现 NetworkBloc
    - 网络切换 (mainnet/testnet)
    - 节点连接状态管理

- [ ] 5. UI 层实现
  - [ ] 5.1 实现 HomeScreen (首页)
    - 余额显示卡片
    - 最近交易列表
    - 刷新功能
  - [ ] 5.2 实现 SendScreen (发送页)
    - 收款地址输入 (支持扫码)
    - 金额输入
    - 手续费选择 (low/medium/high)
    - 0.001% 强制捐赠展示
    - 交易确认对话框
  - [ ] 5.3 实现 ReceiveScreen (收款页)
    - 收款地址 QR 码显示
    - 地址复制功能
  - [ ] 5.4 实现 SettingsScreen (设置页)
    - 网络切换 (Mainnet/Testnet)
    - 生物识别认证开关
    - 强制捐赠规则展示
    - 钱包备份 (显示助记词)
  - [ ] 5.5 实现 SidechainScreen (侧链页)
    - 侧链余额显示
    - 跨链充值/提现操作

- [ ] 6. 0.001% 强制捐赠功能实现
  - [ ] 6.1 创建 DonationCalculator 工具类
    - 硬编码主网捐赠地址: 1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc
    - 计算 0.001% 捐赠金额
    - 计算交易总支出
  - [ ] 6.2 集成 DonationCalculator 到 TransactionBloc
    - 在 BuildTransaction 时自动计算捐赠金额
    - 在交易确认对话框中显示捐赠详情
  - [ ] 6.3 在 SettingsScreen 展示强制捐赠规则
    - 明确显示捐赠地址与固定费率

- [ ] 7. 检查点 - 基础功能验证
  - 确保项目可以编译运行
  - 验证钱包创建/恢复流程
  - 验证余额查询功能

- [ ] 8. 安全性实现
  - [ ] 8.1 集成 local_auth 生物识别认证
  - [ ] 8.2 实现钱包锁定/解锁逻辑
  - [ ] 8.3 敏感数据内存清理

- [ ] 9. 集成测试
  - [ ] 9.1 RPC 通信测试 (需连接测试网节点)
  - [ ] 9.2 交易构建-签名-广播全流程测试
  - [ ] 9.3 钱包从助记词恢复测试

- [ ] 10. 最终检查与打包
  - [ ] 10.1 Android APK 构建配置
  - [ ] 10.2 iOS 构建配置 (如果需要)
  - [ ] 10.3 最终功能验证
