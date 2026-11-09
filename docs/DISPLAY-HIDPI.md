# 内屏缩放与 HiDPI

面板：`B160QANAA.H`，EDID 厂商 `06af`、产品 `81b5`，原生 2560 × 1600，165 Hz。

## 点对点档位

| 档位 | 逻辑分辨率 | 渲染分辨率 | 是否需要缩放 |
| --- | --- | --- | --- |
| 默认 | 1280 × 800 | 2560 × 1600 | 否，点对点，最锐利 |
| HiDPI | 1440 × 900 | 2880 × 1800 | 是，缩回 2560 × 1600 |
| HiDPI | 1536 × 960 | 3072 × 1920 | 是，缩得更明显 |

结论：如果目标是文字最清晰，使用 **1280 × 800**，它同时保留 165 Hz。觉得界面太大时，优先在应用内缩放内容，而不是提高系统分辨率。

## 添加 1440 × 900 HiDPI 档位

仓库提供：

- `extras/hidpi/DisplayProductID-81b5`
- `extras/hidpi/install-1440x900-hidpi.command`

在 macOS 下执行：

```zsh
zsh extras/hidpi/install-1440x900-hidpi.command
```

脚本会请求管理员授权，把显示配置写入

```
/Library/Displays/Contents/Resources/Overrides/DisplayVendorID-6af/DisplayProductID-81b5
```

之后重启，在「系统设置 → 显示器 → 显示所有分辨率」中选择 1440 × 900。

## 注意事项

1. `scale-resolutions` 使用 **12 字节**格式（宽、高、1），不要用 16 字节且末位为 `0x00200000` 的旧格式，否则模式会被隐藏。
2. 写入后要重启，仅退出登录不生效。
3. `/Library/Displays` 目录默认权限为 700，普通用户无法读取，脚本会同时修正目录权限。
4. 该配置文件只针对上述 EDID 的面板；换屏或不同批次面板需要重新生成。

## 亮度

背光控制依赖显卡驱动暴露的 `IODisplayParameters`。可用下面的命令确认：

```zsh
ioreg -c AppleBacklightDisplay -l -w0 | grep IODisplayParameters
```

如果 `brightness` 键存在但功能键无效，先检查 `BrightnessKeys.kext` 是否加载；如果键不存在，需要等驱动支持。
