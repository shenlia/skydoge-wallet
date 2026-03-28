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
| 捐赠费率 | 0.1% |
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
