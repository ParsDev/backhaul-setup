
set -e
trap "echo -e '\n${RED}✖ An error occurred. Exiting.${RESET}'" ERR
#!/bin/bash

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[36m"
BOLD="\e[1m"
RESET="\e[0m"

# Draw title
clear
echo -e "${BLUE}${BOLD}"
echo "╔════════════════════════════════════════════╗"
echo "║       TunnelKit Unified Installer v1.1     ║"
echo "╚════════════════════════════════════════════╝"
echo -e "${RESET}"

# Utilities
pause() {
    read -p "$(echo -e ${YELLOW}Press Enter to return to menu...${RESET})"
}

# TCP Optimizer
tcp_optimizer() {
    echo -e "${BLUE}Applying TCP Optimization...${RESET}"
    cat >> /etc/sysctl.conf <<EOF

# TCP Optimization
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_fastopen=3
net.core.netdev_max_backlog=250000
net.core.somaxconn=65535
net.ipv4.tcp_max_syn_backlog=8192
net.ipv4.ip_local_port_range=10000 65000
EOF

    sysctl -p
    echo -e "${GREEN}✅ TCP settings applied.${RESET}"
    pause
}

# Backhaul Installer
install_backhaul() {
    echo -e "${YELLOW}[Installing Backhaul Tunnel]${RESET}"
    BACKHAUL_URL="https://github.com/xpersian/Backhaul/releases/download/0.6.6/backhaul"
    INSTALL_DIR="/usr/bin"
    CONFIG_DIR="/root/backhaul"
    CONFIG_FILE="${CONFIG_DIR}/config.toml"

    mkdir -p $CONFIG_DIR
    curl -L -o /usr/bin/backhaul $BACKHAUL_URL
    chmod +x /usr/bin/backhaul

    echo -e "${BLUE}Is this server in ${BOLD}Iran${RESET}${BLUE} or ${BOLD}Outside${RESET}${BLUE}?${RESET}"
    select LOC in "Iran (Server)" "Outside (Client)"; do
        case $LOC in
        "Iran (Server)")
            read -p "Enter token to use: " TOKEN
            read -p "Enter tunnel bind port (e.g. 3080): " BIND_PORT
            read -p "Enter ports to forward (e.g. \"443=443\", \"80=80\"): " PORTS
            cat > $CONFIG_FILE <<EOF
[server]
bind_addr = "0.0.0.0:${BIND_PORT}"
transport = "tcp"
accept_udp = false
token = "${TOKEN}"
keepalive_period = 75
nodelay = true
heartbeat = 40
channel_size = 2048
sniffer = false
web_port = 2060
sniffer_log = "/root/backhaul.json"
log_level = "info"
ports = [${PORTS}]
mux_version = 2
mux_framesize = 32768
mux_recievebuffer = 4194304
mux_streambuffer = 65536
EOF
            ;;
        "Outside (Client)")
            read -p "Enter server IP (Iran): " SERVER_IP
            read -p "Enter token: " TOKEN
            cat > $CONFIG_FILE <<EOF
[client]
remote_addr = "${SERVER_IP}:3080"
transport = "tcp"
token = "${TOKEN}"
connection_pool = 8
aggressive_pool = false
keepalive_period = 75
dial_timeout = 10
nodelay = true
retry_interval = 3
sniffer = false
web_port = 2060
sniffer_log = "/root/backhaul.json"
log_level = "info"
mux_version = 2
mux_framesize = 32768
mux_recievebuffer = 4194304
mux_streambuffer = 65536
EOF
            ;;
        esac
        break
    done

    # Systemd Service
    cat > /etc/systemd/system/backhaul.service <<EOF
[Unit]
Description=Backhaul Tunnel Service
After=network.target

[Service]
ExecStart=/usr/bin/backhaul -c ${CONFIG_FILE}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reexec
    systemctl daemon-reload
    systemctl enable backhaul
    systemctl restart backhaul

    echo -e "${GREEN}✅ Backhaul installation complete.${RESET}"
    pause
}

# Placeholder for other installers
install_chisel() {
    echo -e "${YELLOW}[🔧 Chisel installer coming next...]${RESET}"
    pause
}

install_frp() {
    echo -e "${YELLOW}[🔧 FRP installer coming next...]${RESET}"
    pause
}

install_v2ray() {
    echo -e "${YELLOW}[🔧 V2Ray (Sanaei Panel) installer coming next...]${RESET}"
    pause
}

# Main Menu

main_menu() {
    while true; do
        clear
        echo -e "${BLUE}${BOLD}TunnelKit Menu${RESET}"
        echo "1) 🌀 Install Backhaul"
        echo "2) 🧱 Install Chisel"
        echo "3) 🔁 Install FRP"
        echo "4) 🛰  Install V2Ray (Sanaei Panel)"
        echo "5) ⚙️  Apply TCP Optimization"
        echo "6) 🗑️  Uninstall Components"
        echo "0) ❌ Exit"
        echo -n -e "${YELLOW}Choose an option: ${RESET}"
        read choice
        case $choice in
            1) install_backhaul ;;
            2) install_chisel ;;
            3) install_frp ;;
            4) install_v2ray ;;
            5) apply_tcp_optimization ;;
            6) uninstall_components ;;
            0) exit 0 ;;
            *) echo -e "${RED}Invalid option!${RESET}"; sleep 2 ;;
        esac
    done
}


# Run the menu
main_menu


# Chisel Installer
install_chisel() {
    echo -e "${YELLOW}[Installing Chisel Tunnel]${RESET}"
    CHISEL_URL="https://github.com/jpillora/chisel/releases/latest/download/chisel_linux_amd64.gz"
    INSTALL_DIR="/usr/bin"
    CONFIG_DIR="/root/chisel"
    CONFIG_FILE="${CONFIG_DIR}/chisel.service"

    mkdir -p $CONFIG_DIR
    curl -L $CHISEL_URL -o ${CONFIG_DIR}/chisel.gz
    gunzip -f ${CONFIG_DIR}/chisel.gz
    mv ${CONFIG_DIR}/chisel_linux_amd64 ${INSTALL_DIR}/chisel
    chmod +x ${INSTALL_DIR}/chisel

    echo -e "${BLUE}Is this server in ${BOLD}Iran${RESET}${BLUE} or ${BOLD}Outside${RESET}${BLUE}?${RESET}"
    select LOC in "Iran (Server)" "Outside (Client)"; do
        case $LOC in
        "Iran (Server)")
            read -p "Enter Chisel port to bind (e.g. 3000): " BIND_PORT
            read -p "Enter user (format user:pass): " USERPASS

            cat > /etc/systemd/system/chisel.service <<EOF
[Unit]
Description=Chisel Server
After=network.target

[Service]
ExecStart=/usr/bin/chisel server -p ${BIND_PORT} --auth ${USERPASS}
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
            ;;
        "Outside (Client)")
            read -p "Enter Server IP:PORT to connect to (e.g. 1.2.3.4:3000): " SERVER
            read -p "Enter user (format user:pass): " USERPASS
            read -p "Enter local port:remote port (e.g. 2222:127.0.0.1:22): " PORTMAP

            cat > /etc/systemd/system/chisel.service <<EOF
[Unit]
Description=Chisel Client
After=network.target

[Service]
ExecStart=/usr/bin/chisel client --auth ${USERPASS} ${SERVER} ${PORTMAP}
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
            ;;
        esac
        break
    done

    systemctl daemon-reexec
    systemctl daemon-reload
    systemctl enable chisel
    systemctl restart chisel

    echo -e "${GREEN}✅ Chisel installation complete.${RESET}"
    pause
}


# FRP Installer
install_frp() {
    echo -e "${YELLOW}[Installing FRP Tunnel]${RESET}"
    FRP_VERSION="0.53.4"
    FRP_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz"
    CONFIG_DIR="/root/frp"
    INSTALL_DIR="/usr/local/bin"

    mkdir -p $CONFIG_DIR
    cd $CONFIG_DIR
    curl -L $FRP_URL -o frp.tar.gz
    tar -xzf frp.tar.gz --strip-components=1
    rm -f frp.tar.gz

    cp frps frpc $INSTALL_DIR
    chmod +x $INSTALL_DIR/frps $INSTALL_DIR/frpc

    echo -e "${BLUE}Is this server in ${BOLD}Iran${RESET}${BLUE} (Client) or ${BOLD}Outside${RESET}${BLUE} (Server)?${RESET}"
    select LOC in "Iran (Client)" "Outside (Server)"; do
        case $LOC in
        "Outside (Server)")
            read -p "Enter FRP Bind Port (e.g. 7000): " BIND_PORT
            read -p "Enter Dashboard Port (e.g. 7500): " DASHBOARD_PORT
            read -p "Enter Dashboard User: " DASH_USER
            read -p "Enter Dashboard Password: " DASH_PASS
            read -p "Enter Auth Token: " AUTH_TOKEN

            cat > /etc/systemd/system/frps.service <<EOF
[Unit]
Description=FRP Server
After=network.target

[Service]
ExecStart=/usr/local/bin/frps -c /root/frp/frps.ini
Restart=always

[Install]
WantedBy=multi-user.target
EOF

            cat > $CONFIG_DIR/frps.ini <<EOF
[common]
bind_port = ${BIND_PORT}
dashboard_port = ${DASHBOARD_PORT}
dashboard_user = ${DASH_USER}
dashboard_pwd = ${DASH_PASS}
token = ${AUTH_TOKEN}
EOF
            ;;
        "Iran (Client)")
            read -p "Enter Server Public IP: " SERVER_IP
            read -p "Enter FRP Server Port (e.g. 7000): " SERVER_PORT
            read -p "Enter Auth Token: " AUTH_TOKEN
            read -p "Enter Local SSH Port (default 22): " SSH_PORT
            SSH_PORT=${SSH_PORT:-22}
            read -p "Enter Remote Port (e.g. 6000): " REMOTE_PORT

            cat > /etc/systemd/system/frpc.service <<EOF
[Unit]
Description=FRP Client
After=network.target

[Service]
ExecStart=/usr/local/bin/frpc -c /root/frp/frpc.ini
Restart=always

[Install]
WantedBy=multi-user.target
EOF

            cat > $CONFIG_DIR/frpc.ini <<EOF
[common]
server_addr = ${SERVER_IP}
server_port = ${SERVER_PORT}
token = ${AUTH_TOKEN}

[ssh]
type = tcp
local_ip = 127.0.0.1
local_port = ${SSH_PORT}
remote_port = ${REMOTE_PORT}
EOF
            ;;
        esac
        break
    done

    systemctl daemon-reload
    if [[ "$LOC" == "Iran (Client)" ]]; then
        systemctl enable frpc
        systemctl restart frpc
    else
        systemctl enable frps
        systemctl restart frps
    fi

    echo -e "${GREEN}✅ FRP installation complete.${RESET}"
    pause
}


# ================== UNINSTALL COMPONENTS ==================

uninstall_components() {
    while true; do
        clear
        echo -e "${BLUE}========== Uninstall Tunnel Components ==========${RESET}"
        echo -e " ${BLUE}1)${RESET} Uninstall ${YELLOW}Backhaul${RESET}"
        echo -e " ${BLUE}2)${RESET} Uninstall ${YELLOW}Chisel${RESET}"
        echo -e " ${BLUE}3)${RESET} Uninstall ${YELLOW}FRP${RESET}"
        echo -e " ${BLUE}4)${RESET} Uninstall ${YELLOW}V2Ray (Sanaei Panel)${RESET}"
        echo -e " ${BLUE}5)${RESET} Uninstall ${YELLOW}TCP Optimizer${RESET}"
        echo -e " ${BLUE}0)${RESET} Return to Main Menu"
        echo
        read -p "Select a component to uninstall: " choice
        case $choice in
            1)
                systemctl stop backhaul 2>/dev/null
                systemctl disable backhaul 2>/dev/null
                rm -f /etc/systemd/system/backhaul.service
                rm -rf /root/backhaul /usr/bin/backhaul
                echo -e "${GREEN}✔ Backhaul uninstalled.${RESET}"
                sleep 2;;
            2)
                pkill -f chisel 2>/dev/null || true
                rm -rf /usr/bin/chisel
                echo -e "${GREEN}✔ Chisel uninstalled.${RESET}"
                sleep 2;;
            3)
                systemctl stop frpc 2>/dev/null; systemctl disable frpc 2>/dev/null
                systemctl stop frps 2>/dev/null; systemctl disable frps 2>/dev/null
                rm -f /etc/systemd/system/frpc.service /etc/systemd/system/frps.service
                rm -rf /root/frp*
                echo -e "${GREEN}✔ FRP uninstalled.${RESET}"
                sleep 2;;
            4)
                bash <(curl -Ls https://raw.githubusercontent.com/SanaeiDev/SanaeiPanel/main/uninstall.sh)
                echo -e "${GREEN}✔ V2Ray uninstalled.${RESET}"
                sleep 2;;
            5)
                sysctl -w net.ipv4.tcp_congestion_control=cubic
                echo -e "${GREEN}✔ TCP Optimization settings reset to default.${RESET}"
                sleep 2;;
            0)
                return;;
            *) echo -e "${RED}Invalid option. Please try again.${RESET}"; sleep 1;;
        esac
    done
}
