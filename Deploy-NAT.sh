#!/usr/bin/env bash
# =============================================================
#  XHTTP Installer (NAT/Minimal Edition) — avaco_cloud
#  低配/NAT 小机专用版 | VLESS+XHTTP 一键部署
# -------------------------------------------------------------
#  Copyright (C) 2025 avaco_cloud
#  Repository: https://github.com/zsigoio/XHTTP-Installer
#  Author:     @avaco_cloud (https://t.me/avaco_cloud)
#
#  Licensed under the GNU General Public License v3.0 (GPL-3.0).
# =============================================================
set -euo pipefail

readonly AVC_BUILD_ID="avc-7f3a92e1-2025-zsigoio"
export AVC_BUILD_ID

LOG_FILE="/tmp/xhttp-nat-install.log"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"

exec > >(tee -a "$LOG_FILE") 2>&1

# ── Colors ─────────────────────────────────────────────
C_RESET="\033[0m"
C_CYAN="\033[1;36m"
C_YELLOW="\033[1;33m"
C_GREEN="\033[1;32m"
C_RED="\033[1;31m"
C_MAGENTA="\033[1;35m"
C_GRAY="\033[0;90m"
C_WHITE="\033[1;37m"

step() { echo -e "\n${C_CYAN}>> $1${C_RESET}"; }
ok()   { echo -e "${C_GREEN}   ✔ $1${C_RESET}"; }
warn() { echo -e "${C_YELLOW}   ⚠ $1${C_RESET}"; }
fail() { echo -e "${C_RED}   ✘ $1${C_RESET}"; }
info() { echo -e "${C_GRAY}   $1${C_RESET}"; }

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
  echo -e "          ${C_GRAY}低配/NAT 小机专用版${C_RESET}"
  echo -e "          ${C_GRAY}t.me/avaco_cloud${C_RESET}"
  echo ""
}

confirm() {
  local prompt="$1"
  read -rp "$(echo -e "  ${C_YELLOW}${prompt}${C_RESET} ${C_GRAY}[Y/n]${C_RESET}: ")" yn
  case "${yn,,}" in n|no) return 1;; *) return 0;; esac
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
    fail "必填项。"
  done
}

# =============================================================
#  PHASE 1 — PREFLIGHT (精简)
# =============================================================
phase1_preflight() {
  step "阶段 1 — 系统检查与前置准备（精简模式）"

  if [[ $EUID -ne 0 ]]; then
    fail "请以 root 身份运行: sudo bash Deploy-NAT.sh"
    exit 1
  fi
  ok "以 root 身份运行"

  info "更新软件包列表..."
  apt-get update -qq 2>/dev/null || true

  info "安装最小依赖 (curl, git, openssl, ca-certificates, cron)..."
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    curl wget git openssl ca-certificates gnupg dnsutils unzip jq lsof cron 2>/dev/null || true
  ok "基础依赖安装完成"

  local total_mem_mb avail_mem_mb
  total_mem_mb=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)
  avail_mem_mb=$(awk '/MemAvailable/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)
  info "服务器内存: ${total_mem_mb} MB, 可用: ${avail_mem_mb} MB"
  if (( total_mem_mb < 128 )); then
    warn "内存极低 (${total_mem_mb} MB)，xray 可能需要至少 60MB 内存"
  fi
}

# =============================================================
#  PHASE 2 — 安装 Xray + acme.sh（无Node.js/无CDN CLI）
# =============================================================
phase2_install_light() {
  step "阶段 2 — 安装 Xray-core + acme.sh（轻量模式）"

  # ── Xray ────────────────────────────────────────────
  if command -v xray &>/dev/null && xray version &>/dev/null 2>&1; then
    ok "Xray 已安装 ($(xray version 2>/dev/null | head -1))"
  else
    info "安装 Xray-core（XTLS 官方）..."
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install 2>&1 | tail -3 || true
    if command -v xray &>/dev/null; then
      ok "Xray 安装完成 ($(xray version 2>/dev/null | head -1))"
    else
      fail "Xray 安装失败，请手动安装"
      exit 1
    fi
  fi
  systemctl enable xray 2>/dev/null || true

  # ── acme.sh ──────────────────────────────────────────
  if [[ -f "$HOME/.acme.sh/acme.sh" ]]; then
    ok "acme.sh 已安装"
  else
    info "安装 acme.sh..."
    curl -fsSL https://get.acme.sh | sh -s email=admin@example.com 2>&1 | grep -E "(install|Installed|OK|error|Error|success|crontab)" || true
    if [[ ! -f "$HOME/.acme.sh/acme.sh" ]]; then
      info "尝试强制安装 acme.sh（无 crontab 模式）..."
      curl -fsSL https://get.acme.sh | sh -s email=admin@example.com --force 2>&1 | grep -E "(install|Installed|OK|error|Error|success)" || true
    fi
    if [[ ! -f "$HOME/.acme.sh/acme.sh" ]]; then
      curl -fsSL https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh \
        -o /tmp/acme-install.sh 2>/dev/null && \
        bash /tmp/acme-install.sh --install-online --force 2>&1 | grep -E "(install|Installed|OK)" || true
      rm -f /tmp/acme-install.sh
    fi
  fi

  [[ -f "$HOME/.acme.sh/acme.sh.env" ]] && source "$HOME/.acme.sh/acme.sh.env" 2>/dev/null || true
  ACME_CMD="$HOME/.acme.sh/acme.sh"

  if [[ ! -x "$ACME_CMD" ]]; then
    fail "acme.sh 安装失败，无法继续"
    exit 1
  fi
  ok "acme.sh 就绪"
}

# =============================================================
#  PHASE 3 — 收集配置信息
# =============================================================
CFG_DOMAIN=""
CFG_EMAIL=""
CFG_INBOUND_PORT=""
CFG_RELAY_PATH=""
CFG_EXTERNAL_IP=""
CFG_EXTERNAL_PORT=""

phase3_collect_input() {
  step "阶段 3 — 配置信息收集"

  echo ""
  echo -e "  ${C_MAGENTA}📌 NAT 小机使用说明：${C_RESET}"
  echo -e "  ${C_GRAY}如果服务器在 NAT 内网（无公网 IP），你需要有公网端口转发。${C_RESET}"
  echo -e "  ${C_GRAY}脚本会尝试检测公网 IP，你也可以手动填写。${C_RESET}"
  echo ""

  CFG_DOMAIN=$(read_required "域名（例如 ns.example.com）")
  CFG_EMAIL=$(read_required "邮箱（用于 Let's Encrypt 通知，必须真实）")
  CFG_INBOUND_PORT=$(read_default "Xray 入站端口" "443")
  CFG_RELAY_PATH=$(read_default "转发路径 (例如 /api)" "/api")
  [[ "${CFG_RELAY_PATH:0:1}" != "/" ]] && CFG_RELAY_PATH="/$CFG_RELAY_PATH"

  CFG_EXTERNAL_IP=$(read_default "公网 IP（留空自动检测）" "")
  if [[ -z "$CFG_EXTERNAL_IP" ]]; then
    CFG_EXTERNAL_IP=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || \
                       curl -s --max-time 5 ip.sb 2>/dev/null || \
                       curl -s --max-time 5 icanhazip.com 2>/dev/null || true)
    if [[ -z "$CFG_EXTERNAL_IP" ]]; then
      CFG_EXTERNAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
    fi
    info "检测到公网 IP: ${CFG_EXTERNAL_IP}"
  fi

  CFG_EXTERNAL_PORT=$(read_default "NAT 映射的公网端口（留空等于入站端口）" "$CFG_INBOUND_PORT")

  # ── 确认 ─────────────────────────────────────────────
  echo ""
  echo -e "  ${C_CYAN}────────────── 配置摘要 ──────────────${C_RESET}"
  echo -e "  ${C_WHITE}域名          :${C_RESET} $CFG_DOMAIN"
  echo -e "  ${C_WHITE}邮箱          :${C_RESET} $CFG_EMAIL"
  echo -e "  ${C_WHITE}入站端口      :${C_RESET} $CFG_INBOUND_PORT"
  echo -e "  ${C_WHITE}转发路径      :${C_RESET} $CFG_RELAY_PATH"
  echo -e "  ${C_WHITE}公网 IP       :${C_RESET} $CFG_EXTERNAL_IP"
  echo -e "  ${C_WHITE}公网端口      :${C_RESET} $CFG_EXTERNAL_PORT"
  echo -e "  ${C_CYAN}─────────────────────────────────────${C_RESET}"
  echo ""
  if ! confirm "使用以上配置继续？"; then
    fail "用户取消"
    exit 1
  fi
}

# =============================================================
#  PHASE 4a — SSL 证书 (acme.sh standalone)
# =============================================================
phase4a_ssl() {
  step "阶段 4a — 申请 SSL 证书"

  SSL_DIR="/etc/ssl/xhttp/${CFG_DOMAIN}"
  mkdir -p "$SSL_DIR"
  SSL_CERT="${SSL_DIR}/fullchain.pem"
  SSL_KEY="${SSL_DIR}/privkey.pem"

  local resolved
  resolved=$(dig +short +time=3 +tries=1 "$CFG_DOMAIN" A @1.1.1.1 2>/dev/null | grep -oE '^[0-9.]+$' | head -1)
  if [[ -n "$resolved" ]]; then
    ok "DNS 解析: ${CFG_DOMAIN} → ${resolved}"
  else
    warn "DNS 解析失败（刚配置 DNS 请等待 1-2 分钟）"
  fi

  # ── 释放端口 80 ──
  if ss -tlnp 2>/dev/null | grep -q ':80 '; then
    warn "端口 80 被占用，尝试释放..."
    for svc in apache2 httpd nginx caddy; do
      systemctl stop "$svc" 2>/dev/null || true
    done
    local p80
    p80=$(ss -tlnp 2>/dev/null | grep ':80 ' | grep -oP 'pid=\K[0-9]+' | head -1)
    [[ -n "$p80" ]] && kill "$p80" 2>/dev/null || true
    sleep 2
  fi

  "$ACME_CMD" --register-account -m "$CFG_EMAIL" --server letsencrypt 2>&1 | \
    grep -iE "register|already|account" | head -3 || true

  local issue_rc=0 acme_out
  info "通过 standalone 模式申请证书..."
  acme_out=$("$ACME_CMD" --issue -d "$CFG_DOMAIN" --standalone \
    --keylength ec-256 --listen-v4 --server letsencrypt 2>&1) || issue_rc=$?
  echo "$acme_out" | tail -10 | while IFS= read -r l; do echo -e "    ${C_GRAY}${l}${C_RESET}"; done

  # ── 处理"跳过续期"的情况 ──
  local acme_cert_path="$HOME/.acme.sh/${CFG_DOMAIN}_ecc/${CFG_DOMAIN}.cer"
  if [[ $issue_rc -ne 0 ]] && echo "$acme_out" | grep -qiE "Skipping|Next renewal"; then
    if [[ -f "$acme_cert_path" ]]; then
      info "现有证书仍然有效，直接使用"
      issue_rc=0
    else
      warn "强制重新签发..."
      sleep 3
      acme_out=$("$ACME_CMD" --issue -d "$CFG_DOMAIN" --standalone \
        --keylength ec-256 --listen-v4 --server letsencrypt --force 2>&1) || issue_rc=$?
      echo "$acme_out" | tail -10 | while IFS= read -r l; do echo -e "    ${C_GRAY}${l}${C_RESET}"; done
    fi
  fi

  if [[ $issue_rc -ne 0 ]] || [[ ! -f "$acme_cert_path" ]]; then
    warn "首次申请失败，清除缓存重试..."
    rm -rf "$HOME/.acme.sh/ca" "$HOME/.acme.sh/account.conf" 2>/dev/null || true
    "$ACME_CMD" --register-account -m "$CFG_EMAIL" --server letsencrypt 2>&1 | head -3 || true
    sleep 2
    issue_rc=0
    acme_out=$("$ACME_CMD" --issue -d "$CFG_DOMAIN" --standalone \
      --keylength ec-256 --listen-v4 --server letsencrypt --force 2>&1) || issue_rc=$?
    echo "$acme_out" | tail -10 | while IFS= read -r l; do echo -e "    ${C_GRAY}${l}${C_RESET}"; done
  fi

  if [[ $issue_rc -ne 0 ]] || [[ ! -f "$acme_cert_path" ]]; then
    fail "SSL 证书申请失败"
    info "请检查:"
    info "  • DNS A 记录必须指向此服务器的公网 IP"
    info "  • 端口 80 必须可从公网访问"
    info "  • 如果使用 Cloudflare，确保是 DNS-only（灰色云）"
    return 1
  fi
  ok "SSL 证书申请成功"

  "$ACME_CMD" --installcert -d "$CFG_DOMAIN" --ecc \
    --cert-file "${SSL_DIR}/cert.pem" \
    --key-file "$SSL_KEY" \
    --fullchain-file "$SSL_CERT" \
    --reloadcmd "systemctl restart xray 2>/dev/null || true" 2>&1 | tail -3

  if [[ -f "$SSL_CERT" && -f "$SSL_KEY" ]]; then
    chmod 644 "$SSL_CERT" 2>/dev/null || true
    chmod 640 "$SSL_KEY" 2>/dev/null || true
    chgrp nobody "$SSL_KEY" 2>/dev/null || true
    chmod o+x /etc/ssl/xhttp 2>/dev/null || true
    ok "SSL 证书安装完成 → $SSL_CERT"
  else
    fail "证书安装失败"
    return 1
  fi
}

# =============================================================
#  PHASE 4b — 配置 Xray (VLESS+XHTTP+TLS)
# =============================================================
phase4b_configure_xray() {
  step "阶段 4b — 配置 Xray VLESS+XHTTP+TLS"

  local XRAY_CFG="/usr/local/etc/xray/config.json"
  [[ -f "$XRAY_CFG" ]] && cp "$XRAY_CFG" "${XRAY_CFG}.bak" 2>/dev/null || true

  INBOUND_UUID=$(uuidgen 2>/dev/null | tr '[:upper:]' '[:lower:]')
  [[ -z "$INBOUND_UUID" ]] && INBOUND_UUID=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || echo "$(date +%s)-$$")
  info "生成的 UUID: ${INBOUND_UUID}"

  info "写入 Xray 配置 → ${XRAY_CFG}"
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
          "mode": "auto",
          "xPaddingBytes": "100-1000"
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

  local test_out
  test_out=$(xray -test -config "$XRAY_CFG" 2>&1 || true)
  if echo "$test_out" | grep -qi "configuration ok\|Configuration OK"; then
    ok "Xray 配置语法正确"
  else
    fail "Xray 配置测试失败: $test_out"
    return 1
  fi

  # ── 启动 Xray ──
  mkdir -p /etc/systemd/system/xray.service.d
  cat > /etc/systemd/system/xray.service.d/override.conf <<'OVERRIDE'
[Service]
User=root
Group=root
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=false
OVERRIDE

  chown -R root:root /var/log/xray 2>/dev/null || true
  systemctl daemon-reload 2>/dev/null || true
  systemctl restart xray 2>/dev/null || true
  systemctl enable xray 2>/dev/null || true
  sleep 3

  if systemctl is-active --quiet xray 2>/dev/null; then
    ok "Xray 运行中 (端口 ${CFG_INBOUND_PORT})"
  else
    fail "Xray 启动失败"
    journalctl -u xray -n 20 --no-pager 2>/dev/null || true
    return 1
  fi

  ok "UUID: ${INBOUND_UUID}"
}

# =============================================================
#  PHASE 5 — 本地健康检查
# =============================================================
phase5_healthcheck() {
  step "阶段 5 — 本地健康检查"

  info "测试本地 Xray 响应..."
  local http_code
  http_code=$(curl -sk --max-time 5 \
    "https://127.0.0.1:${CFG_INBOUND_PORT}${CFG_RELAY_PATH}" \
    -o /dev/null -w "%{http_code}" 2>/dev/null || echo "000")
  if echo "$http_code" | grep -qE "^(4[0-9]{2}|200)$"; then
    ok "本地测试通过 (HTTP $http_code)"
  else
    warn "本地测试返回 HTTP $http_code（XHTTP 协议下属于正常）"
  fi

  info "检查端口可达性..."
  local public_ip="${CFG_EXTERNAL_IP}"
  local public_port="${CFG_EXTERNAL_PORT:-$CFG_INBOUND_PORT}"
  if [[ -n "$public_ip" ]]; then
    local ext_result
    ext_result=$(curl -sk --max-time 5 "https://${public_ip}:${public_port}${CFG_RELAY_PATH}" \
      -o /dev/null -w "%{http_code}" 2>/dev/null || echo "超时/拒绝连接")
    if [[ "$ext_result" =~ ^(4[0-9]{2}|200|000)$ ]]; then
      ok "公网端口可达: ${public_ip}:${public_port} (HTTP $ext_result)"
    else
      warn "公网端口测试: $ext_result"
      warn "请检查 NAT 端口转发是否已配置"
    fi
  fi
}

# =============================================================
#  PHASE 6 — 生成客户端配置
# =============================================================
phase6_summary() {
  step "阶段 6 — 生成客户端配置"

  local SERVER="${CFG_EXTERNAL_IP:-$CFG_DOMAIN}"
  local PORT="${CFG_EXTERNAL_PORT:-$CFG_INBOUND_PORT}"
  local ENCODED_PATH
  ENCODED_PATH=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${CFG_RELAY_PATH}'))" 2>/dev/null || echo "${CFG_RELAY_PATH}")
  local EXTRA_JSON='{"xPaddingBytes":"100-1000"}'
  local ENCODED_EXTRA
  ENCODED_EXTRA=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=''))" "$EXTRA_JSON" 2>/dev/null || echo "$EXTRA_JSON")
  local CLIENT_LINK="vless://${INBOUND_UUID}@${SERVER}:${PORT}?encryption=none&security=tls&sni=${CFG_DOMAIN}&fp=chrome&alpn=h2%2Chttp%2F1.1&insecure=0&allowInsecure=0&type=xhttp&host=${CFG_DOMAIN}&path=${ENCODED_PATH}&mode=auto&extra=${ENCODED_EXTRA}#XHTTP-NAT"

  echo ""
  echo -e "${C_GREEN}"
  echo "  ╔══════════════════════════════════════════════════════════╗"
  echo "  ║                  安装完成  ✔                           ║"
  echo "  ╚══════════════════════════════════════════════════════════╝"
  echo -e "${C_RESET}"
  echo ""
  echo -e "  ${C_CYAN}── 服务器信息 ──${C_RESET}"
  echo -e "  ${C_WHITE}域名        :${C_RESET} ${CFG_DOMAIN}"
  echo -e "  ${C_WHITE}公网地址    :${C_RESET} ${SERVER}:${PORT}"
  echo -e "  ${C_WHITE}入站端口    :${C_RESET} ${CFG_INBOUND_PORT}"
  echo -e "  ${C_WHITE}转发路径    :${C_RESET} ${CFG_RELAY_PATH}"
  echo -e "  ${C_WHITE}UUID        :${C_RESET} ${C_YELLOW}${INBOUND_UUID}${C_RESET}"
  echo ""
  echo -e "  ${C_CYAN}── 客户端配置 (导入到 v2rayN / v2rayNG / Nekoray 等) ──${C_RESET}"
  echo ""
  echo -e "  ${C_YELLOW}${CLIENT_LINK}${C_RESET}"
  echo ""
  echo -e "  ${C_CYAN}── 后续可选：配置 CDN 转发 ──${C_RESET}"
  echo -e "  ${C_GRAY}你也可以用 Vercel 或 Netlify 作为前置 CDN 来隐藏服务器 IP。${C_RESET}"
  echo -e "  ${C_GRAY}在有足够内存的机器上运行 ZH_Deploy-Ubuntu.sh 完成 CDN 部署即可。${C_RESET}"
  echo -e "  ${C_GRAY}CDN 的 TARGET_DOMAIN 设为: ${C_WHITE}https://${CFG_DOMAIN}:${CFG_INBOUND_PORT}${C_RESET}"
  echo ""
  echo -e "  ${C_WHITE}管理命令:${C_RESET}"
  echo -e "  ${C_GRAY}  systemctl status xray   — 查看 Xray 状态${C_RESET}"
  echo -e "  ${C_GRAY}  systemctl restart xray  — 重启 Xray${C_RESET}"
  echo -e "  ${C_GRAY}  journalctl -u xray -f   — 查看实时日志${C_RESET}"
  echo ""
  echo -e "  ${C_GRAY}安装日志: ${LOG_FILE}${C_RESET}"
  echo -e "${C_GREEN}  ══════════════════════════════════════════════════════════${C_RESET}"
  echo ""
}

# =============================================================
#  ENTRYPOINT
# =============================================================
main() {
  print_banner
  echo -e "  ${C_MAGENTA}重要:${C_RESET} 请确保域名 DNS A 记录指向此服务器的公网 IP。"
  echo -e "  ${C_GRAY}提示: NAT 环境请确保端口转发已配置。随时按 Ctrl+C 中止。${C_RESET}"
  echo ""
  read -rp "$(echo -e "  ${C_WHITE}按 Enter 开始安装...${C_RESET}")"

  phase1_preflight
  phase2_install_light
  phase3_collect_input
  phase4a_ssl || { warn "SSL 失败，重试一次..."; phase4a_ssl || fail "SSL 失败"; }
  phase4b_configure_xray || { fail "Xray 配置失败"; exit 1; }
  phase5_healthcheck
  phase6_summary
}

main "$@"
