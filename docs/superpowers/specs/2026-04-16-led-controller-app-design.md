# LED 灯带控制器 APP - 设计文档

**项目名称：** LedControl
**框架：** Flutter 3.19+
**语言：** Dart 3.0+
**状态管理：** Riverpod
**UI 风格：** Cupertino (iOS 风格)
**创建日期：** 2026-04-16

---

## 1. 项目概述

一个用于控制 ESP8266 LED 灯带的跨平台 Flutter 应用。支持通过 WiFi 和 UDP 协议控制多个 LED 灯带设备，包括 8 种预设灯效、亮度调节、设备管理和 WiFi 配置功能。

### 核心功能

1. **LED 控制** - 8种灯效切换、亮度调节
2. **设备管理** - 多设备添加、切换、删除
3. **设备扫描** - 局域网自动发现 LED 设备
4. **WiFi 配置** - 设备热点模式配置

---

## 2. 架构设计

### 2.1 分层架构

采用经典的三层架构，职责清晰，易于测试和维护。

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                   │
│  Pages, Widgets, Controllers                            │
├─────────────────────────────────────────────────────────┤
│                      Domain Layer                       │
│  Providers (Riverpod), Use Cases, Models                │
├─────────────────────────────────────────────────────────┤
│                       Data Layer                        │
│  Repositories, UDP Client, Storage                      │
└─────────────────────────────────────────────────────────┘
```

### 2.2 依赖方向

- Presentation → Domain：UI 通过 Riverpod Provider 获取数据和调用方法
- Domain → Data：Provider 通过 Repository 接口访问数据层
- Data → 外部：UDP、SharedPreferences、网络扫描

---

## 3. 模块设计

### 3.1 设备管理模块

**职责：** 设备的添加、删除、列表显示、当前设备切换

**主要组件：**
```
device_manager/
├── device_manager_page.dart          # 主页面，带Tab切换
├── widgets/
│   ├── device_list_item.dart         # 设备列表项
│   ├── add_device_button.dart        # 添加设备按钮
│   └── device_scan_dialog.dart       # 扫描设备对话框
└── repositories/
    └── device_repository.dart        # 设备数据仓库接口
```

**数据模型：**
```dart
class Device {
  final String id;           // 唯一标识 (UUID)
  final String name;         // 用户自定义名称
  final String ipAddress;    // IP 地址
  final int port;            // 端口 (默认 8888)
  final DateTime lastSeen;   // 最后在线时间
  final bool isOnline;       // 是否在线
}
```

---

### 3.2 LED 控制模块

**职责：** 灯效切换、亮度调节、状态查询

**主要组件：**
```
control/
├── control_page.dart                 # 主控制页面（Tab布局）
├── widgets/
│   ├── effect_preview.dart           # 效果预览动画组件
│   ├── brightness_slider.dart        # 亮度滑块
│   ├── effect_grid.dart              # 效果选择网格
│   └── status_indicator.dart        # 连接状态指示器
└── providers/
    └── control_provider.dart         # 控制状态管理
```

**数据模型：**
```dart
enum LEDEffect {
  rainbow,    // 彩虹
  breathing,  // 呼吸
  fire,       // 火焰
  starry,     // 星空
  wave,       // 波浪
  chase,      // 追逐
  flash,      // 闪烁
  snake       // 贪吃蛇
}

class LEDState {
  final LEDEffect currentEffect;
  final int brightness;        // 0-255
  final bool isConnected;
  final DateTime? lastUpdate;
}
```

---

### 3.3 设备配置模块

**职责：** WiFi 配置、设备连接热点模式

**主要组件：**
```
device_config/
├── config_page.dart                 # 配置向导页面
├── widgets/
│   ├── wifi_list.dart               # WiFi 网络列表
│   ├── password_input.dart          # 密码输入
│   └── config_progress.dart        # 配置进度
└── providers/
    └── config_provider.dart         # 配置状态管理
```

---

### 3.4 网络通信模块

**职责：** UDP 通信、设备扫描、协议处理

**主要组件：**
```
network/
├── udp_client.dart                  # UDP 客户端封装
├── device_scanner.dart              # 局域网设备扫描
├── led_protocol.dart                # LED 通信协议
└── models/
    ├── command.dart                 # 命令模型
    └── response.dart                # 响应模型
```

**协议定义：**

控制模式 (UDP 8888):
| 命令 | 说明 | 响应 |
|------|------|------|
| `mode:rainbow` | 切换效果 | `OK:rainbow` |
| `mode:next` | 下一个效果 | `OK:效果名` |
| `mode:prev` | 上一个效果 | `OK:效果名` |
| `bright:180` | 设置亮度 | `OK:180` |
| `status` | 查询状态 | `MODE:xxx;BRIGHT:xxx` |

配置模式 (UDP 8889):
| 命令 | 说明 | 响应 |
|------|------|------|
| `config:SSID:PASSWORD` | 保存 WiFi | `OK!Rebooting...` |
| `list` | 扫描网络 | `WIFIS:网络1,网络2,...` |

---

### 3.5 数据存储模块

**职责：** 设备数据持久化

**主要组件：**
```
storage/
├── device_storage.dart              # SharedPreferences 封装
└── models/
    └── storage_device.dart          # 存储用设备模型
```

---

## 4. 状态管理

### 4.1 Riverpod Provider 架构

```
UI Layer
  ↓ watch/read
Provider Layer (Riverpod)
  ↓ Repository
Data Source Layer
  ↓
UDP Client / DeviceStorage
```

### 4.2 主要 Provider

```dart
// 设备列表状态
class DeviceListState {
  final List<Device> devices;
  final Device? selectedDevice;
  final bool isLoading;
  final String? error;
}

// 控制状态
class ControlState {
  final LEDEffect currentEffect;
  final int brightness;
  final bool isConnected;
  final bool isLoading;
  final String? error;
}

// 扫描状态
sealed class ScanState {}
class ScanIdle extends ScanState {}
class ScanScanning extends ScanState {}
class ScanFinished extends ScanState {
  final List<DiscoveredDevice> devices;
}
class ScanError extends ScanState {
  final String message;
}
```

---

## 5. 错误处理

### 5.1 网络错误类型

```dart
enum NetworkErrorType {
  timeout,           // 请求超时
  connectionFailed,  // 连接失败
  deviceOffline,     // 设备离线
  invalidResponse,   // 响应格式错误
  unknown,           // 未知错误
}

sealed class NetworkResult<T> {
  const NetworkResult();
}

class NetworkSuccess<T> extends NetworkResult<T> {
  final T data;
  const NetworkSuccess(this.data);
}

class NetworkError extends NetworkResult<Nothing> {
  final String message;
  final NetworkErrorType type;
  const NetworkError(this.message, this.type);
}
```

### 5.2 错误展示策略

| 错误类型 | 展示方式 | 用户操作 |
|---------|---------|---------|
| 设备离线 | 状态栏红色提示 + Toast | "重试" 按钮 |
| 命令超时 | 亮度滑块回滚 + 提示 | "重试" 按钮 |
| 扫描无结果 | 空状态页面 + 提示 | "手动添加" 按钮 |
| WiFi 配置失败 | 错误对话框 | 返回上一步 |
| 无网络权限 | 权限申请对话框 | "去设置" |

---

## 6. UI 设计

### 6.1 主控制页面布局

采用分页导航式设计，顶部 Tab 切换不同功能区。

**Tab 结构：**
- 效果 (默认显示) - 效果选择和亮度控制
- 设置 - 高级设置选项
- 设备 - 设备切换和管理

**效果 Tab 组件：**
```
┌─────────────────────────────────┐
│     LED 效果预览动画区域         │  <- 120px 高度
├─────────────────────────────────┤
│  ┌───┐ ┌───┐ ┌───┐ ┌───┐       │
│  │ 🌈│ │ 💨│ │ 🔥│ │ ⭐│       │  <- 2x4 网格
│  └───┘ └───┘ └───┘ └───┘       │
│  ┌───┐ ┌───┐ ┌───┐ ┌───┐       │
│  │ 🌊│ │ 💫│ │ ✨│ │ 🐍│       │
│  └───┘ └───┘ └───┘ └───┘       │
├─────────────────────────────────┤
│  ◁━━━━━━━━━━━━━▷  亮度调节      │  <- 滑块
└─────────────────────────────────┘
```

### 6.2 设备管理页面

**布局：**
```
┌─────────────────────────────────┐
│  ← 设备管理          [+ 扫描]   │
├─────────────────────────────────┤
│  ┌─────────────────────────────┐ │
│  │ 🟢 客厅灯带                │ │
│  │ 192.168.1.100              │ │
│  └─────────────────────────────┘ │
│  ┌─────────────────────────────┐ │
│  │ 🔴 卧室灯带 (离线)          │ │
│  │ 192.168.1.101              │ │
│  └─────────────────────────────┘ │
│                                 │
│  [+ 手动添加设备]               │
└─────────────────────────────────┘
```

---

## 7. 依赖配置

```yaml
dependencies:
  flutter:
    sdk: flutter

  # 状态管理
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # 网络通信
  udp: ^5.0.3

  # 数据存储
  shared_preferences: ^2.2.2

  # UI 组件
  cupertino_icons: ^1.0.6

  # 工具类
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter

  # 代码生成
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  riverpod_generator: ^2.3.9
  riverpod_lint: ^2.3.7

  # 测试工具
  mocktail: ^1.0.1
  integration_test:
    sdk: flutter
```

---

## 8. 项目目录结构

```
led_control/
├── lib/
│   ├── main.dart                       # 应用入口
│   ├── app.dart                        # 根组件
│   ├── core/
│   │   ├── models/
│   │   │   ├── device.dart            # 设备数据模型
│   │   │   ├── led_effect.dart        # 灯效枚举
│   │   │   ├── command.dart           # 命令模型
│   │   │   └── response.dart          # 响应模型
│   │   ├── network/
│   │   │   ├── led_protocol.dart      # LED 通信协议
│   │   │   ├── udp_client.dart        # UDP 客户端
│   │   │   └── device_scanner.dart    # 设备扫描
│   │   ├── storage/
│   │   │   └── device_storage.dart    # 设备数据存储
│   │   └── providers/
│   │       ├── device_provider.dart   # 设备状态管理
│   │       ├── control_provider.dart  # 控制状态管理
│   │       └── scan_provider.dart     # 扫描状态管理
│   ├── features/
│   │   ├── control/
│   │   │   ├── control_page.dart      # 主控制页面
│   │   │   └── widgets/
│   │   │       ├── effect_preview.dart    # 效果预览动画
│   │   │       ├── brightness_slider.dart # 亮度滑块
│   │   │       └── effect_grid.dart       # 效果选择网格
│   │   ├── device_config/
│   │   │   ├── config_page.dart       # 设备配置页面
│   │   │   └── widgets/
│   │   │       ├── wifi_list.dart
│   │   │       ├── password_input.dart
│   │   │       └── config_progress.dart
│   │   └── device_manager/
│   │       ├── device_manager_page.dart  # 设备管理页面
│   │       └── widgets/
│   │           ├── device_list_item.dart
│   │           ├── add_device_button.dart
│   │           └── device_scan_dialog.dart
│   └── widgets/
│       └── common/                    # 通用组件
│           ├── loading_indicator.dart
│           └── error_display.dart
├── test/
│   ├── unit/
│   │   ├── core/
│   │   │   ├── network/
│   │   │   └── providers/
│   │   └── features/
│   └── integration/
│       └── flows/
├── android/                           # Android 平台配置
├── ios/                               # iOS 平台配置
├── pubspec.yaml                       # 依赖配置
└── README.md                          # 项目说明
```

---

## 9. 开发计划

### 第一阶段：基础设施 (1-2天)
- 项目初始化
- pubspec.yaml 依赖配置
- 基础目录结构搭建
- 路由配置

### 第二阶段：数据层 (2-3天)
- UDP 客户端实现
- LED 协议定义
- 设备存储实现
- 设备扫描实现
- 单元测试

### 第三阶段：领域层 (2-3天)
- Provider 定义
- 业务逻辑实现
- 状态模型定义
- 单元测试

### 第四阶段：展示层 - 设备管理 (2-3天)
- 设备管理页面
- 设备列表组件
- 扫描对话框
- 集成测试

### 第五阶段：展示层 - LED 控制 (3-4天)
- 控制页面（Tab布局）
- 效果预览动画
- 亮度滑块
- 效果选择网格
- 集成测试

### 第六阶段：展示层 - WiFi 配置 (2-3天)
- 配置向导页面
- WiFi 列表
- 密码输入
- 进度指示

### 第七阶段：优化与测试 (2-3天)
- UI 细节打磨
- 性能优化
- 端到端测试
- 真机测试
- Bug 修复

**预计总工期：** 15-20 天

---

## 10. 测试策略

### 单元测试（目标覆盖率 80%+）
- Domain Layer：业务逻辑、状态管理
- Data Layer：协议处理、数据转换
- 测试框架：flutter_test + mocktail

### 集成测试
- 完整用户流程：扫描 → 添加 → 控制
- 跨模块交互验证
- 测试框架：integration_test

### 关键测试场景
1. 扫描并添加新设备
2. 切换 LED 效果
3. 调节亮度
4. 设备离线处理
5. WiFi 配置流程

---

## 11. 平台要求

- **Android:** 8.0+ (API 26+)
- **iOS:** 13.0+
- **权限:**
  - WiFi 状态访问
  - 局域网通信

---

## 12. 已知限制

1. iOS 模拟器不支持 UDP，需要真机测试网络功能
2. WiFi 扫描功能可能需要额外权限（取决于平台）
3. 设备和手机需要在同一局域网内

---

**文档版本:** 1.0
**最后更新:** 2026-04-16
