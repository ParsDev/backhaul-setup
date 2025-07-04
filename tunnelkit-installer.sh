
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
() {
    while true; do
        clear
        echo -e "${BLUE}Select Backhaul Mode${RESET}"
        echo -e "${BLUE}-----------------------${RESET}"
        echo "1) 🧩 Normal"
        echo "2) 🌐 Nginx with SSL"
        echo "3) ⚡ Hysteria 2"
        echo "4) ❌ Uninstall Backhaul"
        echo "0) 🔙 Return to Main Menu"
        echo -n -e "${YELLOW}Choose mode: ${RESET}"
        read mode
        case $mode in
            1) install_backhaul_normal ;;
            2) install_backhaul_nginx ;;
            3) install_backhaul_hysteria ;;
            4) uninstall_backhaul_all ;;
                        5) monitor_service backhaul ;;
            0) return ;;
            *) echo -e "${RED}Invalid option.${RESET}"; sleep 1 ;;
        esac
    done
}


    while true; do
        clear
        echo -e "${BLUE}${BOLD}Backhaul Installation Menu${RESET}"
        echo "1) Install Backhaul (Normal)"
        echo "2) Install Backhaul (via Nginx with SSL)"
        echo "3) Install Backhaul (Hysteria 2 with Config)"
        echo "0) Return to Main Menu"
        echo -n -e "${YELLOW}Choose a mode: ${RESET}"
        read choice
        case $choice in
            1)
                echo -e "${GREEN}Installing Backhaul (Normal)...${RESET}"
                wget -O /usr/bin/backhaul https://github.com/xpersian/Backhaul/releases/download/0.6.6/backhaul
                chmod +x /usr/bin/backhaul
                mkdir -p /root/backhaul
                read -p "Enter Backhaul server port (e.g. 3080): " BPORT
                read -p "Enter token: " BTOKEN
                cat <<EOF > /root/backhaul/config.toml
[server]
bind_addr = "0.0.0.0:${BPORT}"
transport = "tcp"
accept_udp = false
token = "${BTOKEN}"
keepalive_period = 75
nodelay = true
heartbeat = 40
channel_size = 2048
web_port = 2060
sniffer = false
log_level = "info"
ports = ["443=443", "80=80"]
EOF
                systemctl daemon-reexec
                echo -e "${GREEN}Backhaul (Normal) installed.${RESET}"
                sleep 2
                ;;
            2)
                echo -e "${YELLOW}Setting up Nginx reverse proxy with SSL for Backhaul...${RESET}"
                apt install nginx certbot python3-certbot-nginx -y
                read -p "Enter your domain (e.g., tunnel.example.com): " DOMAIN
                read -p "Enter local port to proxy to (e.g., 3080): " LOCAL_PORT

                cat > /etc/nginx/sites-available/backhaul <<EOF
server {
    listen 80;
    server_name ${DOMAIN};
    location / {
        proxy_pass http://127.0.0.1:${LOCAL_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
EOF
                ln -s /etc/nginx/sites-available/backhaul /etc/nginx/sites-enabled/backhaul
                nginx -t && systemctl reload nginx
                certbot --nginx -d ${DOMAIN}
                echo -e "${GREEN}Nginx + SSL configuration completed.${RESET}"
                sleep 2
                ;;
            3)
                echo -e "${YELLOW}Installing Hysteria 2 and configuring...${RESET}"
                bash <(curl -fsSL https://get.hy2.sh/)
                mkdir -p /etc/hysteria
                read -p "Enter password for Hysteria2 (client/server): " HYPASS
                cat > /etc/hysteria/config.yaml <<EOF
listen: :443
auth:
  type: password
  password: ${HYPASS}
tls:
  cert: /etc/hysteria/cert.pem
  key: /etc/hysteria/key.pem
masquerade:
  type: proxy
  proxy:
    url: https://www.wikipedia.org
    rewriteHost: true
EOF
                echo -e "${YELLOW}Paste your SSL cert PEM path (e.g., /etc/ssl/certs/ssl-cert.pem): ${RESET}"
                read cert
                echo -e "${YELLOW}Paste your SSL key PEM path (e.g., /etc/ssl/private/ssl-cert.key): ${RESET}"
                read key
                cp "$cert" /etc/hysteria/cert.pem
                cp "$key" /etc/hysteria/key.pem
                systemctl restart hysteria-server
                echo -e "${GREEN}Hysteria 2 installed and running with TLS.${RESET}"
                sleep 2
                ;;
            0)
                return ;;
            *)
                echo -e "${RED}Invalid option.${RESET}"
                sleep 2 ;;
        esac
    done
}

    while true; do
        clear
        echo -e "${BLUE}${BOLD}Backhaul Installation Menu${RESET}"
        echo "1) Install Backhaul (Normal)"
        echo "2) Install Backhaul (via Nginx)"
        echo "3) Install Backhaul (Hysteria 2)"
        echo "0) Return to Main Menu"
        echo -n -e "${YELLOW}Choose a mode: ${RESET}"
        read choice
        case $choice in
            1)
                echo -e "${GREEN}Installing Backhaul (Normal)...${RESET}"
                wget -O /usr/bin/backhaul https://github.com/xpersian/Backhaul/releases/download/0.6.6/backhaul
                chmod +x /usr/bin/backhaul
                mkdir -p /root/backhaul
                read -p "Enter Backhaul server port (e.g. 3080): " BPORT
                read -p "Enter token: " BTOKEN
                cat <<EOF > /root/backhaul/config.toml
[server]
bind_addr = "0.0.0.0:${BPORT}"
transport = "tcp"
accept_udp = false
token = "${BTOKEN}"
keepalive_period = 75
nodelay = true
heartbeat = 40
channel_size = 2048
web_port = 2060
sniffer = false
log_level = "info"
ports = ["443=443", "80=80"]
EOF
                systemctl daemon-reexec
                echo -e "${GREEN}Backhaul (Normal) installed.${RESET}"
                sleep 2
                ;;
            2)
                echo -e "${YELLOW}Setting up Nginx-based tunnel for Backhaul...${RESET}"
                apt install nginx -y
                cat > /etc/nginx/conf.d/backhaul.conf <<EOF
server {
    listen 443 ssl;
    server_name yourdomain.com;
    ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;

    location / {
        proxy_pass http://127.0.0.1:3080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
EOF
                systemctl reload nginx
                echo -e "${GREEN}Nginx-based reverse proxy for Backhaul configured.${RESET}"
                sleep 2
                ;;
            3)
                echo -e "${YELLOW}Installing Hysteria 2 for tunneling...${RESET}"
                bash <(curl -fsSL https://get.hy2.sh/)
                echo -e "${GREEN}Hysteria 2 installation complete. You can now configure it manually under /etc/hysteria/config.yaml.${RESET}"
                sleep 2
                ;;
            0) return ;;
            *) echo -e "${RED}Invalid option.${RESET}"; sleep 2 ;;
        esac
    done
}



main_menu() {
    while true; do
        clear
        echo -e "${BLUE}============== TunnelKit Unified Installer ==============${RESET}"
        echo
        echo -e "  ${BLUE}1)${RESET} Install Backhaul Tunnel"
        echo -e "  ${BLUE}2)${RESET} Install Chisel Tunnel"
        echo -e "  ${BLUE}3)${RESET} Install FRP Tunnel"
        echo -e "  ${BLUE}4)${RESET} Install Sanaei Panel"
        echo -e "  ${BLUE}5)${RESET} Apply TCP Optimizer"
        echo -e "  ${BLUE}6)${RESET} View Logs"
        echo -e "  ${BLUE}7)${RESET} Update Script"
        echo -e "  ${BLUE}8)${RESET} Uninstall Components"
        echo
        echo -e "  ${BLUE}0)${RESET} Exit"
        echo
        echo -n -e "${YELLOW}Choose an option: ${RESET}"
        read choice

        case $choice in
            1) install_backhaul_menu ;;
            2) install_chisel_menu ;;
            3) install_frp ;;
            4) install_v2ray_sanaei ;;
            5) apply_tcp_optimization ;;
            6) view_logs ;;
            7) update_script ;;
            8) uninstall_components ;;
            0) echo -e "${GREEN}Exiting...${RESET}"; exit 0 ;;
            *) echo -e "${RED}Invalid option!${RESET}"; sleep 1 ;;
        esac
    done
}


# Run the menu
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
            ;;
        2)
            systemctl stop chisel 2>/dev/null
            systemctl disable chisel 2>/dev/null
            rm -f /etc/systemd/system/chisel.service
            rm -rf /root/chisel /usr/local/bin/chisel
            echo -e "${GREEN}✔ Chisel uninstalled.${RESET}"
            ;;
        3)
            systemctl stop frps 2>/dev/null
            systemctl disable frps 2>/dev/null
            systemctl stop frpc 2>/dev/null
            systemctl disable frpc 2>/dev/null
            rm -f /etc/systemd/system/frps.service /etc/systemd/system/frpc.service
            rm -rf /root/frp /usr/local/bin/frps /usr/local/bin/frpc
            echo -e "${GREEN}✔ FRP uninstalled.${RESET}"
            ;;
        4)
            systemctl stop v2ray 2>/dev/null
            systemctl disable v2ray 2>/dev/null
            rm -f /etc/systemd/system/v2ray.service
            rm -rf /usr/local/etc/v2ray /usr/local/bin/v2ray /usr/local/bin/v2ctl /etc/v2ray /var/log/v2ray
            rm -rf /opt/v2ray-panel
            echo -e "${GREEN}✔ V2Ray and Sanaei Panel uninstalled.${RESET}"
            ;;
        5)
            sysctl -w net.core.default_qdisc=cake
            sysctl -w net.ipv4.tcp_congestion_control=cubic
            echo -e "${GREEN}✔ TCP optimizer reset to default.${RESET}"
            ;;
        0)
            return
            ;;
        *)
            echo -e "${RED}Invalid option.${RESET}"
            ;;
    esac
    systemctl daemon-reexec
    sleep 2
    pause
}


install_hysteria_client() {
    echo -e "${YELLOW}Installing Hysteria 2 Client...${RESET}"
    bash <(curl -fsSL https://get.hy2.sh/)
    mkdir -p /etc/hysteria
    read -p "Enter Hysteria server IP or domain: " SERVER_IP
    read -p "Enter password: " HYPASS
    read -p "Enter port to forward (e.g., 1080): " FORWARD_PORT
    cat > /etc/hysteria/config.yaml <<EOF
server: ${SERVER_IP}:443
auth: ${HYPASS}
up_mbps: 10
down_mbps: 50
socks5:
  listen: 127.0.0.1:${FORWARD_PORT}
EOF
    systemctl restart hysteria-client || true
    echo -e "${GREEN}Hysteria 2 Client configuration saved.${RESET}"
    sleep 2
}


install_chisel_client() {
    echo -e "${YELLOW}Installing Chisel Client...${RESET}"
    CHISEL_VERSION="1.7.7"
    wget -O /usr/local/bin/chisel https://github.com/jpillora/chisel/releases/download/${CHISEL_VERSION}/chisel_${CHISEL_VERSION}_linux_amd64.gz
    gunzip -f /usr/local/bin/chisel
    chmod +x /usr/local/bin/chisel
    read -p "Enter server address (e.g., 1.2.3.4:3333): " SERVER
    read -p "Enter remote port (e.g., R:2222:127.0.0.1:22): " PORT_MAP
    cat > /etc/systemd/system/chisel-client.service <<EOF
[Unit]
Description=Chisel Client
After=network.target

[Service]
ExecStart=/usr/local/bin/chisel client ${SERVER} ${PORT_MAP}
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reexec
    systemctl daemon-reload
    systemctl enable --now chisel-client
    echo -e "${GREEN}Chisel client service installed and started.${RESET}"
    sleep 2
}


install_backhaul_normal() {
    echo -e "${YELLOW}Installing Backhaul (Normal)...${RESET}"
    wget -O /usr/bin/backhaul https://github.com/xpersian/Backhaul/releases/download/0.6.6/backhaul
    chmod +x /usr/bin/backhaul
    mkdir -p /root/backhaul
    read -p "Enter Backhaul server port (e.g. 3080): " BPORT
    read -p "Enter token: " BTOKEN
    cat <<EOF > /root/backhaul/config.toml
[server]
bind_addr = "0.0.0.0:${BPORT}"
transport = "tcp"
accept_udp = false
token = "${BTOKEN}"
keepalive_period = 75
nodelay = true
heartbeat = 40
channel_size = 2048
web_port = 2060
sniffer = false
log_level = "info"
ports = ["443=443", "80=80"]
EOF
    echo -e "${GREEN}Backhaul (Normal) installed.${RESET}"
    sleep 2
}

install_backhaul_nginx() {
    echo -e "${YELLOW}Setting up Nginx reverse proxy with SSL for Backhaul...${RESET}"
    apt install nginx certbot python3-certbot-nginx -y
    read -p "Enter your domain (e.g., tunnel.example.com): " DOMAIN
    read -p "Enter local port to proxy to (e.g., 3080): " LOCAL_PORT
    cat > /etc/nginx/sites-available/backhaul <<EOF
server {
    listen 80;
    server_name ${DOMAIN};
    location / {
        proxy_pass http://127.0.0.1:${LOCAL_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
EOF
    ln -s /etc/nginx/sites-available/backhaul /etc/nginx/sites-enabled/backhaul
    nginx -t && systemctl reload nginx
    certbot --nginx -d ${DOMAIN}
    echo -e "${GREEN}Nginx + SSL configuration completed.${RESET}"
    sleep 2
}

install_backhaul_hysteria() {
    echo -e "${YELLOW}Installing Hysteria 2 and configuring...${RESET}"
    bash <(curl -fsSL https://get.hy2.sh/)
    mkdir -p /etc/hysteria
    read -p "Enter password for Hysteria2: " HYPASS
    cat > /etc/hysteria/config.yaml <<EOF
listen: :443
auth:
  type: password
  password: ${HYPASS}
tls:
  cert: /etc/hysteria/cert.pem
  key: /etc/hysteria/key.pem
masquerade:
  type: proxy
  proxy:
    url: https://www.wikipedia.org
    rewriteHost: true
EOF
    read -p "Paste path to SSL cert PEM: " cert
    read -p "Paste path to SSL key PEM: " key
    cp "$cert" /etc/hysteria/cert.pem
    cp "$key" /etc/hysteria/key.pem
    systemctl restart hysteria-server
    echo -e "${GREEN}Hysteria 2 installed and running.${RESET}"
    sleep 2
}


uninstall_backhaul_all() {
    echo -e "${YELLOW}Uninstalling all Backhaul modes...${RESET}"
    systemctl stop backhaul 2>/dev/null
    systemctl disable backhaul 2>/dev/null
    systemctl stop chisel-client 2>/dev/null
    systemctl disable chisel-client 2>/dev/null
    systemctl stop hysteria-server 2>/dev/null
    systemctl disable hysteria-server 2>/dev/null
    rm -f /usr/bin/backhaul /usr/local/bin/chisel
    rm -rf /root/backhaul /etc/hysteria /etc/systemd/system/chisel-client.service
    rm -f /etc/nginx/sites-available/backhaul /etc/nginx/sites-enabled/backhaul
    nginx -t && systemctl reload nginx
    echo -e "${GREEN}Backhaul (all modes) uninstalled.${RESET}"
    sleep 2
}


tunnel_install_menu() {
    while true; do
        clear
        echo -e "${BLUE}${BOLD}Tunnel Installation Menu${RESET}"
        echo "1) 🌀 Backhaul"
        echo "2) 🧱 Chisel"
        echo "3) 🔁 FRP"
        echo "4) 🛰 V2Ray (Sanaei Panel)"
        echo "0) 🔙 Back to Main Menu"
        echo -n -e "${YELLOW}Select a tunnel to install/configure: ${RESET}"
        read tunnel_choice
        case $tunnel_choice in
            1) tunnel_install_menu ;;
            2) install_chisel_menu ;;
            3) install_frp ;;
            4) install_v2ray_sanaei ;;
            0) return ;;
            *) echo -e "${RED}Invalid option.${RESET}"; sleep 1 ;;
        esac
    done
}
() {
    while true; do
        clear
        echo -e "${BLUE}Select Chisel Mode${RESET}"
        echo -e "${BLUE}----------------------${RESET}"
        echo "1) 🖥  Install Chisel as Server (Iran)"
        echo "2) 🌍 Install Chisel as Client (Foreign)"
        echo "4) 🔒 Install Chisel Client (Nginx HTTPS)"
        echo "3) 🌐 Install Chisel with Nginx (Reverse Proxy)"
        echo "3) ❌ Uninstall Chisel"
        echo "0) 🔙 Return to Main Menu"
        echo -n -e "${YELLOW}Choose mode: ${RESET}"
        read chisel_mode
        case $chisel_mode in
            4) install_chisel_client_nginx ;;
            1) install_chisel_server ;;
            2) install_chisel_client ;;
            
            3) install_chisel_nginx ;; uninstall_chisel ;;
                        6) monitor_service chisel ;;
            0) return ;;
            *) echo -e "${RED}Invalid option.${RESET}"; sleep 1 ;;
        esac
    done
}


install_chisel_nginx() {
    echo -e "${YELLOW}Installing Chisel + Nginx reverse proxy...${RESET}"
    apt update && apt install -y nginx certbot python3-certbot-nginx
    read -p "Enter your domain name (e.g., tunnel.example.com): " DOMAIN
    read -p "Enter Chisel backend port (e.g., 3333): " PORT

    # نصب chisel
    wget -O /usr/local/bin/chisel https://github.com/jpillora/chisel/releases/latest/download/chisel_linux_amd64.gz
    gunzip -f /usr/local/bin/chisel
    chmod +x /usr/local/bin/chisel

    # ایجاد systemd
    cat > /etc/systemd/system/chisel.service <<EOF
[Unit]
Description=Chisel Server (Nginx Proxy)
After=network.target

[Service]
ExecStart=/usr/local/bin/chisel server -p ${PORT} --reverse
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    # ایجاد nginx conf
    cat > /etc/nginx/sites-available/chisel <<EOF
server {
    listen 80;
    server_name ${DOMAIN};

    location / {
        proxy_pass http://127.0.0.1:${PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
EOF

    ln -sf /etc/nginx/sites-available/chisel /etc/nginx/sites-enabled/chisel
    nginx -t && systemctl reload nginx
    certbot --nginx -d ${DOMAIN}

    # فعال‌سازی chisel
    systemctl daemon-reexec
    systemctl daemon-reload
    systemctl enable --now chisel

    echo -e "${GREEN}Chisel is now running behind HTTPS proxy via nginx at https://${DOMAIN}.${RESET}"
    sleep 2
}


install_chisel_client_nginx() {
    echo -e "${YELLOW}Installing Chisel Client for Nginx Reverse Proxy...${RESET}"
    CHISEL_VERSION="1.7.7"
    wget -O /usr/local/bin/chisel https://github.com/jpillora/chisel/releases/download/${CHISEL_VERSION}/chisel_${CHISEL_VERSION}_linux_amd64.gz
    gunzip -f /usr/local/bin/chisel
    chmod +x /usr/local/bin/chisel
    read -p "Enter domain name of Nginx proxy (e.g., tunnel.example.com): " DOMAIN
    read -p "Enter remote mapping (e.g., R:2222:localhost:22): " REMOTE

    # تولید فایل client.json
    mkdir -p /etc/chisel
    cat > /etc/chisel/client.json <<EOF
{
  "server": "https://${DOMAIN}",
  "mapping": "${REMOTE}"
}
EOF

    # systemd service
    cat > /etc/systemd/system/chisel-client-nginx.service <<EOF
[Unit]
Description=Chisel Client (via Nginx HTTPS)
After=network.target

[Service]
ExecStart=/usr/local/bin/chisel client https://${DOMAIN} ${REMOTE}
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reexec
    systemctl daemon-reload
    systemctl enable --now chisel-client-nginx

    echo -e "${GREEN}Chisel client configured and client.json saved at /etc/chisel/client.json${RESET}"
    sleep 2
}


monitor_service() {
    SERVICE_NAME=$1
    echo -e "${YELLOW}Monitoring service: $SERVICE_NAME${RESET}"
    echo -e "${BLUE}Press Ctrl+C to exit.${RESET}"
    journalctl -fu "$SERVICE_NAME"
}

main_menu
