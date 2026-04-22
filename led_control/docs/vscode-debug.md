# VS Code 调试 Flutter App

本文说明如何在 VS Code 中调试 `led_control` 应用。

## 前置条件

- 已安装 Flutter SDK
- 已安装 VS Code 的 Flutter 和 Dart 扩展
- Android SDK 已配置完成
- 已连接真机，或已启动 Android 模拟器

## 一次性准备

### 1. 打开项目

在 VS Code 中打开项目根目录：

```bash
/Users/chenxi/workspace/LedControl/led_control
```

### 2. 检查设备

在 VS Code 终端里执行：

```bash
flutter devices
```

确认能看到：
- 已连接的 Android 真机，或
- Android 模拟器

### 3. 安装依赖

如果是第一次打开项目，先执行：

```bash
flutter pub get
```

### 4. 生成代码

如果项目里有 `build_runner` 生成代码，先执行：

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 启动调试

### 方法一：直接按 F5

1. 在 VS Code 中打开 `lib/main.dart`
2. 按 `F5`
3. 选择 `Flutter` 调试配置
4. 等待 App 编译并安装到设备

### 方法二：命令面板启动

1. 按 `Cmd + Shift + P`
2. 输入 `Flutter: Launch Emulator` 或 `Flutter: Select Device`
3. 选择目标设备
4. 再按 `F5`

## 调试时常用操作

- **热重载**：`r`
- **热重启**：`R`
- **停止调试**：`Shift + F5`
- **切换断点**：点击编辑器左侧行号区域

## 推荐的调试方式

### 调试单个页面

如果只想看控制页：

1. 运行 App
2. 进入控制页
3. 在这些位置打断点：
   - `lib/features/control/control_page.dart`
   - `lib/core/providers/control_provider.dart`

### 调试网络命令

如果怀疑 UDP 命令有问题，重点看：

- `setEffect`
- `setBrightness`
- `nextEffect`
- `previousEffect`
- `getStatus`

这些都在 `lib/core/providers/control_provider.dart`。

## 常见问题

### 1. 找不到设备

先执行：

```bash
flutter devices
```

如果没有 Android 设备：
- 确认模拟器已启动，或
- 确认真机 USB 调试已开启

### 2. 启动后黑屏或报错

先看 VS Code 的 **Debug Console** 和 **Terminal** 输出。

### 3. 代码改了但界面没变

执行：

- `r` 热重载
- 如果不生效，再用 `R` 热重启

### 4. 第一次运行特别慢

这是正常的，第一次会下载依赖并构建 Flutter / Android 产物。

## 建议的调试顺序

1. `flutter devices`
2. 选设备
3. `F5` 启动
4. 先确认首页能打开
5. 再检查控制页状态更新
6. 最后验证 UDP 控制命令

## 相关文件

- `lib/main.dart`
- `lib/app.dart`
- `lib/features/control/control_page.dart`
- `lib/core/providers/control_provider.dart`

## 备注

如果你需要，我可以再补一份 `.vscode/launch.json` 示例，方便直接按 F5 调试。