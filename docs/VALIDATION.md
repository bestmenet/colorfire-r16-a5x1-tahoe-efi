# 实机验证到什么程度

本页区分「已验证」「部分验证」「未验证」，避免把配置正确当成功能可用。

## 已验证

| 项目 | 证据 |
| --- | --- |
| OpenCore 能引导 | 从本 EFI 启动并进入 macOS 桌面 |
| 系统版本 | macOS Tahoe 26.7.2（25G332），`sw_vers` 可查 |
| NVIDIA 显卡 | `system_profiler SPDisplaysDataType` 显示 RTX 5060 Laptop、8 GB、Metal 3 |
| 内屏 | 2560 × 1600 @165 Hz，UI 1280 × 800 |
| 1440 × 900 HiDPI | 设置后系统显示 `Resolution: 2880 x 1800`、`UI Looks like: 1440 x 900 @ 165.00Hz` |
| 触摸板 | 安装器与桌面均可用 |
| 安装卷与数据卷挂载 | 曾观察到两卷先后挂载成功（其中安装卷延迟约 9 分钟） |

## 部分验证

| 项目 | 情况 |
| --- | --- |
| Wi-Fi 原生方案 | 能连接、能上网，但周期性掉线，重连超时；切换网络后曾完全扫不到网络 |
| 摄像头 | USB 能识别，系统权限弹窗能显示画面，Photo Booth 预览黑屏 |
| 蓝牙 | 控制器可出现，但状态为 Off、地址为 NULL，扫描后自动关闭 |
| 手机 USB 共享 | 手机能被 macOS 识别，DHCP 阶段不稳定 |
| U 盘安装盘 | 能引导，但卷读取、推出、关机存在明显卡顿 |

## 尚未验证

- Wi-Fi 备选方案（App 管理连接）在 Tahoe 上的实际表现。
- 睡眠 / 唤醒。
- 内置扬声器与耳机（AppleALC 已注入 `layout-id=100`，但没有完成听感验证）。
- 电池电量与充电状态显示。
- 亮度调节在最新配置下的实际效果。
- 外接显示器、HDMI / USB-C 视频输出。
- 长期稳定性、温度与风扇策略。
- 其它批次 R16 A5X1 的兼容性。

## 采样方法

上述结论来自 SSH 远程执行的只读命令，例如：

```zsh
sw_vers
system_profiler SPDisplaysDataType
system_profiler SPBluetoothDataType
kmutil showloaded | grep -iE 'nullmoth|AirportMtkWlan|itlmt7922|USBToolBox'
ioreg -p IOUSB -w0
log show --last 30m --predicate 'process == "airportd"'
```

没有实机验证过的功能，不要把「配置写对了」当作「功能可用」。
