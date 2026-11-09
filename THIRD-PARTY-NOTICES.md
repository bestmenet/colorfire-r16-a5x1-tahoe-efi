# 第三方组件与许可

`EFI/` 中的 kext 与 EFI 驱动均来自上游项目的公开版本，本仓库只修改了 `config.plist` 与 ACPI 选择，**未修改任何上游二进制**。

| 组件 | 版本 | 上游 | 许可说明 |
| --- | --- | --- | --- |
| OpenCorePkg（OpenCore.efi / BOOTx64.efi / OpenRuntime / OpenCanopy / ResetNvramEntry） | 1.0.9 | https://github.com/acidanthera/OpenCorePkg | BSD-3-Clause |
| HfsPlus.efi | — | https://github.com/acidanthera/OcBinaryData | 见上游仓库 |
| Lilu | 1.7.3 | https://github.com/acidanthera/Lilu | BSD-3-Clause |
| WhateverGreen | 1.7.2 | https://github.com/acidanthera/WhateverGreen | BSD-3-Clause |
| AppleALC | 1.9.9 | https://github.com/acidanthera/AppleALC | BSD-3-Clause |
| VirtualSMC | 1.3.9 | https://github.com/acidanthera/VirtualSMC | BSD-3-Clause |
| SMCBatteryManager / SMCLightSensor | 1.3.9 | https://github.com/acidanthera/VirtualSMC | BSD-3-Clause |
| NVMeFix | 1.1.4 | https://github.com/acidanthera/NVMeFix | 见上游仓库 |
| BrightnessKeys | — | https://github.com/acidanthera/BrightnessKeys | BSD-3-Clause |
| RestrictEvents | 1.1.7 | https://github.com/acidanthera/RestrictEvents | BSD-3-Clause |
| AMFIPass | 1.4.1 | 社区项目，见 kext 内 `Info.plist` 标识 `com.dhinakg.AMFIPass` | 许可以上游为准 |
| AppleMCEReporterDisabler | — | 社区常见组件，`org.xlnc.disabler.MCEReporter` | 上游仓库状态不明，许可以原发布方为准 |
| RealtekRTL8111 | 2.4.2 | https://github.com/Mieze/RTL8111_driver_for_OS_X | 见上游仓库 |
| VoodooI2C | 2.9.1 | https://github.com/VoodooI2C/VoodooI2C | GPL-3.0 |
| VoodooI2CHID | 1.x | https://github.com/VoodooI2C/VoodooI2C | GPL-3.0 |
| VoodooPS2Controller | 2.3.8 | https://github.com/acidanthera/VoodooPS2 | 见上游仓库 |
| USBToolBox.kext | 1.2.0 | https://github.com/USBToolBox/kext | 上游仓库未声明许可信息，使用前请核对上游 |
| UTBMap.kext | 1.1 | 本机端口映射（生成数据） | 与本仓库其它原创文件相同 |
| AirportMtkWlan | 2.0.0 | https://github.com/Arxusion/AirportMtkWlan | GPL-2.0 |
| itlmt7922 | 0.2.2 | https://github.com/hbyonly1/itlmt7922-wifi | 上游 README 标注 GPLv2，仓库同时保留原始项目的 Clear BSD 声明 |
| SimpleMtkBtFw / SimpleMtkBtPatcher | 1.0.0 | https://github.com/laobamac/SimpleMtkBtFw | GPL-3.0 |
| ItlWiFi7922.app | 0.2.2 | https://github.com/hbyonly1/itlmt7922-wifi | 同上 |

## 不包含的外部组件

以下组件不在本仓库中，需要单独获取：

| 组件 | 用途 | 上游 |
| --- | --- | --- |
| NullMoth NVIDIA 驱动 | RTX 5060 显卡加速 | https://github.com/nullmoth/nvidia-macos-driver |
| macOS 安装器 | 安装系统 | Apple |
| TetherKitNext | 手机 USB 共享网络（可选） | https://github.com/AA-EION/TetherKitNext |
| BetterDisplay | 自定义缩放（可选） | https://github.com/waydabber/BetterDisplay |

## 许可文本

`LICENSES/` 中收录了本仓库可直接获取到的上游许可文本。上表标注「见上游仓库」的组件，请以对应上游仓库内的许可文件为准。如果你是对应组件的权利人，认为本仓库的收录方式不妥，请提 issue，我们会配合调整或移除。
