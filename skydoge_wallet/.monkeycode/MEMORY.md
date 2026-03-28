# 用户指令记忆

本文件记录了用户的指令、偏好和教导，用于在未来的交互中提供参考。

## 格式

### 用户指令条目
用户指令条目应遵循以下格式：

[用户指令摘要]
- Date: [YYYY-MM-DD]
- Context: [提及的场景或时间]
- Instructions:
  - [用户教导或指示的内容，逐行描述]

### 项目知识条目
Agent 在任务执行过程中发现的条目应遵循以下格式：

[项目知识摘要]
- Date: [YYYY-MM-DD]
- Context: Agent 在执行 [具体任务描述] 时发现
- Category: [代码结构|代码模式|代码生成|构建方法|测试方法|依赖关系|环境配置]
- Instructions:
  - [具体的知识点，逐行描述]

## 去重策略
- 添加新条目前，检查是否存在相似或相同的指令
- 若发现重复，跳过新条目或与已有条目合并
- 合并时，更新上下文或日期信息
- 这有助于避免冗余条目，保持记忆文件整洁

## 条目

[本轮 Skydoge Wallet 工作记录]
- Date: 2026-03-28
- Context: Agent 在执行 Flutter 钱包完善、PR 创建、构建可行性检查时发现
- Category: 代码结构
- Instructions:
  - 项目仍是 Flutter 仓库，核心代码位于 `lib/`，Android 工程位于 `android/`
  - 已在分支 `260328-feat-complete-skydoge-wallet` 上完成一轮系统性改造
  - 已创建 PR：`https://github.com/shenlia/skydoge-wallet/pull/1`

[Skydoge 链配置与 donation 约束]
- Date: 2026-03-28
- Context: Agent 在执行 Skydoge 架构对齐改造时发现
- Category: 代码模式
- Instructions:
  - 链参数已集中到 `lib/core/chain/chain_config.dart`
  - donation 规则固定为每笔主转账金额的 `0.01%`
  - donation 地址固定为 `1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc`
  - donation 逻辑已下沉到 `lib/services/transaction_service.dart`
  - 发送页不允许关闭 donation，确认页必须显示 donation 金额、地址、fee、total cost

[钱包导入与本地签名进展]
- Date: 2026-03-28
- Context: Agent 在执行钱包能力补齐时发现
- Category: 代码结构
- Instructions:
  - 已补充 WIF 导入能力，入口在 `lib/ui/screens/welcome_screen.dart`
  - 钱包模型已扩展 `wif`、`walletType`、`derivationPath`
  - 已新增 `lib/services/local_signer_service.dart`，实现本地授权签名与验签
  - 当前仍未完全实现 Bitcoin-like input 级原始交易签名，只实现了广播前本地授权签名校验

[测试与文档现状]
- Date: 2026-03-28
- Context: Agent 在执行测试补齐与文档完善时发现
- Category: 测试方法
- Instructions:
  - 已新增测试：`test/core/donation_constants_test.dart`
  - 已新增测试：`test/services/address_service_test.dart`
  - 已新增测试：`test/services/transaction_service_test.dart`
  - README 已更新为当前钱包架构、规则、构建与限制说明

[当前环境限制]
- Date: 2026-03-28
- Context: Agent 在执行 `flutter test` 与 APK 构建前检查环境时发现
- Category: 环境配置
- Instructions:
  - 当前运行环境没有 `flutter`
  - 当前运行环境没有 `dart`
  - 当前运行环境没有 `java`
  - 当前运行环境没有 `adb`
  - 因此当前无法实际执行 `flutter test` 或 `flutter build apk`
  - 后续若要继续构建 APK，需要切换到具备 Flutter 3.24.0、Java 17、Android SDK 34 的环境
