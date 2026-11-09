# COLORFIRE R16 A5X1 macOS Tahoe OpenCore EFI

适用于 **COLORFIRE 七彩虹 R16 A5X1**（AMD Ryzen 7 H 255 + NVIDIA GeForce RTX 5060 Laptop GPU）的 OpenCore 引导配置，已实机引导 macOS Tahoe 26.7.2（25G332）进入桌面。

仓库只包含引导文件（EFI）、配置和说明文档，**不包含 macOS 安装镜像**。请自行从 Apple 获取安装器后制作安装盘。

## 重要：使用前先补全自己的 SMBIOS

为避免泄露他人机器的唯一标识，仓库中的 `PlatformInfo -> Generic` 已经清空：

| 字段 | 仓库中的值 |
| --- | --- |
| `SystemProductName` | `MacBookPro16,2` |
| `SystemSerialNumber` | 空 |
| `MLB` | 空 |
| `SystemUUID` | `00000000-0000-0000-0000-000000000000` |
| `ROM` | 空 |

请用 **GenSMBIOS** 或 **OCAuxiliaryTools** 为 `MacBookPro16,2` 生成属于自己的三码，写回 `EFI/OC/config.plist` 后再启动。直接使用他人三码可能导致 iMessage / FaceTime / App Store 登录异常。

## 硬件

| 部件 | 型号 |
| --- | --- |
| 机型 | COLORFIRE R16 A5X1 |
| CPU | AMD Ryzen 7 H 255（Phoenix，8C/16T） |
| 独显 | NVIDIA GeForce RTX 5060 Laptop GPU（`10de:2d19`，8 GB，独显直连 eDP） |
| 内存 | 板载 DDR5 |
| 内屏 | `B160QANAA.H`（`06af:81b5`），2560 × 1600，165 Hz |
| 无线 | MediaTek MT7922 / AMD RZ616（`14c3:0616` PCIe；蓝牙 `0e8d:0616` USB） |
| 摄像头 | Chicony USB2.0 Camera（`04f2:b729`） |
| 固件 | Insyde UEFI 1.07.05COLO，支持 Above 4G Decoding；无 CSM 关闭项时保持默认 |

## 目录

```
EFI/                                  可直接使用的 OpenCore 引导（默认原生 Wi-Fi 版）
extras/config.itlmt7922.plist    备用 Wi-Fi 方案配置（App 管理连接）
extras/ItlWiFi7922.app-0.2.2.zip      备用 Wi-Fi 方案的菜单栏 App
extras/hidpi/                         1440 × 900 HiDPI 显示配置与安装脚本
docs/INSTALL.md                       安装盘制作与首次启动
docs/TROUBLESHOOTING.md               常见问题与解决办法
docs/WIFI.md                          无线网卡两种方案的取舍
docs/USB-STORAGE.md                   USB 存储设备卡顿、无法推出
docs/DISPLAY-HIDPI.md                 内屏缩放与清晰度
docs/VALIDATION.md                    实机验证到什么程度
THIRD-PARTY-NOTICES.md                第三方组件与许可
SHA256SUMS                            文件校验值
```

## 状态一览

| 功能 | 状态 | 说明 |
| --- | --- | --- |
| 引导 / 安装 | 可用 | OpenCore 1.0.9，Tahoe 26.7.2 已装好并可进桌面 |
| NVIDIA RTX 5060 | 可用 | NullMoth 驱动，Metal 3，内屏 2560 × 1600 @165 Hz |
| 触摸板 / 键盘 | 可用 | VoodooI2C + VoodooPS2Controller |
| 内屏缩放 | 可用 | 1280 × 800 为点对点；1440 × 900 HiDPI 见 `docs/DISPLAY-HIDPI.md` |
| Wi-Fi | 部分可用 | 原生驱动能连但会掉线；备选方案见 `docs/WIFI.md` |
| 蓝牙 | 未解决 | 能开启，搜索后自动关闭，详见故障文档 |
| 摄像头 | 部分可用 | 系统能识别，Photo Booth 预览黑屏 |
| USB 存储 | 不稳定 | 特定 U 盘识别慢、读不出、推不出，见 `docs/USB-STORAGE.md` |
| 手机 USB 共享 | 未解决 | 手机可被识别，RNDIS/DHCP 不稳定 |
| 亮度调节 | 待确认 | 已注入 BrightnessKeys 与内屏背光启动参数（见 `EFI/OC/config.plist`） |
| 睡眠 / 唤醒 | 未验证 | 建议先关闭睡眠 |

## 快速开始

1. 用 `createinstallmedia` 制作 macOS Tahoe 安装盘，EFI 分区不少于 200 MB。
2. 把本仓库的 `EFI` 目录整个复制到安装盘 EFI 分区的 `EFI` 目录下。
3. 先补全自己的三码，再启动。
4. 开机按启动菜单键，选择该盘的 **UEFI** 启动项，进入 OpenCore 后选 `Install macOS Tahoe`。
5. 安装过程中选择已有的 APFS 卷，**不要格式化 Windows 或其他数据分区**。
6. 系统装好后，可把 EFI 复制到内置 SSD 的 EFI 分区，实现脱离 U 盘启动。

详细的 BIOS 选项、安装步骤与首次配置见 `docs/INSTALL.md`。

## 已知问题

完整的问题、原因和解决办法见 `docs/TROUBLESHOOTING.md`，常见几类：

- `OCVAR: Setting NVRAM ... boot-args - ignored, exists`：`boot-args` 不生效。
- `Still waiting for root device` / 卡在 `validate_root_image`：安装盘读取卡住。
- 安装器里键鼠不可用：USB 端口映射缺失。
- Wi-Fi 掉线、扫描不到网络：驱动兼容性问题。
- 蓝牙开启后自动关闭：蓝牙固件 / 补丁问题。
- Photo Booth 黑屏但权限弹窗有画面：显卡驱动渲染问题。
- 内屏字体发糊：缩放与渲染分辨率不匹配。
- U 盘识别慢、读不出、推不出、关机卡住：USB 存储兼容性问题。

## 许可

本仓库中的原创文档、配置修改与脚本以 MIT 许可发布，见 `LICENSE`。EFI 中第三方二进制组件（OpenCore、kext、驱动）版权归各自作者所有，许可以上游仓库为准，详见 `THIRD-PARTY-NOTICES.md` 与 `LICENSES/`。

## 免责声明

黑苹果为非官方用法，配置在不同批次硬件、不同固件版本上可能表现不同。修改 EFI、写入磁盘、关闭 SIP 等操作有风险，请先备份重要数据。本仓库不包含亦不提供 macOS 安装镜像。
