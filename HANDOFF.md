# HANDOFF

## 项目概况

本仓库是 `skydoge-wallet`，当前重点开发目标是：在现有 Flutter + Dart 项目基础上，持续对齐《Skydoge 钱包技术架构设计文档 v0.2（Flutter 版）》。

必须遵守的原则：

- 继续基于当前 Flutter 仓库开发
- 不迁移到 React Native
- donation 规则必须落实在交易核心逻辑
- 私钥只允许保存在端上
- 签名必须在端上完成
- 最终需要能构建 Android APK

---

## 当前仓库与分支

- 仓库地址：`https://github.com/shenlia/skydoge-wallet.git`
- 当前工作分支：`260329-feat-align-skydoge-wallet-v2`
- 默认分支：`main`

接手后建议先执行：

```bash
git checkout 260329-feat-align-skydoge-wallet-v2
git pull
git status
```

Pull Request 入口：

- `https://github.com/shenlia/skydoge-wallet/pull/new/260329-feat-align-skydoge-wallet-v2`

注意：

- 之前尝试用 `gh pr create` 创建 PR 失败，原因是当前环境没有 GitHub CLI 认证
- 之前尝试运行 Flutter 命令失败，原因是环境里没有 `flutter`

---

## 当前已完成工作

### 1. 2.0 设计基础对齐

已完成以下基础对齐：

- 新增链配置集中管理：
  - `skydoge_wallet/lib/core/chain/chain_config.dart`
- 修正 donation 比例：
  - 从旧版 `0.1%` 改为 `0.01%`
- donation 改为强制开启：
  - UI 中不再允许关闭
- 发送确认页展示增强：
  - 收款地址
  - 发送金额
  - donation 金额
  - donation 地址
  - fee
  - total cost
  - network
- README 已重写，替换 Flutter 默认模板：
  - `skydoge_wallet/README.md`

---

### 2. 钱包能力

已实现：

- 创建助记词钱包
- 助记词恢复钱包
- WIF 导入钱包

WIF 导入相关实现包括：

- `ImportWifWalletEvent`
- `WalletBloc` 中的导入处理
- `WelcomeScreen` 中的 WIF 导入入口
- `AddressService` 中的 Base58 / WIF 解析与地址派生

关键文件：

- `skydoge_wallet/lib/blocs/wallet/wallet_event.dart`
- `skydoge_wallet/lib/blocs/wallet/wallet_bloc.dart`
- `skydoge_wallet/lib/ui/screens/welcome_screen.dart`
- `skydoge_wallet/lib/services/address_service.dart`

---

### 3. donation 规则

当前 donation 逻辑已调整到 2.0 目标方向：

- donation 地址固定
- donation 比例为 `0.01%`
- donation 为强制输出
- donation 计入总支出
- donation 太小时阻止交易

关键文件：

- `skydoge_wallet/lib/core/constants/donation_constants.dart`
- `skydoge_wallet/lib/services/transaction_service.dart`
- `skydoge_wallet/lib/ui/screens/send_screen.dart`
- `skydoge_wallet/lib/ui/screens/settings_screen.dart`

---

### 4. 本地签名能力

当前已实现 P2PKH 路径的本地签名主干。

已完成：

- 本地序列化 unsigned raw transaction
- 本地生成签名前镜像
- 本地计算 `SIGHASH_ALL`
- 使用 secp256k1 进行本地 ECDSA 签名
- DER 编码签名
- 拼装 P2PKH `scriptSig`
- 生成 signed raw tx
- 发送主路径改为走 `signLocally(...)`

关键文件：

- `skydoge_wallet/lib/services/transaction_service.dart`

---

### 5. 测试

已新增测试：

- `skydoge_wallet/test/donation_constants_test.dart`
- `skydoge_wallet/test/address_service_test.dart`
- `skydoge_wallet/test/transaction_service_test.dart`

覆盖方向：

- donation 计算
- 助记词派生地址
- WIF 导入
- 本地签名的输入归属校验
- 缺少 `scriptPubKey` 的签名拒绝逻辑

注意：
- 当前还没有真正执行 `flutter test`
- 原因是当前环境缺少 `flutter`

---

## 最近关键提交

按顺序的重要提交如下：

- `0e94e9a` - `align wallet flow with skydoge v2 design`
- `50cdc94` - `add wif wallet import flow`
- `a768290` - `tighten local signing validation`
- `df8825e` - `add local p2pkh transaction signing`
- `93463fd` - `add project handoff guide`

建议接手者优先查看这些提交对应的差异。

---

## 当前关键文件

优先阅读：

- `skydoge_wallet/lib/core/chain/chain_config.dart`
- `skydoge_wallet/lib/core/constants/donation_constants.dart`
- `skydoge_wallet/lib/core/constants/network_constants.dart`
- `skydoge_wallet/lib/services/address_service.dart`
- `skydoge_wallet/lib/services/transaction_service.dart`
- `skydoge_wallet/lib/blocs/wallet/wallet_bloc.dart`
- `skydoge_wallet/lib/ui/screens/welcome_screen.dart`
- `skydoge_wallet/lib/ui/screens/send_screen.dart`
- `skydoge_wallet/test/address_service_test.dart`
- `skydoge_wallet/test/transaction_service_test.dart`
- `HANDOFF.md`

---

## 当前仍未完成的工作

### 1. 验证并修正本地签名

虽然已经实现了 P2PKH 本地签名主干，但还没有经过真实广播验证。

必须优先验证：

- unsigned tx 序列化是否与链节点兼容
- sighash 计算是否正确
- DER 编码是否被节点接受
- `scriptSig` 拼装是否正确
- testnet 小额交易是否可以广播成功

这是当前第一优先级。

---

### 2. 地址和脚本类型扩展

当前本地签名实现主要面向：

- legacy / P2PKH

还未完善：

- bech32
- P2SH
- sidechain 地址
- 其他脚本类型的 UTXO 签名

如果后续需求涉及这些类型，需要继续扩展。

---

### 3. UI 功能缺口

以下能力仍需继续补齐：

- 交易历史页
- 交易详情页
- donation 输出详情展示
- block explorer 链接
- 发送成功后的状态刷新

说明：
- `transaction_tile.dart` 中仍存在 block explorer 相关 TODO

---

### 4. 安全能力缺口

虽然已使用 `flutter_secure_storage`，但仍不是最终安全方案。

还需要继续加强：

- seed / privateKey 的应用层加密
- PIN / 生物识别联动
- 解锁生命周期管理
- 内存中敏感数据处理

---

### 5. 测试缺口

仍需补充：

- Widget 测试
- 集成测试
- donation 全链路专项测试
- 确认页展示测试
- 交易详情/历史展示测试
- 本地签名广播流程测试

---

## 最近一轮新增进展

2026-03-29 新增进展：

- 已把正式交接文档写入仓库根目录 `HANDOFF.md`
- 已明确要求后续每一轮开发完成后，都必须同步更新 `HANDOFF.md`
- 已补充交易详情弹层中的主要输出展示
- 已将区块浏览器按钮从纯 TODO 改为可给出浏览器交易链接提示
- 已新增独立交易历史页面，并在首页提供 `View All` 入口
- 已新增独立交易详情页面，并将交易列表点击行为切换为详情页跳转

本轮仍未解决：

- 区块浏览器当前只是提示链接，尚未接入真正跳转能力
- 本地签名仍需 testnet 广播验证
- Flutter 测试和构建仍未在当前环境实际执行
- 区块浏览器当前仍只是展示链接提示，尚未接入真正外部跳转

2026-03-29 接手验证进展（当前轮）：

- 已切换并拉取 `260329-feat-align-skydoge-wallet-v2`
- 已读取 `HANDOFF.md` 并按第一优先级开始检查 testnet 广播链路
- 已确认当前环境仍缺少 `flutter` 和 `dart`，无法直接运行 Flutter/Dart 测试或构造一次真实钱包发送
- 已确认 `testnet.skydoge.net` 与 `testnet.explorer.skydoge.net` 当前在本环境中无法解析 DNS，无法连通 testnet RPC/浏览器做真实广播验证
- 已确认 `explorer.skydoge.net` 主网浏览器可访问，说明当前阻塞点集中在 testnet 域名不可解析，而非整体外网不可用
- 已修正 `AddressService.validateAddress(...)`，补齐 testnet legacy/bech32 前缀识别：`m`、`n`、`2`、`tb1`
- 已补充对应地址校验测试用例，避免 testnet 地址在发送前被前端本地校验错误拦截

本轮结论：

- 还不能证明“本地 P2PKH 签名后的 raw tx 可以在 testnet 成功广播”
- 当前最直接阻塞因素是：缺少可解析的 testnet RPC/浏览器地址，以及缺少 Flutter/Dart 运行环境
- 在具备可用 testnet 节点或用户提供可访问的自定义 testnet RPC 后，应继续做真实 signed raw tx 广播验证

2026-03-30 UI 补齐进展（当前轮）：

- 已把 `TransactionTile` 的网络态透传到交易详情页，避免 testnet 交易仍错误推断为 mainnet 浏览器链接
- 已增强 `transaction_history_screen.dart`，新增交易总数、收款数、付款数、donation 数和当前网络的摘要信息
- 已增强 `transaction_detail_screen.dart`，在概览区新增 `Network` 字段，便于确认当前交易所属网络
- 已补充交易详情页的 Explorer 区块，支持直接复制 `txid` 和 explorer 链接，减少手动拼接链接成本
- 已把首页交易列表的详情跳转同步接入网络态，保证首页与历史页进入详情时行为一致

本轮仍未解决：

- 区块浏览器仍未接入真正的外部跳转能力，当前仍以展示和复制链接为主
- 当前环境仍缺少 `flutter` / `dart`，因此本轮无法执行 Flutter 格式化、测试或真机验证
- 本地签名的 testnet 广播验证仍受 testnet 域名不可解析影响，主优先级不变

2026-03-30 浏览器跳转与广播保护进展（当前轮）：

- 已在 `transaction_detail_screen.dart` 接入 `url_launcher`，点击 `View on Block Explorer` 会尝试使用外部应用真正打开区块浏览器链接
- 已保留复制 `txid` 与 explorer 链接能力，作为外部跳转失败时的退路
- 已修正 UI 层 `Validators.isValidSkydogeAddress(...)`，补齐 testnet legacy / P2SH / bech32 前缀识别，避免发送页先于服务层把 testnet 地址误判为非法
- 已修正 `AddressService._validateBech32Address(...)`，允许 `tb1` testnet bech32 地址通过基础校验
- 已修正 `TransactionBloc` 广播链路，避免 `BroadcastTransactionEvent` 误把 unsigned raw tx 直接送去 `sendrawtransaction`
- 已在 `TransactionService.broadcastTransaction(...)` 增加最小签名外观校验，拒绝明显未签名的占位 payload，降低误广播错误 raw tx 的风险
- 已补充测试用例，覆盖 UI 地址校验和未签名 payload 广播拒绝逻辑

本轮结论：

- 区块浏览器体验已从“仅提示链接”推进到“尝试真实外部跳转 + 失败时可复制链接”
- 本地签名广播链路已补上一个关键保护：不会再从 `TransactionBloc` 直接广播 `_unsignedTransaction.rawHex`
- 但这仍不等于完成 testnet 广播验证；当前仍缺少可用 testnet 节点与 Flutter 运行环境做真实验证

2026-03-30 压缩公钥一致性排查进展（当前轮）：

- 已继续静态排查本地签名链路，发现 `AddressService.deriveWallet(...)` 使用的是 BIP32 返回的压缩公钥，而 `getAddressFromPrivateKey(...)` / `getPublicKeyFromPrivateKey(...)` 之前返回的是未压缩公钥
- 这会导致“同一个私钥推导地址”和“钱包持久化地址”在某些路径下不一致，进而影响 `TransactionService.signLocally(...)` 的输入归属校验与签名后 `scriptSig` 中公钥格式
- 已将 `AddressService._publicKeyFromPrivateKey(...)` 改为统一返回压缩公钥，和助记词 / WIF 导入路径保持一致
- 已补充测试，验证 `getAddressFromPrivateKey(...)` 与助记词派生钱包地址一致，避免后续再次出现公钥压缩格式漂移
- 已补充本地签名测试，覆盖“助记词派生私钥 + 对应地址”场景，确保签名流程不会因为地址推导不一致而被自身拦截

本轮结论：

- 当前本地签名链路在“地址推导格式一致性”这一层已经更接近真实链上要求，压缩公钥是更合理的默认选择
- 这仍然不是对 testnet 广播成功的证明；后续仍需在可用节点环境里验证 raw tx 是否被链节点接受

2026-03-30 交易构造兼容性排查进展（当前轮）：

- 已继续检查 `TransactionService.buildTransaction(...)`，发现找零若小于 dust 阈值时此前仍会被当作独立输出构造，这可能导致节点拒收含 dust change 的交易
- 已调整找零逻辑：当 change 小于 `546 sat` 时，不再生成找零输出，而是并入 network fee，避免构造明显无效的 dust output
- 已继续检查 `_scriptPubKeyForAddress(...)`，发现此前所有 Base58 地址都会被按 P2PKH 输出脚本处理，导致 `3...` / `2...` 这类 P2SH 地址脚本错误
- 已将输出脚本构造升级为区分 P2PKH 与 P2SH；对当前尚未支持本地构造的 bech32 输出，改为明确抛出错误而不是走到更隐蔽的 Base58 解析失败
- 已补充测试，覆盖 P2SH 输出签名、bech32 输出显式拒绝，以及 dust change 自动并入 fee 的行为

本轮结论：

- 本地交易构造现在更不容易产出“脚本类型错误”或“dust 找零”这类节点会直接拒收的 raw tx
- 但 bech32 输出仍未完成真正支持；如果要支持 `bc1` / `tb1` 目的地址，后续仍需要补齐 segwit 输出脚本与对应签名路径

2026-03-30 donation 网络与输入脚本约束进展（当前轮）：

- 已继续排查 donation 输出的网络一致性，发现此前 donation 地址在 mainnet 与 testnet 下共用同一个固定主网地址，这会让 testnet 交易构造出跨网风格输出
- 已为 donation 常量增加按网络切换能力：mainnet 继续使用 `1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc`，testnet 改为同一 hash160 对应的 testnet 地址 `mqcLvjMSC927erejtAw6w7k8tBB9hm3Ann`
- 已同步更新发送页预览、设置页展示和 `TransactionService.buildPreview(...)`，确保 UI 与交易构造使用同一 donation 地址来源
- 已继续收紧 `TransactionService.signLocally(...)` 的输入假设：当前仅明确支持标准 P2PKH 输入脚本，若拿到 P2SH/其他脚本类型的 UTXO，会直接报出显式错误而不是尝试错误签名
- 已补充测试，覆盖 donation 地址按网络切换、testnet preview donation 地址，以及非 P2PKH 输入脚本被显式拒绝的行为

本轮结论：

- 当前 testnet 发送路径在 donation 输出这一层已不再默认混入主网地址，跨网构造风险明显降低
- 当前本地签名仍只覆盖标准 P2PKH 输入；如果钱包后续需要花费 P2SH、segwit 或其他脚本类型的 UTXO，仍需补专门签名分支

2026-03-30 UTXO 预过滤与构造前校验进展（当前轮）：

- 已继续排查 `RpcService.listUnspent()` 到 `TransactionService.buildTransaction()` 的输入链路，发现此前只按确认数筛 UTXO，直到签名阶段才暴露“脚本不支持”或“地址不匹配”问题
- 已把本地签名约束前移到构造阶段：当前只会选择 `address == fromAddress` 且 `scriptPubKey` 为标准 P2PKH 的 UTXO 进入待构造交易
- 若节点返回的 UTXO 虽已确认，但不满足本地签名前提，当前会被直接跳过；如果最终没有可用输入，会明确报错 `No eligible locally signable UTXOs found`
- 已把 bech32 目的地址的拒绝逻辑提前到 `buildTransaction(...)`，避免先构造 unsigned tx、再在签名阶段才失败
- 已补充测试，覆盖构造阶段提前拒绝 bech32 收款地址，以及忽略不支持脚本 / 错误归属 UTXO 后给出清晰错误

本轮结论：

- 当前失败会更早暴露在“构造阶段”，而不是等到签名阶段才发现 UTXO 无法本地签名，问题定位成本更低
- 但这也意味着钱包当前对可花费 UTXO 的支持范围更明确地收窄到标准 P2PKH；若链上资金以其他脚本类型存在，后续仍需专门适配

2026-03-30 缺失地址回退推导进展（当前轮）：

- 已继续排查 `listunspent` 返回值对本地签名的影响，发现当前实现默认依赖节点返回 `address` 字段；若节点省略该字段，即使 `scriptPubKey` 是标准 P2PKH，也会被误过滤掉
- 已在 `AddressService` 中新增 `tryDeriveAddressFromScriptPubKey(...)`，可从标准 P2PKH `scriptPubKey` 反推出对应 mainnet/testnet 地址
- 已在 `TransactionService` 的 UTXO 可签名判断中加入回退逻辑：若 `address` 为空，则尝试由 `scriptPubKey` 反推地址，再与 `fromAddress` 对比
- 这让当前实现对节点返回字段的要求更宽松，在保持仅支持标准 P2PKH 的前提下，减少了对 `listunspent.address` 的硬依赖
- 已补充测试，覆盖 mainnet/testnet 下从 `scriptPubKey` 反推地址，以及 `address` 缺失时仍可接受标准 P2PKH UTXO 的行为

本轮结论：

- 当前本地签名对节点 `listunspent` 返回格式的鲁棒性更强，即使缺少 `address` 字段，只要 `scriptPubKey` 足够标准，仍可继续构造交易
- 但这仍只覆盖标准 P2PKH 脚本；如果节点返回的是 P2SH、segwit 或更复杂脚本，当前仍会被显式排除

---

### 6. 构建验证缺口

尚未验证以下命令：

```bash
flutter pub get
flutter test
flutter build apk --debug
flutter build apk --release
```

需要在具备 Flutter 环境的机器上执行。

---

## 仓库内的重要事实

### 1. 没有子模块，没有别的隐藏仓库

已经检查过：

- 没有 `.gitmodules`
- 没有 git submodule
- `skydoge_wallet/` 不是独立子仓库，而是主仓库中的 Flutter 子目录

---

### 2. 仓库内旧 spec 与当前 2.0 目标不完全一致

`.monkeycode/specs/skydoge-mobile-wallet/` 中仍有旧设计内容，例如：

- donation 比例仍写成 `0.1%`
- donation 可开关
- 旧设计和当前 2.0 目标存在偏差

注意：

- 当前代码逻辑已经比旧 spec 更接近 2.0
- 不要简单用旧 spec 覆盖当前 donation 逻辑

说明：
- 之前没有修改 `.monkeycode`，因为该目录受仓库规则约束，修改后需要自动提交并推送

---

## 建议的后续开发顺序

### 阶段 1：优先验证本地签名广播

先做：

- 用 testnet 小额交易验证 signed raw tx 是否可广播
- 修复签名兼容性问题
- 确认交易被节点接受

这是当前最重要的下一步。

---

### 阶段 2：补齐交易展示能力

继续完善：

- 交易历史页
- 交易详情页
- donation 输出展示
- block explorer 跳转

---

### 阶段 3：增强安全能力

继续完善：

- seed / privateKey 加密
- PIN / 生物识别
- 解锁状态管理

---

### 阶段 4：补测试

补充：

- Widget 测试
- 集成测试
- donation 专项测试
- 本地签名广播链路测试

---

### 阶段 5：跑构建并准备交付

执行：

```bash
flutter pub get
flutter test
flutter build apk --debug
flutter build apk --release
```

然后更新：

- README
- 构建说明
- 测试说明
- 最终交付说明

---

## 建议接手后给用户的首条回复

建议这样对用户说明：

> 我已接手 `260329-feat-align-skydoge-wallet-v2` 分支，会继续基于当前 Flutter 仓库增量开发，不会迁移技术栈。  
> 我会先验证当前已实现的本地 P2PKH 签名链路是否能在 testnet 正常广播，再继续补齐 2.0 设计剩余缺口，包括交易历史/详情、安全存储、测试和 APK 构建验证。  
> 每完成一轮，我会汇报：做了什么、改了哪些文件、运行了哪些验证命令、是否已提交并推送。

---

## 建议汇报格式

请在每轮开发结束后，按以下格式向用户汇报：

1. 本轮完成了什么
2. 修改了哪些文件
3. 运行了哪些命令，结果如何
4. 当前还剩什么问题
5. 是否已 git 提交并推送
6. 当前 commit hash 是什么

---

## 当前总结

当前分支 `260329-feat-align-skydoge-wallet-v2` 已实现：

- donation 规则从旧版调整到 2.0 方向
- WIF 导入流程
- 链配置集中管理
- 发送确认信息增强
- P2PKH 本地签名主干
- 多个基础测试

当前仍未完成：

- 真实 testnet 广播验证
- 更完整的交易页面
- 更强的安全能力
- 更完整的测试覆盖
- Flutter 构建验证

接手后请从“验证本地签名是否可在 testnet 成功广播”开始。

并且请遵守：

- 每完成一轮有效开发后，必须同步更新 `HANDOFF.md`
