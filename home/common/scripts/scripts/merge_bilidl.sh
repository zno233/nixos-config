#!/usr/bin/env bash
# ==================== 改进版：万能视频+音频合并脚本 ====================

# 1. NixOS 自适应 + ffmpeg 检查
if ! command -v ffmpeg &> /dev/null; then
    echo "错误: 未找到 ffmpeg。"
    echo "提示: 请运行 'nix-shell -p ffmpeg' 进入环境后再执行此脚本。"
    exit 1
fi

mkdir -p ./merged_output

# ====================== 使用说明 ======================
usage() {
    cat <<EOF
用法:
  $0                          # 批量处理当前目录（自动多音轨）
  $0 video.mkv                # 处理单个视频 + 自动找同名音频
  $0 video.mkv audio1.mka audio2.flac ...   # 手动指定视频 + 任意多个音频
  $0 --help | -h

输出目录: ./merged_output/
支持任意文件名、多个音频轨、无损优先、自动 fallback AAC
EOF
}

[[ "$1" == "--help" || "$1" == "-h" ]] && { usage; exit 0; }

# ====================== 核心处理函数 ======================
process_video() {
    local video="$1"
    shift
    local -a provided_audios=("$@")

    # 检查是否为视频文件
    if ! ffprobe -v error -show_streams -select_streams v "$video" 2>/dev/null | grep -q "codec_type=video"; then
        echo "跳过（非视频文件）: $video"
        return
    fi

    local videoname="${video##*/}"
    local base="${videoname%.*}"
    local output="./merged_output/${base}_merged.mkv"

    # 收集音频文件
    local -a audio_list=()
    local fullbase="${video%.*}"

    if [ ${#provided_audios[@]} -gt 0 ]; then
        # CLI 手动模式
        for a in "${provided_audios[@]}"; do
            [ -f "$a" ] || continue
            [[ "$a" == "$video" ]] && continue
            if ffprobe -v error -show_streams -select_streams a "$a" 2>/dev/null | grep -q "codec_type=audio"; then
                audio_list+=("$a")
            fi
        done
    else
        # 自动查找同名音频（支持多轨）
        for candidate in "$fullbase".*; do
            [ -f "$candidate" ] || continue
            [[ "$candidate" == "$video" ]] && continue
            if ffprobe -v error -show_streams -select_streams a "$candidate" 2>/dev/null | grep -q "codec_type=audio"; then
                audio_list+=("$candidate")
            fi
        done
    fi

    if [ ${#audio_list[@]} -eq 0 ]; then
        echo "无音频候选，跳过: $video"
        return
    fi

    # 音频按字母排序，保证顺序稳定
    IFS=$'\n' audio_list=($(sort <<<"${audio_list[*]}"))
    unset IFS

    echo -e "\n>>> 正在合并:\n    视频: $video\n    音频 (${#audio_list[@]} 轨): ${audio_list[*]}"
    echo "    输出: $output"

    # 构建 ffmpeg 参数（数组方式，彻底防空格）
    local -a args=("-i" "$video")
    for a in "${audio_list[@]}"; do
        args+=("-i" "$a")
    done

    args+=("-map" "0")
    local idx=1
    for _ in "${audio_list[@]}"; do
        args+=("-map" "${idx}:a")
        ((idx++))
    done
    args+=("-shortest" "-y" "$output")

    # 5. 先尝试完全无损封装
    echo "尝试无损合并 (-c copy)..."
    if ! ffmpeg "${args[@]}" -c copy 2>/tmp/ffmpeg_err.log; then
        echo "── 无损失败，切换兼容模式 (视频原编码 + 音频转 AAC 192k)..."
        local -a fallback_args=("-i" "$video")
        for a in "${audio_list[@]}"; do
            fallback_args+=("-i" "$a")
        done
        fallback_args+=("-c:v" "copy" "-c:a" "aac" "-b:a" "192k" "-map" "0")
        local idx=1
        for _ in "${audio_list[@]}"; do
            fallback_args+=("-map" "${idx}:a")
            ((idx++))
        done
        fallback_args+=("-shortest" "-y" "$output")

        if ffmpeg "${fallback_args[@]}" 2>/dev/null; then
            echo "✅ 成功（兼容模式）: $output"
        else
            echo "❌ 失败: $video （请查看 /tmp/ffmpeg_err.log）"
        fi
    else
        echo "✅ 成功（无损）: $output"
    fi
}

# ====================== 主逻辑 ======================
if [ $# -eq 0 ]; then
    # 批量模式：当前目录所有视频
    echo "=== 进入批量模式（当前目录）==="
    for f in *; do
        [ -f "$f" ] || continue
        [[ "$f" == *"_merged"* || "$f" == "$(basename "$0")" ]] && continue
        if ffprobe -v error -show_streams -select_streams v "$f" 2>/dev/null | grep -q "codec_type=video"; then
            process_video "$f"
        fi
    done
else
    # CLI 模式：第一个参数是视频，后续是音频（可空）
    process_video "$@"
fi

echo -e "\n=== 全部处理完成！输出目录: ./merged_output/ ==="