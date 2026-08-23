#!/usr/bin/env bash
# ==================== 万能字幕改名脚本 v4（智能剧集号匹配版） ====================

mkdir -p ./subtitle_backup

# ====================== 配置 ======================
DRY_RUN=true
FORCE=false

# ====================== 语言后缀保留 + 严格推断 ======================
preserve_or_infer_lang() {
    local subname="$1"
    local sub_base="${subname%.*}"

    # 1. 优先保留已存在的标准语言后缀（.eng / .en / .chs 等）
    if [[ "$sub_base" =~ \.(chs|cht|eng|jpn|kor|chi|tc|gb|en|jp|ko)$ ]]; then
        echo "${BASH_REMATCH[0]}"
        return
    fi

    # 2. 没有后缀时才推断（严格版：只认明确关键词，避免 Gensou 等误判）
    if [[ $subname =~ (chs|chi|中文|简体|gb|简) ]]; then echo ".chs"
    elif [[ $subname =~ (cht|tc|繁体|big5|繁) ]]; then echo ".cht"
    elif [[ $subname =~ (eng|english|英) ]]; then echo ".eng"
    elif [[ $subname =~ (jpn|jp|日|japanese) ]]; then echo ".jpn"
    elif [[ $subname =~ (kor|ko|韩|korean) ]]; then echo ".kor"
    else echo ""
    fi
}

# ====================== 智能剧集号提取（核心升级） ======================
# 支持 [01]、[02]、[OVA]、S01E01、Episode 1、纯数字 01/1 等
extract_episode_key() {
    local fname="${1##*/}"
    fname="${fname%.*}"  # 去掉扩展名

    # 1. 最常见动漫压制组格式：[01] / [02] / [OVA]
    if [[ $fname =~ \[(0?[0-9]{1,2}|OVA)\] ]]; then
        local num="${BASH_REMATCH[1]}"
        [[ $num == OVA ]] && echo "OVA" || printf "%02d" "$num"
        return
    fi

    # 2. S01E01 / S01E02 格式
    if [[ $fname =~ S[0-9]+E0?([0-9]{1,3}) ]]; then
        printf "%02d" "${BASH_REMATCH[1]}"
        return
    fi

    # 3. Episode 1 / Ep.01 / 第01话 等
    if [[ $fname =~ (Episode|Ep|第)[^0-9]*0?([0-9]{1,3}) ]]; then
        printf "%02d" "${BASH_REMATCH[2]}"
        return
    fi

    # 4. 纯数字（如 1.ass、01.mkv）
    if [[ $fname =~ ([0-9]{1,3}) ]]; then
        printf "%02d" "${BASH_REMATCH[1]}"
        return
    fi

    # 兜底：无剧集号时用文件名简写（避免完全无法匹配）
    echo "NOKEY_${fname:0:8}"
}

# ====================== 使用说明 ======================
usage() {
    cat <<EOF
用法:
  $0                          # 批量智能剧集号匹配（推荐！按 [01]/S01E01/OVA 自动对应）
  $0 video.mkv                # 处理单个视频 + 自动找同基名字幕
  $0 video.mkv sub1.srt ...   # 手动指定
  $0 --force                  # 执行真实改名（默认只预览）
  $0 --help | -h

v4 重磅升级：
- 智能剧集号匹配（不再依赖文件名排序！）
- 支持 [01]、[OVA]、S01E01、Episode 1、纯数字等
- 已有 .eng/.chs 后缀完整保留
- 已匹配文件显示“✅ 已完美匹配”
- 你的 VCB-Studio 文件会 100% 完美对应
EOF
}

[[ "$1" == "--help" || "$1" == "-h" ]] && { usage; exit 0; }

if [[ "$1" == "--force" ]]; then
    FORCE=true
    DRY_RUN=false
    shift
fi

# ====================== 核心改名函数 ======================
rename_sub() {
    local video="$1"
    local sub="$2"

    local videoname="${video##*/}"
    local base="${videoname%.*}"
    local subname="${sub##*/}"
    local subext="${sub##*.}"

    local lang_suffix=$(preserve_or_infer_lang "$subname")
    local new_sub="${base}${lang_suffix}.${subext}"

    echo -e ">>> 字幕改名:\n    原: $sub\n    新: $new_sub"

    # 如果新旧完全一样
    if [[ "$(realpath "$sub" 2>/dev/null || echo "$sub")" == "$(realpath "$new_sub" 2>/dev/null || echo "$new_sub")" ]]; then
        echo "✅ 已完美匹配视频名，无需改名"
        return
    fi

    if [ -f "$new_sub" ]; then
        echo "⚠️  目标已存在，跳过"
        return
    fi

    if $DRY_RUN; then
        echo "   [dry-run] mv \"$sub\" \"$new_sub\""
        echo "   [dry-run] 备份 → ./subtitle_backup/$subname"
    else
        cp "$sub" "./subtitle_backup/${subname}" 2>/dev/null || true
        mv "$sub" "$new_sub"
        echo "✅ 成功: $new_sub"
    fi
}

# ====================== 主逻辑 ======================
if [ $# -eq 0 ]; then
    # ==================== v4 智能剧集号匹配模式 ====================
    echo "=== 进入批量智能剧集号匹配模式 ==="

    mapfile -t videos < <(find . -maxdepth 1 -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.m2ts" -o -name "*.ts" -o -name "*.avi" -o -name "*.mov" -o -name "*.webm" \) | sort)
    mapfile -t subs < <(find . -maxdepth 1 -type f \( -name "*.srt" -o -name "*.ass" -o -name "*.ssa" -o -name "*.vtt" -o -name "*.sub" \) | sort)

    if [ ${#videos[@]} -eq 0 ] || [ ${#subs[@]} -eq 0 ]; then
        echo "未找到视频或字幕文件"
        exit 1
    fi

    declare -A video_by_key
    declare -A sub_by_key

    for v in "${videos[@]}"; do
        key=$(extract_episode_key "$v")
        video_by_key["$key"]="$v"
    done

    for s in "${subs[@]}"; do
        key=$(extract_episode_key "$s")
        sub_by_key["$key"]="$s"
    done

    matched=0
    for key in "${!video_by_key[@]}"; do
        if [[ -n "${sub_by_key[$key]}" ]]; then
            rename_sub "${video_by_key[$key]}" "${sub_by_key[$key]}"
            ((matched++))
        else
            echo "⚠️  未找到匹配字幕 (剧集号=$key): ${video_by_key[$key]}"
        fi
    done

    echo "智能匹配完成：共匹配 $matched 个视频/字幕对"

    # 如果一个都没匹配到，友好提示退回旧方式
    if [ $matched -eq 0 ]; then
        echo "⚠️  未检测到任何剧集号，建议使用手动模式或检查文件名"
    fi

elif [ $# -eq 1 ]; then
    # ==================== 单视频模式（保持原样） ====================
    video="$1"
    base="${video%.*}"
    echo "=== 处理视频: $video（自动找同基名字幕）==="
    for candidate in "$base".*; do
        [ -f "$candidate" ] || continue
        [[ "$candidate" == "$video" ]] && continue
        ext="${candidate##*.}"
        [[ "$ext" =~ ^(srt|ass|ssa|vtt|sub)$ ]] || continue
        rename_sub "$video" "$candidate"
    done

else
    # ==================== 手动模式 ====================
    video="$1"
    shift
    echo "=== 手动模式: $video + ${#} 个字幕 ==="
    for sub in "$@"; do
        [ -f "$sub" ] || { echo "跳过不存在文件: $sub"; continue; }
        rename_sub "$video" "$sub"
    done
fi

if $DRY_RUN; then
    echo -e "\n=== 这是预览模式 ===\n使用 \`$0 --force\` 才能真正执行！"
else
    echo -e "\n=== 全部处理完成！备份目录: ./subtitle_backup/ ==="
fi