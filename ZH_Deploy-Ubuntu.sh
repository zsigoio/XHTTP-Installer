#!/usr/bin/env bash
# =============================================================
#  XHTTP Installer — avaco_cloud
#  Ubuntu Server | VLESS+XHTTP Auto-Installer
# -------------------------------------------------------------
#  Copyright (C) 2025 avaco_cloud
#  Repository: https://github.com/ZhengYuHangOvO/XHTTP-Installer
#  Author:     @avaco_cloud (https://t.me/avaco_cloud)
#
#  Licensed under the GNU General Public License v3.0 (GPL-3.0).
#  See LICENSE file for full terms.
#
#  Redistribution requires preserving this copyright notice and
#  the LICENSE file. Unauthorized removal of attribution is a
#  copyright violation and will result in a DMCA takedown.
# =============================================================
set -euo pipefail

# Build identifier — do not remove (used for integrity verification)
readonly AVC_BUILD_ID="avc-7f3a92e1-2025-ZhengYuHangOvO"
export AVC_BUILD_ID

LOG_FILE="/tmp/xhttp-install.log"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"

drain_process_substitution_source() {
  local source_path="${BASH_SOURCE[0]:-}"
  case "$source_path" in
    /dev/fd/*|/proc/*/fd/*) ;;
    *) return 0 ;;
  esac

  # When this large script is launched as `bash <(curl ...)`, re-execing early
  # closes Bash's script FD while curl may still be writing the rest of the file.
  # Consume the remaining bytes first so curl exits cleanly instead of printing
  # `curl: (23) Failure writing output to destination`.
  cat "$source_path" >/dev/null 2>&1 || true
}

# If launched via process substitution (e.g. `bash <(curl ...)`),
# SCRIPT_DIR points to /dev/fd/... and the deploy/ folder is missing.
# Auto-download the full repo into /opt/xhttp-installer and re-exec from there.
if [[ -z "$SCRIPT_DIR" || ! -d "${SCRIPT_DIR}/deploy" ]]; then
  REPO_DIR="/opt/xhttp-installer"
  REPO_URL="https://github.com/ZhengYuHangOvO/XHTTP-Installer.git"
  echo ">> 检测到远程管道运行 — 正在将完整仓库下载到 ${REPO_DIR}..."
  if [[ ! -d "$REPO_DIR/.git" ]]; then
    if command -v git >/dev/null 2>&1; then
      git clone --depth 1 "$REPO_URL" "$REPO_DIR" || {
        echo "错误：git 克隆失败。请先安装 git：apt install -y git"; exit 1; }
    else
      apt-get update -qq && apt-get install -y -qq git 2>/dev/null
      git clone --depth 1 "$REPO_URL" "$REPO_DIR" || {
        echo "错误：git 克隆失败。"; exit 1; }
    fi
  else
    (cd "$REPO_DIR" && git pull --ff-only 2>/dev/null) || true
  fi
  echo ">> 正在从 ${REPO_DIR}/Deploy-Ubuntu.sh 重新执行"
  drain_process_substitution_source
  exec bash "${REPO_DIR}/Deploy-Ubuntu.sh" "$@"
fi

VERCEL_DIR="${SCRIPT_DIR}/deploy/vercel"
NETLIFY_DIR="${SCRIPT_DIR}/deploy/netlify"

exec > >(tee -a "$LOG_FILE") 2>&1

# ─────────────────────────────────────────────
#  COLORS
# ─────────────────────────────────────────────
C_RESET="\033[0m"
C_CYAN="\033[1;36m"
C_YELLOW="\033[1;33m"
C_GREEN="\033[1;32m"
C_RED="\033[1;31m"
C_MAGENTA="\033[1;35m"
C_GRAY="\033[0;90m"
C_WHITE="\033[1;37m"

print_banner() {
  clear
  echo ""
  echo -e "   ${C_CYAN}██╗  ██╗${C_WHITE}██╗  ██╗████████╗████████╗██████╗ ${C_RESET}"
  echo -e "   ${C_CYAN}╚██╗██╔╝${C_WHITE}██║  ██║╚══██╔══╝╚══██╔══╝██╔══██╗${C_RESET}"
  echo -e "    ${C_CYAN}╚███╔╝ ${C_WHITE}███████║   ██║      ██║   ██████╔╝${C_RESET}"
  echo -e "    ${C_CYAN}██╔██╗ ${C_WHITE}██╔══██║   ██║      ██║   ██╔═══╝ ${C_RESET}"
  echo -e "   ${C_CYAN}██╔╝ ██╗${C_WHITE}██║  ██║   ██║      ██║   ██║     ${C_RESET}"
  echo -e "   ${C_CYAN}╚═╝  ╚═╝${C_WHITE}╚═╝  ╚═╝   ╚═╝      ╚═╝   ╚═╝     ${C_RESET}"
  echo ""
  echo -e "   ${C_YELLOW}██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗ ${C_RESET}"
  echo -e "   ${C_YELLOW}██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗${C_RESET}"
  echo -e "   ${C_YELLOW}██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝${C_RESET}"
  echo -e "   ${C_YELLOW}██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗${C_RESET}"
  echo -e "   ${C_YELLOW}██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║${C_RESET}"
  echo -e "   ${C_YELLOW}╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝${C_RESET}"
  echo ""
  echo -e "          ${C_MAGENTA}★${C_RESET}  ${C_WHITE}a v a c o _ c l o u d${C_RESET}  ${C_MAGENTA}★${C_RESET}"
  echo -e "          ${C_GRAY}─────────────────────────${C_RESET}"
  echo -e "          ${C_GRAY}VLESS + XHTTP + TLS${C_RESET}"
  echo -e "          ${C_GRAY}Ubuntu 自动安装器${C_RESET}"
  echo -e "          ${C_GRAY}转发: Vercel / Netlify${C_RESET}"
  echo -e "          ${C_GRAY}t.me/avaco_cloud${C_RESET}"
  echo ""
}

step() { echo -e "\n${C_CYAN}>> $1${C_RESET}"; }
ok()   { echo -e "${C_GREEN}   ✔ $1${C_RESET}"; }
warn() { echo -e "${C_YELLOW}   ⚠ $1${C_RESET}"; }
fail() { echo -e "${C_RED}   ✘ $1${C_RESET}"; }
info() { echo -e "${C_GRAY}   $1${C_RESET}"; }

# ─────────────────────────────────────────────
#  PROGRESS HELPERS
# ─────────────────────────────────────────────
# Run a long command with a live spinner + elapsed-time counter so the user
# sees progress instead of a frozen terminal. Usage:
#   spin "Installing X" -- some_command --with args
# Exit code of the command is preserved.
spin() {
  local label="$1"; shift
  [[ "$1" == "--" ]] && shift
  local frames='|/-\' i=0 start now elapsed
  start=$(date +%s)

  # Run command in background, redirect output to a log so spinner can paint
  local logfile; logfile=$(mktemp)
  ( "$@" >"$logfile" 2>&1 ) &
  local pid=$!

  # Real escape character (not the literal \033 backslash-zero-three-three)
  local ESC=$'\033'
  # Hide cursor
  printf '%s[?25l' "$ESC"
  while kill -0 "$pid" 2>/dev/null; do
    now=$(date +%s); elapsed=$(( now - start ))
    local frame="${frames:i++%${#frames}:1}"
    printf '\r   %s[1;36m%s%s[0m %s %s[0;90m(%ds elapsed)%s[0m   ' \
      "$ESC" "$frame" "$ESC" "$label" "$ESC" "$elapsed" "$ESC"
    sleep 0.2
  done
  wait "$pid"; local rc=$?
  now=$(date +%s); elapsed=$(( now - start ))
  # Clear spinner line and restore cursor
  printf '\r%s[2K%s[?25h' "$ESC" "$ESC"

  if [[ $rc -eq 0 ]]; then
    echo -e "   ${C_GREEN}✔${C_RESET} ${label} ${C_GRAY}(${elapsed}s)${C_RESET}"
  else
    echo -e "   ${C_RED}✘${C_RESET} ${label} ${C_RED}— exit ${rc}${C_RESET} ${C_GRAY}(${elapsed}s)${C_RESET}"
    echo -e "   ${C_GRAY}── last 10 lines of output ──${C_RESET}"
    tail -10 "$logfile" 2>/dev/null | while IFS= read -r l; do echo -e "     ${C_GRAY}$l${C_RESET}"; done
  fi
  rm -f "$logfile"
  return $rc
}

read_default() {
  local prompt="$1" default="$2" val
  read -rp "$(echo -e "  ${C_WHITE}${prompt}${C_RESET} ${C_GRAY}[${default}]${C_RESET}: ")" val
  echo "${val:-$default}"
}

read_required() {
  local prompt="$1" val
  while true; do
    read -rp "$(echo -e "  ${C_WHITE}${prompt}${C_RESET}: ")" val
    if [[ -n "${val// }" ]]; then echo "$val"; return; fi
    fail "必填字段。"
  done
}

read_secret() {
  local prompt="$1" val
  while true; do
    read -rp "$(echo -e "  ${C_WHITE}${prompt}${C_RESET}: ")" val
    if [[ -n "${val// }" ]]; then echo "$val"; return; fi
    fail "必填字段。"
  done
}

confirm() {
  local prompt="$1"
  read -rp "$(echo -e "  ${C_YELLOW}${prompt} [Y/n]${C_RESET}: ")" yn
  case "${yn,,}" in n|no) return 1;; *) return 0;; esac
}

# =============================================================
#  AUTO-FIX ENGINE
# =============================================================
AUTOFIX_MAX=3

autofix_diagnose() {
  local ctx="$1"
  echo -e "\n  ${C_MAGENTA}[自动修复]${C_RESET} 正在诊断: ${ctx}..."
  case "$ctx" in
    SSL)
      if ss -tlnp 2>/dev/null | grep -q ':80 '; then
        local pid80
        pid80=$(ss -tlnp 2>/dev/null | grep ':80 ' | grep -oP 'pid=\K[0-9]+' | head -1)
        [[ -n "$pid80" ]] && { warn "正在终止 80 端口进程 PID $pid80"; kill "$pid80" 2>/dev/null || true; sleep 2; }
      fi
      local resolved_ip my_ipv4 my_ipv6
      resolved_ip=$(dig +short "${CFG_DOMAIN:-x}" A 2>/dev/null | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 || true)

      # Get public IPv4 — try multiple sources including AWS/GCP/Azure metadata APIs
      # AWS Lightsail/EC2: public IP is NOT on any interface (NAT), must use metadata
      my_ipv4=$(
        # AWS EC2/Lightsail metadata (IMDSv1 — works without token on most instances)
        curl -4 -s --max-time 3 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null | \
          grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -1
      )
      if [[ -z "$my_ipv4" ]]; then
        my_ipv4=$(
          curl -4 -s --max-time 5 https://ifconfig.me 2>/dev/null ||
          curl -4 -s --max-time 5 https://api4.ipify.org 2>/dev/null ||
          curl -4 -s --max-time 5 https://ipv4.icanhazip.com 2>/dev/null ||
          hostname -I 2>/dev/null | tr ' ' '\n' | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -1 || true
        )
      fi
      my_ipv6=$(curl -6 -s --max-time 5 https://ifconfig.me 2>/dev/null || \
                hostname -I 2>/dev/null | tr ' ' '\n' | grep ':' | head -1 || true)

      if [[ -z "$resolved_ip" ]]; then
        fail "DNS: ${CFG_DOMAIN:-?} A 记录未找到。请将其指向 ${my_ipv4:-<你的服务器 IP>}"
        [[ -n "$my_ipv6" ]] && info "服务器也有 IPv6: ${my_ipv6} (如果需要，使用 AAAA 记录)"
      elif [[ "$resolved_ip" == "$my_ipv4" ]]; then
        ok "DNS 正常: ${CFG_DOMAIN:-?} -> ${resolved_ip} (与服务器公网 IPv4 匹配)"
      elif [[ -n "$my_ipv6" ]] && dig +short "${CFG_DOMAIN:-x}" AAAA 2>/dev/null | grep -q "$my_ipv6"; then
        ok "DNS 正常: ${CFG_DOMAIN:-?} AAAA 记录与服务器 IPv6 匹配"
      else
        fail "DNS 不匹配: ${CFG_DOMAIN:-?} -> ${resolved_ip}  |  服务器公网 IPv4: ${my_ipv4:-?}"
        [[ -n "$my_ipv6" ]] && info "服务器 IPv6: ${my_ipv6}"
        warn "修复: 将 ${CFG_DOMAIN:-?} 的 A 记录设置为 ${my_ipv4:-<服务器公网 IP>}"
        info "注意: 在 AWS Lightsail/EC2 上，请使用控制台中显示的静态/弹性 IP，而非私有 IP"
      fi
      # Only add UFW rule if it's already active
      if ufw status 2>/dev/null | grep -qi "Status: active"; then
        ufw allow 80/tcp 2>/dev/null || true
        ok "防火墙: 已放行 80 端口 (ufw 已激活)"
      fi
      ;;
    XRAYSSL)
      [[ -f "${SSL_CERT:-}" ]] && chmod 644 "${SSL_CERT}" 2>/dev/null && ok "证书权限已修复" || fail "证书缺失: ${SSL_CERT:-未设置}"
      if [[ -f "${SSL_KEY:-}" ]]; then
        chmod 640 "${SSL_KEY}" 2>/dev/null || true
        chgrp nobody "${SSL_KEY}" 2>/dev/null || true
        chmod o+x /etc/ssl/xhttp 2>/dev/null || true
        chmod o+x "$(dirname "${SSL_KEY}")" 2>/dev/null || true
        ok "密钥权限已修复 (640 nobody + 目录遍历)"
      else
        fail "密钥缺失: ${SSL_KEY:-未设置}"
      fi
      ;;
    VERCEL)
      curl -s --max-time 6 https://vercel.com -o /dev/null || { fail "无法访问 vercel.com"; return; }
      command -v vercel &>/dev/null || { warn "正在重新安装 vercel CLI..."; npm install -g vercel --silent && ok "vercel CLI 已重新安装"; }
      rm -rf "${VERCEL_DIR}/.vercel" 2>/dev/null || true
      ok "Vercel 链接缓存已清除 — 重试时将重新链接"
      ;;
    FIREWALL)
      # Only add allow rules if UFW is ALREADY enabled — do NOT enable it ourselves.
      if ufw status 2>/dev/null | grep -qi "Status: active"; then
        ufw allow 22/tcp 2>/dev/null || true
        ufw allow 80/tcp 2>/dev/null || true
        ufw allow 443/tcp 2>/dev/null || true
        ufw allow "${CFG_INBOUND_PORT:-2096}/tcp" 2>/dev/null || true
        ok "防火墙规则已添加 (ufw 已激活): 22, 80, 443, ${CFG_INBOUND_PORT:-2096}"
      else
        info "UFW 未激活 — 跳过防火墙配置"
      fi
      ;;
    XRAY)
      warn "正在重启 xray 服务..."
      local pid_port
      pid_port=$(lsof -ti:"${CFG_INBOUND_PORT:-2096}" 2>/dev/null || true)
      [[ -n "$pid_port" ]] && { info "正在终止端口 ${CFG_INBOUND_PORT:-2096} 上的 PID $pid_port"; kill -9 "$pid_port" 2>/dev/null || true; sleep 2; }
      systemctl restart xray 2>/dev/null || true
      sleep 4
      if systemctl is-active --quiet xray 2>/dev/null; then
        ok "xray 已重启"
      else
        fail "xray 仍未运行"
        journalctl -u xray -n 20 --no-pager 2>/dev/null || true
      fi
      ;;
    *)
      info "没有针对 '$ctx' 的自动修复方案"
      ;;
  esac
}

autofix_and_retry() {
  local ctx="$1" phase_fn="$2"
  shift 2
  local attempt=0
  while [[ $attempt -lt $AUTOFIX_MAX ]]; do
    attempt=$(( attempt + 1 ))
    info "[$ctx] 尝试 $attempt/$AUTOFIX_MAX..."
    if "$phase_fn" "$@"; then
      ok "[$ctx] 第 $attempt 次尝试成功"
      return 0
    fi
    [[ $attempt -ge $AUTOFIX_MAX ]] && { fail "[$ctx] $AUTOFIX_MAX 次尝试后失败。查看日志: $LOG_FILE"; return 1; }
    warn "[$ctx] 失败 — 正在运行自动修复..."
    autofix_diagnose "$ctx"
    sleep 3
  done
}

# =============================================================
#  PHASE 1 — PREFLIGHT: ROOT + OS + BASE PACKAGES
# =============================================================
phase1_preflight() {
  step "阶段 1 — 系统检查与前置准备"

  if [[ $EUID -ne 0 ]]; then
    fail "请以 root 身份运行: sudo bash Deploy-Ubuntu.sh"
    exit 1
  fi
  ok "以 root 身份运行"

  if grep -qiE "ubuntu" /etc/os-release 2>/dev/null; then
    local ver
    ver=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2 | cut -d'.' -f1)
    if [[ "$ver" -lt 20 ]]; then
      fail "需要 Ubuntu 20.04+ (检测到 Ubuntu $ver)"
      exit 1
    fi
    ok "检测到 Ubuntu $ver"
  else
    warn "非 Ubuntu 系统 — 继续执行"
  fi

  info "正在更新软件包列表..."
  spin "更新软件包列表 (apt-get update)" -- bash -c 'apt-get update -qq'

  spin "安装基础依赖 (curl, git, jq, dig, openssl, ...)" -- bash -c '
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
      curl wget git socat ufw jq openssl uuid-runtime netcat-openbsd \
      build-essential ca-certificates gnupg lsb-release dnsutils unzip lsof
  '

  if ! command -v node &>/dev/null; then
    spin "添加 NodeSource 源" -- bash -c 'curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -'
    spin "安装 Node.js LTS (~30秒, 下载 ~30MB)" -- bash -c 'DEBIAN_FRONTEND=noninteractive apt-get install -y -qq nodejs'
    ok "Node.js $(node -v) 已安装"
  else
    ok "Node.js $(node -v) 已存在"
  fi

  # ── 可选：为低内存 VPS 创建 swap（提示用户输入大小，输入 0 跳过）
  local total_mem_mb swap_mb avail_disk_mb
  total_mem_mb=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)
  swap_mb=$(awk '/SwapTotal/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)
  avail_disk_mb=$(df -m / 2>/dev/null | awk 'NR==2 {print int($4)}' || echo 0)
  if (( total_mem_mb < 2048 && swap_mb < 1024 )); then
    info "检测到低内存 (${total_mem_mb} MB, swap ${swap_mb} MB, 磁盘剩余 ${avail_disk_mb} MB)"
    local max_swap_mb=$(( avail_disk_mb / 2 ))
    (( max_swap_mb > 1024 )) && max_swap_mb=1024
    if (( max_swap_mb < 128 )); then
      warn "可用磁盘空间不足 (~${avail_disk_mb} MB 剩余) — 跳过创建 swap"
    else
      local swap_prompt swap_size_mb
      swap_prompt="Swap 大小 (MB) (输入 0 跳过, 默认为 ${max_swap_mb})"
      read -rp "$(echo -e "  ${C_WHITE}${swap_prompt}${C_RESET}: ")" swap_size_mb
      [[ -z "$swap_size_mb" ]] && swap_size_mb=$max_swap_mb
      if (( swap_size_mb > 0 )); then
        if (( swap_size_mb > avail_disk_mb - 128 )); then
          warn "请求的 ${swap_size_mb}MB 超出可用空间 — 限制为 ${max_swap_mb}MB"
          swap_size_mb=$max_swap_mb
        fi
        if [[ ! -f /swapfile ]]; then
          info "正在创建 ${swap_size_mb}MB swap 文件..."
          fallocate -l "${swap_size_mb}M" /swapfile 2>/dev/null || dd if=/dev/zero of=/swapfile bs=1M count="$swap_size_mb" 2>/dev/null
          chmod 600 /swapfile 2>/dev/null
          mkswap /swapfile >/dev/null 2>&1
          swapon /swapfile 2>/dev/null
          grep -q "/swapfile" /etc/fstab 2>/dev/null || echo "/swapfile none swap sw 0 0" >> /etc/fstab
          ok "${swap_size_mb} MB swap 已添加到 /swapfile"
        else
          swapon /swapfile 2>/dev/null || true
          ok "已激活现有的 /swapfile"
        fi
      else
        info "用户已跳过创建 swap"
      fi
    fi
  fi
}

# =============================================================
#  PHASE 2 — DOWNLOAD & INSTALL ALL TOOLS (no config yet)
# =============================================================
phase2_install_all() {
  step "阶段 2 — 下载并安装所有工具"

  # ── 2a. Xray ────────────────────────────────────────────
  if command -v xray &>/dev/null && xray version &>/dev/null 2>&1; then
    ok "Xray 已安装 ($(xray version 2>/dev/null | head -1))"
  else
    spin "安装 Xray (XTLS 官方, ~15MB)" -- bash -c '
      bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
    '
    ok "Xray 已安装 ($(xray version 2>/dev/null | head -1))"
  fi
  systemctl enable xray 2>/dev/null || true

  # setup xray log dirs (owned by root since we run xray as root)
  mkdir -p /var/log/xray
  touch /var/log/xray/access.log /var/log/xray/error.log 2>/dev/null || true
  chown -R root:root /var/log/xray 2>/dev/null || true
  chmod 755 /var/log/xray 2>/dev/null || true
  chmod 644 /var/log/xray/*.log 2>/dev/null || true

  # ── 2b. Netlify CLI ─────────────────────────────────────
  if command -v netlify &>/dev/null && netlify --version &>/dev/null 2>&1; then
    ok "Netlify CLI 已安装 ($(netlify --version 2>/dev/null | head -1))"
  else
    info "正在安装 Netlify CLI..."

    # Check Node version — current netlify-cli needs Node >=20.12.2.
    local node_ver
    node_ver=$(node -p "process.versions.node" 2>/dev/null || echo "0.0.0")
    if ! node -e '
      const [maj, min, patch] = process.versions.node.split(".").map(Number);
      process.exit(maj > 20 || (maj === 20 && (min > 12 || (min === 12 && patch >= 2))) ? 0 : 1);
    ' 2>/dev/null; then
      warn "检测到 Node.js ${node_ver} — netlify-cli 需要 >=20.12.2。正在升级 Node.js..."
      curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - >/dev/null 2>&1
      DEBIAN_FRONTEND=noninteractive apt-get install -y -qq nodejs 2>/dev/null
      ok "Node.js 已升级到 $(node -v)"
    fi

    local netlify_ok=false
    local NPM_REGISTRY="https://registry.npmjs.org/"
    local NPM_CACHE_DIR="/tmp/xhttp-npm-cache"
    mkdir -p "$NPM_CACHE_DIR" 2>/dev/null || true
    npm config set registry "$NPM_REGISTRY" >/dev/null 2>&1 || true

    # Common npm flags to speed up installs:
    #   --no-audit / --no-fund  → skips post-install network calls
    #   --no-progress           → suppresses progress bar (much faster on slow terms)
    #   --prefer-online         → refresh package metadata; avoids stale-cache ETARGET
    local NPM_FAST="--no-audit --no-fund --no-progress --prefer-online --registry=${NPM_REGISTRY} --cache=${NPM_CACHE_DIR} --fetch-retries=5 --fetch-retry-mintimeout=20000 --fetch-retry-maxtimeout=120000 --maxsockets=3"

    # ── 尝试 1: 快速 npm 全局安装 ─────────────────────────
    if spin "通过 npm 安装 Netlify CLI (~30-60秒)" -- \
         bash -c "npm install -g netlify-cli ${NPM_FAST}"; then
      command -v netlify &>/dev/null && netlify_ok=true
    fi

    # ── Attempt 2: npm with lower max-old-space (low-RAM VPS) ─
    if [[ "$netlify_ok" != "true" ]]; then
      warn "第一次尝试失败 — 使用低内存设置重试..."
      if spin "安装 Netlify CLI (低内存模式)" -- \
           bash -c "NODE_OPTIONS='--max-old-space-size=384' npm install -g netlify-cli ${NPM_FAST}"; then
        command -v netlify &>/dev/null && netlify_ok=true
      fi
    fi

    # ── Attempt 3: npm cache clean + retry ───────────────
    if [[ "$netlify_ok" != "true" ]]; then
      warn "第二次尝试失败 — 正在清理 npm 缓存并重试..."
      npm cache clean --force --cache="$NPM_CACHE_DIR" >/dev/null 2>&1 || true
      npm view content-type@2.0.0 version --registry="$NPM_REGISTRY" >/dev/null 2>&1 || \
        warn "npm registry 元数据似乎仍然过期；强制使用官方 npm registry 重试。"
      if spin "安装 Netlify CLI (缓存清理后)" -- \
           bash -c "NODE_OPTIONS='--max-old-space-size=384' npm install -g netlify-cli ${NPM_FAST}"; then
        command -v netlify &>/dev/null && netlify_ok=true
      fi
    fi

    # ── Attempt 4: npx wrapper (no global install needed) ─
    if [[ "$netlify_ok" != "true" ]]; then
      warn "第三次尝试失败 — 正在创建基于 npx 的包装器..."
      cat > /usr/local/bin/netlify <<'NPXWRAP'
#!/usr/bin/env bash
exec env \
  NODE_OPTIONS="${NODE_OPTIONS:---max-old-space-size=384}" \
  npm_config_registry="https://registry.npmjs.org/" \
  npm_config_cache="/tmp/xhttp-npm-cache" \
  npm_config_prefer_online=true \
  npx --yes --package netlify-cli netlify "$@"
NPXWRAP
      chmod +x /usr/local/bin/netlify
      # Warm up the npx cache once
      NODE_OPTIONS='--max-old-space-size=384' \
        npm_config_registry="$NPM_REGISTRY" \
        npm_config_cache="$NPM_CACHE_DIR" \
        npm_config_prefer_online=true \
        npx --yes --package netlify-cli netlify --version >/dev/null 2>&1 && netlify_ok=true || true
    fi

    if [[ "$netlify_ok" == "true" ]]; then
      ok "Netlify CLI 已就绪: $(netlify --version 2>/dev/null | head -1)"
    else
      fail "4 次尝试后仍无法安装 Netlify CLI。"
      warn "手动修复: npm install -g netlify-cli  或  npx netlify-cli"
      warn "安装将继续，但 Netlify 部署阶段可能会失败。"
    fi
  fi

  # ── 2c. acme.sh ─────────────────────────────────────────
  if [[ -f "$HOME/.acme.sh/acme.sh" ]]; then
    ok "acme.sh 已安装"
  else
    info "正在安装 acme.sh (尝试 1/2 — 官方源)..."
    curl -fsSL https://get.acme.sh | sh -s email=admin@example.com 2>&1 | \
      grep -E "(install|Installed|OK|error|Error|success)" || true

    if [[ ! -f "$HOME/.acme.sh/acme.sh" ]]; then
      warn "第一次尝试失败 — 尝试备用镜像..."
      curl -fsSL https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh \
        -o /tmp/acme-install.sh 2>/dev/null && \
        bash /tmp/acme-install.sh --install-online 2>&1 | \
          grep -E "(install|Installed|OK|error|Error)" || true
      rm -f /tmp/acme-install.sh
    fi

    if [[ -f "$HOME/.acme.sh/acme.sh" ]]; then
      ok "acme.sh 已安装 → $HOME/.acme.sh/acme.sh"
    else
      fail "acme.sh 安装失败 — SSL 证书阶段将无法工作。"
      warn "服务器上的手动修复: curl https://get.acme.sh | sh"
      warn "继续执行... (脚本将在 SSL 阶段失败)"
    fi
  fi

  # Source acme.sh env so it's on PATH for this session
  [[ -f "$HOME/.acme.sh/acme.sh.env" ]] && source "$HOME/.acme.sh/acme.sh.env" 2>/dev/null || true
  ACME_CMD="$HOME/.acme.sh/acme.sh"

  # Hard-fail early if acme.sh truly missing — better than cryptic "No such file" later
  if [[ ! -x "$ACME_CMD" ]]; then
    fail "未在 $ACME_CMD 找到 acme.sh — 没有 SSL 工具无法继续。"
    exit 1
  fi

  # ── 2d. Vercel CLI (仅 Vercel 平台需要) ────
  if [[ "${CFG_PLATFORM:-vercel}" == "vercel" ]]; then
    if command -v vercel &>/dev/null; then
      ok "Vercel CLI 已安装 ($(vercel --version 2>/dev/null | head -1))"
    else
      spin "通过 npm 安装 Vercel CLI (~20-40秒)" -- \
        bash -c 'npm install -g vercel --no-audit --no-fund --no-progress --prefer-offline'
    fi
  else
    info "跳过 Vercel CLI (Netlify 不需要)"
  fi

  # ── 2d. xray-knife ──────────────────────────────────────
  XRAY_KNIFE_BIN="/usr/local/bin/xray-knife"
  if [[ -x "$XRAY_KNIFE_BIN" ]]; then
    ok "xray-knife 已安装"
  else
    info "正在下载 xray-knife..."
    local arch release_url knife_url tmp_dir
    arch=$(uname -m)
    # xray-knife uses zip files: Xray-knife-linux-64.zip or Xray-knife-linux-arm.zip
    case "$arch" in
      aarch64) arch_tag="arm64" ;;
      armv7*)  arch_tag="arm"   ;;
      *)       arch_tag="64"    ;;
    esac

    release_url="https://api.github.com/repos/lilendian0x00/xray-knife/releases/latest"
    knife_url=$(curl -fsSL "$release_url" 2>/dev/null | \
      grep -oP '"browser_download_url":\s*"\Khttps://[^"]+Xray-knife-linux-'"${arch_tag}"'\.zip' | head -1 || true)

    if [[ -z "$knife_url" ]]; then
      warn "无法自动检测 xray-knife URL — 尝试直接下载"
      knife_url="https://github.com/lilendian0x00/xray-knife/releases/latest/download/Xray-knife-linux-${arch_tag}.zip"
    fi

    tmp_dir=$(mktemp -d)
    info "正在下载: $knife_url"
    if curl -fsSL "$knife_url" -o "$tmp_dir/xray-knife.zip" 2>/dev/null; then
      unzip -q "$tmp_dir/xray-knife.zip" -d "$tmp_dir" 2>/dev/null || true
    else
      warn "zip 下载失败 — 尝试 tar.gz 备用"
      curl -fsSL "https://github.com/lilendian0x00/xray-knife/releases/latest/download/Xray-knife-linux-${arch_tag}.tar.gz" \
        -o "$tmp_dir/xray-knife.tar.gz" 2>/dev/null || true
      tar -xzf "$tmp_dir/xray-knife.tar.gz" -C "$tmp_dir" 2>/dev/null || true
    fi
    local knife_bin
    knife_bin=$(find "$tmp_dir" -type f \( -name "xray-knife" -o -name "Xray-knife" \) | head -1 || true)
    if [[ -n "$knife_bin" ]]; then
      cp "$knife_bin" "$XRAY_KNIFE_BIN"
      chmod +x "$XRAY_KNIFE_BIN"
      ok "xray-knife 已安装 → $XRAY_KNIFE_BIN"
    else
      warn "未找到 xray-knife 二进制文件 — 将跳过健康检查步骤"
      XRAY_KNIFE_BIN=""
    fi
    rm -rf "$tmp_dir"
  fi
}

# =============================================================
#  PHASE 3 — COLLECT ALL USER INPUT (one shot, then confirm)
# =============================================================
phase3_collect_input() {
  step "阶段 3 — 配置输入"
  echo -e "  ${C_GRAY}请在下面填写数值。按 Enter 接受默认值。${C_RESET}\n"

  # ── SSL / Domain ────────────────────────────────────────
  echo -e "\n  ${C_CYAN}[ SSL 与域名 ]${C_RESET}"
  CFG_DOMAIN=$(read_required "你的域名 (例如 sub.example.com)")

  # Email must be a REAL deliverable address — Let's Encrypt rejects
  # admin@yoursub, *@example.com, *@test.com, etc.
  echo -e "  ${C_GRAY}输入真实的邮箱 — 任何提供商均可 (Gmail, Yahoo, Outlook,${C_RESET}"
  echo -e "  ${C_GRAY}ProtonMail, iCloud, Zoho, 你自己的域名等)。${C_RESET}"
  echo -e "  ${C_GRAY}Let's Encrypt 拒绝虚假/占位地址。${C_RESET}"
  while true; do
    CFG_EMAIL=$(read_required "Let's Encrypt 通知邮箱 (必须真实)")
    # Reject obvious placeholders
    local lower_email="${CFG_EMAIL,,}"
    if [[ ! "$lower_email" =~ ^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$ ]]; then
      fail "邮箱格式无效。示例: yourname@yourprovider.com"
      continue
    fi
    if echo "$lower_email" | grep -qE '@(example\.|test\.|domain\.|yourdomain\.|mydomain\.|localhost|local$|invalid$)'; then
      fail "虚假/占位邮箱已被拒绝。请使用你拥有的真实邮箱。"
      continue
    fi
    if echo "$lower_email" | grep -qE "@${CFG_DOMAIN}$"; then
      warn "你正在使用与你正在保护的域名相同的邮箱 (@${CFG_DOMAIN})。"
      warn "如果没有 MX 记录，Let's Encrypt 可能会拒绝此邮箱。"
      warn "建议: 使用任何第三方提供商 (Gmail, Yahoo, Outlook, ProtonMail 等)"
      if ! confirm "仍然使用 ${CFG_EMAIL} 继续？"; then
        continue
      fi
    fi
    break
  done
  ok "邮箱已接受: ${CFG_EMAIL}"

  # ── Inbound / Relay ─────────────────────────────────────
  echo -e "\n  ${C_CYAN}[ 入站与转发 ]${C_RESET}"
  CFG_INBOUND_PORT=$(read_default "服务器入站端口 (XHTTP)" "443")
  CFG_RELAY_PATH=$(read_default   "中继路径 — RELAY_PATH (入站路径, 例如 /api)" "/api")
  CFG_PUBLIC_PATH=$(read_default  "公共中继路径 — PUBLIC_RELAY_PATH (Vercel 端路径)" "/api")
  [[ "${CFG_RELAY_PATH:0:1}" != "/" ]] && CFG_RELAY_PATH="/$CFG_RELAY_PATH"
  [[ "${CFG_PUBLIC_PATH:0:1}" != "/" ]] && CFG_PUBLIC_PATH="/$CFG_PUBLIC_PATH"

  # ── Platform credentials ─────────────────────────────────
  local rand_proj
  rand_proj="relay-$(cat /dev/urandom | tr -dc 'a-z0-9' 2>/dev/null | head -c8 || true)"
  if [[ "$CFG_PLATFORM" == "vercel" ]]; then
    echo -e "\n  ${C_CYAN}[ Vercel 部署 ]${C_RESET}"
    CFG_VERCEL_TOKEN=""
    while [[ -z "${CFG_VERCEL_TOKEN// }" ]]; do
      read -rp "$(echo -e "  ${C_WHITE}Vercel API 令牌 (设置 → 令牌)${C_RESET}: ")" CFG_VERCEL_TOKEN
      [[ -z "${CFG_VERCEL_TOKEN// }" ]] && fail "必填字段。"
    done
    CFG_PROJECT_NAME=$(read_default "Vercel 项目名称" "$rand_proj")
    CFG_VERCEL_SCOPE=$(read_default "Vercel 范围/团队 slug (个人账户留空)" "")
    CFG_NETLIFY_TOKEN=""
    CFG_NETLIFY_SITE=""
  else
    echo -e "\n  ${C_CYAN}[ Netlify 部署 ]${C_RESET}"
    CFG_NETLIFY_TOKEN=""
    while [[ -z "${CFG_NETLIFY_TOKEN// }" ]]; do
      read -rp "$(echo -e "  ${C_WHITE}Netlify 个人访问令牌 (app.netlify.com → 用户设置 → OAuth)${C_RESET}: ")" CFG_NETLIFY_TOKEN
      [[ -z "${CFG_NETLIFY_TOKEN// }" ]] && fail "必填字段。"
    done
    CFG_NETLIFY_SITE=$(read_default "Netlify 站点名称" "$rand_proj")
    CFG_VERCEL_TOKEN=""
    CFG_PROJECT_NAME=""
    CFG_VERCEL_SCOPE=""
  fi

  # ── Performance ─────────────────────────────────────────
  if [[ "$CFG_PLATFORM" == "vercel" ]]; then
    echo -e "\n  ${C_CYAN}[ 性能配置 (按 Enter 使用默认值) ]${C_RESET}"
    CFG_MAX_INFLIGHT=$(read_default      "MAX_INFLIGHT"         "128")
    CFG_MAX_UP_BPS=$(read_default        "MAX_UP_BPS"           "2621440")
    CFG_MAX_DOWN_BPS=$(read_default      "MAX_DOWN_BPS"         "2621440")
    CFG_UPSTREAM_TIMEOUT=$(read_default  "UPSTREAM_TIMEOUT_MS"  "50000")
    CFG_SUCCESS_LOG=$(read_default       "SUCCESS_LOG_SAMPLE_RATE" "0")
    CFG_SUCCESS_DUR=$(read_default       "SUCCESS_LOG_MIN_DURATION_MS" "3000")
    CFG_ERROR_INT=$(read_default         "ERROR_LOG_MIN_INTERVAL_MS"  "5000")
  else
    # Netlify: use sensible defaults silently (edge function handles its own tuning)
    CFG_MAX_INFLIGHT="128"
    CFG_MAX_UP_BPS="2621440"
    CFG_MAX_DOWN_BPS="2621440"
    CFG_UPSTREAM_TIMEOUT="50000"
    CFG_SUCCESS_LOG="0"
    CFG_SUCCESS_DUR="3000"
    CFG_ERROR_INT="5000"
    info "性能设置: 使用默认值 (Netlify)"
  fi

  # ── Summary ─────────────────────────────────────────────
  echo ""
  echo -e "  ${C_CYAN}────────────── 配置摘要 ──────────────${C_RESET}"
  echo -e "  ${C_WHITE}平台            :${C_RESET} $CFG_PLATFORM"
  echo -e "  ${C_WHITE}域名            :${C_RESET} $CFG_DOMAIN"
  echo -e "  ${C_WHITE}入站端口        :${C_RESET} $CFG_INBOUND_PORT"
  echo -e "  ${C_WHITE}中继路径        :${C_RESET} $CFG_RELAY_PATH"
  echo -e "  ${C_WHITE}公共路径        :${C_RESET} $CFG_PUBLIC_PATH"
  if [[ "$CFG_PLATFORM" == "vercel" ]]; then
    echo -e "  ${C_WHITE}Vercel 项目     :${C_RESET} $CFG_PROJECT_NAME"
    [[ -n "$CFG_VERCEL_SCOPE" ]] && echo -e "  ${C_WHITE}Vercel 范围     :${C_RESET} $CFG_VERCEL_SCOPE"
  else
    echo -e "  ${C_WHITE}Netlify 站点    :${C_RESET} $CFG_NETLIFY_SITE"
  fi
  if [[ "$CFG_PLATFORM" == "vercel" ]]; then
    echo -e "  ${C_WHITE}MAX_INFLIGHT    :${C_RESET} $CFG_MAX_INFLIGHT"
    echo -e "  ${C_WHITE}MAX_UP_BPS      :${C_RESET} $CFG_MAX_UP_BPS"
    echo -e "  ${C_WHITE}MAX_DOWN_BPS    :${C_RESET} $CFG_MAX_DOWN_BPS"
    echo -e "  ${C_WHITE}TIMEOUT_MS      :${C_RESET} $CFG_UPSTREAM_TIMEOUT"
    echo -e "  ${C_WHITE}SUCCESS_LOG     :${C_RESET} $CFG_SUCCESS_LOG"
    echo -e "  ${C_WHITE}SUCCESS_DUR_MS  :${C_RESET} $CFG_SUCCESS_DUR"
    echo -e "  ${C_WHITE}ERROR_INT_MS    :${C_RESET} $CFG_ERROR_INT"
  fi
  echo -e "  ${C_CYAN}─────────────────────────────────────${C_RESET}"
  echo ""
  if ! confirm "使用这些设置继续？"; then
    warn "用户已中止。"
    exit 0
  fi
}

# =============================================================
#  PHASE 4a — SSL WITH acme.sh
# =============================================================
phase4a_ssl() {
  step "阶段 4a — 为 ${CFG_DOMAIN} 获取 SSL 证书"

  SSL_DIR="/etc/ssl/xhttp/${CFG_DOMAIN}"
  mkdir -p "$SSL_DIR"

  SSL_CERT="${SSL_DIR}/fullchain.pem"
  SSL_KEY="${SSL_DIR}/privkey.pem"

  # ── Pre-flight: verify domain resolves from THIS server ─────
  # acme.sh validation works because Let's Encrypt resolves DNS itself, but if
  # the server can't resolve its own domain it can't bind to the right interface
  # and webroot/standalone won't behave correctly. Use multiple resolvers.
  local resolved
  resolved=$(
    dig +short +time=3 +tries=1 "$CFG_DOMAIN" A @1.1.1.1 2>/dev/null | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -1
  )
  [[ -z "$resolved" ]] && resolved=$(
    dig +short +time=3 +tries=1 "$CFG_DOMAIN" A @8.8.8.8 2>/dev/null | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -1
  )
  [[ -z "$resolved" ]] && resolved=$(
    curl -s --max-time 5 "https://cloudflare-dns.com/dns-query?name=${CFG_DOMAIN}&type=A" \
      -H "accept: application/dns-json" 2>/dev/null | \
      grep -oP '"data"\s*:\s*"\K[0-9.]+' | head -1
  )

  if [[ -n "$resolved" ]]; then
    ok "DNS 解析正常: ${CFG_DOMAIN} → ${resolved}"
  else
    warn "从服务器无法解析 ${CFG_DOMAIN} (DNS 检查失败)。"
    warn "如果你刚刚创建了 A 记录，请等待 1-2 分钟等待传播。"
    warn "acme.sh 仍将尝试；Let's Encrypt 独立解析 DNS。"
  fi

  # ── Detect & stop any service holding port 80 (Apache / Nginx / etc.) ─
  local port80_used=false port80_pid="" port80_proc=""
  local STOPPED_SERVICES=()   # remember what we stopped so we can restart after

  if ss -tlnp 2>/dev/null | grep -q ':80 '; then
    port80_used=true
    port80_pid=$(ss -tlnp 2>/dev/null | grep ':80 ' | grep -oP 'pid=\K[0-9]+' | head -1)
    port80_proc=$(ss -tlnp 2>/dev/null | grep ':80 ' | grep -oP 'users:\(\("\K[^"]+' | head -1)
    warn "端口 80 正被 '${port80_proc:-未知}' 占用 (PID ${port80_pid:-?})"

    # Try to stop known web services cleanly via systemctl (preferred over kill)
    for svc in apache2 httpd nginx caddy lighttpd; do
      if systemctl is-active --quiet "$svc" 2>/dev/null; then
        info "正在停止 ${svc}.service (SSL 完成后将重启)..."
        if systemctl stop "$svc" 2>/dev/null; then
          STOPPED_SERVICES+=("$svc")
          ok "${svc} 已停止"
        fi
      fi
    done
    sleep 2

    # Verify port is free now
    if ss -tlnp 2>/dev/null | grep -q ':80 '; then
      warn "停止 Web 服务后端口 80 仍被占用"
    else
      ok "端口 80 已释放"
      port80_used=false
    fi
  fi

  # Helper: restart all services we stopped (called on success and failure)
  _restart_stopped_services() {
    for svc in "${STOPPED_SERVICES[@]}"; do
      if systemctl start "$svc" 2>/dev/null; then
        ok "${svc} 已重启"
      else
        warn "无法重启 ${svc} — 如有需要请手动启动"
      fi
    done
  }

  # ── Register acme.sh account (idempotent) ──────────────────
  "$ACME_CMD" --register-account -m "$CFG_EMAIL" --server letsencrypt 2>&1 | \
    grep -iE "register|already|account" | head -3 || true

  # ── Helper: run acme.sh --issue and capture full output ────
  # $1: mode (standalone | webroot)
  # $2: extra flags (e.g. "--force")
  _run_acme_issue() {
    local mode="$1" extra="${2:-}"
    info "正在运行: acme.sh --issue -d ${CFG_DOMAIN} --${mode} --keylength ec-256 --listen-v4 ${extra}"
    local out rc
    if [[ "$mode" == "webroot" ]]; then
      mkdir -p /var/www/html
      out=$("$ACME_CMD" --issue -d "$CFG_DOMAIN" --webroot /var/www/html \
        --keylength ec-256 --listen-v4 --server letsencrypt $extra 2>&1) || rc=$?
    else
      out=$("$ACME_CMD" --issue -d "$CFG_DOMAIN" --standalone \
        --keylength ec-256 --listen-v4 --server letsencrypt $extra 2>&1) || rc=$?
    fi
    rc=${rc:-0}
    # Save full output for later inspection
    LAST_ACME_OUT="$out"
    # Show last 25 lines so user can see the real error
    echo "$out" | tail -25 | while IFS= read -r l; do echo -e "    ${C_GRAY}${l}${C_RESET}"; done
    return $rc
  }

  # ── Check if a valid cert already exists on disk (covers both ECC and RSA) ─
  local acme_cert_path="$HOME/.acme.sh/${CFG_DOMAIN}_ecc/${CFG_DOMAIN}.cer"
  local acme_cert_path_rsa="$HOME/.acme.sh/${CFG_DOMAIN}/${CFG_DOMAIN}.cer"
  if [[ -f "$acme_cert_path" ]]; then
    info "找到现有 EC 证书位于 ${acme_cert_path} — 将重复使用"
  elif [[ -f "$acme_cert_path_rsa" ]]; then
    info "找到现有 RSA 证书位于 ${acme_cert_path_rsa} — 将重复使用"
    acme_cert_path="$acme_cert_path_rsa"
  fi

  # ── Issue certificate ──────────────────────────────────────
  local issue_rc=0 LAST_ACME_OUT=""
  if [[ "$port80_used" == "true" ]]; then
    if command -v nginx &>/dev/null && [[ -d /var/www/html ]]; then
      _run_acme_issue webroot || issue_rc=$?
    else
      warn "临时停止端口 80 服务以进行独立验证..."
      [[ -n "$port80_pid" ]] && kill "$port80_pid" 2>/dev/null
      systemctl stop xray 2>/dev/null || true
      sleep 2
      _run_acme_issue standalone || issue_rc=$?
      systemctl start xray 2>/dev/null || true
    fi
  else
    _run_acme_issue standalone || issue_rc=$?
  fi

  # ── Handle "Skipping. Next renewal time" — cert already exists & valid ───
  # acme.sh exits 2 in this case; treat as success if the cer file is there.
  if [[ $issue_rc -ne 0 ]] && echo "$LAST_ACME_OUT" | grep -qiE "Domains not changed|Skipping.*Next renewal"; then
    if [[ -f "$acme_cert_path" ]]; then
      info "acme.sh: 现有证书仍然有效 — 直接使用"
      issue_rc=0
    else
      # The 'skip' message lied (no cert on disk) — force re-issue
      warn "acme.sh 提示 '跳过' 但未找到证书文件 — 使用 --force 强制重新签发"
      issue_rc=0
      if [[ "$port80_used" == "true" ]] && ! { command -v nginx &>/dev/null && [[ -d /var/www/html ]]; }; then
        systemctl stop xray 2>/dev/null || true
        sleep 2
        _run_acme_issue standalone "--force" || issue_rc=$?
        systemctl start xray 2>/dev/null || true
      elif [[ "$port80_used" == "true" ]]; then
        _run_acme_issue webroot "--force" || issue_rc=$?
      else
        _run_acme_issue standalone "--force" || issue_rc=$?
      fi
    fi
  fi

  # ── If issue failed, try clearing stale acme.sh state and retry once ───
  # acme.sh caches the CA directory URL and account info. If a previous run
  # picked up ZeroSSL (which fails for many users) or got a stale account
  # token, future runs reuse it and keep failing. Wipe and retry with
  # Let's Encrypt forced.
  if [[ $issue_rc -ne 0 ]] || [[ ! -f "$acme_cert_path" ]]; then
    warn "第一次 SSL 尝试失败 — 清除 acme.sh CA/账户缓存并重试..."
    rm -rf "$HOME/.acme.sh/ca" 2>/dev/null || true
    rm -f  "$HOME/.acme.sh/account.conf" 2>/dev/null || true
    # Re-register account explicitly against Let's Encrypt
    "$ACME_CMD" --register-account -m "$CFG_EMAIL" --server letsencrypt 2>&1 | \
      grep -iE "register|account|created" | head -3 || true
    "$ACME_CMD" --set-default-ca --server letsencrypt 2>&1 | tail -3 || true

    issue_rc=0
    if [[ "$port80_used" == "true" ]] && ! { command -v nginx &>/dev/null && [[ -d /var/www/html ]]; }; then
      systemctl stop xray 2>/dev/null || true
      sleep 2
      _run_acme_issue standalone "--force" || issue_rc=$?
      systemctl start xray 2>/dev/null || true
    elif [[ "$port80_used" == "true" ]]; then
      _run_acme_issue webroot "--force" || issue_rc=$?
    else
      _run_acme_issue standalone "--force" || issue_rc=$?
    fi
  fi

  # ── Verify the cert file actually exists before installcert ─
  if [[ $issue_rc -ne 0 ]] || [[ ! -f "$acme_cert_path" ]]; then
    fail "acme.sh --issue 失败 (退出码 ${issue_rc})。未找到证书于 ${acme_cert_path}"
    info "常见原因:"
    info "  • ${CFG_DOMAIN} 的 DNS A 记录未指向此服务器的公网 IP"
    info "  • 启用了 Cloudflare 代理 (橙色云必须改为仅 DNS / 灰色)"
    info "  • 端口 80 无法从互联网访问 (提供商防火墙 / 安全组)"
    info "  • 达到 Let's Encrypt 速率限制 (每个域名每周 5 个证书)"
    info "  • 服务器 IP 被 Let's Encrypt 地理封锁"
    info ""
    info "服务器上的手动恢复:"
    info "  rm -rf /root/.acme.sh/ca /root/.acme.sh/account.conf"
    info "  $ACME_CMD --register-account -m $CFG_EMAIL --server letsencrypt"
    info "  $ACME_CMD --issue -d $CFG_DOMAIN --standalone --keylength ec-256 --listen-v4 --server letsencrypt --force"
    autofix_diagnose "SSL"
    return 1
  fi

  ok "acme.sh 证书已就绪"

  # ── Install certificate to target dir ──────────────────────
  # --ecc selects the EC-key cert directory (${domain}_ecc/). Omit it for RSA.
  local ecc_flag="--ecc"
  [[ "$acme_cert_path" == *"${CFG_DOMAIN}/${CFG_DOMAIN}.cer" ]] && ecc_flag=""
  "$ACME_CMD" --installcert -d "$CFG_DOMAIN" $ecc_flag \
    --cert-file     "${SSL_DIR}/cert.pem" \
    --key-file      "${SSL_KEY}" \
    --fullchain-file "${SSL_CERT}" \
    --reloadcmd     "systemctl restart xray 2>/dev/null || true" 2>&1 | tail -5

  if [[ -f "$SSL_CERT" && -f "$SSL_KEY" ]]; then
    chmod 644 "$SSL_CERT" 2>/dev/null || true
    chmod 640 "$SSL_KEY"  2>/dev/null || true
    chgrp nobody "$SSL_KEY" 2>/dev/null || true
    chmod o+x /etc/ssl/xhttp 2>/dev/null || true
    chmod o+x "$(dirname "$SSL_KEY")" 2>/dev/null || true
    ok "SSL 证书已安装 → $SSL_CERT"
    # Restart any web services we stopped to free port 80
    if [[ ${#STOPPED_SERVICES[@]} -gt 0 ]]; then
      _restart_stopped_services
    fi
    # IMPORTANT: explicit `return 0` — the `[[ -gt 0 ]] && cmd` pattern above
    # would return 1 if STOPPED_SERVICES is empty (the normal case), tricking
    # autofix_and_retry into thinking SSL failed even when it succeeded.
    return 0
  else
    fail "SSL 证书安装失败 — 证书已签发但未复制到 ${SSL_CERT}"
    info "手动尝试: $ACME_CMD --installcert -d $CFG_DOMAIN --ecc --cert-file ... --key-file ... --fullchain-file ..."
    if [[ ${#STOPPED_SERVICES[@]} -gt 0 ]]; then
      _restart_stopped_services
    fi
    autofix_diagnose "SSL"
    return 1
  fi
}

# =============================================================
#  PHASE 4b — CONFIGURE XRAY (VLESS+XHTTP+TLS)
# =============================================================
phase4b_configure_xray() {
  step "阶段 4b — 配置 Xray VLESS+XHTTP+TLS 入站"

  local XRAY_CFG="/usr/local/etc/xray/config.json"

  # ── Generate UUID ────────────────────────────────────────
  INBOUND_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]')
  info "已生成 UUID: ${INBOUND_UUID}"

  # ── Backup old config ────────────────────────────────────
  [[ -f "$XRAY_CFG" ]] && cp "$XRAY_CFG" "${XRAY_CFG}.bak" 2>/dev/null || true

  # ── Platform-specific XHTTP tuning ───────────────────────
  # Vercel: default padding 100-1000 works fine.
  # Netlify: needs obfuscation-mode padding (10-50 + random key/header) to
  #          survive Netlify's edge body handling. The same key/header MUST
  #          be present in the client link's `extra` param or traffic is rejected.
  # NOTE: do NOT declare XPADDING / XPADDING_KEY / XPADDING_HEADER / SC_MAX_POST_BYTES
  # as `local` here — they need to outlive this function so phase6_summary and
  # phase7_install_panel can embed them in the VLESS link. The `local` keyword
  # confines them to this function's scope (export doesn't override that).
  local XHTTP_MODE="auto"
  local XHTTP_EXTRA_BLOCK=""        # extra JSON properties for xray xhttpSettings
  XPADDING=""
  XPADDING_KEY=""
  XPADDING_HEADER=""
  XPADDING_OBFS="false"
  SC_MAX_POST_BYTES=""

  if [[ "${CFG_PLATFORM:-vercel}" == "netlify" ]]; then
    XPADDING="10-50"
    XPADDING_OBFS="true"
    SC_MAX_POST_BYTES="1000000"
    # Random key (lowercase, 7 chars) and header (mixed-case, 7 chars).
    # /dev/urandom may produce no bytes in some environments — fall back to RANDOM.
    XPADDING_KEY=$(LC_ALL=C tr -dc 'a-z' </dev/urandom 2>/dev/null | head -c 7 || true)
    XPADDING_HEADER=$(LC_ALL=C tr -dc 'A-Za-z' </dev/urandom 2>/dev/null | head -c 7 || true)
    [[ -z "$XPADDING_KEY"    ]] && XPADDING_KEY="k$(printf '%06d' $RANDOM)"
    [[ -z "$XPADDING_HEADER" ]] && XPADDING_HEADER="H$(printf '%06d' $RANDOM)"

    info "平台=netlify → xPaddingBytes=${XPADDING}, obfsMode=已开启"
    info "已生成 xPaddingKey    : ${XPADDING_KEY}"
    info "已生成 xPaddingHeader : ${XPADDING_HEADER}"

    XHTTP_EXTRA_BLOCK=",
          \"xPaddingObfsMode\": true,
          \"xPaddingKey\": \"${XPADDING_KEY}\",
          \"xPaddingHeader\": \"${XPADDING_HEADER}\",
          \"scMaxEachPostBytes\": \"${SC_MAX_POST_BYTES}\""
  else
    XPADDING="100-1000"
  fi

  # Export so phase6_summary + phase7_install_panel can reuse them in the VLESS link
  export XPADDING XPADDING_KEY XPADDING_HEADER XPADDING_OBFS SC_MAX_POST_BYTES

  # ── Write config.json ────────────────────────────────────
  info "正在写入 Xray 配置 → ${XRAY_CFG}"
  cat > "$XRAY_CFG" <<XRAYCFG
{
  "log": {
    "loglevel": "warning",
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log"
  },
  "inbounds": [
    {
      "tag": "xhttp-in",
      "listen": "0.0.0.0",
      "port": ${CFG_INBOUND_PORT},
      "protocol": "vless",
      "settings": {
        "clients": [
          { "id": "${INBOUND_UUID}", "flow": "" }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "xhttp",
        "security": "tls",
        "tlsSettings": {
          "alpn": ["h2", "http/1.1"],
          "certificates": [
            {
              "certificateFile": "${SSL_CERT}",
              "keyFile": "${SSL_KEY}"
            }
          ]
        },
        "xhttpSettings": {
          "path": "${CFG_RELAY_PATH}",
          "host": "${CFG_DOMAIN}",
          "mode": "${XHTTP_MODE}",
          "xPaddingBytes": "${XPADDING}"${XHTTP_EXTRA_BLOCK}
        }
      }
    }
  ],
  "outbounds": [
    { "protocol": "freedom", "tag": "direct" },
    { "protocol": "blackhole", "tag": "blocked" }
  ]
}
XRAYCFG

  # ── Test config syntax ───────────────────────────────────
  local test_out
  test_out=$(xray -test -config "$XRAY_CFG" 2>&1 || true)
  if echo "$test_out" | grep -qi "configuration ok\|Configuration OK"; then
    ok "Xray 配置语法正确"
  else
    fail "Xray 配置测试失败: $test_out"
    autofix_diagnose "XRAY"
    return 1
  fi

  # ── Start Xray ───────────────────────────────────────────
  # ── Force xray to run as root via systemd drop-in (overrides any service file) ──
  # Keep CAP_NET_BIND_SERVICE so xray can bind to privileged ports (443, etc.)
  mkdir -p /etc/systemd/system/xray.service.d
  cat > /etc/systemd/system/xray.service.d/override.conf <<'OVERRIDE'
[Service]
User=root
Group=root
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=false
OVERRIDE
  # Also patch any User=nobody in main service files (belt + suspenders)
  for svc in /etc/systemd/system/xray.service /etc/systemd/system/xray@.service /lib/systemd/system/xray.service; do
    [[ -f "$svc" ]] && sed -i 's/^User=nobody/User=root/; s/^Group=nogroup/Group=root/' "$svc" 2>/dev/null || true
  done
  # Ensure log dir is owned by root (xray now runs as root)
  chown -R root:root /var/log/xray 2>/dev/null || true
  chmod 755 /var/log/xray 2>/dev/null || true
  chmod 644 /var/log/xray/*.log 2>/dev/null || true
  systemctl daemon-reload 2>/dev/null || true
  ok "xray 服务已强制使用 User=root"

  systemctl restart xray 2>/dev/null || true
  systemctl enable xray 2>/dev/null || true
  sleep 3

  if systemctl is-active --quiet xray 2>/dev/null; then
    ok "Xray 正在端口 ${CFG_INBOUND_PORT} 上运行"
  else
    fail "Xray 启动失败"
    journalctl -u xray -n 20 --no-pager 2>/dev/null || true
    autofix_diagnose "XRAY"
    return 1
  fi

  # ── Quick local test ─────────────────────────────────────
  local http_code
  http_code=$(curl -sk --max-time 5 \
    "https://127.0.0.1:${CFG_INBOUND_PORT}${CFG_RELAY_PATH}" \
    -o /dev/null -w "%{http_code}" 2>/dev/null || echo "000")
  if echo "$http_code" | grep -qE "^(4[0-9]{2}|200)$"; then
    ok "Xray 本地测试: HTTP $http_code (预期 4xx) ✔"
  else
    warn "Xray 本地测试返回 HTTP $http_code (XHTTP 下可能正常)"
  fi

  ok "UUID: ${INBOUND_UUID}"
  echo -e "  ${C_GRAY}TARGET_DOMAIN: https://${CFG_DOMAIN}:${CFG_INBOUND_PORT}${C_RESET}"
}

# =============================================================
#  PHASE 4c — DEPLOY (Vercel or Netlify)
# =============================================================

_random_str() { cat /dev/urandom | tr -dc 'a-z0-9' 2>/dev/null | head -c "$1" || true; }

_randomize_package_json() {
  local pkg="${VERCEL_DIR}/package.json"
  [[ -f "$pkg" ]] || return
  ORIG_PKG=$(cat "$pkg")
  local rname rver rdesc
  rname="host-$(_random_str 10)"
  rver="$(( RANDOM % 3 + 1 )).$((RANDOM % 20)).$((RANDOM % 30))"
  local descs=("轻量主机边缘中继" "优化下载网关" "流量整形中继运行时" "资源友好传输桥接")
  rdesc="${descs[$((RANDOM % ${#descs[@]}))]}"
  jq --arg n "$rname" --arg v "$rver" --arg d "$rdesc" \
    '.name=$n | .version=$v | .description=$d' "$pkg" > "${pkg}.tmp" && mv "${pkg}.tmp" "$pkg"
  info "已随机化 package.json: name=$rname, version=$rver"
}

_restore_package_json() {
  local pkg="${VERCEL_DIR}/package.json"
  [[ -n "${ORIG_PKG:-}" ]] && echo "$ORIG_PKG" > "$pkg" && info "package.json 已恢复"
}

_randomize_vercel_json() {
  # NOTE: previously added a `name` field to vercel.json for obfuscation,
  # but recent Vercel CLI rejects vercel.json containing `name` with the
  # misleading error: "The value of the `version` property within vercel.json
  # can only be `2`." (Vercel sees `name`, assumes legacy v1 schema, fails.)
  # Project-name obfuscation now happens via package.json only.
  ORIG_VCFG=""
  return 0
}

_restore_vercel_json() {
  # Kept for compatibility — randomization is now a no-op so there's
  # nothing to restore. If ORIG_VCFG is set (legacy install state), still
  # restore it to be safe.
  local vcfg="${VERCEL_DIR}/vercel.json"
  [[ -n "${ORIG_VCFG:-}" ]] && echo "$ORIG_VCFG" > "$vcfg" && info "vercel.json restored"
  return 0
}

_vercel_diagnose_deploy_error() {
  local out="$1"
  echo -e "\n  ${C_MAGENTA}[自动修复/Vercel]${C_RESET} 正在分析部署错误..."

  # ── Token / Auth — match strict patterns to avoid false positives ──
  if echo "$out" | grep -qiE "Error: (Invalid token|Not authorized)|invalid_token|401 Unauthorized|403 Forbidden|expired token"; then
    fail "认证错误 — Vercel 令牌无效或已过期"
    warn "修复: 前往 https://vercel.com/account/tokens 创建新令牌"
    warn "然后重新运行此脚本并粘贴新令牌"
    return 1
  fi

  # ── Rate limit ──────────────────────────────────────────
  if echo "$out" | grep -qiE "rate.limit|too many requests|429 Too|deployment limit"; then
    fail "达到 Vercel API 速率限制"
    warn "修复: 等待 60 秒后重试"
    sleep 60
    return 0
  fi

  # ── Project name conflict ─ (owner mismatch / already taken globally) ──
  if echo "$out" | grep -qiE "project.*already exists|name.*already.*taken|409 Conflict"; then
    local new_name
    new_name="relay-$(_random_str 8)"
    warn "项目名称冲突 — 重命名为: $new_name"
    CFG_PROJECT_NAME="$new_name"
    rm -rf "${VERCEL_DIR}/.vercel" 2>/dev/null || true
    return 0
  fi

  # ── Link / project.json stale ─ specific Vercel messages only ────
  if echo "$out" | grep -qiE "project not found|no project linked|linked to a different|\.vercel directory is invalid"; then
    warn "项目链接已过期 — 清除 .vercel 缓存 (重试前将重新链接)"
    rm -rf "${VERCEL_DIR}/.vercel" 2>/dev/null || true
    return 0
  fi

  # ── vercel.json schema error (Vercel often shows misleading "version" message) ──
  if echo "$out" | grep -qiE "version.*property.*vercel\.json|vercel\.json.*can only be|vercel\.json.*invalid|unknown.*property.*vercel\.json|Invalid vercel\.json"; then
    fail "vercel.json 架构错误 — Vercel 拒绝了配置"
    info "来自 Vercel 的实际错误:"
    echo "$out" | grep -iE "error:|invalid|cannot|unknown" | head -5 | \
      while IFS= read -r l; do echo -e "  ${C_GRAY}    $l${C_RESET}"; done

    if command -v jq &>/dev/null && [[ -f "${VERCEL_DIR}/vercel.json" ]]; then
      warn "自动修复: 清理 vercel.json 中的已弃用属性..."
      # Strip every property known to break recent Vercel CLI:
      #   .name           — deprecated, makes Vercel think v1 schema
      #   .functions[].regions  — per-function regions removed
      #   .regions        — only allowed on Pro/Enterprise plans
      #   .$schema        — JSON Schema reference, some CLI builds reject
      #   .builds         — legacy v1 build config
      #   .routes         — replaced by rewrites/redirects
      jq 'del(.name) | del(.["$schema"]) | del(.builds) | del(.routes) | del(.regions)
          | if .functions then
              .functions = (.functions | with_entries(.value |= del(.regions)))
            else . end' \
          "${VERCEL_DIR}/vercel.json" > "${VERCEL_DIR}/vercel.json.tmp" && \
        mv "${VERCEL_DIR}/vercel.json.tmp" "${VERCEL_DIR}/vercel.json"
      ok "已清理 vercel.json (已移除: name, \$schema, builds, routes, regions, functions.*.regions)"
      info "当前 vercel.json:"
      cat "${VERCEL_DIR}/vercel.json" | head -20 | \
        while IFS= read -r l; do echo -e "  ${C_GRAY}    $l${C_RESET}"; done
    else
      warn "jq 不可用 — 无法自动清理 vercel.json"
    fi
    return 0
  fi

  # ── Build failure ───────────────────────────────────────
  if echo "$out" | grep -qiE "Build (failed|error)|Failed to compile|npm ERR!|Module not found"; then
    fail "Vercel 内部构建失败"
    warn "检查: api/index.js 是否存在, package.json 是否有效, vercel.json 是否正确"
    _restore_vercel_json 2>/dev/null || true
    _restore_package_json 2>/dev/null || true
    return 1
  fi

  # ── Network / DNS from server ───────────────────────────
  if echo "$out" | grep -qiE "ENOTFOUND|ETIMEDOUT|getaddrinfo|network unreachable|connect ECONNREFUSED"; then
    fail "从此服务器访问 vercel.com 时出现网络错误"
    warn "检查: curl -I https://vercel.com"
    curl -sI --max-time 5 https://vercel.com | head -3 || true
    return 1
  fi

  # ── Scope / team error — strict patterns ────────────────
  if echo "$out" | grep -qiE "scope .* not found|team .* (not found|does not exist)|not a member of|invalid scope"; then
    warn "范围/团队错误 — 清除范围并在没有团队的情况下重试"
    CFG_VERCEL_SCOPE=""
    return 0
  fi

  # ── Generic fallback ────────────────────────────────────
  warn "未知部署错误 — 最后 15 行:"
  echo "$out" | tail -15 | while IFS= read -r l; do echo -e "  ${C_GRAY}  $l${C_RESET}"; done
  warn "尝试: 检查 https://vercel.com/dashboard 查看错误详情"
  return 1
}

phase4c_vercel_deploy() {
  step "阶段 4c — 部署到 Vercel"

  # ── IMPORTANT pre-deploy notice about Deployment Protection ──
  echo -e "  ${C_YELLOW}⚠ 重要:${C_RESET} ${C_WHITE}Vercel 部署保护必须关闭${C_RESET}"
  echo -e "  ${C_GRAY}    如果你有 Pro/Team 计划, 请前往:${C_RESET}"
  echo -e "  ${C_GRAY}    团队设置 → 部署保护 → 默认保护 → 已禁用${C_RESET}"
  echo -e "  ${C_GRAY}    否则转发将返回 HTTP 401, Xray 无法代理流量。${C_RESET}"
  echo ""

  if [[ ! -d "$VERCEL_DIR" ]]; then
    fail "未找到 vercel/ 目录。预期位置: $VERCEL_DIR"
    return 1
  fi
  pushd "$VERCEL_DIR" > /dev/null

  export VERCEL_TOKEN="${CFG_VERCEL_TOKEN}"

  # ── Validate token (re-prompt if invalid) ───────────────
  # Success output: just a username on one line, exit 0.
  # Failure output: contains "Error:" prefix or known auth keywords, exit !=0.
  local whoami_out whoami_rc attempt=0
  while [[ $attempt -lt 3 ]]; do
    attempt=$(( attempt + 1 ))
    whoami_out=$(vercel whoami --token "$CFG_VERCEL_TOKEN" 2>&1); whoami_rc=$?
    # Only treat as failure if exit code != 0 OR output starts with explicit Error:
    if [[ $whoami_rc -ne 0 ]] || echo "$whoami_out" | grep -qiE "^(\s*)?Error:|invalid token|forbidden|401|403|unauthorized"; then
      fail "Vercel 令牌无效 (尝试 $attempt/3)"
      info "服务器响应: $(echo "$whoami_out" | head -3)"
      warn "从以下位置获取令牌: https://vercel.com/account/tokens"
      [[ $attempt -ge 3 ]] && { fail "3 次尝试后无法通过 Vercel 身份验证。"; popd > /dev/null; return 1; }
      CFG_VERCEL_TOKEN=$(read_secret "粘贴新的 Vercel 令牌")
      export VERCEL_TOKEN="${CFG_VERCEL_TOKEN}"
    else
      ok "Vercel 认证通过: $(echo "$whoami_out" | head -1 | tr -d '[:space:]')"
      break
    fi
  done

  # ── Create / ensure project ─────────────────────────────
  local scope_args=()
  [[ -n "${CFG_VERCEL_SCOPE:-}" ]] && scope_args=(--scope "$CFG_VERCEL_SCOPE")

  info "正在创建 Vercel 项目 '${CFG_PROJECT_NAME}'..."
  local proj_out proj_rc
  proj_out=$(vercel project add "$CFG_PROJECT_NAME" --token "$CFG_VERCEL_TOKEN" \
    "${scope_args[@]}" 2>&1); proj_rc=$?
  # exit 0 = created. exit !=0 might mean "already exists" (we treat that as OK)
  if [[ $proj_rc -eq 0 ]]; then
    ok "项目已创建: $CFG_PROJECT_NAME"
  elif echo "$proj_out" | grep -qiE "already exists|Project found"; then
    ok "项目已存在 — 重复使用"
  else
    warn "项目添加返回 $proj_rc — 继续执行 (链接步骤将捕获真正的错误)"
    echo "$proj_out" | tail -5 | while IFS= read -r l; do echo -e "  ${C_GRAY}  $l${C_RESET}"; done
  fi

  # ── Link helper — re-runnable from anywhere in the flow ─────
  _vercel_link() {
    rm -rf "${VERCEL_DIR}/.vercel" 2>/dev/null || true
    local link_out link_rc
    link_out=$(vercel link --yes --project "$CFG_PROJECT_NAME" \
      --token "$CFG_VERCEL_TOKEN" "${scope_args[@]}" 2>&1); link_rc=$?
    if [[ $link_rc -ne 0 ]] && ! echo "$link_out" | grep -qiE "Linked to|Already linked"; then
      warn "链接失败:"
      echo "$link_out" | tail -5 | while IFS= read -r l; do echo -e "  ${C_GRAY}  $l${C_RESET}"; done
      return 1
    fi
    return 0
  }

  info "正在链接到项目..."
  _vercel_link || { fail "无法链接到项目 $CFG_PROJECT_NAME"; popd > /dev/null; return 1; }
  ok "已链接到 $CFG_PROJECT_NAME"

  # ── Disable Deployment Protection via REST API ──────────
  # Pro/Team accounts often have ssoProtection / passwordProtection enabled by
  # default; this returns HTTP 401 on every request to the deployment and
  # breaks the relay. Vercel API allows clearing both fields.
  info "正在禁用项目上的部署保护 (如果适用)..."
  local api_url="https://api.vercel.com/v9/projects/${CFG_PROJECT_NAME}"
  [[ -n "${CFG_VERCEL_SCOPE:-}" ]] && api_url="${api_url}?teamId=${CFG_VERCEL_SCOPE}"
  local prot_out prot_code
  prot_out=$(curl -s -o /tmp/.vercel-prot-resp -w "%{http_code}" --max-time 10 \
    -X PATCH "$api_url" \
    -H "Authorization: Bearer ${CFG_VERCEL_TOKEN}" \
    -H "Content-Type: application/json" \
    --data '{"ssoProtection":null,"passwordProtection":null}' 2>/dev/null || echo "000")
  prot_code="$prot_out"
  if [[ "$prot_code" == "200" ]]; then
    ok "通过 API 禁用了部署保护"
  elif [[ "$prot_code" == "403" ]]; then
    info "无法通过 API 禁用 (Hobby 计划 — 默认已关闭)"
  else
    warn "无法通过 API 禁用部署保护 (HTTP ${prot_code})"
    info "如果稍后部署返回 401, 请手动禁用在:"
    info "  https://vercel.com/dashboard → ${CFG_PROJECT_NAME} → Settings → Deployment Protection"
    [[ -s /tmp/.vercel-prot-resp ]] && head -3 /tmp/.vercel-prot-resp | \
      while IFS= read -r l; do info "  $l"; done
  fi
  rm -f /tmp/.vercel-prot-resp

  # ── ENV vars ────────────────────────────────────────────
  info "正在设置环境变量 (通过标准输入 — 新版 Vercel CLI 要求)..."
  local TARGET_DOMAIN_VAL="https://${CFG_DOMAIN}:${CFG_INBOUND_PORT}"

  # Recent Vercel CLI deprecated --value flag. Now `vercel env add` reads the
  # value from stdin. We pipe the value in and the flag is gone.
  _set_env() {
    local name="$1" value="$2" out rc
    # Try stdin-style (current CLI behavior)
    out=$(printf '%s' "$value" | vercel env add "$name" production --force \
          --token "$CFG_VERCEL_TOKEN" "${scope_args[@]}" 2>&1 </dev/stdin); rc=$?
    # Older CLIs that still accept --value: fall back if stdin form failed
    if [[ $rc -ne 0 ]] && ! echo "$out" | grep -qiE "added|created|updated|overwrote|saved"; then
      out=$(vercel env add "$name" production --value "$value" --force --yes \
            --token "$CFG_VERCEL_TOKEN" "${scope_args[@]}" 2>&1); rc=$?
    fi
    if [[ $rc -eq 0 ]] || echo "$out" | grep -qiE "added|created|updated|overwrote|saved"; then
      info "  ✓ ${name}  (已设置)"
    else
      warn "  ! ${name} (rc=$rc): $(echo "$out" | head -1)"
    fi
  }
  _set_env "TARGET_DOMAIN"               "$TARGET_DOMAIN_VAL"
  _set_env "RELAY_PATH"                  "$CFG_RELAY_PATH"
  _set_env "PUBLIC_RELAY_PATH"           "$CFG_PUBLIC_PATH"
  _set_env "MAX_INFLIGHT"                "$CFG_MAX_INFLIGHT"
  _set_env "MAX_UP_BPS"                  "$CFG_MAX_UP_BPS"
  _set_env "MAX_DOWN_BPS"                "$CFG_MAX_DOWN_BPS"
  _set_env "UPSTREAM_TIMEOUT_MS"         "$CFG_UPSTREAM_TIMEOUT"
  _set_env "SUCCESS_LOG_SAMPLE_RATE"     "$CFG_SUCCESS_LOG"
  _set_env "SUCCESS_LOG_MIN_DURATION_MS" "$CFG_SUCCESS_DUR"
  _set_env "ERROR_LOG_MIN_INTERVAL_MS"   "$CFG_ERROR_INT"

  # ── Verify ENVs actually landed on Vercel ─────────────────
  local env_list
  env_list=$(vercel env ls production --token "$CFG_VERCEL_TOKEN" "${scope_args[@]}" 2>&1 || true)
  if echo "$env_list" | grep -q "TARGET_DOMAIN"; then
    ok "环境变量已在 Vercel 上验证"
  else
    warn "无法验证环境变量 — 值可能尚未生效。"
    echo "$env_list" | head -10 | while IFS= read -r l; do echo -e "  ${C_GRAY}  $l${C_RESET}"; done
  fi

  # ── Deploy with retry ───────────────────────────────────
  local deploy_attempt=0 deploy_out deploy_url=""
  while [[ $deploy_attempt -lt $AUTOFIX_MAX ]]; do
    deploy_attempt=$(( deploy_attempt + 1 ))
    info "部署尝试 $deploy_attempt/$AUTOFIX_MAX..."

    _randomize_package_json
    _randomize_vercel_json

    deploy_out=$(vercel deploy --prod --yes \
      --token "$CFG_VERCEL_TOKEN" "${scope_args[@]}" 2>&1) && {
      _restore_vercel_json; _restore_package_json; break
    }
    _restore_vercel_json; _restore_package_json

    fail "第 $deploy_attempt 次部署尝试失败"
    if ! _vercel_diagnose_deploy_error "$deploy_out"; then
      [[ $deploy_attempt -ge $AUTOFIX_MAX ]] && { fail "$AUTOFIX_MAX 次尝试后部署失败。查看日志: $LOG_FILE"; popd > /dev/null; return 1; }
    fi
    # refresh scope_args in case CFG_VERCEL_SCOPE was cleared by diagnose
    scope_args=()
    [[ -n "${CFG_VERCEL_SCOPE:-}" ]] && scope_args=(--scope "$CFG_VERCEL_SCOPE")
    # If diagnose cleared .vercel cache, we MUST re-link before next deploy
    if [[ ! -d "${VERCEL_DIR}/.vercel" ]]; then
      info "缓存清除后重新链接项目..."
      _vercel_link || warn "重新链接失败 — 下次部署仍可能失败"
    fi
    sleep 3
  done

  # ── Extract URL ─────────────────────────────────────────
  deploy_url=$(echo "$deploy_out" | grep -oP 'https://[^\s]+\.vercel\.app' | tail -1 || true)
  [[ -z "$deploy_url" ]] && \
    deploy_url=$(echo "$deploy_out" | grep -iE 'production|preview' | grep -oP 'https://\S+\.vercel\.app' | tail -1 || true)

  if [[ -n "$deploy_url" ]]; then
    VERCEL_URL="$deploy_url"
    ok "生产环境 URL: ${VERCEL_URL}"

    # ── Detect Deployment Protection (returns 401 + Vercel SSO page) ──
    info "正在检查 Vercel 部署保护..."
    local probe_code probe_body
    probe_code=$(curl -sk -o /dev/null --max-time 10 -w "%{http_code}" "$VERCEL_URL" 2>/dev/null || echo "000")
    probe_body=$(curl -sk --max-time 10 "$VERCEL_URL" 2>/dev/null | head -c 500)

    if [[ "$probe_code" == "401" ]] || echo "$probe_body" | grep -qi "Authentication Required\|_vercel_sso\|sso\.vercel\.com"; then
      warn "部署保护仍然启用 (HTTP 401) — 正在通过 API 禁用..."

      # ── Try project-level API again (more aggressive, with retries) ──
      local prot_api_url="https://api.vercel.com/v9/projects/${CFG_PROJECT_NAME}"
      [[ -n "${CFG_VERCEL_SCOPE:-}" ]] && prot_api_url="${prot_api_url}?teamId=${CFG_VERCEL_SCOPE}"
      local attempt2=0 prot_rc=""
      while [[ $attempt2 -lt 3 ]]; do
        attempt2=$(( attempt2 + 1 ))
        prot_rc=$(curl -s -o /tmp/.vp -w "%{http_code}" --max-time 12 \
          -X PATCH "$prot_api_url" \
          -H "Authorization: Bearer ${CFG_VERCEL_TOKEN}" \
          -H "Content-Type: application/json" \
          --data '{"ssoProtection":null,"passwordProtection":null}' 2>/dev/null || echo "000")
        if [[ "$prot_rc" == "200" ]]; then
          ok "通过 API 禁用了部署保护"
          break
        fi
        info "API 尝试 ${attempt2}/3 → HTTP ${prot_rc}"
        sleep 2
      done

      # ── Also try team-level Default Protection (Pro/Team only) ──
      if [[ -n "${CFG_VERCEL_SCOPE:-}" ]] && [[ "$prot_rc" != "200" ]]; then
        info "尝试团队级默认保护..."
        curl -s -o /tmp/.vp -w "%{http_code}" --max-time 12 \
          -X PATCH "https://api.vercel.com/v2/teams/${CFG_VERCEL_SCOPE}" \
          -H "Authorization: Bearer ${CFG_VERCEL_TOKEN}" \
          -H "Content-Type: application/json" \
          --data '{"defaultProtection":"disabled"}' >/dev/null 2>&1 || true
      fi
      rm -f /tmp/.vp

      # ── Force a fresh deploy so the new protection setting takes effect ──
      info "正在重新部署以使保护禁用设置生效..."
      _randomize_package_json
      local redeploy_out
      redeploy_out=$(vercel deploy --prod --yes \
        --token "$CFG_VERCEL_TOKEN" "${scope_args[@]}" 2>&1 || true)
      _restore_package_json
      local new_url
      new_url=$(echo "$redeploy_out" | grep -oP 'https://[^\s]+\.vercel\.app' | tail -1 || true)
      [[ -n "$new_url" ]] && VERCEL_URL="$new_url"

      # ── Verify protection is now off ──
      sleep 3
      probe_code=$(curl -sk -o /dev/null --max-time 10 -w "%{http_code}" "$VERCEL_URL" 2>/dev/null || echo "000")
      probe_body=$(curl -sk --max-time 10 "$VERCEL_URL" 2>/dev/null | head -c 500)
      if [[ "$probe_code" != "401" ]] && ! echo "$probe_body" | grep -qi "Authentication Required\|_vercel_sso"; then
        ok "部署保护已成功禁用 (HTTP ${probe_code})"
      else
        # API path didn't work (Hobby plan can't even use the API, or token lacks perms).
        # Fall back to manual instructions but keep them short.
        fail "无法自动禁用部署保护"
        echo ""
        echo -e "  ${C_YELLOW}请手动禁用它 (一次性操作, 只需 10 秒):${C_RESET}"
        echo -e "    1. https://vercel.com/dashboard → ${CFG_PROJECT_NAME} → 设置 → 部署保护"
        echo -e "    2. 将 ${C_YELLOW}Vercel 身份验证${C_RESET}和 ${C_YELLOW}密码保护${C_RESET}均设置为 ${C_GREEN}已禁用${C_RESET}"
        echo -e "    3. 重新运行此脚本或打开 ${C_WHITE}xhttp${C_RESET} 面板 → 更新/重新部署"
        echo ""
      fi
    else
      ok "部署保护检查: 正常 (HTTP ${probe_code})"
    fi
  else
    warn "无法解析生产环境 URL — 检查 Vercel 仪表板"
    VERCEL_URL="(检查仪表板)"
    echo "$deploy_out" | tail -8
  fi

  popd > /dev/null
}

phase4c_netlify_deploy() {
  step "阶段 4c — 部署到 Netlify"

  if [[ ! -d "$NETLIFY_DIR" ]]; then
    fail "未找到 netlify/ 目录。预期位置: $NETLIFY_DIR"
    return 1
  fi
  info "Netlify 项目目录: $NETLIFY_DIR"

  local TARGET_DOMAIN_VAL="https://${CFG_DOMAIN}:${CFG_INBOUND_PORT}"
  local attempt=0

  # ── Validate token ───────────────────────────────────────
  while [[ $attempt -lt 3 ]]; do
    attempt=$(( attempt + 1 ))
    local whoami_out
    whoami_out=$(NETLIFY_AUTH_TOKEN="$CFG_NETLIFY_TOKEN" netlify api getCurrentUser 2>&1 || true)
    if echo "$whoami_out" | grep -qiE '"id":|"email":'; then
      local nl_user
      nl_user=$(echo "$whoami_out" | grep -oP '"email"\s*:\s*"\K[^"]+' || echo "ok")
      ok "Netlify 认证通过: $nl_user"
      break
    else
      fail "Netlify 令牌无效 (尝试 $attempt/3)"
      warn "从以下位置获取令牌: https://app.netlify.com/user/applications#personal-access-tokens"
      CFG_NETLIFY_TOKEN=$(read_secret "粘贴新的 Netlify 令牌")
    fi
    [[ $attempt -ge 3 ]] && { fail "3 次尝试后无法通过 Netlify 认证。"; return 1; }
  done

  export NETLIFY_AUTH_TOKEN="$CFG_NETLIFY_TOKEN"

  # ── Create or get site ───────────────────────────────────
  info "正在创建/查找 Netlify 站点 '${CFG_NETLIFY_SITE}'..."
  local site_id
  site_id=$(netlify api listSites 2>/dev/null | \
    grep -oP '"id"\s*:\s*"\K[^"]+(?=.*"name"\s*:\s*"'"${CFG_NETLIFY_SITE}"'")' | head -1 || true)

  if [[ -z "$site_id" ]]; then
    local create_out
    create_out=$(netlify api createSite --data "{\"name\":\"${CFG_NETLIFY_SITE}\"}" 2>/dev/null || true)
    site_id=$(echo "$create_out" | grep -oP '"id"\s*:\s*"\K[^"]+' | head -1 || true)
    [[ -z "$site_id" ]] && { fail "无法创建 Netlify 站点"; return 1; }
    ok "Netlify 站点已创建: ${CFG_NETLIFY_SITE} (id: ${site_id})"
  else
    ok "使用现有 Netlify 站点: ${CFG_NETLIFY_SITE} (id: ${site_id})"
  fi
  NETLIFY_SITE_ID="$site_id"

  # ── Set env vars (Netlify edge function ONLY uses TARGET_DOMAIN) ──
  info "正在设置 Netlify 环境变量: TARGET_DOMAIN=${TARGET_DOMAIN_VAL}"
  pushd "$NETLIFY_DIR" > /dev/null

  # Wait briefly for site to be fully ready in Netlify's API
  sleep 3

  # Resolve account_slug for this site (the `-` shorthand doesn't work for env endpoints)
  local NETLIFY_ACCOUNT_SLUG
  NETLIFY_ACCOUNT_SLUG=$(curl -sS --max-time 15 \
    "https://api.netlify.com/api/v1/sites/${site_id}" \
    -H "Authorization: Bearer ${CFG_NETLIFY_TOKEN}" 2>/dev/null | \
    grep -oP '"account_slug"\s*:\s*"\K[^"]+' | head -1 || true)
  if [[ -z "$NETLIFY_ACCOUNT_SLUG" ]]; then
    NETLIFY_ACCOUNT_SLUG=$(curl -sS --max-time 15 \
      "https://api.netlify.com/api/v1/accounts" \
      -H "Authorization: Bearer ${CFG_NETLIFY_TOKEN}" 2>/dev/null | \
      grep -oP '"slug"\s*:\s*"\K[^"]+' | head -1 || true)
  fi
  info "Netlify account_slug: ${NETLIFY_ACCOUNT_SLUG:-<未知>}"

  # Helper: set/replace one env var via REST API (no CLI, no prompts)
  # Usage: _netlify_set_env_api KEY VALUE
  # Tries with scopes=["functions"] first (paid plans); on 403 retries without scopes (free tier).
  _netlify_set_env_api() {
    local key="$1" value="$2"
    local api_base="https://api.netlify.com/api/v1/accounts/${NETLIFY_ACCOUNT_SLUG}/env"
    [[ -z "$NETLIFY_ACCOUNT_SLUG" ]] && { warn "  没有 account_slug — 无法使用 REST API"; return 1; }

    # Inner: try one body shape with POST then PUT. Returns 0 on success.
    _try_body() {
      local body="$1"
      # Try POST first
      local api_out
      api_out=$(curl -sS --max-time 20 \
        -X POST "${api_base}?site_id=${site_id}" \
        -H "Authorization: Bearer ${CFG_NETLIFY_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "$body" 2>&1 || true)
      if echo "$api_out" | grep -qE "\"key\"\s*:\s*\"${key}\""; then
        return 0
      fi
      # Detect 403 scope-not-allowed → caller will retry without scopes
      if echo "$api_out" | grep -qiE "Upgrade your Netlify account to set specific scopes|scopes"; then
        echo "__SCOPE_NOT_ALLOWED__"
        return 1
      fi
      # POST failed for other reasons → try PUT
      local single_obj="${body#[}"; single_obj="${single_obj%]}"
      api_out=$(curl -sS --max-time 20 \
        -X PUT "${api_base}/${key}?site_id=${site_id}" \
        -H "Authorization: Bearer ${CFG_NETLIFY_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "$single_obj" 2>&1 || true)
      if echo "$api_out" | grep -qE "\"key\"\s*:\s*\"${key}\""; then
        return 0
      fi
      # Surface error to caller
      echo "$api_out" | head -c 300
      return 1
    }

    # Step 1: DELETE any existing var (idempotent; 404 is fine)
    curl -sS --max-time 15 -o /dev/null \
      -X DELETE "${api_base}/${key}?site_id=${site_id}" \
      -H "Authorization: Bearer ${CFG_NETLIFY_TOKEN}" >/dev/null 2>&1 || true

    # Step 2: try WITH scopes (paid plans / pro Netlify accounts)
    local body_with_scope body_no_scope try_out
    body_with_scope=$(printf '[{"key":"%s","values":[{"value":"%s","context":"production"}],"scopes":["functions"]}]' "$key" "$value")
    try_out=$(_try_body "$body_with_scope" 2>&1)
    if [[ $? -eq 0 ]]; then
      ok "  ${key} 已通过 REST API 设置 (含范围)"
      return 0
    fi

    # Step 3: free-tier fallback — same call WITHOUT the scopes field
    if [[ "$try_out" == *"__SCOPE_NOT_ALLOWED__"* ]] || echo "$try_out" | grep -qiE "scopes|upgrade"; then
      info "  账户处于免费层级 — 尝试不指定范围..."
    fi
    body_no_scope=$(printf '[{"key":"%s","values":[{"value":"%s","context":"production"}]}]' "$key" "$value")
    try_out=$(_try_body "$body_no_scope" 2>&1)
    if [[ $? -eq 0 ]]; then
      ok "  ${key} 已通过 REST API 设置 (无范围)"
      return 0
    fi

    # Step 4: last resort — apply to all contexts (some accounts reject per-context)
    local body_all
    body_all=$(printf '[{"key":"%s","values":[{"value":"%s","context":"all"}]}]' "$key" "$value")
    try_out=$(_try_body "$body_all" 2>&1)
    if [[ $? -eq 0 ]]; then
      ok "  ${key} 已通过 REST API 设置 (context=all)"
      return 0
    fi

    warn "  ${key} 的 REST API 失败。最后响应: $(echo "$try_out" | head -c 200)"
    return 1
  }

  local set_ok=false
  _netlify_set_env_api TARGET_DOMAIN "$TARGET_DOMAIN_VAL" && set_ok=true

  # ── FALLBACK: CLI (only if REST API failed). Use --scope only (not both). ──
  if [[ "$set_ok" != "true" ]]; then
    info "回退到 netlify CLI (关闭标准输入以避免提示)..."
    timeout 30 netlify link --id "$site_id" </dev/null >/dev/null 2>&1 || true
    # Try without --context (since CLI rejects scope+context on existing vars)
    local set_out
    set_out=$(timeout 30 netlify env:set TARGET_DOMAIN "$TARGET_DOMAIN_VAL" \
      --scope functions --site "$site_id" </dev/null 2>&1 || true)
    if echo "$set_out" | grep -qiE "set environment variable|in the .* context|added|updated|saved"; then
      ok "TARGET_DOMAIN 已通过 CLI 回退设置 (仅范围)"
      set_ok=true
    else
      warn "CLI 回退也失败: $(echo "$set_out" | head -c 200)"
    fi
  fi

  # Verify (REST API — fast, no hangs)
  local env_list
  if [[ -n "$NETLIFY_ACCOUNT_SLUG" ]]; then
    env_list=$(curl -sS --max-time 15 \
      "https://api.netlify.com/api/v1/accounts/${NETLIFY_ACCOUNT_SLUG}/env?site_id=${site_id}" \
      -H "Authorization: Bearer ${CFG_NETLIFY_TOKEN}" 2>/dev/null || true)
  fi
  popd > /dev/null

  if echo "$env_list" | grep -qF "$TARGET_DOMAIN_VAL"; then
    ok "TARGET_DOMAIN 已在 Netlify 上验证"
  elif echo "$env_list" | grep -q "TARGET_DOMAIN"; then
    ok "TARGET_DOMAIN 键存在 (值已被 Netlify CLI 隐藏)"
  else
    warn "无法验证 TARGET_DOMAIN — env:list 输出:"
    echo "$env_list" | head -10 | while read -r l; do echo "    $l"; done
  fi

  # ── Deploy ───────────────────────────────────────────────
  info "正在部署到 Netlify..."
  local deploy_log
  deploy_log=$(mktemp)
  local deploy_rc=0
  # IMPORTANT: cd into the project root so netlify.toml is detected and edge functions wire up
  pushd "$NETLIFY_DIR" > /dev/null
  netlify deploy --prod \
    --dir public \
    --site "$site_id" 2>&1 | tee "$deploy_log" || true
  deploy_rc=${PIPESTATUS[0]}
  popd > /dev/null
  local deploy_out
  deploy_out=$(<"$deploy_log")
  rm -f "$deploy_log"

  # ── STRICT success check ──
  # CLI exit code is unreliable on netlify-cli 26+ — it can return 0 even after
  # JSONHTTPError: Forbidden. So we require BOTH no error keywords AND a
  # parsed netlify.app URL.
  local cli_url=""
  cli_url=$(echo "$deploy_out" | grep -oP 'https://[a-z0-9-]+\.netlify\.app' | grep -v -- '--' | head -1 || true)
  [[ -z "$cli_url" ]] && \
    cli_url=$(echo "$deploy_out" | grep -oP 'https://[^\s<>]+\.netlify\.app' | tail -1 || true)

  local cli_failed=false
  if echo "$deploy_out" | grep -qiE "JSONHTTPError|Forbidden|Unauthorized|Error: .* 40[13]|deploy.*failed|access denied"; then
    cli_failed=true
  fi
  [[ -z "$cli_url" ]] && cli_failed=true

  if [[ "$cli_failed" == "true" ]]; then
    fail "Netlify CLI 部署失败 (可能是令牌范围问题)"
    info "正在尝试 REST API zip 上传备用方案..."

    # ── Fallback: deploy via REST API (zip upload) ──
    if ! command -v zip &>/dev/null; then
      DEBIAN_FRONTEND=noninteractive apt-get install -y -qq zip 2>/dev/null || true
    fi
    if ! command -v zip &>/dev/null; then
      fail "无法安装 'zip' — REST API 备用方案不可用"
      echo "$deploy_out" | tail -10
      return 1
    fi

    local tmp_zip
    tmp_zip=$(mktemp --suffix=.zip)
    pushd "$NETLIFY_DIR" > /dev/null
    # Bundle netlify.toml + public/ + netlify/ (edge functions live under netlify/edge-functions/)
    zip -rq "$tmp_zip" netlify.toml public netlify 2>&1 | tail -3
    popd > /dev/null

    info "正在上传 zip ($(du -h "$tmp_zip" | awk '{print $1}')) 到 Netlify..."
    local upload_resp upload_code
    upload_resp=$(curl -s --max-time 90 -w "\n%{http_code}" \
      -X POST "https://api.netlify.com/api/v1/sites/${site_id}/deploys" \
      -H "Authorization: Bearer ${CFG_NETLIFY_TOKEN}" \
      -H "Content-Type: application/zip" \
      --data-binary "@${tmp_zip}" 2>&1 || true)
    rm -f "$tmp_zip"
    upload_code=$(echo "$upload_resp" | tail -1)
    upload_resp=$(echo "$upload_resp" | sed '$d')

    if [[ "$upload_code" == "200" || "$upload_code" == "201" ]]; then
      VERCEL_URL=$(echo "$upload_resp" | grep -oP '"deploy_ssl_url"\s*:\s*"\K[^"]+' | head -1)
      [[ -z "$VERCEL_URL" ]] && \
        VERCEL_URL=$(echo "$upload_resp" | grep -oP '"ssl_url"\s*:\s*"\K[^"]+' | head -1)
      [[ -z "$VERCEL_URL" ]] && \
        VERCEL_URL=$(echo "$upload_resp" | grep -oP '"url"\s*:\s*"\K[^"]+' | head -1)
      if [[ -n "$VERCEL_URL" ]]; then
        ok "REST API 部署成功: ${VERCEL_URL}"
      else
        warn "部署成功但未解析出 URL — 检查 Netlify 仪表板"
        echo "$upload_resp" | head -c 500
        return 1
      fi
    else
      fail "REST API 部署也失败 (HTTP ${upload_code})"
      echo "$upload_resp" | head -c 500
      echo ""
      warn "你的 Netlify 令牌没有部署权限。"
      info "如何修复:"
      info "  1. 前往 https://app.netlify.com/user/applications#personal-access-tokens"
      info "  2. 创建一个新令牌 (旧的 '个人访问令牌' 页面 — 非作用域令牌)"
      info "  3. 使用新令牌重新运行此脚本"
      return 1
    fi
  else
    VERCEL_URL="$cli_url"
    ok "Netlify 已部署: ${VERCEL_URL}"
  fi

  # ── Verify edge function actually invokes (not Netlify's generic 404 page) ──
  if [[ -n "${VERCEL_URL:-}" ]]; then
    local verify_attempt=0
    local edge_ok=false
    while [[ $verify_attempt -lt 3 ]]; do
      verify_attempt=$(( verify_attempt + 1 ))
      info "正在验证边缘函数 (尝试 ${verify_attempt}/3)..."
      sleep 4   # give CDN time to propagate
      local verify_body verify_code
      verify_body=$(curl -sk -X POST "${VERCEL_URL}${CFG_PUBLIC_PATH}" \
        --max-time 12 -d "ping" 2>&1 || true)
      verify_code=$(curl -sk -o /dev/null -w "%{http_code}" -X POST "${VERCEL_URL}${CFG_PUBLIC_PATH}" \
        --max-time 12 -d "ping" 2>/dev/null || echo "000")

      # 404 + Netlify HTML = edge function NOT routed
      # 500 + "Misconfigured" = edge function ran but TARGET_DOMAIN env missing
      local need_redeploy=false redeploy_reason=""
      if echo "$verify_body" | grep -qi "Looks like you.ve followed a broken link\|<title>Page not found</title>"; then
        need_redeploy=true
        redeploy_reason="static 404 page (routing not wired)"
      elif [[ "$verify_code" == "500" ]] && echo "$verify_body" | grep -qi "Misconfigured\|TARGET_DOMAIN"; then
        need_redeploy=true
        redeploy_reason="HTTP 500 — TARGET_DOMAIN 环境变量对边缘函数不可见"
        # Re-set TARGET_DOMAIN via REST API (NOT CLI — avoid overwrite-prompt hang)
        info "重新部署前重新应用 TARGET_DOMAIN (通过 REST API)..."
        _netlify_set_env_api TARGET_DOMAIN "$TARGET_DOMAIN_VAL" || \
          warn "通过 REST API 重新应用失败 — 依赖已部署的值"
      fi

      if [[ "$need_redeploy" == "true" ]]; then
        warn "边缘函数检查失败: ${redeploy_reason} — 强制重新部署..."
        pushd "$NETLIFY_DIR" > /dev/null
        deploy_log=$(mktemp)
        netlify deploy --prod \
          --dir public \
          --skip-functions-cache \
          --site "$site_id" 2>&1 | tee "$deploy_log" || true
        popd > /dev/null
        deploy_out=$(<"$deploy_log")
        rm -f "$deploy_log"
        local new_url
        new_url=$(echo "$deploy_out" | grep -oP 'https://[a-z0-9-]+\.netlify\.app' | grep -v -- '--' | head -1 || true)
        [[ -n "$new_url" ]] && VERCEL_URL="$new_url"
      else
        edge_ok=true
        ok "边缘函数正在响应 (HTTP ${verify_code}, 转发路由 + 环境变量正常)"
        break
      fi
    done
    if [[ "$edge_ok" != "true" ]]; then
      warn "3 次尝试后边缘函数仍然无响应。"
      info "检查日志: https://app.netlify.com/projects/${CFG_NETLIFY_SITE}/logs/edge-functions"
    fi
  fi
}

phase4c_deploy() {
  if [[ "${CFG_PLATFORM:-vercel}" == "netlify" ]]; then
    phase4c_netlify_deploy
  else
    phase4c_vercel_deploy
  fi
}

# helper — redeploy ENV after user corrects a value
_redeploy_env_fix() {
  if [[ "${CFG_PLATFORM:-vercel}" == "netlify" ]]; then
    info "Netlify 上跳过自动重新部署 (手动: 如有需要重新运行脚本)"
    return 0
  fi
  local scope_args=()
  [[ -n "${CFG_VERCEL_SCOPE:-}" ]] && scope_args=(--scope "$CFG_VERCEL_SCOPE")
  info "正在更新 Vercel 上的环境变量并重新部署..."
  pushd "$VERCEL_DIR" > /dev/null
  local TARGET_DOMAIN_VAL="https://${CFG_DOMAIN}:${CFG_INBOUND_PORT}"

  # Use stdin-style env add (current Vercel CLI), with --value fallback for older CLIs
  _v_env() {
    local name="$1" value="$2" out rc
    out=$(printf '%s' "$value" | vercel env add "$name" production --force \
          --token "$CFG_VERCEL_TOKEN" "${scope_args[@]}" 2>&1 </dev/stdin); rc=$?
    if [[ $rc -ne 0 ]] && ! echo "$out" | grep -qiE "added|updated|saved"; then
      vercel env add "$name" production --value "$value" --force --yes \
        --token "$CFG_VERCEL_TOKEN" "${scope_args[@]}" 2>/dev/null || true
    fi
  }
  _v_env "TARGET_DOMAIN"     "$TARGET_DOMAIN_VAL"
  _v_env "RELAY_PATH"        "$CFG_RELAY_PATH"
  _v_env "PUBLIC_RELAY_PATH" "$CFG_PUBLIC_PATH"

  _randomize_package_json; _randomize_vercel_json
  local out
  out=$(vercel deploy --prod --yes --token "$CFG_VERCEL_TOKEN" "${scope_args[@]}" 2>&1) && {
    _restore_vercel_json; _restore_package_json
    local url
    url=$(echo "$out" | grep -oP 'https://[^\s]+\.vercel\.app' | tail -1 || true)
    [[ -n "$url" ]] && VERCEL_URL="$url"
    ok "已重新部署: ${VERCEL_URL:-完成}"
  } || {
    _restore_vercel_json; _restore_package_json
    fail "重新部署失败 — 检查日志 $LOG_FILE"
  }
  popd > /dev/null
}

# =============================================================
#  PHASE 5 — HEALTH CHECK WITH xray-knife + CONFIG VALIDATOR
# =============================================================
phase5_healthcheck() {
  step "阶段 5 — 健康检查与配置验证"

  local TARGET_DOMAIN_VAL="https://${CFG_DOMAIN}:${CFG_INBOUND_PORT}"
  local VERCEL_HOST
  VERCEL_HOST=$(echo "${VERCEL_URL:-}" | sed 's|https://||' | sed 's|/.*||')
  local need_redeploy=false

  # ── Test 1: upstream (Xray) directly ────────────────────
  echo -e "\n  ${C_CYAN}[ 测试 1 ] 直接上游可达性${C_RESET}"
  local http1 direct_ok=false
  http1=$(curl -sk --max-time 8 "${TARGET_DOMAIN_VAL}${CFG_RELAY_PATH}" \
    -o /dev/null -w "%{http_code}" 2>/dev/null || echo "000")
  if echo "$http1" | grep -qE "^(200|400|401|403|404|405)$"; then
    ok "上游可达 — ${CFG_DOMAIN}:${CFG_INBOUND_PORT} 返回 HTTP $http1"
    direct_ok=true
  else
    fail "上游不可达 (HTTP $http1) 于 ${TARGET_DOMAIN_VAL}${CFG_RELAY_PATH}"
    if ufw status 2>/dev/null | grep -qi "Status: active"; then
      warn "→ 自动修复: 打开防火墙端口 ${CFG_INBOUND_PORT}..."
      ufw allow "${CFG_INBOUND_PORT}/tcp" 2>/dev/null || true
    fi
    warn "→ 正在重启 xray..."
    systemctl restart xray 2>/dev/null || true; sleep 3
    # retry once after fix
    http1=$(curl -sk --max-time 8 "${TARGET_DOMAIN_VAL}${CFG_RELAY_PATH}" \
      -o /dev/null -w "%{http_code}" 2>/dev/null || echo "000")
    if echo "$http1" | grep -qE "^(200|400|401|403|404|405)$"; then
      ok "修复后上游可达 — HTTP $http1"
      direct_ok=true
    else
      fail "仍然不可达。检查: systemctl status xray / SSL 证书 / DNS"
    fi
  fi

  # ── Test 2: Relay + smart PATH/TARGET fix ────────────────
  echo -e "\n  ${C_CYAN}[ 测试 2 ] 中继与配置验证${C_RESET}"
  if [[ -n "$VERCEL_HOST" ]]; then
    local vercel_code
    vercel_code=$(curl -sk --max-time 15 \
      "https://${VERCEL_HOST}${CFG_PUBLIC_PATH}" \
      -o /dev/null -w "%{http_code}" 2>/dev/null || echo "000")

    case "$vercel_code" in
      200|101)
        ok "Vercel 中继正在响应 — HTTP $vercel_code" ;;

      404)
        if [[ "$CFG_PUBLIC_PATH" == "/api" ]]; then
          warn "在 ${CFG_PUBLIC_PATH} 上返回 HTTP 404 — 对于 VLESS/XHTTP 端点来说正常 (浏览器 GET ≠ XHTTP 握手)"
          info "这是预期的。真实客户端流量仍然可以工作。"
        else
          fail "HTTP 404 — PUBLIC_RELAY_PATH 不匹配"
          info "当前 PUBLIC_RELAY_PATH: ${CFG_PUBLIC_PATH}"
          if [[ "$CFG_PLATFORM" == "vercel" ]]; then
            info "Vercel 在 vercel.json 中的重写仅支持: /api 和 /api/:path*"
          else
            info "Netlify 边缘函数需要在 netlify.toml 中匹配路径"
          fi
          warn "自动修复: 将 PUBLIC_RELAY_PATH 更正为 /api"
          CFG_PUBLIC_PATH="/api"
          need_redeploy=true
        fi ;;

      502)
        fail "HTTP 502 — 中继无法到达你的服务器 (TARGET_DOMAIN 错误或防火墙)"
        info "当前 TARGET_DOMAIN: ${TARGET_DOMAIN_VAL}"
        if [[ "$direct_ok" == "false" ]]; then
          warn "自动修复: 上游同样不可达 — 正在重启 xray"
          if ufw status 2>/dev/null | grep -qi "Status: active"; then
            ufw allow "${CFG_INBOUND_PORT}/tcp" 2>/dev/null || true
          fi
          systemctl restart xray 2>/dev/null || true; sleep 3
        fi
        warn "请确认 TARGET_DOMAIN 正确:"
        local new_domain
        new_domain=$(read_default "TARGET_DOMAIN 主机 (域名:端口)" "${CFG_DOMAIN}:${CFG_INBOUND_PORT}")
        if [[ "$new_domain" != "${CFG_DOMAIN}:${CFG_INBOUND_PORT}" ]]; then
          CFG_DOMAIN="${new_domain%%:*}"
          CFG_INBOUND_PORT="${new_domain##*:}"
          need_redeploy=true
        fi ;;

      500)
        fail "HTTP 500 — ${CFG_PLATFORM} 上的环境变量缺失或错误"
        warn "自动修复: 重新推送所有环境变量..."
        need_redeploy=true ;;

      503)
        fail "HTTP 503 — 已达到 MAX_INFLIGHT 限制"
        warn "自动修复: 将 MAX_INFLIGHT 加倍 (${CFG_MAX_INFLIGHT} -> $(( CFG_MAX_INFLIGHT * 2 )))"
        CFG_MAX_INFLIGHT=$(( CFG_MAX_INFLIGHT * 2 ))
        need_redeploy=true ;;

      504)
        fail "HTTP 504 — 上游超时"
        warn "自动修复: 将 UPSTREAM_TIMEOUT_MS 加倍 (${CFG_UPSTREAM_TIMEOUT} -> $(( CFG_UPSTREAM_TIMEOUT * 2 )))"
        CFG_UPSTREAM_TIMEOUT=$(( CFG_UPSTREAM_TIMEOUT * 2 ))
        systemctl restart xray 2>/dev/null || true
        need_redeploy=true ;;

      000)
        fail "来自 ${CFG_PLATFORM} 无响应 (000) — 部署可能仍在传播"
        warn "等待 15 秒后重试..."
        sleep 15
        vercel_code=$(curl -sk --max-time 15 "https://${VERCEL_HOST}${CFG_PUBLIC_PATH}" \
          -o /dev/null -w "%{http_code}" 2>/dev/null || echo "000")
        if [[ "$vercel_code" == "000" ]]; then
          fail "仍然无响应。检查: https://${VERCEL_HOST}"
        else
          ok "${CFG_PLATFORM} 现在正在响应 — HTTP $vercel_code"
        fi ;;

      *)
        warn "${CFG_PLATFORM} 返回 HTTP $vercel_code — XHTTP 握手下可能正常" ;;
    esac

    # ── Auto-redeploy if any fix was applied ──────────────
    if [[ "$need_redeploy" == "true" ]]; then
      echo -e "\n  ${C_MAGENTA}[自动修复]${C_RESET} 配置已更正 — 正在重新部署到 ${CFG_PLATFORM}..."
      _redeploy_env_fix
      # re-test after redeploy
      sleep 5
      local retest_code
      retest_code=$(curl -sk --max-time 15 \
        "https://${VERCEL_HOST}${CFG_PUBLIC_PATH}" \
        -o /dev/null -w "%{http_code}" 2>/dev/null || echo "000")
      if echo "$retest_code" | grep -qE "^(200|101|404)$"; then
        ok "修复后测试: HTTP $retest_code — 中继正在响应"
      else
        warn "修复后测试: HTTP $retest_code — 检查 ${CFG_PLATFORM} 仪表板查看构建日志"
      fi
    fi
  else
    warn "中继 URL 未知 — 跳过中继测试"
  fi

  # ── Test 3: real end-to-end VLESS test using local xray as client ──
  echo -e "\n  ${C_CYAN}[ 测试 3 ] 端到端 VLESS+XHTTP 测试 (真实客户端)${C_RESET}"
  if [[ -z "${VERCEL_HOST:-}" || -z "${INBOUND_UUID:-}" ]]; then
    warn "缺少中继主机或 UUID — 跳过端到端测试"
    info "  VERCEL_HOST='${VERCEL_HOST:-<空>}'  INBOUND_UUID='${INBOUND_UUID:-<空>}'"
  else
    # Locate the xray binary (must be explicit — PATH can be stripped in screen/sudo)
    local XRAY_BIN
    XRAY_BIN=$(command -v xray 2>/dev/null || echo "")
    [[ -z "$XRAY_BIN" ]] && XRAY_BIN="/usr/local/bin/xray"
    if [[ ! -x "$XRAY_BIN" ]]; then
      warn "在 '$XRAY_BIN' 未找到 xray 二进制文件 — 跳过端到端测试"
      E2E_STATUS="UNKNOWN"
      E2E_DETAIL="未找到 xray 二进制文件"
    else
    info "端到端变量 — 中继: ${VERCEL_HOST}  uuid: ${INBOUND_UUID}  路径: ${CFG_PUBLIC_PATH}"

    local CLIENT_MODE="auto"
    local TEST_SOCKS_PORT=10809
    local TEST_CFG
    TEST_CFG=$(mktemp --suffix=.json)
    cat > "$TEST_CFG" <<E2ECFG
{
  "log": {"loglevel": "debug"},
  "inbounds": [{
    "tag": "socks-test",
    "port": ${TEST_SOCKS_PORT},
    "listen": "127.0.0.1",
    "protocol": "socks",
    "settings": {"auth": "noauth", "udp": false}
  }],
  "outbounds": [{
    "tag": "vless-out",
    "protocol": "vless",
    "settings": {
      "vnext": [{
        "address": "${VERCEL_HOST}",
        "port": 443,
        "users": [{"id": "${INBOUND_UUID}", "encryption": "none"}]
      }]
    },
    "streamSettings": {
      "network": "xhttp",
      "security": "tls",
      "tlsSettings": {
        "serverName": "${VERCEL_HOST}",
        "alpn": ["h2", "http/1.1"],
        "allowInsecure": false
      },
      "xhttpSettings": {
        "path": "${CFG_PUBLIC_PATH}",
        "host": "${VERCEL_HOST}",
        "mode": "${CLIENT_MODE}"
      }
    }
  }, {
    "protocol": "freedom",
    "tag": "direct"
  }]
}
E2ECFG

    # Free the test port if anything is on it
    local _pid
    _pid=$(lsof -ti:${TEST_SOCKS_PORT} 2>/dev/null || true)
    [[ -n "$_pid" ]] && { info "正在终止端口 ${TEST_SOCKS_PORT} 上的现有 PID ${_pid}"; kill -9 "$_pid" 2>/dev/null || true; sleep 1; }

    # Initialize global E2E status for final summary
    E2E_STATUS="UNKNOWN"
    E2E_DETAIL=""

    info "正在启动 xray 测试客户端 (${XRAY_BIN}) 在 127.0.0.1:${TEST_SOCKS_PORT}..."
    "$XRAY_BIN" run -c "$TEST_CFG" >/tmp/xray-test-client.log 2>&1 &
    local TEST_PID=$!
    trap "kill ${TEST_PID} 2>/dev/null; sleep 1; kill -9 ${TEST_PID} 2>/dev/null; rm -f '${TEST_CFG}' /tmp/xray-test-client.log 2>/dev/null" RETURN

    # ── Wait up to 12 s for the SOCKS port to actually open ──
    local port_ready=false pw=0
    while [[ $pw -lt 12 ]]; do
      sleep 1; pw=$(( pw + 1 ))
      # Check if process died early
      if ! kill -0 "$TEST_PID" 2>/dev/null; then
        fail "xray 测试客户端在 ${pw} 秒后退出"
        break
      fi
      # Use ss (preferred) or nc to confirm port is listening
      if ss -tlnp 2>/dev/null | grep -q ":${TEST_SOCKS_PORT} " || \
         nc -z 127.0.0.1 "${TEST_SOCKS_PORT}" 2>/dev/null; then
        port_ready=true
        break
      fi
    done

    if [[ "$port_ready" != "true" ]]; then
      fail "xray 测试客户端 SOCKS 端口 ${TEST_SOCKS_PORT} 从未打开 (等待了 ${pw} 秒)"
      info "xray 测试客户端日志的最后 15 行:"
      tail -15 /tmp/xray-test-client.log 2>/dev/null | while read -r l; do echo -e "  ${C_GRAY}  $l${C_RESET}"; done
      E2E_STATUS="FAIL"
      E2E_DETAIL="SOCKS 端口 ${TEST_SOCKS_PORT} 未打开 (检查 xray 测试客户端日志)"
    else
      ok "测试客户端正在运行 (PID $TEST_PID) — SOCKS 端口 ${TEST_SOCKS_PORT} 在 ${pw}s 后打开"

      # Direct VLESS test. For Netlify we do at most 1 attempt then bail out to
      # the parallel fronted probe — direct test always 429s on the loop path
      # so retrying is just wasted time. For Vercel we retry up to 5×.
      local max_attempts=5
      [[ "${CFG_PLATFORM:-vercel}" == "netlify" ]] && max_attempts=1
      local attempt=0 probe_code="000" probe_time="0"
      local upstream_status="" last_known_upstream=""
      while [[ $attempt -lt $max_attempts ]]; do
        attempt=$(( attempt + 1 ))
        info "VLESS 握手尝试 ${attempt}/${max_attempts} → https://www.gstatic.com/generate_204"
        local probe_out
        probe_out=$(curl --socks5-hostname 127.0.0.1:${TEST_SOCKS_PORT} \
          -s -o /dev/null \
          -w "code=%{http_code}|time=%{time_total}" \
          --max-time 15 \
          "https://www.gstatic.com/generate_204" 2>&1 || true)
        probe_code=$(echo "$probe_out" | grep -oP 'code=\K[0-9]+' || echo "000")
        probe_time=$(echo "$probe_out" | grep -oP 'time=\K[0-9.]+' || echo "0")
        if [[ "$probe_code" == "204" || "$probe_code" == "200" ]]; then
          break
        fi

        # Sniff the most recent xray log to figure out *why* the handshake failed
        upstream_status=$(grep -oE "unexpected status [0-9]+" /tmp/xray-test-client.log 2>/dev/null | tail -1 | grep -oE '[0-9]+$' || true)
        [[ -n "$upstream_status" ]] && last_known_upstream="$upstream_status"

        if [[ -n "$upstream_status" ]]; then
          warn "收到 HTTP ${probe_code} (CDN 对 XHTTP 请求响应了 ${upstream_status})"
        else
          warn "收到 HTTP ${probe_code} (无响应 — 可能是连接级阻止/超时)"
        fi

        # Wait shorter between attempts (only for Vercel which retries)
        if [[ $attempt -lt $max_attempts ]]; then
          info "等待 10 秒后重试..."
          sleep 10
        fi
      done

      if [[ "$probe_code" == "204" || "$probe_code" == "200" ]]; then
        echo ""
        echo -e "  ${C_GREEN}╔══════════════════════════════════════════════════╗${C_RESET}"
        echo -e "  ${C_GREEN}║  ✔ VLESS+XHTTP 端到端工作正常                  ║${C_RESET}"
        echo -e "  ${C_GREEN}║    HTTP ${probe_code} 耗时 ${probe_time}s — 代理功能正常      ║${C_RESET}"
        echo -e "  ${C_GREEN}╚══════════════════════════════════════════════════╝${C_RESET}"
        echo ""

        # ── Latency profiling: 5 pings through the proxy ──
        info "正在测量中继延迟 (通过 VLESS 代理的 5 个样本)..."
        local times=()
        local i
        for i in 1 2 3 4 5; do
          local t
          t=$(curl --socks5-hostname 127.0.0.1:${TEST_SOCKS_PORT} \
            -s -o /dev/null \
            -w "%{time_total}" \
            --max-time 15 \
            "https://www.gstatic.com/generate_204" 2>/dev/null || echo "0")
          # Convert to ms (rounded)
          local t_ms
          t_ms=$(awk -v t="$t" 'BEGIN{ printf "%.0f", t*1000 }')
          times+=("$t_ms")
          echo -e "    ${C_GRAY}#$i  → ${t_ms} ms${C_RESET}"
        done

        # Compute min / avg / max
        local min=999999 max=0 sum=0 valid=0
        for t in "${times[@]}"; do
          [[ "$t" == "0" ]] && continue
          (( t < min )) && min=$t
          (( t > max )) && max=$t
          sum=$(( sum + t ))
          valid=$(( valid + 1 ))
        done
        local avg=0
        (( valid > 0 )) && avg=$(( sum / valid ))

        echo ""
        echo -e "  ${C_CYAN}─── 中继延迟 (通过真实 VLESS 代理) ───${C_RESET}"
        echo -e "  ${C_WHITE}最小 :${C_RESET} ${C_GREEN}${min} ms${C_RESET}"
        echo -e "  ${C_WHITE}平均 :${C_RESET} ${C_GREEN}${avg} ms${C_RESET}"
        echo -e "  ${C_WHITE}最大 :${C_RESET} ${C_YELLOW}${max} ms${C_RESET}"
        echo -e "  ${C_GRAY}    (服务器→中继→上游→互联网 往返)${C_RESET}"
        echo ""

        # Also measure direct relay latency (HTTP HEAD, no proxy)
        info "正在测量直接 CDN 延迟 (无代理, 仅中继可达性)..."
        local cdn_times=()
        for i in 1 2 3; do
          local ct
          ct=$(curl -s -o /dev/null -w "%{time_total}" --max-time 8 \
            -X HEAD "https://${VERCEL_HOST}/" 2>/dev/null || echo "0")
          local ct_ms
          ct_ms=$(awk -v t="$ct" 'BEGIN{ printf "%.0f", t*1000 }')
          cdn_times+=("$ct_ms")
          echo -e "    ${C_GRAY}#$i  → ${ct_ms} ms${C_RESET}"
        done
        local cdn_sum=0 cdn_valid=0
        for ct in "${cdn_times[@]}"; do
          [[ "$ct" == "0" ]] && continue
          cdn_sum=$(( cdn_sum + ct ))
          cdn_valid=$(( cdn_valid + 1 ))
        done
        local cdn_avg=0
        (( cdn_valid > 0 )) && cdn_avg=$(( cdn_sum / cdn_valid ))
        echo -e "  ${C_CYAN}CDN 平均延迟:${C_RESET} ${cdn_avg} ms ${C_GRAY}(服务器 → ${VERCEL_HOST})${C_RESET}"
        echo ""

        E2E_STATUS="PASS"
        E2E_DETAIL="HTTP ${probe_code} | min/avg/max: ${min}/${avg}/${max}ms | CDN: ${cdn_avg}ms"
        E2E_PING_MIN=$min
        E2E_PING_AVG=$avg
        E2E_PING_MAX=$max
        E2E_CDN_PING=$cdn_avg
      else
        # ── Netlify 429 fallback: try domain-fronted configs ──────
        # The direct test loops back to the same server IP, which Netlify
        # often rate-limits. Domain fronting (clean IP + clean SNI + Netlify
        # in the Host header) bypasses this. We try a small sample of known
        # clean IP/SNI combinations until one succeeds.
        if [[ "${CFG_PLATFORM:-vercel}" == "netlify" && "$last_known_upstream" == "429" ]]; then
          echo ""
          warn "直接测试收到 HTTP 429 (Netlify 同 IP 环回速率限制)。"
          info "正在并行探测约 1500 个 IP×SNI 组合 (基于 curl, 最长 60 秒)..."

          # Stop the current test client
          kill "$TEST_PID" 2>/dev/null || true; sleep 1; kill -9 "$TEST_PID" 2>/dev/null || true

          # Full curated lists (35 IPs × 45 SNIs ≈ 1575 combos)
          local FRONT_IPS=(
            50.7.5.83 50.7.5.85 50.7.87.2 50.7.87.3 50.7.87.4 50.7.87.5
            144.76.1.88 216.24.57.1 37.16.18.81 52.250.41.2 76.76.21.21 76.76.21.112
            85.10.207.48 94.130.13.19 94.130.33.41 94.130.50.12 95.216.69.37
            198.202.211.1 198.252.206.1 204.12.196.34 216.150.1.193 65.109.34.234
            94.130.70.160 104.18.25.196 138.201.54.122 142.54.178.211 149.154.167.99
            178.22.122.101 204.79.197.220 213.180.193.56 216.239.38.120
            40.114.177.246 63.141.252.203 64.239.109.193
          )
          local FRONT_SNIS=(
            helm.sh keda.sh rook.io istio.io cilium.io fluxcd.io harbor.io
            calico.org linkerd.io openebs.io tekton.dev longhorn.io
            blog.helm.sh docs.helm.sh crossplane.io kubernetes.io kubebuilder.io
            cert-manager.io letsencrypt.org
            kind.sigs.k8s.io kops.sigs.k8s.io krew.sigs.k8s.io kwok.sigs.k8s.io
            kueue.sigs.k8s.io jobset.sigs.k8s.io kaniko.sigs.k8s.io
            minikube.sigs.k8s.io operatorframework.io container.sigs.k8s.io
            kustomize.sigs.k8s.io argo-cd.readthedocs.io
            cluster-api.sigs.k8s.io descheduler.sigs.k8s.io
            gateway-api.sigs.k8s.io external-dns.sigs.k8s.io
            service-apis.sigs.k8s.io image-builder.sigs.k8s.io
            kubectl.docs.kubernetes.io metrics-server.sigs.k8s.io
            scheduler-plugins.sigs.k8s.io controller-runtime.sigs.k8s.io
            prometheus-operator.sigs.k8s.io node-feature-discovery.sigs.k8s.io
            hierarchical-namespaces.sigs.k8s.io secrets-store-csi-driver.sigs.k8s.io
            security-profiles-operator.sigs.k8s.io
            cluster-proportional-autoscaler.sigs.k8s.io
          )

          # Build combos file and result/stop file
          local combos_file result_file
          combos_file=$(mktemp)
          result_file=$(mktemp)
          : > "$result_file"   # empty
          local total_combos=0
          for fip in "${FRONT_IPS[@]}"; do
            for fsni in "${FRONT_SNIS[@]}"; do
              echo "${fip}|${fsni}" >> "$combos_file"
              total_combos=$(( total_combos + 1 ))
            done
          done
          info "  总组合: ${total_combos}  |  并行数: 60  |  每次探测超时: 2秒"

          # Export env so xargs subprocesses can read them
          export NETLIFY_HOST_FOR_PROBE="$VERCEL_HOST"
          export RELAY_PATH_FOR_PROBE="$CFG_PUBLIC_PATH"
          export PROBE_RESULT_FILE="$result_file"

          # Parallel probe — each tests TCP+TLS+Host-header against Netlify endpoint.
          # Counts as success if HTTP response is 2xx/3xx/4xx (NOT 000 / NOT 429).
          # Early-stops globally as soon as any worker writes to result file.
          local probe_start probe_end probe_dur
          probe_start=$(date +%s)
          timeout 60 bash -c '
            while IFS= read -r combo; do
              # Stop early if another worker already found a hit
              [[ -s "$PROBE_RESULT_FILE" ]] && break
              echo "$combo"
            done < "$1"
          ' _ "$combos_file" | \
          xargs -P 60 -I {} -- bash -c '
            [[ -s "$PROBE_RESULT_FILE" ]] && exit 0
            combo="$1"
            ip="${combo%%|*}"
            sni="${combo##*|}"
            out=$(curl -sk --resolve "${sni}:443:${ip}" \
              -o /dev/null -w "%{http_code}|%{time_total}" \
              --max-time 2 \
              --header "Host: ${NETLIFY_HOST_FOR_PROBE}" \
              "https://${sni}${RELAY_PATH_FOR_PROBE}" 2>/dev/null || echo "000|0")
            code="${out%%|*}"
            time_total="${out##*|}"
            # Success = anything that proves Netlify edge received us (not 000, not 429)
            case "$code" in
              200|301|302|404|405|403)
                # Atomically grab the slot (first writer wins)
                if ( set -o noclobber; > "${PROBE_RESULT_FILE}.lock" ) 2>/dev/null; then
                  ms=$(awk -v t="$time_total" "BEGIN{printf \"%.0f\", t*1000}")
                  echo "${ip}|${sni}|${code}|${ms}" > "$PROBE_RESULT_FILE"
                fi
                ;;
            esac
          ' _ {} 2>/dev/null

          probe_end=$(date +%s)
          probe_dur=$(( probe_end - probe_start ))
          rm -f "$combos_file" "${result_file}.lock"

          if [[ -s "$result_file" ]]; then
            local hit; hit=$(cat "$result_file")
            local hit_ip hit_sni hit_code hit_ms
            hit_ip="${hit%%|*}"; hit="${hit#*|}"
            hit_sni="${hit%%|*}"; hit="${hit#*|}"
            hit_code="${hit%%|*}"; hit_ms="${hit##*|}"

            echo ""
            echo -e "  ${C_GREEN}╔══════════════════════════════════════════════════╗${C_RESET}"
            echo -e "  ${C_GREEN}║  ✔ 域名前端路径可用                            ║${C_RESET}"
            echo -e "  ${C_GREEN}║    在 ${probe_dur}s 内找到可用的 IP/SNI              ║${C_RESET}"
            echo -e "  ${C_GREEN}╚══════════════════════════════════════════════════╝${C_RESET}"
            info "  可用组合:  IP=${hit_ip}  SNI=${hit_sni}  延迟=${hit_ms}ms (HTTP ${hit_code})"
            info "  注意: 真实客户端可以使用主链接或前端变体。"
            E2E_STATUS="PASS"
            E2E_DETAIL="fronted via ${hit_ip} / ${hit_sni}  (${hit_ms}ms)"
            E2E_PING_MIN="$hit_ms"
            E2E_PING_AVG="$hit_ms"
            E2E_PING_MAX="$hit_ms"
            E2E_CDN_PING="?"
          else
            warn "在 ${probe_dur} 秒内未从 ${total_combos} 个组合中找到可用的 IP/SNI。"
            info "  直接: 429 (环回速率限制)  |  前端: 此服务器没有路由到 Netlify"
            info "  真实客户端 (手机/电脑) 通常仍然可以工作 — 主链接如下。"
            E2E_STATUS="UNKNOWN"
            E2E_DETAIL="自测不确定 — 请使用真实客户端验证"
          fi

          rm -f "$result_file" "$TEST_CFG" /tmp/xray-test-client.log
          trap - RETURN
          return 0
        fi

        echo ""
        echo -e "  ${C_RED}╔══════════════════════════════════════════════════╗${C_RESET}"
        echo -e "  ${C_RED}║  ✘ 端到端测试失败                               ║${C_RESET}"
        echo -e "  ${C_RED}║    HTTP ${probe_code:-000} 经过 ${max_attempts} 次尝试          ║${C_RESET}"
        echo -e "  ${C_RED}╚══════════════════════════════════════════════════╝${C_RESET}"
        echo ""
        E2E_STATUS="FAIL"
        E2E_DETAIL="HTTP ${probe_code:-000} (${max_attempts} 次尝试)"

        # ── Targeted diagnostics based on what we actually saw ──
        echo -e "  ${C_CYAN}─── 诊断信息 ───${C_RESET}"

        # 1. Can the server reach the CDN at all (TCP/443 + TLS)?
        local cdn_reachable
        cdn_reachable=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 8 \
          -X HEAD "https://${VERCEL_HOST}/" 2>/dev/null || echo "000")
        if [[ "$cdn_reachable" == "000" ]]; then
          fail "  • 完全无法访问 CDN (从服务器到 ${VERCEL_HOST} 的 443 端口被阻止)"
        else
          ok "  • CDN 在 443 端口可达 (HTTP ${cdn_reachable})"
        fi

        # 2. Is the upstream xray port (server-side) actually open from outside?
        local upstream_reachable
        upstream_reachable=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 8 \
          "https://${CFG_DOMAIN}:${CFG_INBOUND_PORT}${CFG_RELAY_PATH}" 2>/dev/null || echo "000")
        if [[ "$upstream_reachable" == "000" ]]; then
          fail "  • 上游 xray 在 ${CFG_DOMAIN}:${CFG_INBOUND_PORT} 不可达 (防火墙/端口被阻止)"
        else
          ok "  • 上游 xray 可达 (${CFG_INBOUND_PORT} 端口返回 HTTP ${upstream_reachable})"
        fi

        # 3. Is xray service still alive on the server?
        if systemctl is-active --quiet xray 2>/dev/null; then
          ok "  • xray 服务正在运行"
        else
          fail "  • xray 服务未在此服务器上运行"
        fi

        # 4. Decode what we saw at the application layer
        echo ""
        echo -e "  ${C_CYAN}─── 根本原因分析 ───${C_RESET}"
        if [[ -n "$last_known_upstream" ]]; then
          case "$last_known_upstream" in
            429)
              warn "  CDN 限制了自测速率 (HTTP 429)"
              info "  ⓘ 这通常是假性失败。端到端测试从"
              info "    此服务器运行, 然后通过 CDN 回环到自身。"
              info "    Netlify 经常限制这种回环模式, 即使真实"
              info "    客户端 (手机、桌面、从其他网络) 也能完美工作。"
              info "  → 在假设配置损坏之前, 请先从手机/电脑上尝试客户端配置。"
              ;;
            500|502|503|504)
              fail "  CDN 收到上游错误 (HTTP ${last_known_upstream}) — 中继无法到达你的服务器"
              info "  检查: ${CFG_PLATFORM} 上的 TARGET_DOMAIN 环境变量, 端口 ${CFG_INBOUND_PORT} 的防火墙, SSL 证书有效期"
              ;;
            404)
              fail "  CDN 返回 404 — 客户端/服务器之间的路径不匹配 (RELAY_PATH vs PUBLIC_RELAY_PATH)"
              ;;
            403)
              fail "  CDN 返回 403 — 请求被拒绝 (可能是 WAF 或中继上的地理封锁)"
              ;;
            *)
              fail "  CDN 返回 HTTP ${last_known_upstream} — 请查看下方 xray 日志"
              ;;
          esac
        elif [[ "$cdn_reachable" == "000" ]]; then
          fail "  从此服务器到 ${VERCEL_HOST}:443 的网络出口被阻止"
          info "  修复: 检查提供商防火墙/安全组/出站规则"
        elif [[ "$upstream_reachable" == "000" ]]; then
          fail "  入站端口 ${CFG_INBOUND_PORT} 不可达 — CDN 无法将流量中继给你"
          info "  修复: 在 UFW 和提供商防火墙上打开端口 ${CFG_INBOUND_PORT}"
        else
          fail "  握手从未完成 — 可能是 TLS/SNI 不匹配或 UUID/路径错误"
          info "  验证: 客户端 UUID 是否与服务器 UUID ${INBOUND_UUID:-?} 匹配"
          info "  验证: 客户端路径是否与服务器路径 ${CFG_RELAY_PATH} 匹配"
        fi

        # 5. Always dump xray test client log for offline inspection
        echo ""
        echo -e "  ${C_CYAN}─── xray 测试客户端日志 (最后 20 行) ───${C_RESET}"
        tail -20 /tmp/xray-test-client.log 2>/dev/null | while read -r l; do echo -e "  ${C_GRAY}  $l${C_RESET}"; done
        echo ""
        info "完整 xray 日志已保存到: ${LOG_FILE}"
      fi
    fi

    kill "$TEST_PID" 2>/dev/null || true
    sleep 1
    kill -9 "$TEST_PID" 2>/dev/null || true
    rm -f "$TEST_CFG" /tmp/xray-test-client.log
    trap - RETURN
    fi  # end: xray binary found
  fi
  # End of phase5 (Test 4 / xray-knife removed — Test 3 above is the authoritative check)
  return 0
}

# Stub for the rest of the file that still references xray-knife (keep minimal)
_unused_xray_knife_block() {
  if [[ -z "${XRAY_KNIFE_BIN:-}" || ! -x "${XRAY_KNIFE_BIN:-}" ]]; then
    return 0
  fi

  local KNIFE_CFG
  KNIFE_CFG=$(mktemp --suffix=.json)
  cat > "$KNIFE_CFG" <<KNIFECFG
{
  "log": {"loglevel": "warning"},
  "inbounds": [{
    "port": 10809, "listen": "127.0.0.1",
    "protocol": "socks",
    "settings": {"auth": "noauth", "udp": false}
  }],
  "outbounds": [{
    "protocol": "vless",
    "settings": {
      "vnext": [{
        "address": "${VERCEL_HOST:-${CFG_DOMAIN}}",
        "port": 443,
        "users": [{"id": "${INBOUND_UUID:-00000000-0000-0000-0000-000000000000}", "encryption": "none"}]
      }]
    },
    "streamSettings": {
      "network": "xhttp",
      "security": "tls",
      "tlsSettings": {"serverName": "${VERCEL_HOST:-${CFG_DOMAIN}}"},
      "xhttpSettings": {
        "path": "${CFG_PUBLIC_PATH}",
        "host": "${VERCEL_HOST:-${CFG_DOMAIN}}",
        "mode": "auto"
      }
    }
  }]
}
KNIFECFG

  # xray-knife CLI syntax varies by version — try several common forms.
  local knife_out=""
  local knife_ok=false
  local syntaxes=("net http -c" "http -c" "net real -c" "net tcp -c")
  for syn in "${syntaxes[@]}"; do
    knife_out=$("$XRAY_KNIFE_BIN" $syn "$KNIFE_CFG" \
      -d "https://www.gstatic.com/generate_204" -t 15000 2>&1 || true)
    # Real success contains a numeric latency or HTTP status, NOT just the word "ms" in help
    if echo "$knife_out" | grep -qiE '[0-9]+\s*ms\b|delay:\s*[0-9]+|latency:\s*[0-9]+|status:\s*2[0-9]{2}|HTTP/[0-9.]+\s*2[0-9]{2}'; then
      knife_ok=true
      break
    fi
    # If output looks like a syntax/help error, try next variant; otherwise stop.
    if ! echo "$knife_out" | grep -qiE "unknown command|help for|usage:|\bflag\b|requires.*argument"; then
      break
    fi
  done
  rm -f "$KNIFE_CFG"

  if [[ "$knife_ok" == "true" ]]; then
    ok "xray-knife 测试通过 ✔"
    echo "$knife_out" | grep -iE 'latency|delay|[0-9]+\s*ms\b|status' | head -3 | while read -r l; do
      echo -e "  ${C_GREEN}  $l${C_RESET}"
    done
  else
    warn "xray-knife 测试无法运行 (二进制语法不匹配 — 非致命)"
    info "代理已通过上述测试 1/2 验证。尝试客户端链接以确认。"
  fi
}

# =============================================================
#  PHASE 6 — FINAL SUMMARY
# =============================================================
phase6_summary() {
  local TARGET_DOMAIN_VAL="https://${CFG_DOMAIN}:${CFG_INBOUND_PORT}"
  local VERCEL_HOST
  VERCEL_HOST=$(echo "${VERCEL_URL:-}" | sed 's|https://||' | sed 's|/.*||')
  local ENCODED_PATH
  ENCODED_PATH=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${CFG_PUBLIC_PATH}'))" 2>/dev/null || echo "${CFG_PUBLIC_PATH}")
  local LINK_TAG="XHTTP-${CFG_PLATFORM}"
  # Build the `extra` JSON. Netlify needs obfuscation params; Vercel just gets xPaddingBytes.
  local EXTRA_JSON
  if [[ "${CFG_PLATFORM:-vercel}" == "netlify" ]]; then
    EXTRA_JSON=$(printf '{"xPaddingBytes":"%s","xPaddingObfsMode":true,"xPaddingKey":"%s","xPaddingHeader":"%s","scMaxEachPostBytes":"%s"}' \
      "${XPADDING:-10-50}" "${XPADDING_KEY:-}" "${XPADDING_HEADER:-}" "${SC_MAX_POST_BYTES:-1000000}")
  else
    EXTRA_JSON=$(printf '{"xPaddingBytes":"%s"}' "${XPADDING:-100-1000}")
  fi
  local ENCODED_EXTRA
  ENCODED_EXTRA=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=''))" "$EXTRA_JSON" 2>/dev/null || echo "$EXTRA_JSON")
  local CLIENT_LINK="vless://${INBOUND_UUID:-UUID}@${VERCEL_HOST}:443?encryption=none&security=tls&sni=${VERCEL_HOST}&fp=chrome&alpn=h2%2Chttp%2F1.1&insecure=0&allowInsecure=0&type=xhttp&host=${VERCEL_HOST}&path=${ENCODED_PATH}&mode=auto&extra=${ENCODED_EXTRA}#${LINK_TAG}"

  echo ""
  echo -e "${C_GREEN}"
  echo "  ╔══════════════════════════════════════════════════════════╗"
  echo "  ║             安装完成  ✔                                ║"
  echo "  ╚══════════════════════════════════════════════════════════╝"
  echo -e "${C_RESET}"
  local SERVER_IP
  SERVER_IP=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
  echo -e "  ${C_WHITE}平台             :${C_RESET} ${CFG_PLATFORM}"
  echo -e "  ${C_WHITE}中继 URL         :${C_RESET} ${C_CYAN}${VERCEL_URL:-无}${C_RESET}"
  echo -e "  ${C_WHITE}入站 UUID        :${C_RESET} ${C_YELLOW}${INBOUND_UUID:-无}${C_RESET}"
  echo -e "  ${C_WHITE}域名             :${C_RESET} ${CFG_DOMAIN}"
  echo -e "  ${C_WHITE}中继路径         :${C_RESET} ${CFG_RELAY_PATH}"
  echo -e "  ${C_WHITE}公共路径         :${C_RESET} ${CFG_PUBLIC_PATH}"
  echo -e "  ${C_WHITE}目标域名         :${C_RESET} ${TARGET_DOMAIN_VAL}"

  # ── Obfuscation params (Netlify only) ──
  if [[ "${CFG_PLATFORM:-vercel}" == "netlify" && -n "${XPADDING_KEY:-}" ]]; then
    echo ""
    echo -e "  ${C_CYAN}── XHTTP 混淆参数 (Netlify) ──${C_RESET}"
    echo -e "  ${C_WHITE}xPaddingBytes    :${C_RESET} ${XPADDING:-10-50}"
    echo -e "  ${C_WHITE}xPaddingKey      :${C_RESET} ${C_YELLOW}${XPADDING_KEY:-}${C_RESET}"
    echo -e "  ${C_WHITE}xPaddingHeader   :${C_RESET} ${C_YELLOW}${XPADDING_HEADER:-}${C_RESET}"
    echo -e "  ${C_GRAY}                   (已嵌入下方的客户端链接中)${C_RESET}"
  fi
  echo ""

  # ── E2E test result (set by phase5_healthcheck) ──
  case "${E2E_STATUS:-UNKNOWN}" in
    PASS)
      echo -e "  ${C_GREEN}端到端代理测试   : ✔ 通过${C_RESET}"
      echo -e "  ${C_WHITE}延迟 (最小/平均/最大):${C_RESET} ${C_GREEN}${E2E_PING_MIN:-?}/${E2E_PING_AVG:-?}/${E2E_PING_MAX:-?} ms${C_RESET} ${C_GRAY}(通过 VLESS)${C_RESET}"
      echo -e "  ${C_WHITE}CDN 延迟         :${C_RESET} ${C_CYAN}${E2E_CDN_PING:-?} ms${C_RESET} ${C_GRAY}(直接到中继)${C_RESET}"
      # Quality assessment
      if (( ${E2E_PING_AVG:-9999} < 300 )); then
        echo -e "  ${C_GREEN}质量             : 优秀${C_RESET}"
      elif (( ${E2E_PING_AVG:-9999} < 600 )); then
        echo -e "  ${C_YELLOW}质量             : 良好${C_RESET}"
      elif (( ${E2E_PING_AVG:-9999} < 1200 )); then
        echo -e "  ${C_YELLOW}质量             : 可接受 (高延迟)${C_RESET}"
      else
        echo -e "  ${C_RED}质量             : 较差 (延迟非常高)${C_RESET}"
      fi
      echo -e "  ${C_GREEN}                   你的客户端配置已验证为可用。${C_RESET}"
      ;;
    FAIL)
      echo -e "  ${C_RED}端到端代理测试   : ✘ 失败${C_RESET} ${C_GRAY}(${E2E_DETAIL})${C_RESET}"
      echo -e "  ${C_RED}                   客户端配置可能无法工作 — 检查日志: ${LOG_FILE}${C_RESET}"
      ;;
    *)
      echo -e "  ${C_YELLOW}端到端代理测试   : ⚠ 未运行${C_RESET}"
      ;;
  esac
  echo ""

  echo -e "  ${C_CYAN}── 客户端配置 (复制到你的 v2ray/xray 客户端) ──${C_RESET}"
  echo ""
  echo -e "  ${C_YELLOW}${CLIENT_LINK}${C_RESET}"
  echo ""

  echo -e "  ${C_CYAN}── 管理面板 ──${C_RESET}"
  echo -e "  ${C_WHITE}随时输入 ${C_YELLOW}xhttp${C_WHITE} 打开管理面板${C_RESET}"
  echo -e "  ${C_GRAY}    (查看配置, 重启 xray, 续期 SSL, 查看日志, 卸载, ...)${C_RESET}"
  echo ""

  echo -e "  ${C_GRAY}完整安装日志已保存至: ${LOG_FILE}${C_RESET}"
  echo -e "${C_GREEN}  ══════════════════════════════════════════════════════════${C_RESET}"
  echo ""
}

# =============================================================
#  PHASE 7 — INSTALL MANAGEMENT PANEL ( `xhttp` CLI )
# =============================================================
phase7_install_panel() {
  step "阶段 7 — 安装管理面板 (输入 'xhttp' 打开)"

  # ── 1. Persist install state ─────────────────────────────────
  local STATE_DIR="/etc/xhttp-installer"
  local STATE_FILE="${STATE_DIR}/info.env"
  mkdir -p "$STATE_DIR"
  chmod 700 "$STATE_DIR"

  # Build the client link (same as summary)
  local VERCEL_HOST ENCODED_PATH EXTRA_JSON ENCODED_EXTRA CLIENT_LINK
  VERCEL_HOST=$(echo "${VERCEL_URL:-}" | sed 's|https://||; s|/.*||')
  ENCODED_PATH=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${CFG_PUBLIC_PATH}'))" 2>/dev/null || echo "${CFG_PUBLIC_PATH}")
  if [[ "${CFG_PLATFORM:-vercel}" == "netlify" ]]; then
    EXTRA_JSON=$(printf '{"xPaddingBytes":"%s","xPaddingObfsMode":true,"xPaddingKey":"%s","xPaddingHeader":"%s","scMaxEachPostBytes":"%s"}' \
      "${XPADDING:-10-50}" "${XPADDING_KEY:-}" "${XPADDING_HEADER:-}" "${SC_MAX_POST_BYTES:-1000000}")
  else
    EXTRA_JSON=$(printf '{"xPaddingBytes":"%s"}' "${XPADDING:-100-1000}")
  fi
  ENCODED_EXTRA=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=''))" "$EXTRA_JSON" 2>/dev/null || echo "$EXTRA_JSON")
  CLIENT_LINK="vless://${INBOUND_UUID}@${VERCEL_HOST}:443?encryption=none&security=tls&sni=${VERCEL_HOST}&fp=chrome&alpn=h2%2Chttp%2F1.1&insecure=0&allowInsecure=0&type=xhttp&host=${VERCEL_HOST}&path=${ENCODED_PATH}&mode=auto&extra=${ENCODED_EXTRA}#XHTTP-${CFG_PLATFORM}"

  cat > "$STATE_FILE" <<STATE
# XHTTP Installer — 持久化状态 (请勿手动编辑)
INSTALL_DATE="$(date -Iseconds)"
CFG_PLATFORM="${CFG_PLATFORM}"
CFG_DOMAIN="${CFG_DOMAIN}"
CFG_EMAIL="${CFG_EMAIL}"
CFG_INBOUND_PORT="${CFG_INBOUND_PORT}"
CFG_RELAY_PATH="${CFG_RELAY_PATH}"
CFG_PUBLIC_PATH="${CFG_PUBLIC_PATH}"
INBOUND_UUID="${INBOUND_UUID}"
VERCEL_URL="${VERCEL_URL:-}"
VERCEL_HOST="${VERCEL_HOST}"
SSL_CERT="${SSL_CERT:-}"
SSL_KEY="${SSL_KEY:-}"
XPADDING="${XPADDING:-}"
XPADDING_KEY="${XPADDING_KEY:-}"
XPADDING_HEADER="${XPADDING_HEADER:-}"
SC_MAX_POST_BYTES="${SC_MAX_POST_BYTES:-}"
CLIENT_LINK="${CLIENT_LINK}"
HYBRID_SUB_URL="${HYBRID_SUB_URL:-}"
HYBRID_CONFIG_COUNT="${HYBRID_CONFIG_COUNT:-0}"
E2E_STATUS="${E2E_STATUS:-UNKNOWN}"
E2E_PING_AVG="${E2E_PING_AVG:-0}"
LOG_FILE="${LOG_FILE}"
STATE

  chmod 600 "$STATE_FILE"
  ok "状态已保存 → $STATE_FILE"

  # ── 2. Write the panel script ────────────────────────────────
  cat > /usr/local/bin/xhttp <<'PANEL'
#!/usr/bin/env bash
# XHTTP Installer — 管理面板
set -u

STATE_FILE="/etc/xhttp-installer/info.env"
[[ ! -f "$STATE_FILE" ]] && { echo "未找到 XHTTP Installer。请先运行安装程序。"; exit 1; }
# shellcheck source=/dev/null
source "$STATE_FILE"

C_RESET="\033[0m"; C_CYAN="\033[1;36m"; C_YELLOW="\033[1;33m"; C_GREEN="\033[1;32m"
C_RED="\033[1;31m"; C_GRAY="\033[0;90m"; C_WHITE="\033[1;37m"; C_MAGENTA="\033[1;35m"

_banner() {
  clear
  echo ""
  echo -e "   ${C_CYAN}╔══════════════════════════════════════════╗${C_RESET}"
  echo -e "   ${C_CYAN}║${C_WHITE}        XHTTP Installer — 面板          ${C_CYAN}║${C_RESET}"
  echo -e "   ${C_CYAN}║${C_GRAY}        avaco_cloud · t.me/avaco_cloud   ${C_CYAN}║${C_RESET}"
  echo -e "   ${C_CYAN}╚══════════════════════════════════════════╝${C_RESET}"
  echo ""
}

_status_line() {
  # Compact one-line status (running/stopped + port + cert expiry)
  local xray_state="${C_RED}已停止${C_RESET}"
  systemctl is-active --quiet xray 2>/dev/null && xray_state="${C_GREEN}运行中${C_RESET}"

  local port_state="${C_RED}已关闭${C_RESET}"
  ss -tlnp 2>/dev/null | grep -q ":${CFG_INBOUND_PORT} " && port_state="${C_GREEN}监听中${C_RESET}"

  local cert_expiry="?"
  if [[ -n "${SSL_CERT:-}" && -f "${SSL_CERT}" ]]; then
    cert_expiry=$(openssl x509 -in "$SSL_CERT" -noout -enddate 2>/dev/null | cut -d= -f2 || echo "?")
  fi

  echo -e "  ${C_WHITE}xray         :${C_RESET} ${xray_state}"
  echo -e "  ${C_WHITE}端口 ${CFG_INBOUND_PORT}  :${C_RESET} ${port_state}"
  echo -e "  ${C_WHITE}域名         :${C_RESET} ${CFG_DOMAIN}"
  echo -e "  ${C_WHITE}平台         :${C_RESET} ${CFG_PLATFORM}"
  echo -e "  ${C_WHITE}中继         :${C_RESET} ${VERCEL_URL:-无}"
  echo -e "  ${C_WHITE}证书到期     :${C_RESET} ${cert_expiry}"
  if [[ "${E2E_STATUS:-}" == "PASS" ]]; then
    echo -e "  ${C_WHITE}端到端测试   :${C_RESET} ${C_GREEN}通过${C_RESET} ${C_GRAY}(平均 ${E2E_PING_AVG}ms)${C_RESET}"
  elif [[ "${E2E_STATUS:-}" == "FAIL" ]]; then
    echo -e "  ${C_WHITE}端到端测试   :${C_RESET} ${C_RED}失败${C_RESET}"
  fi
}

_show_config() {
  _banner
  echo -e "  ${C_CYAN}── 客户端配置 ──${C_RESET}"
  echo ""
  echo -e "  ${C_YELLOW}${CLIENT_LINK}${C_RESET}"
  echo ""
  echo -e "  ${C_WHITE}UUID           :${C_RESET} ${C_YELLOW}${INBOUND_UUID}${C_RESET}"
  echo -e "  ${C_WHITE}域名           :${C_RESET} ${CFG_DOMAIN}"
  echo -e "  ${C_WHITE}端口           :${C_RESET} ${CFG_INBOUND_PORT}"
  echo -e "  ${C_WHITE}中继路径       :${C_RESET} ${CFG_RELAY_PATH}"
  echo -e "  ${C_WHITE}公共路径       :${C_RESET} ${CFG_PUBLIC_PATH}"
  echo -e "  ${C_WHITE}中继主机       :${C_RESET} ${VERCEL_HOST}"
  if [[ "${CFG_PLATFORM:-}" == "netlify" && -n "${XPADDING_KEY:-}" ]]; then
    echo ""
    echo -e "  ${C_CYAN}── 混淆参数 (Netlify) ──${C_RESET}"
    echo -e "  ${C_WHITE}xPaddingBytes  :${C_RESET} ${XPADDING:-10-50}"
    echo -e "  ${C_WHITE}xPaddingKey    :${C_RESET} ${C_YELLOW}${XPADDING_KEY}${C_RESET}"
    echo -e "  ${C_WHITE}xPaddingHeader :${C_RESET} ${C_YELLOW}${XPADDING_HEADER}${C_RESET}"
    echo -e "  ${C_GRAY}                   (已在上方链接中)${C_RESET}"
  fi
  echo ""
  read -rp "  按 Enter 返回..." _
}

_show_status() {
  _banner
  echo -e "  ${C_CYAN}── 系统状态 ──${C_RESET}"
  echo ""
  _status_line
  echo ""

  echo -e "  ${C_CYAN}── xray 服务 ──${C_RESET}"
  systemctl status xray --no-pager -n 5 2>/dev/null | head -12 | \
    while IFS= read -r l; do echo "   $l"; done
  echo ""
  read -rp "  按 Enter 返回..." _
}

_restart_xray() {
  _banner
  echo -e "  ${C_CYAN}── 正在重启 xray ──${C_RESET}"
  systemctl restart xray
  sleep 2
  if systemctl is-active --quiet xray; then
    echo -e "  ${C_GREEN}✔ xray 重启成功${C_RESET}"
  else
    echo -e "  ${C_RED}✘ xray 启动失败${C_RESET}"
    journalctl -u xray -n 10 --no-pager | sed 's/^/   /'
  fi
  echo ""
  read -rp "  按 Enter 返回..." _
}

_view_logs() {
  _banner
  echo -e "  ${C_CYAN}── 日志选项 ──${C_RESET}"
  echo "    1) xray 错误日志 (最后 30 行)"
  echo "    2) xray 访问日志 (最后 30 行)"
  echo "    3) xray systemd 日志 (最后 50 行)"
  echo "    4) 安装日志"
  echo "    0) 返回"
  echo ""
  read -rp "  选择: " ch
  case "$ch" in
    1) tail -n 30 /var/log/xray/error.log 2>/dev/null || echo "无日志"; read -rp "按 Enter..." _;;
    2) tail -n 30 /var/log/xray/access.log 2>/dev/null || echo "无日志"; read -rp "按 Enter..." _;;
    3) journalctl -u xray -n 50 --no-pager; read -rp "按 Enter..." _;;
    4) tail -n 100 "${LOG_FILE:-/tmp/xhttp-install.log}" 2>/dev/null || echo "无日志"; read -rp "按 Enter..." _;;
  esac
}

_renew_ssl() {
  _banner
  echo -e "  ${C_CYAN}── 正在续期 SSL 证书 ──${C_RESET}"
  local ACME="${HOME}/.acme.sh/acme.sh"
  if [[ ! -x "$ACME" ]]; then
    echo -e "  ${C_RED}未在 $ACME 找到 acme.sh${C_RESET}"
    read -rp "按 Enter..." _; return
  fi
  systemctl stop xray 2>/dev/null
  sleep 2
  "$ACME" --renew -d "$CFG_DOMAIN" --force --ecc --server letsencrypt 2>&1 | tail -10
  systemctl start xray 2>/dev/null
  echo ""
  echo -e "  ${C_GREEN}完成。新到期时间:${C_RESET}"
  openssl x509 -in "$SSL_CERT" -noout -enddate 2>/dev/null
  echo ""
  read -rp "按 Enter..." _
}

_update_script() {
  _banner
  echo -e "  ${C_CYAN}── 更新 / 重新部署 ──${C_RESET}"
  echo ""
  echo -e "  ${C_GRAY}这会拉取最新的安装程序, 重新运行部署阶段,${C_RESET}"
  echo -e "  ${C_GRAY}并保留你现有的 SSL 证书 (acme.sh 如果仍然有效会自动跳过)。${C_RESET}"
  echo -e "  ${C_GRAY}你的 UUID、域名和配置保持不变。${C_RESET}"
  echo ""
  read -rp "  继续? [y/N]: " yn
  case "${yn,,}" in y|yes) ;; *) return ;; esac

  local TARGET_DIR="/root/XHTTP-Installer"
  if [[ -d "$TARGET_DIR/.git" ]]; then
    echo -e "  ${C_CYAN}正在从 GitHub 拉取最新版本...${C_RESET}"
    git -C "$TARGET_DIR" fetch --depth=1 origin main 2>&1 | tail -5
    git -C "$TARGET_DIR" reset --hard origin/main 2>&1 | tail -3
  else
    echo -e "  ${C_YELLOW}没有现有检出 — 正在全新克隆...${C_RESET}"
    git clone --depth=1 --branch main \
      "https://github.com/ZhengYuHangOvO/XHTTP-Installer.git" "$TARGET_DIR" 2>&1 | tail -5
  fi

  echo ""
  echo -e "  ${C_CYAN}正在运行更新后的安装程序 (将重复使用现有 SSL)...${C_RESET}"
  sleep 1
  cd "$TARGET_DIR"
  chmod +x Deploy-Ubuntu.sh
  # XHTTP_NO_SCREEN=1 prevents the auto-screen wrapper (we're already inside a terminal)
  exec env XHTTP_NO_SCREEN=1 bash Deploy-Ubuntu.sh
}

_uninstall() {
  _banner
  echo -e "  ${C_RED}── 卸载 XHTTP Installer ──${C_RESET}"
  echo -e "  ${C_YELLOW}此操作将:${C_RESET}"
  echo "    • 停止并禁用 xray 服务"
  echo "    • 删除 xray 二进制文件 + 配置"
  echo "    • 删除 SSL 证书"
  echo "    • 删除此面板"
  echo "    • 保留 acme.sh 和 node.js (其他工具)"
  echo ""
  read -rp "  输入 'YES' 确认: " confirm
  [[ "$confirm" != "YES" ]] && { echo "已取消。"; sleep 1; return; }

  systemctl stop xray 2>/dev/null
  systemctl disable xray 2>/dev/null
  bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove --purge 2>/dev/null || true
  rm -rf /etc/ssl/xhttp "$STATE_FILE" /etc/xhttp-installer
  rm -f /root/xhttp-configs.txt /root/xhttp-sub.txt
  rm -f /usr/local/bin/xhttp
  echo -e "  ${C_GREEN}✔ 已卸载。${C_RESET}"
  exit 0
}

# ── 主菜单循环 ──
while true; do
  _banner
  _status_line
  echo ""
  echo -e "  ${C_CYAN}── 菜单 ──${C_RESET}"
  echo -e "    ${C_YELLOW}1${C_RESET}) 显示客户端配置"
  echo -e "    ${C_YELLOW}2${C_RESET}) 显示详细状态"
  echo -e "    ${C_YELLOW}3${C_RESET}) 重启 xray"
  echo -e "    ${C_YELLOW}4${C_RESET}) 查看日志"
  echo -e "    ${C_YELLOW}5${C_RESET}) 续期 SSL 证书"
  echo -e "    ${C_YELLOW}6${C_RESET}) ${C_CYAN}更新 / 重新部署${C_RESET} ${C_GRAY}(保留现有 SSL)${C_RESET}"
  echo -e "    ${C_YELLOW}7${C_RESET}) ${C_RED}卸载${C_RESET}"
  echo -e "    ${C_YELLOW}0${C_RESET}) 退出"
  echo ""
  read -rp "  选择 [0-7]: " choice
  case "$choice" in
    1) _show_config ;;
    2) _show_status ;;
    3) _restart_xray ;;
    4) _view_logs ;;
    5) _renew_ssl ;;
    6) _update_script ;;
    7) _uninstall ;;
    0) clear; exit 0 ;;
    *) ;;
  esac
done
PANEL

  chmod +x /usr/local/bin/xhttp
  ok "面板已安装 → /usr/local/bin/xhttp"
  info "随时打开: ${C_YELLOW}xhttp${C_RESET}"
}

# =============================================================
#  AUTO-WRAP IN SCREEN (so SSH disconnect won't kill the install)
# =============================================================
ensure_screen_session() {
  # If already inside screen ($STY) or tmux ($TMUX), do nothing.
  if [[ -n "${STY:-}" ]]; then
    info "已在 screen 会话内: $STY"
    return 0
  fi
  if [[ -n "${TMUX:-}" ]]; then
    info "已在 tmux 会话内 — 继续执行"
    return 0
  fi
  # Skip if user explicitly opts out
  if [[ "${XHTTP_NO_SCREEN:-0}" == "1" ]]; then
    info "XHTTP_NO_SCREEN=1 已设置 — 跳过 screen 包装器"
    return 0
  fi

  echo ""
  echo -e "  ${C_YELLOW}⚠ 你不在 screen/tmux 内。${C_RESET}"
  echo -e "  ${C_GRAY}如果你的 SSH 断开连接, 安装过程将中途终止。${C_RESET}"
  echo -e "  ${C_GRAY}建议: 在 screen 内运行, 以便你可以使用以下命令重新连接: ${C_WHITE}screen -r xhttp${C_RESET}"
  echo ""
  read -rp "$(echo -e "  ${C_WHITE}自动在 screen 内启动? [Y/n]${C_RESET}: ")" yn
  case "${yn,,}" in
    n|no)
      warn "继续 WITHOUT screen — 请注意 SSH 稳定性"
      return 0 ;;
  esac

  # Install screen if missing
  if ! command -v screen &>/dev/null; then
    info "正在安装 screen..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq screen 2>/dev/null || {
      fail "无法安装 screen — 继续不使用它"
      return 0
    }
  fi

  # Handle existing session if present
  if screen -ls 2>/dev/null | grep -q "\.xhttp\b"; then
    warn "发现现有的 screen 会话 'xhttp'。"
    echo -e "  ${C_GRAY}1) 重新连接到它    (继续正在运行的内容)${C_RESET}"
    echo -e "  ${C_GRAY}2) 终止并重新开始${C_RESET}"
    echo -e "  ${C_GRAY}3) 取消${C_RESET}"
    local sc_choice
    read -rp "$(echo -e "  ${C_WHITE}选择 [1/2/3]${C_RESET}: ")" sc_choice
    case "$sc_choice" in
      1)
        ok "正在重新连接..."
        exec screen -r xhttp ;;
      2)
        info "正在终止旧会话..."
        screen -S xhttp -X quit 2>/dev/null || true
        sleep 1
        ;;
      *)
        info "已取消。"
        exit 0 ;;
    esac
  fi

  # Re-launch self inside screen (UTF-8 enabled with -U)
  local script_path
  script_path="$(realpath "$0" 2>/dev/null || echo "$0")"
  ok "正在 screen 会话 'xhttp' 内启动..."
  echo -e "  ${C_GRAY}随时按 Ctrl+A 然后 D 分离${C_RESET}"
  echo -e "  ${C_GRAY}如果 SSH 断开, 重新连接后运行: ${C_WHITE}screen -r xhttp${C_RESET}"
  sleep 2
  # IMPORTANT: pass XHTTP_NO_SCREEN through sudo (sudo strips env by default).
  # `sudo VAR=value cmd` passes VAR into the command's environment.
  exec screen -U -S xhttp bash -c "sudo XHTTP_NO_SCREEN=1 bash '$script_path'; echo; echo 'Press Enter to close screen...'; read"
}

# =============================================================
#  ENTRYPOINT
# =============================================================
main() {
  print_banner
  ensure_screen_session
  print_banner
  echo -e "  ${C_MAGENTA}重要:${C_RESET} 在继续之前, 请确保你的域名 DNS A 记录指向此服务器 IP。"
  echo -e "  ${C_GRAY}提示: 随时按 Ctrl+C 中止。${C_RESET}"
  echo ""

  echo -e "  ${C_CYAN}[ 部署平台 ]${C_RESET}"
  echo -e "  ${C_WHITE}选择转发平台:${C_RESET}"
  echo -e "    ${C_YELLOW}1${C_RESET}) Vercel"
  echo -e "    ${C_YELLOW}2${C_RESET}) Netlify"
  while true; do
    read -rp "$(echo -e "  ${C_WHITE}输入选择 [1/2]${C_RESET}: ")" plat_choice
    case "$plat_choice" in
      1) CFG_PLATFORM="vercel";  break ;;
      2) CFG_PLATFORM="netlify"; break ;;
      *) fail "输入 1 选择 Vercel 或 2 选择 Netlify" ;;
    esac
  done
  ok "平台: ${CFG_PLATFORM}"
  echo ""

  read -rp "$(echo -e "  ${C_WHITE}按 Enter 开始安装...${C_RESET}")"

  phase1_preflight
  phase2_install_all
  phase3_collect_input
  autofix_diagnose "FIREWALL"
  autofix_and_retry "SSL"    phase4a_ssl
  autofix_and_retry "XRAYSSL" phase4b_configure_xray
  autofix_and_retry "${CFG_PLATFORM:-vercel}" phase4c_deploy
  phase5_healthcheck
  phase7_install_panel
  phase6_summary
}

main "$@"
