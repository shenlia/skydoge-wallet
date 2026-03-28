# Skydoge Wallet 项目操作指引

## 项目信息

| 项目 | 链接 |
|------|------|
| GitHub仓库 | https://github.com/shenlia/skydoge-wallet |
| Releases下载 | https://github.com/shenlia/skydoge-wallet/releases |
| 最新版本APK | https://github.com/shenlia/skydoge-wallet/releases/download/v1.0.0/skydoge-wallet-debug.apk |
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
