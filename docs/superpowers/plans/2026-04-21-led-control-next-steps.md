# LED 控制 APP 后续开发实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 补齐 LED 控制 APP 的首版闭环，完成设备发现、配网、状态同步和设备管理的可执行实现路径。

**Architecture:** 现有工程已经具备设备存储、UDP 控制和基础控制页，因此本计划优先在这些底座之上补齐流程层。整体按“设备发现层 → 配网流程层 → 控制同步层 → 设备管理增强”拆分，每一层都保持独立 provider 和页面边界，避免把发现、配网、控制逻辑继续堆进 `control_page.dart`。

**Tech Stack:** Flutter, Riverpod, Riverpod Annotation, Freezed, SharedPreferences, UDP networking, flutter_test, mocktail

---

## 文件结构

### 现有文件，后续会继续修改
- `led_control/lib/core/models/device.dart`：设备基础字段与展示属性，作为设备发现、配网和控制的统一数据模型。
- `led_control/lib/core/providers/device_provider.dart`：设备列表、选中设备、更新/删除设备的状态入口。
- `led_control/lib/core/providers/control_provider.dart`：设备控制命令、状态同步和错误状态管理。
- `led_control/lib/core/storage/device_storage.dart`：SharedPreferences 持久化设备列表和选中设备。
- `led_control/lib/features/control/control_page.dart`：当前主控制页和设备页入口，需要拆出或接入发现与配网入口。
- `led_control/test/unit/core/providers/device_provider_test.dart`：设备列表存储和 CRUD 行为的单元测试。
- `led_control/test/widget_test.dart`：应用入口和基础页面结构测试。

### 计划新增文件
- `led_control/lib/core/providers/discovery_provider.dart`：设备发现、在线状态刷新、手动设备合并。
- `led_control/lib/core/providers/provisioning_provider.dart`：配网步骤状态、SSID 选择、密码提交、重连等待。
- `led_control/lib/features/discovery/discovery_page.dart`：设备搜索页，作为 APP 的入口页。
- `led_control/lib/features/provisioning/provisioning_guide_page.dart`：配网引导页。
- `led_control/lib/features/provisioning/wifi_select_page.dart`：Wi‑Fi 列表展示与 SSID 选择页。
- `led_control/lib/features/provisioning/password_entry_page.dart`：密码输入与提交页。
- `led_control/lib/features/provisioning/provisioning_wait_page.dart`：等待重启和重连页。
- `led_control/lib/features/device/device_settings_page.dart`：设备设置页，包含重命名、删除、重新配网入口。
- `led_control/test/unit/core/providers/discovery_provider_test.dart`：发现流程和设备合并策略测试。
- `led_control/test/unit/core/providers/provisioning_provider_test.dart`：配网状态机测试。
- `led_control/test/widget/discovery_page_test.dart`：设备搜索页交互测试。
- `led_control/test/widget/provisioning_flow_test.dart`：配网流程页面切换测试。

---

## Task 1: 统一设备与控制状态边界

**Files:**
- Modify: `led_control/lib/core/models/device.dart`
- Modify: `led_control/lib/core/providers/control_provider.dart`
- Modify: `led_control/lib/core/network/led_protocol.dart`
- Test: `led_control/test/unit/core/providers/device_provider_test.dart`
- Test: `led_control/test/widget_test.dart`

- [ ] **Step 1: Add a test that captures the current duplicate status model problem**

```dart
void main() {
  test('DeviceStatus should come from one shared source', () {
    expect(DeviceStatus, isNotNull);
  });
}
```

- [ ] **Step 2: Run the focused tests to observe the current split-state behavior**

Run: `flutter test test/unit/core/providers/device_provider_test.dart test/widget_test.dart`
Expected: tests pass today, but code review should show `DeviceStatus` is duplicated in two files and state parsing is split across model and protocol layers.

- [ ] **Step 3: Consolidate the shared status shape in the smallest surface area**

```dart
class DeviceStatus {
  const DeviceStatus({
    required this.effect,
    required this.brightness,
  });

  final LEDEffect effect;
  final int brightness;
}
```

Move the canonical status type to a single home and update control parsing to consume that one type. Keep the public API stable so `ControlState` still exposes `currentEffect` and `currentBrightness`.

- [ ] **Step 4: Run the provider tests again**

Run: `flutter test test/unit/core/providers/device_provider_test.dart`
Expected: pass, with no behavior change in CRUD flows.

- [ ] **Step 5: Commit**

```bash
git add led_control/lib/core/models/device.dart led_control/lib/core/providers/control_provider.dart led_control/lib/core/network/led_protocol.dart led_control/test/unit/core/providers/device_provider_test.dart led_control/test/widget_test.dart
git commit -m "refactor: unify led status model"
```

**Acceptance criteria:**
- A single status model is used by parsing and control state.
- No user-visible behavior changes.
- Existing storage and control tests still pass.

---

## Task 2: Add device discovery provider and tests

**Files:**
- Create: `led_control/lib/core/providers/discovery_provider.dart`
- Modify: `led_control/lib/core/providers/device_provider.dart`
- Test: `led_control/test/unit/core/providers/discovery_provider_test.dart`

- [ ] **Step 1: Write a discovery provider test for merging discovered devices with stored devices**

```dart
void main() {
  test('discovered devices should update stored devices by IP', () async {
    final stored = Device(
      id: 'stored-1',
      name: '客厅灯',
      ipAddress: '192.168.1.50',
      port: 8888,
      lastSeen: DateTime(2026, 4, 21),
      isOnline: false,
    );

    final discovered = stored.copyWith(isOnline: true, lastSeen: DateTime(2026, 4, 21, 12));

    expect(discovered.ipAddress, stored.ipAddress);
    expect(discovered.isOnline, isTrue);
  });
}
```

- [ ] **Step 2: Run the new test and confirm the provider does not exist yet**

Run: `flutter test test/unit/core/providers/discovery_provider_test.dart`
Expected: fail because the provider and merge behavior are not implemented yet.

- [ ] **Step 3: Implement the discovery provider with a narrow API**

```dart
@riverpod
class DeviceDiscovery extends _$DeviceDiscovery {
  @override
  Future<List<Device>> build() async {
    return const [];
  }

  Future<void> refresh() async {}
  Future<void> addDiscoveredDevice(Device device) async {}
}
```

Wire it to `deviceProvider` so discovered devices update the stored list by IP or ID rather than creating duplicates.

- [ ] **Step 4: Run the discovery provider test and the existing device provider tests**

Run: `flutter test test/unit/core/providers/discovery_provider_test.dart test/unit/core/providers/device_provider_test.dart`
Expected: both pass.

- [ ] **Step 5: Commit**

```bash
git add led_control/lib/core/providers/discovery_provider.dart led_control/lib/core/providers/device_provider.dart led_control/test/unit/core/providers/discovery_provider_test.dart
git commit -m "feat: add device discovery state"
```

**Acceptance criteria:**
- Discovery has its own provider boundary.
- Discovered devices can update existing stored devices.
- Device persistence remains the source of truth.

---

## Task 3: Create the device search entry page

**Files:**
- Create: `led_control/lib/features/discovery/discovery_page.dart`
- Modify: `led_control/lib/app.dart`
- Test: `led_control/test/widget/discovery_page_test.dart`

- [ ] **Step 1: Write a widget test for the search page showing scan, manual add, and provision entry actions**

```dart
void main() {
  testWidgets('discovery page shows scan and provisioning actions', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DiscoveryPage()));

    expect(find.text('扫描设备'), findsOneWidget);
    expect(find.text('手动添加 IP'), findsOneWidget);
    expect(find.text('开始配网'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the test and confirm the page is not implemented yet**

Run: `flutter test test/widget/discovery_page_test.dart`
Expected: fail.

- [ ] **Step 3: Implement the page as a thin shell over the discovery provider**

```dart
class DiscoveryPage extends ConsumerWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('设备搜索')),
      child: SafeArea(
        child: Column(
          children: const [
            Text('扫描设备'),
            Text('手动添加 IP'),
            Text('开始配网'),
          ],
        ),
      ),
    );
  }
}
```

Connect the page as the app entry route so it becomes the first user-facing step.

- [ ] **Step 4: Run the widget test and app entry smoke test**

Run: `flutter test test/widget/discovery_page_test.dart test/widget_test.dart`
Expected: pass.

- [ ] **Step 5: Commit**

```bash
git add led_control/lib/app.dart led_control/lib/features/discovery/discovery_page.dart led_control/test/widget/discovery_page_test.dart
git commit -m "feat: add device discovery entry page"
```

**Acceptance criteria:**
- The app starts from the search page.
- Discovery actions are visible and wired to a single page boundary.
- The existing control page is no longer the only entry point.

---

## Task 4: Implement the provisioning flow state machine

**Files:**
- Create: `led_control/lib/core/providers/provisioning_provider.dart`
- Create: `led_control/lib/features/provisioning/provisioning_guide_page.dart`
- Create: `led_control/lib/features/provisioning/wifi_select_page.dart`
- Create: `led_control/lib/features/provisioning/password_entry_page.dart`
- Create: `led_control/lib/features/provisioning/provisioning_wait_page.dart`
- Test: `led_control/test/unit/core/providers/provisioning_provider_test.dart`
- Test: `led_control/test/widget/provisioning_flow_test.dart`

- [ ] **Step 1: Write a provider test that drives the provisioning steps in order**

```dart
void main() {
  test('provisioning state moves from guide to wifi selection to password entry', () {
    final state = ProvisioningState.initial();
    expect(state.step, ProvisioningStep.guide);
  });
}
```

- [ ] **Step 2: Run the test and confirm the provider does not exist yet**

Run: `flutter test test/unit/core/providers/provisioning_provider_test.dart`
Expected: fail.

- [ ] **Step 3: Implement a compact provisioning state model and notifier**

```dart
enum ProvisioningStep { guide, wifiSelect, passwordEntry, waiting, complete, error }

class ProvisioningState {
  const ProvisioningState({
    required this.step,
    this.selectedSsid,
    this.errorMessage,
  });

  final ProvisioningStep step;
  final String? selectedSsid;
  final String? errorMessage;

  factory ProvisioningState.initial() => const ProvisioningState(step: ProvisioningStep.guide);
}
```

Use the provider to move between steps, submit `config:SSID:PASSWORD`, and expose a retry path from `waiting`.

- [ ] **Step 4: Add thin page shells for each provisioning step**

Each page should only render its step-specific UI and call into the provider; do not put protocol logic directly in the widget layer.

- [ ] **Step 5: Run the provider and widget flow tests**

Run: `flutter test test/unit/core/providers/provisioning_provider_test.dart test/widget/provisioning_flow_test.dart`
Expected: pass.

- [ ] **Step 6: Commit**

```bash
git add led_control/lib/core/providers/provisioning_provider.dart led_control/lib/features/provisioning/provisioning_guide_page.dart led_control/lib/features/provisioning/wifi_select_page.dart led_control/lib/features/provisioning/password_entry_page.dart led_control/lib/features/provisioning/provisioning_wait_page.dart led_control/test/unit/core/providers/provisioning_provider_test.dart led_control/test/widget/provisioning_flow_test.dart
git commit -m "feat: add provisioning flow state machine"
```

**Acceptance criteria:**
- Provisioning has an explicit step model.
- Users can move through guide, Wi‑Fi selection, password entry, and waiting states.
- The flow is testable without UI timing hacks.

---

## Task 5: Connect control page to live device status refresh

**Files:**
- Modify: `led_control/lib/features/control/control_page.dart`
- Modify: `led_control/lib/core/providers/control_provider.dart`
- Test: `led_control/test/widget_test.dart`

- [ ] **Step 1: Add a widget test for automatic status refresh when the control page loads**

```dart
void main() {
  testWidgets('control page requests status for the selected device', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LedControlApp()));
    await tester.pump();
    expect(find.byType(CupertinoTabScaffold), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the test and confirm the current page does not yet perform automatic refresh**

Run: `flutter test test/widget_test.dart`
Expected: pass today, but the behavior gap is visible in code review.

- [ ] **Step 3: Trigger `getStatus` when the selected device becomes available**

```dart
final device = _currentDevice();
if (device != null) {
  ref.read(controlProvider.notifier).getStatus(device.ipAddress, port: device.port);
}
```

Keep the call in a lifecycle-safe place so it does not fire on every rebuild.

- [ ] **Step 4: Run widget tests and manual smoke test of effect/brightness controls**

Run: `flutter test test/widget_test.dart`
Expected: pass.

- [ ] **Step 5: Commit**

```bash
git add led_control/lib/features/control/control_page.dart led_control/lib/core/providers/control_provider.dart led_control/test/widget_test.dart
git commit -m "feat: refresh control state from device"
```

**Acceptance criteria:**
- Control page reflects current device state on entry.
- The refresh behavior is not tied to manual user action only.
- Existing control commands still work.

---

## Task 6: Complete device settings and management actions

**Files:**
- Create: `led_control/lib/features/device/device_settings_page.dart`
- Modify: `led_control/lib/features/control/control_page.dart`
- Modify: `led_control/lib/core/providers/device_provider.dart`
- Test: `led_control/test/unit/core/providers/device_provider_test.dart`

- [ ] **Step 1: Add tests for renaming and removing a selected device**

```dart
void main() {
  test('updateDevice saves the renamed device', () async {
    final updated = Device(
      id: 'id1',
      name: '新名称',
      ipAddress: '192.168.1.100',
      port: 8888,
      lastSeen: DateTime(2026, 4, 21),
      isOnline: true,
    );

    expect(updated.name, '新名称');
  });
}
```

- [ ] **Step 2: Run the focused provider tests**

Run: `flutter test test/unit/core/providers/device_provider_test.dart`
Expected: pass.

- [ ] **Step 3: Build the settings page around existing deviceProvider actions**

The page should expose:
- rename device
- update IP/port
- remove device
- re-enter provisioning

- [ ] **Step 4: Hook the settings page into the existing control tab navigation**

Keep the page as a thin UI shell and reuse storage/provider methods rather than duplicating persistence logic.

- [ ] **Step 5: Commit**

```bash
git add led_control/lib/features/device/device_settings_page.dart led_control/lib/features/control/control_page.dart led_control/lib/core/providers/device_provider.dart led_control/test/unit/core/providers/device_provider_test.dart
git commit -m "feat: complete device management actions"
```

**Acceptance criteria:**
- A user can rename, remove, and reconfigure a device from the app.
- Device CRUD continues to be backed by the existing storage layer.
- No new persistence mechanism is introduced.

---

## Task 7: Add end-to-end flow coverage for the first-use path

**Files:**
- Modify: `led_control/test/widget_test.dart`
- Create: `led_control/test/widget/provisioning_flow_test.dart`
- Create: `led_control/test/widget/discovery_page_test.dart`

- [ ] **Step 1: Write a flow test that describes the first-use path from discovery to control**

```dart
void main() {
  testWidgets('first use flow reaches control page after discovery and setup', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LedControlApp()));
    expect(find.text('设备搜索'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the new flow tests**

Run: `flutter test test/widget/provisioning_flow_test.dart test/widget/discovery_page_test.dart test/widget_test.dart`
Expected: pass once the earlier tasks are complete.

- [ ] **Step 3: Tighten the test assertions around navigation and page state**

Verify that discovery, provisioning, and control pages each render their core actions, rather than only checking app startup.

- [ ] **Step 4: Commit**

```bash
git add led_control/test/widget_test.dart led_control/test/widget/provisioning_flow_test.dart led_control/test/widget/discovery_page_test.dart
git commit -m "test: cover first use app flow"
```

**Acceptance criteria:**
- The full first-use path is covered by widget tests.
- Page-level behavior is exercised at the boundaries that matter to the user.

---

## Execution notes

- Keep providers thin and move protocol details out of widgets.
- Prefer one new provider per workflow instead of growing `control_provider.dart` further.
- When adding UI, start with a test that proves the page or state exists before filling in the interaction.
- Preserve current storage behavior unless a task explicitly changes it.
- Do not introduce cloud, accounts, remote control, or scene scheduling; those are out of scope for this release.

## Gaps covered by this plan

- App entry and device discovery are represented by Tasks 2 and 3.
- Provisioning and Wi‑Fi selection are represented by Task 4.
- Control state synchronization is represented by Task 5.
- Device management completion is represented by Task 6.
- End-to-end validation is represented by Task 7.

## Self-review

- No TODO/TBD placeholders remain.
- All tasks map back to the original design document scope.
- Status parsing is normalized through a single shared shape before discovery and provisioning are expanded.
- The plan stays within one release-sized feature set and does not split into independent sub-projects.
