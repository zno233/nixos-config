#!/usr/bin/env bash
# ==================== dnstest — DNS 测速（明文/DoH/DoT · 国内/海外）====================
# 明文: 纯 bash /dev/udp（无需 dig/nslookup）；DoH: curl；DoT: openssl
# 自动纳入当前网络在用 DNS（resolv.conf / resolvectl），行首以 * 标记
# 用法: dnstest [-g cn|foreign|all] [-p plain|doh|dot|all] [-i] [-r N] [-t SEC] [-s LIST] [-d LIST] [--no-color] [-h]
# 无参数且在终端中运行 → 进入交互模式
set -u
# 列宽计算依赖按字节遍历，强制 C locale 保证行为一致
export LC_ALL=C

# ====================== 默认配置 ======================
ROUNDS=3
TIMEOUT=2
GROUP=cn
PROTO=plain
INTERACTIVE=0
EXTRA_SERVERS=""
CUSTOM_DOMAINS=""
COLOR=1

# 测试域名：全部为国内可正常解析的站点（避免被墙域名导致全员超时）
DOMAINS=(baidu.com www.taobao.com bilibili.com www.qq.com www.jd.com www.zhihu.com)

# 国内明文公共 DNS："IP|名称"
CURATED_CN=(
  "223.5.5.5|阿里AliDNS"
  "223.6.6.6|阿里备用"
  "119.29.29.29|腾讯DNSPod"
  "182.254.116.116|腾讯备用"
  "114.114.114.114|114DNS"
  "114.114.115.115|114备用"
  "180.76.76.76|百度"
  "101.226.4.6|360安全"
  "1.2.4.8|CNNIC"
  "210.2.4.8|CNNIC备用"
)
# 海外明文公共 DNS
CURATED_FOREIGN=(
  "1.1.1.1|Cloudflare"
  "8.8.8.8|Google"
  "9.9.9.9|Quad9"
  "208.67.222.222|OpenDNS"
)
# 国内 DoH："URL|名称"
DOH_CN=(
  "https://dns.alidns.com/dns-query|阿里AliDNS"
  "https://223.5.5.5/dns-query|阿里IP"
  "https://223.6.6.6/dns-query|阿里备用"
  "https://doh.pub/dns-query|腾讯DNSPod"
  "https://1.12.12.12/dns-query|腾讯IP"
  "https://doh.360.cn/dns-query|360安全"
)
# 海外 DoH
DOH_FOREIGN=(
  "https://dns.cloudflare.com/dns-query|Cloudflare"
  "https://1.1.1.1/dns-query|CloudflareIP"
  "https://dns.google/dns-query|Google"
  "https://8.8.8.8/dns-query|GoogleIP"
  "https://dns.quad9.net/dns-query|Quad9"
)
# 国内 DoT（853 端口）："connect地址:853|SNI|名称"（优先 IP+SNI，不依赖系统解析）
DOT_CN=(
  "223.5.5.5:853|dns.alidns.com|阿里AliDNS"
  "223.6.6.6:853|dns.alidns.com|阿里备用"
  "1.12.12.12:853|dot.pub|腾讯DNSPod"
  "120.53.53.53:853|dot.pub|腾讯备用"
  "dot.360.cn:853|dot.360.cn|360安全"
)
# 海外 DoT
DOT_FOREIGN=(
  "8.8.8.8:853|dns.google|Google"
  "8.8.4.4:853|dns.google|Google备用"
  "1.1.1.1:853|cloudflare-dns.com|Cloudflare"
  "1.0.0.1:853|cloudflare-dns.com|Cloudflare备用"
  "9.9.9.9:853|dns.quad9.net|Quad9"
)

usage() {
  cat <<'EOF'
用法: dnstest [选项]
       dnstest              无参数且在终端中 → 进入交互模式

选项:
  -g, --group cn|foreign|all  服务器分组: 国内 / 海外 / 全部（默认 cn）
  -p, --proto plain|doh|dot|all  测试协议: 明文 / DoH / DoT / 全部（默认 plain）
  -i, --interactive        进入交互模式（也可用管道喂入选择）
  -r, --rounds N           每个域名测试轮数（默认 3）
  -t, --timeout SEC        单次查询超时秒数（默认 2）
  -a, --all                等价于 -g all（国内外一并测试）
  -s, --servers LIST       追加服务器，逗号分隔: IP=明文 ｜ https://…=DoH ｜ host[:port][|SNI]=DoT
  -d, --domains LIST       自定义测试域名，逗号分隔（默认国内常用站点）
      --no-color           关闭彩色输出
  -h, --help               显示本帮助

说明:
  明文 DNS：纯 bash /dev/udp 实现，仅依赖 coreutils；自动对比当前网络在用 DNS（* 标记）。
  DoH：依赖 curl，延迟含 DNS/TCP/TLS/HTTP 开销（每次查询独立建连）。
  DoT：依赖 openssl（853 端口），延迟含 TCP+TLS 握手（每次查询独立建连）。

示例:
  dnstest                      # 交互模式
  dnstest -g all -p all        # 国内外 × 全部协议
  dnstest -p doh -r 5          # 只测 DoH，5 轮
  dnstest -g foreign -t 3      # 只测海外明文 DNS
  dnstest -p all -s 1.2.3.4,https://dns.alidns.com/dns-query
  dnstest -p dot -s '1.2.3.4:853|dns.alidns.com'   # 自定义 DoT 服务器
EOF
}

# ====================== 交互模式 ======================
ask() { # $1=提示 $2=默认 $3=合法正则 → REPLY
  local a
  while :; do
    printf '%s' "$1"
    read -r a || a=""
    a=${a:-$2}
    if [[ $a =~ $3 ]]; then
      REPLY=$a
      return 0
    fi
    printf '  无效输入: %s\n' "$a"
  done
}

run_interactive() {
  local d
  echo "—— dnstest 交互模式（回车 = 采用默认值）——"
  case $GROUP in
    cn) d=1 ;;
    foreign) d=2 ;;
    all) d=3 ;;
    *) d=1 ;;
  esac
  ask "服务器分组: 1) 国内  2) 海外  3) 全部  [$d]: " "$d" '^[123]$'
  case $REPLY in
    1) GROUP=cn ;;
    2) GROUP=foreign ;;
    3) GROUP=all ;;
  esac
  case $PROTO in
    plain) d=1 ;;
    doh) d=2 ;;
    dot) d=3 ;;
    all) d=4 ;;
    *) d=1 ;;
  esac
  ask "测试协议  : 1) 普通DNS  2) DoH  3) DoT  4) 全部  [$d]: " "$d" '^[1234]$'
  case $REPLY in
    1) PROTO=plain ;;
    2) PROTO=doh ;;
    3) PROTO=dot ;;
    4) PROTO=all ;;
  esac
  ask "测试轮数  : [$ROUNDS]: " "$ROUNDS" '^[1-9][0-9]*$'
  ROUNDS=$REPLY
  echo ""
}

# ====================== 参数解析 ======================
NOARGS=0
[[ $# -eq 0 ]] && NOARGS=1

while [[ $# -gt 0 ]]; do
  case $1 in
    -g | --group)
      GROUP=${2:?}
      shift 2
      ;;
    -p | --proto | --protocol)
      PROTO=${2:?}
      shift 2
      ;;
    -i | --interactive)
      INTERACTIVE=1
      shift
      ;;
    -r | --rounds)
      ROUNDS=${2:?}
      shift 2
      ;;
    -t | --timeout)
      TIMEOUT=${2:?}
      shift 2
      ;;
    -a | --all)
      GROUP=all
      shift
      ;;
    -s | --servers)
      EXTRA_SERVERS=${2:?}
      shift 2
      ;;
    -d | --domains)
      CUSTOM_DOMAINS=${2:?}
      shift 2
      ;;
    --no-color)
      COLOR=0
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "未知选项: $1（-h 查看帮助）" >&2
      exit 1
      ;;
  esac
done

if [[ $NOARGS -eq 1 && -t 0 ]]; then
  INTERACTIVE=1
fi
if [[ $INTERACTIVE -eq 1 ]]; then
  run_interactive
fi

[[ $GROUP == cn || $GROUP == foreign || $GROUP == all ]] ||
  { echo "无效分组: $GROUP（cn|foreign|all）" >&2; exit 1; }
[[ $PROTO == plain || $PROTO == doh || $PROTO == dot || $PROTO == all ]] ||
  { echo "无效协议: $PROTO（plain|doh|dot|all）" >&2; exit 1; }
[[ $ROUNDS =~ ^[1-9][0-9]*$ ]] || { echo "轮数须为正整数: $ROUNDS" >&2; exit 1; }
[[ $TIMEOUT =~ ^[1-9][0-9]*$ ]] || { echo "超时须为正整数: $TIMEOUT" >&2; exit 1; }
[[ -n ${EPOCHREALTIME+x} ]] || { echo "需要 bash 5+（EPOCHREALTIME）" >&2; exit 1; }

# ====================== 工具函数 ======================

is_ip() {
  [[ $1 =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]] && return 0
  [[ $1 == *:* && $1 =~ ^[0-9a-fA-F:]+$ ]] && return 0
  return 1
}

# 显示宽度（逐字节解码 UTF-8，CJK 计 2 列），结果存入 REPLY
disp_w() {
  local s=$1 i=0 n w=0 b b2 b3 cp
  n=${#s}
  while ((i < n)); do
    printf -v b '%d' "'${s:i:1}"
    ((b < 0)) && b=$((b + 256))
    if ((b < 0x80)); then
      cp=$b
      i=$((i + 1))
    elif ((b < 0xe0)); then
      cp=$(( (b & 0x1f) << 6 ))
      if ((i + 1 < n)); then
        printf -v b2 '%d' "'${s:i + 1:1}"
        ((b2 < 0)) && b2=$((b2 + 256))
        cp=$((cp | (b2 & 0x3f)))
      fi
      i=$((i + 2))
    elif ((b < 0xf0)); then
      cp=$(( (b & 0x0f) << 12 ))
      if ((i + 2 < n)); then
        printf -v b2 '%d' "'${s:i + 1:1}"
        printf -v b3 '%d' "'${s:i + 2:1}"
        ((b2 < 0)) && b2=$((b2 + 256))
        ((b3 < 0)) && b3=$((b3 + 256))
        cp=$((cp | ((b2 & 0x3f) << 6) | (b3 & 0x3f)))
      fi
      i=$((i + 3))
    else
      # 4 字节（emoji 等），按 2 列宽
      w=$((w + 2))
      i=$((i + 4))
      continue
    fi
    if (( (cp >= 0x1100 && cp <= 0x115f) ||
      (cp >= 0x2e80 && cp <= 0xa4cf) ||
      (cp >= 0xac00 && cp <= 0xd7a3) ||
      (cp >= 0xf900 && cp <= 0xfaff) ||
      (cp >= 0xfe30 && cp <= 0xfe6f) ||
      (cp >= 0xff00 && cp <= 0xff60) ||
      (cp >= 0xffe0 && cp <= 0xffe6) )); then
      w=$((w + 2))
    else
      w=$((w + 1))
    fi
  done
  REPLY=$w
}

# 右填充到宽度 $1，结果存入 REPLY
pad_str() {
  local w=$1 t=$2 i dw
  disp_w "$t"
  dw=$REPLY
  REPLY=$t
  for ((i = dw; i < w; i++)); do REPLY+=" "; done
}

# 颜色包裹：$1=文本 $2=颜色码(g/y/r/d)
colorize() {
  local t=$1 c=${2:-}
  if [[ $COLOR -eq 1 && -t 1 && -n $c ]]; then
    case $c in
      g) printf '\033[32m%s\033[0m' "$t" ;;
      y) printf '\033[33m%s\033[0m' "$t" ;;
      r) printf '\033[31m%s\033[0m' "$t" ;;
      d) printf '\033[90m%s\033[0m' "$t" ;;
      *) printf '%s' "$t" ;;
    esac
  else
    printf '%s' "$t"
  fi
}

now_us() { printf '%s' "${EPOCHREALTIME//./}"; }

RF=$(mktemp) || exit 1
QF=$(mktemp) || exit 1
EF=$(mktemp) || exit 1 # openssl stderr（DoT 失败诊断）
TF=$(mktemp) || exit 1 # measure 结果回传（避免 $() 子 shell 丢弃动态作用域变量）
trap 'rm -f "$RF" "$QF" "$EF" "$TF"' EXIT

# 浮点秒（curl -w 输出，如 0.012345）→ 微秒，结果存 REPLY
s2us() {
  local v=$1 i f
  if [[ $v =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    i=${v%%.*}
    if [[ $v == *.* ]]; then f=${v#*.}; else f=0; fi
    f=${f}000000
    REPLY=$((10#$i * 1000000 + 10#${f:0:6}))
  else
    REPLY=0
  fi
}

# ====================== DNS 查询构造与校验 ======================
QFMT="" TXHI="" TXLO=""

# $1=域名 → 构造查询包到 QFMT，事务 ID 存 TXHI/TXLO
build_query() {
  local dom=$1 fmt="" esc hi lo label id
  [[ $dom =~ ^[A-Za-z0-9.-]+$ ]] || return 1

  id=$((RANDOM & 0xFFFF))
  hi=$((id >> 8))
  lo=$((id & 255))

  # 组装 DNS 查询包（文本形式的 \x 转义，最后由 printf 展开为二进制）
  printf -v esc '\\x%02x' "$hi"
  fmt=$esc
  printf -v esc '\\x%02x' "$lo"
  fmt+=$esc
  # 标准查询头: flags=0x0100, qd/an/ns/ar=1/0/0/0
  fmt+="\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00"
  local -a parts
  IFS=. read -ra parts <<<"$dom"
  for label in "${parts[@]}"; do
    [[ -n $label ]] || return 1
    printf -v esc '\\x%02x' "${#label}"
    fmt+=$esc
    fmt+=$label
  done
  fmt+="\x00\x00\x01\x00\x01" # qtype=A qclass=IN

  QFMT=$fmt
  TXHI=$hi
  TXLO=$lo
}

# 校验 $RF 中的响应: 事务 ID 匹配 + QR 置位（容忍不完整文件）
check_resp() {
  local b1 b2 fl _
  [[ -s $RF ]] || return 1
  read -r b1 b2 fl _ < <(od -An -tu1 -N4 -v "$RF" 2>/dev/null) || return 1
  fl=${fl:-0}
  [[ ${b1:-} == "$TXHI" && ${b2:-} == "$TXLO" ]] || return 1
  ((fl & 128))
}

# ====================== 三种协议的测量 ======================

# 明文: $1=服务器IP $2=域名 → stdout: 耗时(微秒)，失败返回非 0；原因存 FAILREASON
measure_plain() {
  local ip=$1 t0 t1 rc
  FAILREASON=""
  build_query "$2" || { FAILREASON="域名无效"; return 1; }

  { exec 3<>"/dev/udp/$ip/53"; } 2>/dev/null || { FAILREASON="无法建连"; return 1; }

  t0=$(now_us)
  { printf "$QFMT" >&3; } 2>/dev/null || {
    exec 3>&-
    FAILREASON="发送失败"
    return 1
  }
  timeout "$TIMEOUT" dd bs=4096 count=1 of="$RF" <&3 2>/dev/null
  rc=$?
  exec 3>&-
  if [[ $rc -ne 0 ]]; then
    FAILREASON="超时"
    return 1
  fi
  t1=$(now_us)

  check_resp || { FAILREASON="响应不匹配"; return 1; }
  printf '%s' "$((t1 - t0))"
}

# DoH: $1=完整URL(https://…) $2=域名 → RFC8484 GET（base64url 的 dns= 参数）
# 成功时经 curl -w 解析分阶段耗时存 D_NL/D_CN/D_AC/D_ST（微秒，供 run_section 累计）
measure_doh() {
  local url=$1 b64 t0 t1 sep='?' rc=0 stats nl cn ac st code
  D_NL=0 D_CN=0 D_AC=0 D_ST=0
  FAILREASON=""
  build_query "$2" || { FAILREASON="域名无效"; return 1; }
  # base64 → 去换行/填充 → URL-safe 字符集
  b64=$(printf "$QFMT" | base64 | tr -d '=\n' | tr '+/' '-_')
  [[ -n $b64 ]] || { FAILREASON="编码失败"; return 1; }
  [[ $url == *\?* ]] && sep='&'

  t0=$(now_us)
  stats=$(curl -sS --max-time "$TIMEOUT" -H 'accept: application/dns-message' \
    -o "$RF" -w '%{time_namelookup} %{time_connect} %{time_appconnect} %{time_starttransfer} %{http_code}' \
    "${url}${sep}dns=${b64}" 2>/dev/null) || rc=$?
  t1=$(now_us)

  if [[ $rc -ne 0 ]]; then
    case $rc in
      6) FAILREASON="域名解析失败" ;;
      7) FAILREASON="连接失败" ;;
      22) FAILREASON="HTTP错误" ;;
      28) FAILREASON="超时" ;;
      35) FAILREASON="TLS握手失败" ;;
      51) FAILREASON="证书校验失败" ;;
      56) FAILREASON="接收中断" ;;
      60) FAILREASON="证书不受信" ;;
      *) FAILREASON="curl错误$rc" ;;
    esac
    return 1
  fi

  read -r nl cn ac st code <<<"$stats"
  if [[ -n ${code:-} && $code != 200 ]]; then
    FAILREASON="HTTP ${code}"
    return 1
  fi

  check_resp || { FAILREASON="响应不匹配"; return 1; }

  if [[ -n ${st:-} && $st =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    s2us "${nl:-0}"; D_NL=$REPLY
    s2us "${cn:-0}"; D_CN=$REPLY
    s2us "${ac:-0}"; D_AC=$REPLY
    s2us "$st"; D_ST=$REPLY
  fi
  printf '%s' "$((t1 - t0))"
}

# DoT: $1=connect地址(host:port) $2=SNI主机名 $3=域名
# openssl 后台建连发送查询，轮询 RF 直到拿到合法响应；无论成败都清理子进程；原因存 FAILREASON
measure_dot() {
  local conn=$1 sni=$2 t0 t1 pid kids k deadline why emsg erc
  FAILREASON=""
  build_query "$3" || { FAILREASON="域名无效"; return 1; }
  { printf "$QFMT" > "$QF"; } 2>/dev/null || return 1
  : > "$RF" 2>/dev/null || return 1
  : > "$EF" 2>/dev/null || true

  t0=$(now_us)
  deadline=$((TIMEOUT * 1000000))
  timeout "$TIMEOUT" openssl s_client -connect "$conn" -servername "$sni" \
    -quiet -ign_eof <"$QF" >"$RF" 2>"$EF" &
  pid=$!

  t1=0 why=""
  while :; do
    if check_resp; then
      t1=$(now_us)
      break
    fi
    # 超时优先于进程退出判定（timeout 尚未杀进程时也归为超时）
    if (($(now_us) - t0 >= deadline)); then
      why=timeout
      break
    fi
    # 进程已退出且无有效响应 → 快速失败（连接被拒/握手失败）
    if ! kill -0 "$pid" 2>/dev/null; then
      why=exit
      break
    fi
    sleep 0.01
  done

  # 清理：先杀 openssl 子进程，再杀 timeout，最后回收
  kids=""
  if [[ -r /proc/$pid/task/$pid/children ]]; then
    read -r kids < "/proc/$pid/task/$pid/children" || kids=""
  elif command -v pkill >/dev/null 2>&1; then
    pkill -P "$pid" 2>/dev/null || true
  fi
  for k in $kids; do
    kill "$k" 2>/dev/null || true
  done
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null
  erc=$?

  ((t1 > 0)) || {
    if [[ -s $RF ]]; then
      FAILREASON="响应不匹配"
    elif [[ $why == timeout || $erc -eq 124 ]]; then
      FAILREASON="超时"
    else
      emsg=$(tr -d '\r' <"$EF" 2>/dev/null | grep -iE 'errno=|refused|handshake|alert|unreachable|no route|name or service|reset|EOF' | tail -1)
      if [[ $emsg =~ errno=([0-9]+) ]]; then
        case "${BASH_REMATCH[1]}" in
          0) FAILREASON="无响应" ;;
          101 | 113) FAILREASON="网络不可达" ;;
          104) FAILREASON="连接被重置" ;;
          110) FAILREASON="超时" ;;
          111) FAILREASON="连接被拒" ;;
          *) FAILREASON="连接失败" ;;
        esac
      elif [[ $emsg == *[Hh]andshake* || $emsg == *alert* ]]; then
        FAILREASON="握手失败"
      elif [[ $emsg == *[Rr]efused* ]]; then
        FAILREASON="连接被拒"
      elif [[ $emsg == *nreachable* || $emsg == *"no route"* ]]; then
        FAILREASON="网络不可达"
      elif [[ $emsg == *"name or service"* ]]; then
        FAILREASON="域名解析失败"
      elif [[ $emsg == *EOF* || $erc -eq 0 ]]; then
        FAILREASON="无响应"
      else
        FAILREASON="连接失败"
      fi
    fi
    return 1
  }
  printf '%s' "$((t1 - t0))"
}

# 分发: $1=协议 $2=服务器序号 $3=域名（S_KEY/S_SNI 由 run_section 提供）
measure_at() {
  case $1 in
    plain) measure_plain "${S_KEY[$2]}" "$3" ;;
    doh) measure_doh "${S_KEY[$2]}" "$3" ;;
    dot) measure_dot "${S_KEY[$2]}" "${S_SNI[$2]}" "$3" ;;
    *) return 1 ;;
  esac
}

# ====================== 发现当前网络 DNS ======================
SYS=()
detect_system_dns() {
  local tok
  if [[ -r /etc/resolv.conf ]]; then
    while read -r _ tok; do
      [[ -n ${tok:-} ]] && is_ip "$tok" && SYS+=("$tok")
    done < <(grep -E '^nameserver[[:space:]]+' /etc/resolv.conf)
  fi
  if command -v resolvectl >/dev/null 2>&1; then
    while read -r tok; do
      [[ -n ${tok:-} ]] && is_ip "$tok" && SYS+=("$tok")
    done < <(resolvectl dns 2>/dev/null | tr -s ' \t' '\n')
  fi
}

# ====================== 汇总辅助 ======================
# 平均值（1/10 ms 精度）: sum_µs / (count*100) = 0.1ms 为单位
fmt_avg() {
  if [[ ${2:-0} -eq 0 ]]; then
    REPLY="-"
    return
  fi
  local a=$(($1 / ($2 * 100)))
  REPLY="$((a / 10)).$((a % 10))ms"
}

avg10_of() {
  if [[ ${2:-0} -eq 0 ]]; then
    REPLY=-1
    return
  fi
  REPLY=$(($1 / ($2 * 100)))
}

# ====================== 组装某一协议的服务器列表 ======================
# 由 run_section 调用，向调用方的 S_KEY/S_ADDR/S_NAME/S_SNI/S_INUSE 追加
add_server() { # $1=去重键 $2=测量键 $3=显示地址 $4=名称 $5=SNI
  local u=$1 k=$2 a=$3 n=$4 s=${5:-}
  [[ -n ${SEEN[$u]:-} ]] && return 0
  SEEN[$u]=1
  S_KEY+=("$k")
  S_ADDR+=("$a")
  S_NAME+=("$n")
  S_SNI+=("$s")
  S_INUSE+=(0)
}

build_section() { # $1=协议
  local proto=$1 e ip it url host conn sni name rest
  local -a LIST=() xs=()
  case $proto in
    plain)
      # 1) 当前网络在用的 DNS 优先
      for ip in ${SYS[@]+"${SYS[@]}"}; do
        if [[ $ip == 127.* ]]; then add_server "$ip" "$ip" "$ip" "本机stub" ""
        else add_server "$ip" "$ip" "$ip" "当前网络" ""
        fi
      done
      # 2) 公共 DNS（按分组）
      case $GROUP in
        cn) LIST=("${CURATED_CN[@]}") ;;
        foreign) LIST=("${CURATED_FOREIGN[@]}") ;;
        all) LIST=("${CURATED_CN[@]}" "${CURATED_FOREIGN[@]}") ;;
      esac
      for e in "${LIST[@]}"; do
        add_server "${e%%|*}" "${e%%|*}" "${e%%|*}" "${e#*|}" ""
      done
      # 3) 自定义追加（IP）
      if [[ -n $EXTRA_SERVERS ]]; then
        IFS=, read -ra xs <<<"$EXTRA_SERVERS"
        for it in "${xs[@]}"; do
          [[ -n $it ]] || continue
          is_ip "$it" && add_server "$it" "$it" "$it" "自定义" ""
        done
      fi
      # 4) 标记当前网络在用
      local ssi
      for ip in ${SYS[@]+"${SYS[@]}"}; do
        for ((ssi = 0; ssi < ${#S_KEY[@]}; ssi++)); do
          [[ ${S_KEY[ssi]} == "$ip" ]] && S_INUSE[ssi]=1
        done
      done
      ;;
    doh)
      case $GROUP in
        cn) LIST=("${DOH_CN[@]}") ;;
        foreign) LIST=("${DOH_FOREIGN[@]}") ;;
        all) LIST=("${DOH_CN[@]}" "${DOH_FOREIGN[@]}") ;;
      esac
      for e in "${LIST[@]}"; do
        url=${e%%|*}
        name=${e#*|}
        host=${url#*://}
        host=${host%%/*}
        add_server "$url" "$url" "$host" "$name" ""
      done
      if [[ -n $EXTRA_SERVERS ]]; then
        IFS=, read -ra xs <<<"$EXTRA_SERVERS"
        for it in "${xs[@]}"; do
          [[ -n $it ]] || continue
          if [[ $it == http* ]]; then
            host=${it#*://}
            host=${host%%/*}
            add_server "$it" "$it" "$host" "自定义" ""
          fi
        done
      fi
      ;;
    dot)
      case $GROUP in
        cn) LIST=("${DOT_CN[@]}") ;;
        foreign) LIST=("${DOT_FOREIGN[@]}") ;;
        all) LIST=("${DOT_CN[@]}" "${DOT_FOREIGN[@]}") ;;
      esac
      for e in "${LIST[@]}"; do
        conn=${e%%|*}
        rest=${e#*|}
        sni=${rest%%|*}
        name=${rest#*|}
        add_server "$conn|$sni" "$conn" "${conn%:*}" "$name" "$sni"
      done
      # 自定义追加: host[:port][|SNI]（缺端口默认 853）
      if [[ -n $EXTRA_SERVERS ]]; then
        IFS=, read -ra xs <<<"$EXTRA_SERVERS"
        for it in "${xs[@]}"; do
          [[ -n $it ]] || continue
          [[ $it == http* ]] && continue
          is_ip "$it" && continue
          [[ $it == *'|'* || $it =~ ^[A-Za-z0-9._-]+:[0-9]+$ ]] || continue
          conn=${it%%|*}
          if [[ $it == *'|'* ]]; then
            sni=${it#*|}
          else
            sni=${conn%%:*}
          fi
          [[ $conn == *:* ]] || conn="$conn:853"
          sni=${sni:-${conn%%:*}}
          add_server "$conn|$sni" "$conn" "${conn%:*}" "自定义" "$sni"
        done
      fi
      ;;
  esac
}

# ====================== 单个协议的完整测试流程 ======================
run_section() { # $1=协议；成功输出表格返回 0，无可用服务器返回 1
  local proto=$1
  local -a S_KEY=() S_ADDR=() S_NAME=() S_SNI=() S_INUSE=() S_REASON=()
  local -A SEEN=()
  # measure_* 经动态作用域回写：失败原因 + DoH 分阶段耗时（微秒）
  local FAILREASON="" D_NL=0 D_CN=0 D_AC=0 D_ST=0
  local D_CNT=0 SUM_NL=0 SUM_CN=0 SUM_AC=0 SUM_ST=0
  local dead="" b1 b2 b3 b4 sum2 si

  build_section "$proto"

  local NS=${#S_KEY[@]}
  if [[ $NS -eq 0 ]]; then
    echo "[$proto] 没有可测服务器，跳过" >&2
    return 1
  fi

  # ---------- 预检：剔除不通的服务器 ----------
  local tries=2
  [[ $proto != plain ]] && tries=1
  local -a S_ALIVE=()
  local alive_cnt=0 ok _try
  if [[ -t 2 ]]; then printf '\r预检[%s] %d 个服务器...' "$proto" "$NS" >&2; fi
  for ((si = 0; si < NS; si++)); do
    ok=0
    for ((_try = 0; _try < tries; _try++)); do
      if measure_at "$proto" "$si" "${DOMS[0]}" >/dev/null; then
        ok=1
        break
      fi
    done
    S_ALIVE[si]=$ok
    S_REASON[si]=$FAILREASON
    alive_cnt=$((alive_cnt + ok))
    if [[ -t 2 ]]; then
      printf '\r预检[%s] %d 个服务器... 已检 %d, 可用 %d  ' "$proto" "$NS" "$((si + 1))" "$alive_cnt" >&2
    fi
  done
  if [[ -t 2 ]]; then printf '\r\033[K' >&2; fi

  if [[ $alive_cnt -eq 0 ]]; then
    echo "[$proto] 无可用服务器，原因:" >&2
    for ((si = 0; si < NS; si++)); do
      echo "  - ${S_NAME[si]} ${S_ADDR[si]}: ${S_REASON[si]:-不通}" >&2
    done
    echo "[$proto] 无可用服务器，跳过" >&2
    return 1
  fi

  # ---------- 正式测试（轮→域名→服务器，交错保证公平） ----------
  local -a cell_us=() cell_cnt=() s_us=() s_cnt=() s_try=()
  local total=$((alive_cnt * ND * ROUNDS)) n=0 r di key ms
  for ((r = 0; r < ROUNDS; r++)); do
    for ((di = 0; di < ND; di++)); do
      for ((si = 0; si < NS; si++)); do
        if [[ ${S_ALIVE[si]} -ne 1 ]]; then
          n=$((n + 1))
          continue
        fi
        n=$((n + 1))
        if [[ -t 2 ]]; then
          printf '\r测试 %d/%d  %s          ' "$n" "$total" "${S_NAME[si]}" >&2
        fi
        key=$((si * ND + di))
        # 不用 $()：子 shell 会丢弃 measure_* 经动态作用域回写的 D_*，改走临时文件
        if measure_at "$proto" "$si" "${DOMS[di]}" >"$TF"; then
          ms=$(<"$TF")
          cell_us[key]=$((${cell_us[key]:-0} + ms))
          cell_cnt[key]=$((${cell_cnt[key]:-0} + 1))
          s_us[si]=$((${s_us[si]:-0} + ms))
          s_cnt[si]=$((${s_cnt[si]:-0} + 1))
          if [[ $proto == doh && $D_ST -gt 0 ]]; then
            SUM_NL=$((SUM_NL + D_NL))
            SUM_CN=$((SUM_CN + D_CN))
            SUM_AC=$((SUM_AC + D_AC))
            SUM_ST=$((SUM_ST + D_ST))
            D_CNT=$((D_CNT + 1))
          fi
        fi
        s_try[si]=$((${s_try[si]:-0} + 1))
      done
    done
  done
  if [[ -t 2 ]]; then printf '\r\033[K' >&2; fi

  # ---------- 汇总 ----------
  local -a cell_s=() avg_s=() ok_s=() keys=()
  local best_si=-1 best_key=9999999999 a10
  for ((si = 0; si < NS; si++)); do
    if [[ ${S_ALIVE[si]} -eq 1 ]]; then
      avg10_of "${s_us[si]:-0}" "${s_cnt[si]:-0}"
      a10=$REPLY
      if [[ $a10 -lt 0 ]]; then
        keys[si]=9999999999
        avg_s[si]="-"
      else
        keys[si]=$a10
        fmt_avg "${s_us[si]:-0}" "${s_cnt[si]:-0}"
        avg_s[si]=$REPLY
        if [[ $a10 -lt $best_key ]]; then
          best_key=$a10
          best_si=$si
        fi
      fi
      if [[ ${s_try[si]:-0} -gt 0 ]]; then
        ok_s[si]="$(( ${s_cnt[si]:-0} * 100 / s_try[si] ))%"
      else
        ok_s[si]="0%"
      fi
    else
      keys[si]=9999999999
      avg_s[si]="-"
      ok_s[si]="-"
    fi
    for ((di = 0; di < ND; di++)); do
      key=$((si * ND + di))
      if [[ ${S_ALIVE[si]} -eq 1 ]]; then
        fmt_avg "${cell_us[key]:-0}" "${cell_cnt[key]:-0}"
        cell_s[key]=$REPLY
      else
        cell_s[key]="-"
      fi
    done
  done

  # 短域名做表头
  local -a heads=()
  for ((di = 0; di < ND; di++)); do heads[di]=${DOMS[di]#www.}; done

  # 列宽: [0]=服务器 [1..ND]=域名 [ND+1]=平均 [ND+2]=成功率
  local -a w=()
  w[0]=0
  local lbl
  for ((si = 0; si < NS; si++)); do
    lbl=""
    [[ ${S_INUSE[si]} -eq 1 ]] && lbl="*"
    lbl+="${S_NAME[si]} ${S_ADDR[si]}"
    disp_w "$lbl"
    ((REPLY > w[0])) && w[0]=$REPLY
  done
  disp_w "服务器"
  ((REPLY > w[0])) && w[0]=$REPLY
  for ((di = 0; di < ND; di++)); do
    disp_w "${heads[di]}"
    w[di + 1]=$REPLY
    for ((si = 0; si < NS; si++)); do
      disp_w "${cell_s[si * ND + di]}"
      ((REPLY > w[di + 1])) && w[di + 1]=$REPLY
    done
  done
  disp_w "平均"
  w[ND + 1]=$REPLY
  for ((si = 0; si < NS; si++)); do
    disp_w "${avg_s[si]}"
    ((REPLY > w[ND + 1])) && w[ND + 1]=$REPLY
  done
  disp_w "成功率"
  w[ND + 2]=$REPLY
  for ((si = 0; si < NS; si++)); do
    disp_w "${ok_s[si]}"
    ((REPLY > w[ND + 2])) && w[ND + 2]=$REPLY
  done

  # ---------- 输出 ----------
  local title note
  case $proto in
    plain)
      title="普通DNS · UDP/53"
      note="注: * = 当前网络正在使用 ｜ 平均 = 多轮平均（越小越好）｜ 成功率 = 成功/总尝试"
      ;;
    doh)
      title="DoH · HTTPS"
      note="注: 延迟含 DNS/TCP/TLS/HTTP 开销（每次查询独立建连）｜ 分解 = 各阶段平均 ｜ 成功率 = 成功/总尝试"
      ;;
    dot)
      title="DoT · TLS/853"
      note="注: 延迟含 TCP+TLS 握手（每次查询独立建连）｜ 成功率 = 成功/总尝试"
      ;;
  esac
  printf '%s\n' "$(colorize "── $title ──" d)"
  echo "规模: $alive_cnt/$NS 个服务器 × $ND 域名 × $ROUNDS 轮 = $((alive_cnt * ND * ROUNDS)) 次查询"

  # 表头
  local out="" totw c okv
  pad_str "${w[0]}" "服务器"
  out+="$REPLY"
  for ((di = 0; di < ND; di++)); do
    pad_str "${w[di + 1]}" "${heads[di]}"
    out+=" $REPLY"
  done
  pad_str "${w[ND + 1]}" "平均"
  out+=" $REPLY"
  pad_str "${w[ND + 2]}" "成功率"
  out+=" $REPLY"
  printf '%s\n' "$out"

  # 分隔线
  totw=${w[0]}
  for ((di = 0; di <= ND + 2; di++)); do totw=$((totw + 1 + w[di])); done
  printf '%*s\n' "$totw" '' | tr ' ' '-'

  # 数据行（按平均延迟升序）
  local order=""
  for ((si = 0; si < NS; si++)); do
    order+="${keys[si]} $si"$'\n'
  done
  while read -r _k si; do
    [[ -n $si ]] || continue
    lbl=""
    [[ ${S_INUSE[si]} -eq 1 ]] && lbl="*"
    lbl+="${S_NAME[si]} ${S_ADDR[si]}"
    pad_str "${w[0]}" "$lbl"
    out="$REPLY"
    for ((di = 0; di < ND; di++)); do
      pad_str "${w[di + 1]}" "${cell_s[si * ND + di]}"
      out+=" $REPLY"
    done
    # 平均列着色
    if [[ ${avg_s[si]} == "-" ]]; then
      c=d
    elif [[ ${keys[si]} -lt 300 ]]; then
      c=g
    elif [[ ${keys[si]} -lt 600 ]]; then
      c=y
    else
      c=r
    fi
    pad_str "${w[ND + 1]}" "${avg_s[si]}"
    out+=" $(colorize "$REPLY" "$c")"
    # 成功率列着色
    if [[ ${ok_s[si]} == "-" ]]; then
      c=d
    else
      okv=${ok_s[si]%%%}
      if [[ $okv -ge 100 ]]; then c=g; elif [[ $okv -ge 90 ]]; then c=y; else c=r; fi
    fi
    pad_str "${w[ND + 2]}" "${ok_s[si]}"
    out+=" $(colorize "$REPLY" "$c")"
    printf '%s\n' "$out"
  done < <(printf '%s' "$order" | sort -n)

  echo ""
  printf '%s\n' "$(colorize "$note" d)"

  # DoH 分阶段耗时（curl -w 累计的各阶段平均）
  if [[ $proto == doh && $D_CNT -gt 0 ]]; then
    fmt_avg "$SUM_NL" "$D_CNT"; b1=$REPLY
    sum2=$((SUM_CN - SUM_NL))
    ((sum2 < 0)) && sum2=0
    fmt_avg "$sum2" "$D_CNT"; b2=$REPLY
    sum2=$((SUM_AC - SUM_CN))
    ((sum2 < 0)) && sum2=0
    fmt_avg "$sum2" "$D_CNT"; b3=$REPLY
    sum2=$((SUM_ST - SUM_AC))
    ((sum2 < 0)) && sum2=0
    fmt_avg "$sum2" "$D_CNT"; b4=$REPLY
    printf '%s\n' "$(colorize "分解(平均): 解析 $b1 · 建连 $b2 · TLS $b3 · 服务器 $b4" d)"
  fi

  # 预检不通的服务器及原因
  dead=""
  for ((si = 0; si < NS; si++)); do
    [[ ${S_ALIVE[si]} -eq 0 ]] && dead+="${dead:+, }${S_NAME[si]} ${S_ADDR[si]}[${S_REASON[si]:-不通}]"
  done
  [[ -n $dead ]] && printf '%s\n' "$(colorize "不可达: $dead" r)"

  if [[ $best_si -ge 0 ]]; then
    printf '%s\n' "$(colorize "最快: ${S_NAME[best_si]} ${S_ADDR[best_si]} (${avg_s[best_si]} 平均)" g)"
  fi
  return 0
}

# ====================== 主流程 ======================
detect_system_dns

# 测试域名（-d 覆盖默认）
if [[ -n $CUSTOM_DOMAINS ]]; then
  IFS=, read -ra cs <<<"$CUSTOM_DOMAINS"
  DOMS=()
  for d in "${cs[@]}"; do
    [[ $d =~ ^[A-Za-z0-9.-]+$ ]] && DOMS+=("$d")
  done
  [[ ${#DOMS[@]} -gt 0 ]] || { echo "无效的测试域名" >&2; exit 1; }
else
  DOMS=("${DOMAINS[@]}")
fi
ND=${#DOMS[@]}

# 协议序列 + 依赖检查（缺依赖的协议跳过）
case $PROTO in
  plain) WANTED=(plain) ;;
  doh) WANTED=(doh) ;;
  dot) WANTED=(dot) ;;
  all) WANTED=(plain doh dot) ;;
esac
AVAIL=()
for p in "${WANTED[@]}"; do
  case $p in
    doh)
      if command -v curl >/dev/null 2>&1; then AVAIL+=(doh)
      else echo "跳过 DoH：未找到 curl" >&2
      fi
      ;;
    dot)
      if command -v openssl >/dev/null 2>&1; then AVAIL+=(dot)
      else echo "跳过 DoT：未找到 openssl" >&2
      fi
      ;;
    *) AVAIL+=("$p") ;;
  esac
done
if [[ ${#AVAIL[@]} -eq 0 ]]; then
  echo "没有可测试的协议（缺少依赖）" >&2
  exit 2
fi

# -s 与本次协议不匹配时给出提示
if [[ -n $EXTRA_SERVERS ]]; then
  has_url=0
  has_ip=0
  has_dot=0
  IFS=, read -ra xs <<<"$EXTRA_SERVERS"
  for it in "${xs[@]}"; do
    [[ -n $it ]] || continue
    if [[ $it == http* ]]; then has_url=1
    elif is_ip "$it"; then has_ip=1
    elif [[ $it == *'|'* || $it =~ ^[A-Za-z0-9._-]+:[0-9]+$ ]]; then has_dot=1
    else echo "忽略无效服务器项: $it" >&2
    fi
  done
  if [[ $has_url -eq 1 ]] && ! printf '%s\n' "${AVAIL[@]}" | grep -qx doh; then
    echo "提示: -s 含 DoH URL，但本次不测 DoH（可用 -p doh/all）" >&2
  fi
  if [[ $has_ip -eq 1 ]] && ! printf '%s\n' "${AVAIL[@]}" | grep -qx plain; then
    echo "提示: -s 含 IP，但本次不测明文 DNS（可用 -p plain/all）" >&2
  fi
  if [[ $has_dot -eq 1 ]] && ! printf '%s\n' "${AVAIL[@]}" | grep -qx dot; then
    echo "提示: -s 含 DoT 地址，但本次不测 DoT（可用 -p dot/all）" >&2
  fi
fi

# 标题
echo "=== dnstest — DNS 测速 ==="
sysline=""
declare -A _dup=()
for ip in ${SYS[@]+"${SYS[@]}"}; do
  [[ -n ${_dup[$ip]:-} ]] && continue
  _dup[$ip]=1
  sysline+="${sysline:+, }$ip"
done
echo "当前网络 DNS: ${sysline:-未发现}"
case $GROUP in
  cn) glabel=国内 ;;
  foreign) glabel=海外 ;;
  all) glabel=国内+海外 ;;
esac
case $PROTO in
  plain) plabel=普通DNS ;;
  doh) plabel=DoH ;;
  dot) plabel=DoT ;;
  all) plabel=普通DNS+DoH+DoT ;;
esac
echo "配置: 分组=$glabel 协议=$plabel 轮数=$ROUNDS 超时=${TIMEOUT}s 域名数=$ND"
echo ""

ran=0
for idx in "${!AVAIL[@]}"; do
  [[ $idx -gt 0 ]] && echo ""
  if run_section "${AVAIL[idx]}"; then
    ran=$((ran + 1))
  fi
done

if [[ $ran -eq 0 ]]; then
  echo "没有任何 DNS 服务器可达（检查网络连接或依赖）" >&2
  exit 2
fi
exit 0
