# LED 灯带控制器 APP

一个用于控制 ESP8266 LED 灯带的跨平台 Flutter 应用。

## 项目概述

支持通过 WiFi 和 UDP 协议控制 ESP8266 LED 灯带设备，包括 8 种预设灯效、亮度调节和设备配置功能。

## 技术栈

- **框架**: Flutter 3.19+
- **语言**: Dart
- **状态管理**: Riverpod
- **UI 风格**: Cupertino (iOS 风格)
- **数据持久化**: shared_preferences
- **最低版本**: Android 8.0+ / iOS 13+

## 项目结构

```
led_control/
├── lib/
│   ├── main.dart                      # 应用入口
│   ├── app.dart                       # 根组件
│   ├── core/
│   │   ├── models/
│   │   │   ├── device.dart            # 设备数据模型
│   │   │   └── led_effect.dart        # 灯效枚举
│   │   ├── network/
│   │   │   ├── led_protocol.dart      # LED 通信协议
│   │   │   ├── udp_client.dart        # UDP 客户端
│   │   │   └── device_scanner.dart    # 设备扫描
│   │   ├── storage/
│   │   │   └── device_storage.dart    # 设备数据存储
│   │   └── providers/
│   │       ├── device_provider.dart   # 设备状态管理
│   │       └── control_provider.dart  # 控制状态管理
│   ├── features/
│   │   ├── control/
│   │   │   ├── control_page.dart      # 主控制页面
│   │   │   ├── effect_preview.dart    # 效果预览动画
│   │   │   ├── brightness_slider.dart # 亮度滑块
│   │   │   └── effect_grid.dart       # 效果选择网格
│   │   ├── device_config/
│   │   │   └── config_page.dart       # 设备配置页面
│   │   └── device_manager/
│   │       └── device_manager_page.dart  # 设备管理页面
│   └── widgets/
│       └── common/                    # 通用组件
├── android/                           # Android 平台配置
├── ios/                               # iOS 平台配置
├── pubspec.yaml                       # 依赖配置
└── README.md                          # 项目说明
```

## 开发环境设置

### 前置要求

- Flutter SDK 3.19 或更高版本
- Dart SDK 3.0 或更高版本
- Android Studio / Xcode（用于真机调试）

### 安装步骤

1. **克隆项目**
   ```bash
   cd /Users/chenxi/workspace/LedControl/led_control
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **运行代码生成**
   ```bash
   dart run build_runner build
   ```

4. **运行应用**
   ```bash
   # Android
   flutter run -d android

   # iOS
   flutter run -d ios
   ```

## 功能说明

### 灯效控制

- **彩虹**: 彩虹色彩循环
- **呼吸**: 红色呼吸脉冲
- **火焰**: 随机闪烁火焰效果
- **星空**: 白色/蓝色星光闪烁
- **波浪**: 正弦波颜色渐变
- **追逐**: 三色追逐点
- **闪烁**: 随机多彩闪烁
- **贪吃蛇**: 贪吃蛇动画

### 通信协议

#### 控制模式 (UDP 8888)

| 命令 | 说明 | 响应 |
|------|------|------|
| `mode:rainbow` | 切换效果 | `OK:rainbow` |
| `mode:next` | 下一个效果 | `OK:效果名` |
| `mode:prev` | 上一个效果 | `OK:效果名` |
| `bright:180` | 设置亮度 | `OK:180` |
| `status` | 查询状态 | `MODE:xxx;BRIGHT:xxx` |

#### 配置模式 (UDP 8889)

| 命令 | 说明 | 响应 |
|------|------|------|
| `config:SSID:PASSWORD` | 保存 WiFi | `OK!Rebooting...` |
| `list` | 扫描网络 | `WIFIS:网络1,网络2,...` |

## 设备配置流程

1. 打开 APP，点击"添加设备"
2. 连接到 "LED_Config" 热点
3. 选择家庭 WiFi 网络
4. 输入 WiFi 密码
5. 等待设备重启
6. 切回家庭 WiFi，设备自动上线

## 开发说明

### 添加新的灯效

1. 在 `lib/core/models/led_effect.dart` 添加新的枚举值
2. 在 `lib/features/control/effect_preview.dart` 添加对应的动画组件
3. 在硬件固件中实现对应的动画效果

### 自定义 UI

- UI 组件位于 `lib/features/` 目录
- 使用 Cupertino 风格组件
- 动画使用 AnimatedBuilder 或 CustomPainter

## 已知问题

- iOS 需要在真机上测试 UDP 功能（模拟器不支持）
- WiFi 扫描功能可能需要额外权限

## 许可证

MIT License
