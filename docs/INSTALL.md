# 安装

## 1. 准备安装盘

在任意一台能运行 Tahoe 安装器完整包的 Mac 上：

```zsh
sudo "/Applications/Install macOS Tahoe.app/Contents/Resources/createinstallmedia" \
  --volume /Volumes/INSTALLER --nointeraction
```

要求：

- 磁盘分区表为 **GPT**。
- EFI 分区不少于 **200 MB**（本仓库 EFI 目录连同 OpenCore Resources 约 17 MB，但需要留出日志与报告空间）。
- 安装器分区用 `createinstallmedia` 直接创建，不要手工把 `SharedSupport.dmg` 拆开再拼回去；`.partial` 文件不能改名为正式文件，否则会出现「安装器已损坏」。
- 完成后把本仓库的 `EFI` 目录复制到该盘 EFI 分区的根目录，最终结构为 `EFI/EFI/OC/...`、`EFI/EFI/BOOT/...`。

## 2. 补全 SMBIOS

仓库里的 `EFI/OC/config.plist` 已清空 `SystemSerialNumber`、`MLB`、`SystemUUID`、`ROM`。

1. 用 GenSMBIOS 或 OCAuxiliaryTools 选择机型 `MacBookPro16,2`。
2. 生成一组属于你自己的三码。
3. 填回 `PlatformInfo -> Generic` 的对应字段。
4. 用 OpenCore 官方 `ocvalidate` 校验 `config.plist` 没有报错。

不要直接复制别人的三码，也不要公开发布自己的三码。

## 3. 固件设置（Insyde UEFI 1.07.05COLO）

| 选项 | 值 |
| --- | --- |
| Above 4G Decoding | Enabled |
| CSM / Legacy Boot | Disabled（有该选项时） |
| Secure Boot | Disabled |
| Fast Boot | Disabled |
| VT-d / IOMMU | 可保持开启，配置里 `DisableIoMapper=true` |
| Resizable BAR | 保持固件默认；配置中 `ResizeAppleGpuBars=0`、`ResizeGpuBars=-1` |

开机按启动菜单键，选择安装盘的 **UEFI** 启动项，进入 OpenCore 后选 `Install macOS Tahoe`。

## 4. 安装系统

- 安装目标选**已有的 APFS 卷**，不要抹掉 Windows 或数据分区。
- 安装过程中会重启数次：先选 `macOS Installer`，最后选 `macOS`。
- 首次进入桌面前可能黑屏并只显示鼠标指针，这是 NVIDIA 驱动加载前固件帧缓冲的表现；等待 1–2 分钟。若始终黑屏，见 `TROUBLESHOOTING.md`。

## 5. 安装 NVIDIA 驱动

本仓库的 `boot-args`、SIP 与 `SecureBootModel` 已按 NullMoth 驱动的要求配置，但驱动本体需要单独安装：

1. 下载 NullMoth 的 `nullmoth-nvidia-<版本>.tar.gz`（R16 已验证 2.7.1）。
2. 校验包内 `SHA256SUMS` 全部为 `OK`。
3. `sudo ./install.sh`，重启。
4. 在「系统设置 → 隐私与安全性」允许扩展，再次重启。
5. 用 `kmutil showloaded | grep -i nullmoth` 确认 `NVRM`、`NVRMFB`、`NVAccel`、`NVRMAGDC` 都已加载。

## 6. 安装后建议

- 把 EFI 复制到内置 SSD 的 EFI 分区，之后可脱离 U 盘启动；保留安装盘作为回退。
- 系统设置中关闭睡眠，或至少关闭「断电后自动重启」；睡眠/唤醒尚未验证。
- 若使用手机 USB 共享网络，参考 `TROUBLESHOOTING.md`；不依赖它时优先使用有线网卡或 Wi-Fi。
- 需要远程维护时打开「系统设置 → 通用 → 共享 → 远程登录」，只允许自己的账户。

## 7. 回退

- 启动失败时，可在 OpenCore 菜单按 `Space` 显示辅助项，选择 `Reset NVRAM`。
- 也可以在启动菜单直接选择 Windows 的 UEFI 项，确认引导分区没有被破坏。
- U 盘 EFI 修改前先备份整个 `EFI` 目录，便于逐项回退。
