#!/bin/zsh
set -euo pipefail
umask 077
TARGET='/Library/Displays/Contents/Resources/Overrides/DisplayVendorID-6af/DisplayProductID-81b5'
TEMP=$(/usr/bin/mktemp /private/tmp/r16-hidpi.XXXXXXXX)
trap '/bin/unlink "$TEMP" 2>/dev/null || true' EXIT
/bin/cat > "$TEMP" <<'DISPLAY_PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>DisplayProductID</key>
	<integer>33205</integer>
	<key>DisplayVendorID</key>
	<integer>1711</integer>
	<key>scale-resolutions</key>
	<array>
		<data>
		AAALQAAABwgAAAAB
		</data>
	</array>
</dict>
</plist>
DISPLAY_PLIST
/usr/bin/plutil -lint "$TEMP"
mode=${1:-install}
case "$mode" in
  --check)
    for d in /Library/Displays /Library/Displays/Contents /Library/Displays/Contents/Resources /Library/Displays/Contents/Resources/Overrides "${TARGET:h}"; do
      if [[ -d "$d" && ! -x "$d" ]]; then
        print -u2 "显示配置目录权限阻止读取：$d"
        exit 1
      fi
    done
    if /usr/bin/cmp -s "$TEMP" "$TARGET"; then
      print '配置已安装并通过检查。'
    elif [[ -e "$TARGET" || -L "$TARGET" ]]; then
      print -u2 '已有显示配置，内容或读取权限需要检查。'
      exit 1
    else
      print '安装文件有效；系统中尚无这份显示配置。'
    fi
    exit 0 ;;
  --undo) ;;
  install)
    if [[ ! -L "$TARGET" ]] && /usr/bin/cmp -s "$TEMP" "$TARGET"; then
      print '1440×900 HiDPI 配置已经安装。'
      exit 0
    fi ;;
  *) print -u2 '可用选项：--check、--undo。'; exit 2 ;;
esac
ROOT_ACTION=$(/bin/cat <<'ROOT_SCRIPT'
set -eu
umask 022
src=$1
target=$2
mode=$3
base=/Library/Displays
vendor=${target%/*}
[ "$target" = "$base/Contents/Resources/Overrides/DisplayVendorID-6af/DisplayProductID-81b5" ] || exit 2
for d in "$base" "$base/Contents" "$base/Contents/Resources" "$base/Contents/Resources/Overrides" "$vendor"; do
  if [ -L "$d" ] || { [ -e "$d" ] && [ ! -d "$d" ]; }; then
    printf '显示配置目录不是普通目录：%s\n' "$d" >&2
    exit 1
  fi
done
if [ -L "$target" ] || { [ -e "$target" ] && { [ ! -f "$target" ] || ! /usr/bin/cmp -s "$src" "$target"; }; }; then
  printf '检测到另一份显示配置，已保留原文件。\n' >&2
  exit 1
fi
if [ "$mode" = --undo ]; then
  /usr/bin/cmp -s "$src" "$target" && /bin/unlink "$target"
  exit $?
fi
/usr/bin/install -d -o root -g wheel -m 755 "$vendor"
if [ ! -e "$target" ]; then
  /usr/bin/install -o root -g wheel -m 644 "$src" "$target"
fi
/usr/bin/cmp -s "$src" "$target" || { printf '管理员校验：配置内容不一致。\n' >&2; exit 1; }
/bin/chmod 644 "$target"
/bin/chmod 755 "$base" "$base/Contents" "$base/Contents/Resources" "$base/Contents/Resources/Overrides" "$vendor"
/usr/bin/plutil -lint "$target"
ROOT_SCRIPT
)
print '请在弹出的 macOS 管理员授权窗口里输入本机密码。'
if ! /usr/bin/osascript - "$ROOT_ACTION" "$TEMP" "$TARGET" "$mode" <<'APPLE_SCRIPT'
on run argv
  set actionText to "/bin/sh -c " & quoted form of (item 1 of argv) & " sh " & quoted form of (item 2 of argv) & " " & quoted form of (item 3 of argv) & " " & quoted form of (item 4 of argv)
  do shell script actionText with administrator privileges
end run
APPLE_SCRIPT
then
  print -u2 '管理员授权或写入失败；请保留上面那行错误。'
  exit 1
fi
if [[ "$mode" == --undo ]]; then
  [[ ! -e "$TARGET" && ! -L "$TARGET" ]] || { print -u2 '还原后检查失败。'; exit 1; }
  print '已还原。下次重启后生效。'
else
  /usr/bin/cmp -s "$TEMP" "$TARGET" || { print -u2 '写入后普通用户仍无法读取或文件内容不一致。'; exit 1; }
  print '已安装。下次重启后，到「系统设置 → 显示器 → 显示所有分辨率」查看 1440×900 档位。'
fi
