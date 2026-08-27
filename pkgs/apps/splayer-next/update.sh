#!/usr/bin/env bash
set -euo pipefail

force=0
[ "${1:-}" = "--force" ] && force=1

# 定位仓库根（脚本可能被 passthru.updateScript 包装后调用，故不用 $PWD）
repo="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
files=("$repo/pkgs/splayer-next/default.nix" "$repo/pkgs/splayer-next/electron.nix")

cur="$(grep -oP 'version = "\K[0-9.]+' "${files[1]}")"

tag="$(curl -fsSL https://api.github.com/repos/SPlayer-Dev/SPlayer-Next/releases/latest \
  | grep -oP '"tag_name": "\Kv[0-9.]+' | head -1)"
[ -n "$tag" ] || { echo "无法解析最新版本"; exit 1; }
new="${tag#v}"

if [ "$new" = "$cur" ]; then
  echo "已是最新：v$cur"
  exit 0
fi
echo "发现新版本：v$cur -> v$new"

base="https://github.com/SPlayer-Dev/SPlayer-Next/releases/download/v${new}"
amd_json="$(nix store prefetch-file "${base}/splayer-next-${new}-amd64.deb")"
amd_hash="$(echo "$amd_json" | grep -oP '"hash": "\K[^"]+')"
amd_path="$(echo "$amd_json" | grep -oP '"storePath": "\K[^"]+')"
arm_hash="$(nix store prefetch-file "${base}/splayer-next-${new}-arm64.deb" \
  | grep -oP '"hash": "\K[^"]+')"
echo "amd64: $amd_hash"
echo "arm64: $arm_hash"

# 校验新版捆绑的 Electron 大版本是否与 electron.nix 一致。
# audio-engine/media-ctrl 非 N-API（ABI 绑定 Electron 版本），大版本不符会加载失败。
cur_elec="$(grep -oP 'electron_\K[0-9]+' "${files[1]}" | head -1)"
data="$(ar t "$amd_path" | grep -oE 'data\.tar\.[a-z0-9]+' | head -1)"
new_elec="$(ar p "$amd_path" "$data" | tar -xJOf - --wildcards './opt/*/SPlayer-Next' 2>/dev/null \
  | grep -aoE 'Electron/[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
new_major="${new_elec#Electron/}"; new_major="${new_major%%.*}"
if [ -z "$new_elec" ]; then
  echo "⚠ 无法从新 deb 解析 Electron 版本，跳过校验"
elif [ "$cur_elec" != "$new_major" ]; then
  echo "✗ Electron 大版本不匹配：electron.nix 用 electron_$cur_elec，新版捆绑 $new_elec"
  echo "  需先手动改 electron.nix：electron_$cur_elec -> electron_$new_major"
  echo "  并复验 native/audio-engine.node、media-ctrl.node 能否 dlopen"
  [ "$force" = 1 ] || { echo "  （确认处理完可用 --force 强制继续更新版本号）"; exit 1; }
else
  echo "✓ Electron 大版本一致（electron_$cur_elec = $new_elec），无需改 electron.nix"
fi

for f in "${files[@]}"; do
  sed -i "s|version = \"$cur\"|version = \"$new\"|" "$f"
  # URL 行以 -amd64.deb 字面结尾（版本走 ${version} 模板），据此定位 hash 行
  sed -i '/-amd64\.deb/!b; n; s|hash = ".*"|hash = "'"$amd_hash"'"|' "$f"
  sed -i '/-arm64\.deb/!b; n; s|hash = ".*"|hash = "'"$arm_hash"'"|' "$f"
done

echo "已同步 $(basename "${files[0]}")、$(basename "${files[1]}") 到 v$new"
echo "下一步：nix build .#splayer-next.default .#default.splayer-next-electron 并冒烟测试"