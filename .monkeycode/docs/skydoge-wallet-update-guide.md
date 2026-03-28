# Skydoge Wallet 更新需求文档

## 项目信息

| 项目 | 内容 |
|------|------|
| 仓库地址 | https://github.com/shenlia/skydoge-wallet |
| 主网仓库 | https://github.com/skydogenet |
| 官网 | https://skydoge.net |
| 当前版本 | v1.0.0 |
| 包名 | com.skydoge.skydoge_wallet |

## 已完成的修改

### 1. Flutter项目结构初始化
- 创建完整的Flutter项目结构
- 添加Android和iOS原生项目文件
- 配置Gradle和Kotlin构建环境

### 2. Android构建配置修改

**文件**: `skydoge_wallet/android/settings.gradle`
```diff
- id "org.jetbrains.kotlin.android" version "1.7.10" apply false
+ id "org.jetbrains.kotlin.android" version "1.9.22" apply false
```

**文件**: `skydoge_wallet/android/build.gradle`
```diff
+ ext {
+   kotlin_version = '1.9.22'
+ }
```

**文件**: `skydoge_wallet/android/app/build.gradle`
```diff
- compileSdk = flutter.compileSdkVersion
+ compileSdk = 34
```

### 3. 依赖版本锁定

**文件**: `skydoge_wallet/pubspec.yaml`
```diff
+ dependency_overrides:
+   flutter_plugin_android_lifecycle: 2.0.21
```

### 4. 删除旧文件
- 删除 `skydoge-wallet/skydoge_message_board.md` 占位符

## 核心功能

| 功能 | 状态 | 说明 |
|------|------|------|
| 自定义RPC | 已实现 | 支持pool.skydoge.net |
| 捐赠地址 | 已实现 | 1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc |
| 捐赠费率 | 0.1% | 每笔交易捐赠0.1% |
| BIP39钱包 | 已实现 | 12词助记词创建/导入 |
| Drivechain | 已实现 | 侧链支持 |

## 更新版本步骤

### 1. 环境要求
```bash
# Flutter SDK 3.24.0
# Java OpenJDK 17
# Android SDK Platform 34
# Android SDK Build-Tools 34.0.0
```

### 2. 修改版本号

编辑 `skydoge_wallet/pubspec.yaml`:
```yaml
version: x.x.x+x  # 例如 1.1.0+1
```

### 3. 提交代码
```bash
cd /workspace
git add -A
git commit -m "chore: bump version to x.x.x"
git push origin main
```

### 4. 构建APK
```bash
cd /workspace/skydoge_wallet
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export ANDROID_HOME=/opt/android-sdk
export PATH="/opt/flutter/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

flutter clean
flutter pub get
flutter build apk --debug
```

### 5. 发布Release
```bash
export GH_TOKEN=ghp_YOUR_TOKEN

# 创建新Release
gh release create v{x.x.x} \
  --title "Skydoge Wallet v{x.x.x}" \
  --notes "版本更新说明" \
  --repo shenlia/skydoge-wallet

# 上传APK
gh release upload v{x.x.x} \
  build/app/outputs/flutter-apk/app-debug.apk \
  --repo shenlia/skydoge-wallet --clobber
```

## 注意事项

### 1. Gradle缓存问题
如果遇到 `android.jar` 加载错误，尝试：
```bash
rm -rf /root/.gradle/caches/transforms-*
rm -rf $ANDROID_HOME/platforms/android-35
sdkmanager "platforms;android-35"
```

### 2. Kotlin版本兼容性
- Flutter插件需要Kotlin 1.9.22+
- 如遇版本冲突，使用 `dependency_overrides`

### 3. SDK版本
- `compileSdk` 建议使用 34
- `minSdk` 使用 Flutter默认值
- `targetSdk` 使用 Flutter默认值

### 4. GitHub Token
需要具有 `repo` 权限的Personal Access Token来发布Release。

## 发布检查清单

- [ ] 更新 `pubspec.yaml` 版本号
- [ ] 更新 `lib/core/constants/donation_constants.dart` 如有修改
- [ ] 更新 `lib/core/constants/network_constants.dart` 如有修改
- [ ] 本地测试构建成功
- [ ] 提交并推送到GitHub
- [ ] 创建GitHub Release
- [ ] 上传APK文件
- [ ] 验证下载链接

## 历史版本

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0.0 | 2026-03-28 | 初始版本，支持自定义RPC和捐赠功能 |
