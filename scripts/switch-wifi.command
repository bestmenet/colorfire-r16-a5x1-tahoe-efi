#!/bin/zsh
# Switch the Wi-Fi kext pair between the native and the app-managed variants.
set -euo pipefail

MODE="${1:-native}"
CONFIG="${2:-/Volumes/EFI/EFI/OC/config.plist}"

if [[ ! -f "$CONFIG" ]]; then
  echo "找不到 $CONFIG，请传入 EFI/OC/config.plist 的路径。" >&2
  exit 1
fi

python3 - "$MODE" "$CONFIG" <<'PY'
import plistlib, shutil, sys
from pathlib import Path

mode, path = sys.argv[1], Path(sys.argv[2])
if mode not in ('native', 'app'):
    raise SystemExit('用法：switch-wifi.command native|app [config.plist]')

kexts = path.parent / 'Kexts'
if not kexts.is_dir():
    raise SystemExit('找不到同级的 Kexts 目录，未修改。')

native_names, app_names = set(), set()
for bundle in sorted(kexts.iterdir()):
    info = bundle / 'Contents/Info.plist'
    if not info.is_file():
        continue
    try:
        identifier = plistlib.loads(info.read_bytes()).get('CFBundleIdentifier', '')
    except Exception:
        continue
    if identifier.startswith('com.flxxxxddd'):
        native_names.add(bundle.name)
    elif identifier.startswith('local.experimental'):
        app_names.add(bundle.name)
if len(native_names) != 1 or len(app_names) != 1:
    raise SystemExit('Kexts 目录中的无线驱动与预期不符，未修改。')

config = plistlib.loads(path.read_bytes())
entries = config['Kernel']['Add']
native = [e for e in entries if e['BundlePath'].split('/')[0] in native_names]
app = [e for e in entries if e['BundlePath'].split('/')[0] in app_names]
if len(native) != 1 or len(app) != 1:
    raise SystemExit('配置中的无线 kext 条目与预期不符，未修改。')

shutil.copy2(path, path.with_suffix('.plist.bak'))
for entry in entries:
    if entry in native:
        entry['Enabled'] = (mode == 'native')
    if entry in app:
        entry['Enabled'] = (mode == 'app')
path.write_bytes(plistlib.dumps(config, sort_keys=False))
print('已切换为 %s 方案，原配置备份为 %s' % (mode, path.with_suffix('.plist.bak')))
PY

if command -v ocvalidate >/dev/null 2>&1; then
  ocvalidate "$CONFIG" || echo "ocvalidate 有输出，请检查上面的提示。" >&2
fi
