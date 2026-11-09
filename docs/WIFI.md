# 无线网卡（RZ616 / MT7922）两种方案

硬件：MediaTek MT7922，AMD 型号 RZ616，PCI ID `14c3:0616`，蓝牙部分为 USB `0e8d:0616`。macOS 原生不支持这张卡，需要第三方 kext。

仓库同时提供了两套无线方案，**同一时间只能启用一套**。

## 方案 A：原生 Wi-Fi 菜单（仓库默认）

- kext：`AirportMtkWlan.kext` 2.0.0（Tahoe 构建，`MinKernel 25.0.0`）。
- 表现：网卡以原生 AirPort 接口出现，能用系统 Wi-Fi 菜单、钥匙串和自动加入。
- 实机问题：能连上，但会周期性掉线；日志中 `airportd` 反复出现 `Link down event. Triggering auto-join`，并在约 10 秒后 `AUTO-JOIN: Join FAILED (error=-3905)`。在切换网络后还出现过完全扫描不到网络、反复开关 Wi-Fi 也无效的情况。
- 结论：可以日常勉强使用，但稳定性不足。这是驱动问题，不是配置问题。

## 方案 B：App 管理连接（备选）

- kext：`itlmt7922.kext` 0.2.2，配合 `ItlWiFi7922.app` 菜单栏程序。
- 表现：网卡呈现为以太网接口，由 App 负责扫描与连接；不支持系统 Wi-Fi 菜单。
- 适用：方案 A 完全扫不到网络时用来验证是驱动还是硬件问题。
- 注意：App 会把记住的 Wi-Fi 密码以明文保存在 `~/Library/Application Support/ItlWiFi7922/networks.json`（权限 0600）。测试时建议不要保存密码。
- 结论：上游只在 macOS 15 上做过完整验证，Tahoe 上属于尝试性支持，本仓库尚未完成实机验证。

## 启停与切换

两种方案的差别只有 `Kernel -> Add` 中两个条目的 `Enabled` 状态，其余配置完全一致：

| | 方案 A（原生） | 方案 B（App） |
| --- | --- | --- |
| `AirportMtkWlan.kext` | true | false |
| `itlmt7922.kext` | false | true |

macOS 下可以直接运行：

```zsh
sudo zsh scripts/switch-wifi.command native   # 方案 A
sudo zsh scripts/switch-wifi.command app      # 方案 B
```

也可以手工编辑 `EFI/OC/config.plist`，或用 `extras/config.itlmt7922.plist` 整个替换 `EFI/OC/config.plist`。

改完必须重启才生效。

## 排查步骤

1. 确认驱动加载：`kmutil showloaded | grep -iE 'AirportMtkWlan|itlmt7922'`。
2. 确认接口存在：`ifconfig -l`、`networksetup -listallhardwareports`。
3. 看链路事件：`log show --last 30m --predicate 'process == "airportd"' | grep -E 'Link down|Join FAILED'`。
4. 两个 kext 都启用会导致冲突，必须只留一个。

## 如果只想先稳定上网

- 使用 USB-C 转有线网口；macOS 自带多数 USB 网卡驱动，或在仓库内自行补充对应 kext。
- 使用手机 USB 共享网络（不稳定，见 `TROUBLESHOOTING.md`）。
- 使用 iPhone/安卓手机的 Wi-Fi 热点配合本方案 A，掉线时重新连接。
