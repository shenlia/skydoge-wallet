# Skydoge Wallet 项目操作指引

## 项目信息

| 项目 | 链接 |
|------|------|
| GitHub仓库 | https://github.com/shenlia/skydoge-wallet |
| Releases下载 | https://github.com/shenlia/skydoge-wallet/releases |
| 最新版本APK | https://github.com/shenlia/skydoge-wallet/releases/download/v1.0.2/app-debug.apk |
| 官方主网 | https://github.com/skydogenet |
| 官方网站 | https://skydoge.net |

## 操作文档

详细构建和发布步骤请阅读：
- 仓库内路径：`.monkeycode/docs/skydoge-wallet-update-guide.md`
- GitHub链接：https://github.com/shenlia/skydoge-wallet/blob/main/.monkeycode/docs/skydoge-wallet-update-guide.md

## 快速指令

```
帮我更新 Skydoge Wallet 到 v{x.x.x} 版本
```

## 项目核心配置

| 配置项 | 值 |
|--------|-----|
| 捐赠地址 | 1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc |
| 捐赠费率 | 0.01% |
| 默认RPC | pool.skydoge.net:8332 |
| 包名 | com.skydoge.skydoge_wallet |

## 构建环境要求

- Flutter SDK 3.24.0
- Java OpenJDK 17
- Android SDK Platform 34

## 发布Release命令

```bash
# 1. 克隆仓库
git clone https://github.com/shenlia/skydoge-wallet.git
cd skydoge-wallet

# 2. 修改版本号 (pubspec.yaml)
# version: x.x.x+x

# 3. 构建APK
cd skydoge_wallet
flutter clean && flutter pub get && flutter build apk --debug

# 4. 发布 (需要GitHub Token)
export GH_TOKEN=ghp_你的TOKEN
gh release create v{x.x.x} --title "Skydoge Wallet v{x.x.x}" --repo shenlia/skydoge-wallet
gh release upload v{x.x.x} build/app/outputs/flutter-apk/app-debug.apk --repo shenlia/skydoge-wallet --clobber
```

## GitHub Token

如有需要请用户提供有效的Personal Access Token，需要 `repo` 权限。

---

## 更新需求备注

当您有新的更新需求时，请在下方填写：

### 当前待处理 / 计划中的更新

```
[日期]
待更新内容：
- 

期望版本号：v
```

### 历史更新记录

| 日期 | 版本 | 更新内容 |
|------|------|----------|
| 2026-03-28 | v1.0.0 | 初始版本，支持自定义RPC、捐赠功能(0.1%)、Drivechain侧链 |
| 2026-03-28 | v1.0.1 | 修复Android 9+兼容性问题，添加网络权限和cleartextTraffic配置 |
| 2026-03-28 | v1.0.2 | 修复启动时一直转圈问题，WalletBloc未收到初始化事件 |

[交接文档维护要求]
- Date: 2026-03-29
- Context: 用户要求后续每次继续开发时都同步更新交接文档
- Instructions:
  - 每次继续开发并产生有效进展后，都要同步更新仓库根目录的 `HANDOFF.md`
  - `HANDOFF.md` 需要记录已完成工作、当前分支、后续待办和建议接手顺序

[当前 2.0 对齐状态]
- Date: 2026-03-29
- Context: Agent 在执行 Skydoge Wallet 2.0 对齐开发时发现
- Category: 代码模式
- Instructions:
  - donation 规则已从旧版 0.1% 调整为 0.01%，并且在发送流程中强制开启
  - 当前主开发分支为 `260329-feat-align-skydoge-wallet-v2`
  - 已实现 WIF 导入和 P2PKH 本地签名主干，但仍需优先做 testnet 广播验证

[持续自主推进要求]
- Date: 2026-03-30
- Context: 用户要求我持续执行建议中的后续工作，直到版本更完善
- Instructions:
  - 当我识别出明确的下一步技术改进点时，应直接继续执行，而不是等待用户逐项确认
  - 在每轮完成有效进展后，继续选择最合理的下一步推进，直到版本明显更完善或出现阻塞

[减少不必要确认要求]
- Date: 2026-03-30
- Context: 用户再次强调除非我判断确实需要，否则不要再就后续步骤征求确认
- Instructions:
  - 默认连续执行我判断最合理的后续开发动作
  - 仅在存在真实阻塞、破坏性决策或必须由用户提供额外信息时才提问

---

## 示例：如何备注更新需求

如果您想更新捐赠费率，告诉我：

```
更新 Skydoge Wallet：
- 修改捐赠费率从 0.1% 改为 0.01%
- 期望版本：v1.1.0
```

我会自动：
1. 修改 `lib/core/constants/donation_constants.dart` 中的 `donationRate`
2. 更新版本号
3. 构建APK
4. 发布新版本
