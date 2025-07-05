#!/bin/bash

CONFIG_PATH="/root/backhaul/config.toml"
SERVICE_FILE="/etc/systemd/system/backhaul.service"
BACKHAUL_BIN="/usr/bin/backhaul"

show_menu() {
  clear
  echo "===== Backhaul Tunnel Setup ====="
  echo "1. Install Backhaul (Normal)"
  echo "2. Install Backhaul with Nginx (Reverse SSL)"
  echo "3. TCP Optimizer"
  echo "4. Monitor Backhaul"
  echo "5. Uninstall Backhaul and Nginx"
  echo "0. Exit"
  echo "================================="
  read -p "Select an option: " choice
  case $choice in
    1) install_backhaul_normal ;;
    2) install_backhaul_nginx ;;
    3) optimize_tcp ;;
    4) monitor_backhaul ;;
    5) uninstall_all ;;
    0) exit 0 ;;
    *) echo "Invalid choice!" && sleep 2 && show_menu ;;
  esac
}

install_backhaul_dependencies() {
  apt update -y
  apt install -y curl wget unzip git nginx socat cron jq
}

install_backhaul_binary() {
  mkdir -p /root/backhaul
  cd /root/backhaul
  curl -L -o backhaul.zip https://github.com/xpersian/Backhaul/releases/latest/download/backhaul-linux-amd64.zip
  unzip -o backhaul.zip
  chmod +x backhaul
  mv -f backhaul "$BACKHAUL_BIN"
}

setup_backhaul_service() {
  cat <<EOF > $SERVICE_FILE
[Unit]
Description=Backhaul Tunnel Service
After=network.target

[Service]
ExecStart=$BACKHAUL_BIN -c $CONFIG_PATH
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reexec
  systemctl daemon-reload
  systemctl enable backhaul
  systemctl restart backhaul
}

install_backhaul_normal() {
  echo "Select Mode:"
  echo "1) Server (IR)"
  echo "2) Client (Out)"
  read -p "Enter choice: " mode

  read -p "Enter token (your_token): " token
  read -p "Enter tunnel port (tport): " tport

  if [[ $mode == 1 ]]; then
    read -p "Enter comma-separated ports (e.g. 8080,443,8443): " ports
    IFS=',' read -ra PORT_ARRAY <<< "$ports"
    port_entries=""
    for p in "${PORT_ARRAY[@]}"; do
      port_entries+="port=$p,"
    done
    port_entries="${port_entries%,}"

    mkdir -p /root/backhaul
    cat <<EOF > $CONFIG_PATH
[server]
bind_addr = "0.0.0.0:$tport"
transport = "tcp"
token = "$token"
keepalive_period = 75
nodelay = true
heartbeat = 40
channel_size = 2048
mux_con = 8
mux_version = 2
mux_framesize = 32768
mux_recievebuffer = 4194304
mux_streambuffer = 65536
sniffer = false
web_port = 2060
sniffer_log = "/root/backhaul.json"
log_level = "info"
ports = [$port_entries]
EOF

  elif [[ $mode == 2 ]]; then
    read -p "Enter server IP (IRIP): " irip
    mkdir -p /root/backhaul
    cat <<EOF > $CONFIG_PATH
[client]
remote_addr = "$irip:$tport"
transport = "tcp"
token = "$token"
connection_pool = 8
aggressive_pool = false
keepalive_period = 75
dial_timeout = 10
retry_interval = 3
nodelay = true
mux_version = 2
mux_framesize = 32768
mux_recievebuffer = 4194304
mux_streambuffer = 65536
sniffer = false
web_port = 2060
sniffer_log = "/root/backhaul.json"
log_level = "info"
EOF

  else
    echo "Invalid mode" && sleep 2 && show_menu
  fi

  install_backhaul_dependencies
  install_backhaul_binary
  setup_backhaul_service

  echo "✅ Backhaul installed and running."
  sleep 3
  show_menu
}

install_backhaul_nginx() {
  install_backhaul_normal

  echo "🔐 Setting up NGINX Reverse Proxy with SSL..."
  read -p "Enter domain name (e.g. tunnel.example.com): " domain

  apt install -y socat
  curl https://get.acme.sh | sh
  ~/.acme.sh/acme.sh --issue --standalone -d $domain --force
  mkdir -p /etc/nginx/ssl
  ~/.acme.sh/acme.sh --install-cert -d $domain     --key-file /etc/nginx/ssl/$domain.key     --fullchain-file /etc/nginx/ssl/$domain.crt     --reloadcmd "systemctl reload nginx"

  cat <<EOF > /etc/nginx/sites-available/backhaul
server {
    listen 443 ssl;
    server_name $domain;

    ssl_certificate     /etc/nginx/ssl/$domain.crt;
    ssl_certificate_key /etc/nginx/ssl/$domain.key;

    location / {
        proxy_pass http://127.0.0.1:2060;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

  ln -sf /etc/nginx/sites-available/backhaul /etc/nginx/sites-enabled/backhaul
  nginx -t && systemctl reload nginx

  echo "✅ NGINX Reverse Proxy with SSL setup complete."
  sleep 3
  show_menu
}

optimize_tcp() {
  echo "🔧 Applying advanced TCP optimizations..."

  cat <<EOF >> /etc/sysctl.conf

# TCP Optimization
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_fastopen = 3
net.core.netdev_max_backlog = 250000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 10240 65535
net.ipv4.tcp_fin_timeout = 15
EOF

  sysctl -p

  echo "✅ TCP settings optimized."
  sleep 3
  show_menu
}

monitor_backhaul() {
  echo "📊 Monitoring Backhaul Logs (Press Ctrl+C to stop)"
  journalctl -u backhaul -f
}

uninstall_all() {
  echo "❌ Uninstalling Backhaul and Nginx..."

  systemctl stop backhaul
  systemctl disable backhaul
  rm -f $SERVICE_FILE
  systemctl daemon-reload

  rm -rf /root/backhaul
  rm -f $BACKHAUL_BIN
  rm -rf /etc/nginx/sites-available/backhaul
  rm -rf /etc/nginx/sites-enabled/backhaul
  rm -rf /etc/nginx/ssl
  apt purge -y nginx socat

  echo "✅ Uninstallation complete."
  sleep 2
  show_menu
}

show_menu
