# 常见问题与解决办法

这里记录的问题都来自 R16 A5X1 的实机排查。没有实机确认的结论会标注「未验证」。

## 1. boot-args 不生效

**现象**：`config.plist` 里写了启动参数，但系统里的参数不对；日志出现

```
OCVAR: Setting NVRAM 7C436110-AB2A-4BBB-A880-FE41995C9F82:boot-args - ignored, exists
```

**原因**：NVRAM 中已存在 `boot-args`，OpenCore 不会覆盖。

**处理**：在 `NVRAM -> Delete -> 7C436110-AB2A-4BBB-A880-FE41995C9F82` 列表里加入 `boot-args`，让 OpenCore 先删除旧值。本仓库的配置已经包含这一项。

## 2. 卡在 `Still waiting for root device` 或 `validate_root_image`

**现象**：安装盘引导阶段停下，日志停在

```
Still waiting for root device
imageboot_setup_new ...
authenticate_root_with_chunklist: validating root image against chunklist
```

或在 `validate_root_image` 一行长时间不动。

**原因**：安装盘（USB 存储）读取卡住，多见于特定 U 盘与 macOS USB 存储驱动的组合。此时不要在读取过程中拔盘。

**处理**：

1. 换一只不同主控的 U 盘或移动硬盘重做安装盘。
2. 也可以把安装镜像复制到内置 SSD，再从内存恢复环境读取。
3. 若使用本仓库默认的 USB 映射，确认 `USBToolBox.kext`、`UTBMap.kext` 均已启用，不要启用 `XhciPortLimit`。
4. 具体到某只盘的卡顿、读不出、推不出，见 `USB-STORAGE.md`。

## 3. 安装器里键盘或触摸板不可用

**现象**：能进入安装界面，但无法操作。

**原因**：USB 端口映射缺失或错误，端口被限制在 15 个以内。

**处理**：

1. 确认 `Kernel -> Add` 里 `USBToolBox.kext` 与 `UTBMap.kext` 为启用状态。
2. 用另一台机器（Windows 端 USBToolBox 工具）针对本机生成映射，或按本仓库的 `UTBMap.kext` 端口表核对。
3. 不要同时启用 `XhciPortLimit` 和自定义映射。
4. 开机日志里出现 `USBToolBox: XHCn: Successfully applied map` 才算生效。

## 4. Wi-Fi 掉线、扫描不到网络

**现象**：能连上但每 1–2 分钟断一次；日志反复出现

```
AutoJoin: _handleLinkEvent: Link down event. Triggering auto-join.
AUTO-JOIN: Join FAILED (duration=10166ms, error=(-3905), security=owe-transition)
```

切换网络后甚至完全扫不到网络，反复开关 Wi-Fi 无效。

**原因**：RZ616 / MT7922 的第三方驱动与 macOS 无线栈的兼容性问题，不是密码或路由器设置错误。

**处理**：

1. 按 `WIFI.md` 在两套驱动方案之间切换，先确认是驱动问题还是硬件问题。
2. 更换 Wi-Fi 频段或加密方式（例如从 OWE 过渡模式切到 WPA2 密码网络）后重试。
3. 需要稳定联网时，改用 USB-C 有线网卡。
4. 不要指望通过调整 `boot-args` 或 `DisableIoMapper` 解决，这是驱动层问题。

## 5. 蓝牙能开启，搜索后自动关闭

**现象**：蓝牙开关可以打开，扫描不到设备，几秒后自动关闭。`system_profiler SPBluetoothDataType` 显示

```
Address: NULL
State: Off
Chipset: BCM_4350C2
Transport: UART
```

**判断**：控制器没有被正确初始化，被识别成其它芯片型号。

**处理**：

1. 确认 `SimpleMtkBtFw.kext` 与 `SimpleMtkBtPatcher.kext` 都在启用状态（本仓库已启用）。
2. 蓝牙走 USB（`0e8d:0616`），确认 USB 映射没有把对应端口裁掉。
3. 若仍失败，这是驱动层未解决的问题，建议先用 USB 蓝牙适配器替代。

## 6. Photo Booth 预览黑屏，但系统权限弹窗有画面

**现象**：摄像头指示灯亮，系统询问权限时能看到实时画面，Photo Booth 里却是黑的。日志中反复出现

```
Photo Booth: [com.apple.coreimage:api] ... The destination is nil.
```

**原因**：摄像头取流本身正常，问题出在显卡驱动侧的图像渲染路径。

**处理**：

1. 确认 NVIDIA 驱动版本与 macOS 版本匹配；上游从 2.6.5 起修复过 Photo Booth 黑屏，但仍可能与其它版本组合复发。
2. 重新安装与当前系统匹配的完整驱动包，而不是只替换个别的 bundle。
3. 临时可用系统「相机」权限弹窗、`QuickTime Player` 新建影片录制等方式验证摄像头硬件。
4. 若所有应用都黑屏而权限弹窗正常，记录驱动版本后向上游反馈。

## 7. 内屏字体发糊

**现象**：开启 HiDPI 后文字和图标仍不够锐利。

**原因**：逻辑分辨率与渲染分辨率不匹配。本机面板原生 2560 × 1600：

- 1280 × 800 HiDPI → 2560 × 1600 渲染，是点对点，最锐利；
- 1440 × 900 HiDPI → 2880 × 1800 渲染，系统要再缩回 2560 × 1600，会出现重采样。

**处理**：见 `DISPLAY-HIDPI.md`。追求锐利就用 1280 × 800，需要更大显示面积再考虑 1440 × 900。

## 8. 亮度无法调节

**现象**：内屏亮度滑杆或功能键无效。

**处理**：

1. 本仓库已包含 `BrightnessKeys.kext` 与内屏背光启动参数，先确认它们已启用。
2. 用 `ioreg -c AppleBacklightDisplay | grep IODisplayParameters` 查看 `brightness` 是否存在。
3. 若键值存在但功能键无效，检查键盘映射；若键值不存在，则是显卡驱动没有暴露背光控制，需要等驱动支持。

## 9. 手机 USB 共享网络不稳定

**现象**：手机插上后能被识别，但「USB 网络共享」开关无反应，或连接后很快断开、拿不到 IP。

**已知情况**：荣耀手机需要先在「开发人员选项 → 选择 USB 配置」选 **RNDIS（USB 以太网）**，再打开「个人热点 → 更多共享设置 → USB 共享网络」。即使如此，macOS 侧仍可能出现 DHCP 超时。

**处理**：

1. 确认手机端开关与 USB 配置同时满足。
2. 用 `ioreg -p IOUSB -w0` 确认手机设备已枚举。
3. 需要自动重连时，使用支持 DHCP 重试的 USB 网络共享工具；纯 TetherKitNext 场景下 DHCP 超时后需要手动重新连接。
4. 长期方案仍是 USB-C 有线网卡或可用的 Wi-Fi。

## 10. 提示「安装器已损坏」

**原因**：安装器的 `SharedSupport.dmg` 不完整，或被手工用 `.partial` 文件拼出来。

**处理**：

1. 用官方 `createinstallmedia` 重新制作安装盘。
2. 校验安装器包签名与哈希，再重新展开。
3. 不要把 `SharedSupport.dmg.partial` 直接改名使用。

## 11. 开机黑屏只剩鼠标指针

**原因**：NVIDIA 驱动尚未加载，或驱动与系统版本不匹配。

**处理**：

1. 等待 1–2 分钟；驱动加载完成后画面会恢复。
2. 用 `kmutil showloaded | grep -i nullmoth` 确认驱动已加载。
3. 启动参数中临时加入 `-nvoff` 进入无驱动模式排查。
4. 重新安装与当前 macOS 版本匹配的完整驱动包。

## 12. 开机后短暂卡顿

**现象**：刚开机或首次打开程序时明显卡顿，随后缓解。

**判断**：着色器编译与缓存预热，属于第三方显卡驱动的常见现象。是否与窗口拖动掉帧有关，需要单独看上游 issue。

## 13. 修改配置后无法启动

1. OpenCore 菜单按 `Space`，选择 `Reset NVRAM`。
2. 用备份的 `config.plist` 覆盖回去。
3. 每次只改一个项目，改完立即用 `ocvalidate` 校验。

## 14. 关机或推出磁盘卡住

**现象**：Finder 推出长时间不完成，关机也停在最后一步。

**原因**：磁盘请求没有返回，多见于 USB 存储设备。

**处理**：

1. 先等待，不要反复点击。
2. 正常关机若长时间无反应，可以长按电源键强制关机，再拔掉存储设备。
3. 详见 `USB-STORAGE.md`。
