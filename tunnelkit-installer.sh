#!/bin/bash

# ---------------------- Color Definitions ----------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RESET='\033[0m'
BOLD='\033[1m'

# ---------------------- Uninstall Function ----------------------
uninstall_components() {
    clear
    echo -e "${BLUE}${BOLD}Uninstall Components Menu${RESET}"
    echo "1) 🌀 Uninstall Backhaul"
    echo "2) 🧱 Uninstall Chisel"
    echo "3) 🔁 Uninstall FRP"
    echo "4) 🛰 Uninstall V2Ray (Sanaei Panel)"
    echo "0) 🔙 Back to Main Menu"
    echo -n -e "${YELLOW}Choose a component to uninstall: ${RESET}"
    read uninstall_choice

    case $uninstall_choice in
        1)
            echo -e "${YELLOW}Uninstalling Backhaul...${RESET}"
            pkill backhaul
            rm -rf /usr/bin/backhaul /root/backhaul /etc/systemd/system/backhaul.service
            systemctl daemon-reexec
            echo -e "${GREEN}Backhaul removed.${RESET}"
            ;;
        2)
            echo -e "${YELLOW}Uninstalling Chisel...${RESET}"
            pkill chisel
            rm -rf /usr/bin/chisel /root/chisel /etc/systemd/system/chisel.service
            systemctl daemon-reexec
            echo -e "${GREEN}Chisel removed.${RESET}"
            ;;
        3)
            echo -e "${YELLOW}Uninstalling FRP...${RESET}"
            pkill frpc
            pkill frps
            rm -rf /usr/local/frp /etc/systemd/system/frp*.service
            systemctl daemon-reexec
            echo -e "${GREEN}FRP removed.${RESET}"
            ;;
        4)
            echo -e "${YELLOW}Uninstalling V2Ray...${RESET}"
            bash <(curl -Ls https://raw.githubusercontent.com/AlirezaSanaei/v2ray-sanaei/master/v2ray.sh) --remove
            ;;
        0)
            return
            ;;
        *)
            echo -e "${RED}Invalid choice.${RESET}"
            ;;
    esac

    echo -e "${YELLOW}Press Enter to continue...${RESET}"
    read
}

# ---------------------- Placeholder Install Functions ----------------------
install_backhaul() { echo -e "${YELLOW}Installing Backhaul...${RESET}"; sleep 1; }
install_chisel() { echo -e "${YELLOW}Installing Chisel...${RESET}"; sleep 1; }
install_frp() { echo -e "${YELLOW}Installing FRP...${RESET}"; sleep 1; }
install_v2ray() { echo -e "${YELLOW}Installing V2Ray (Sanaei Panel)...${RESET}"; sleep 1; }
apply_tcp_optimization() { echo -e "${YELLOW}Applying TCP Optimization...${RESET}"; sleep 1; }

# ---------------------- Main Menu ----------------------
main_menu() {
    while true; do
        clear
        echo -e "${BLUE}${BOLD}TunnelKit Menu${RESET}"
        echo "1) 🌀 Install Backhaul"
        echo "2) 🧱 Install Chisel"
        echo "3) 🔁 Install FRP"
        echo "4) 🛰  Install V2Ray (Sanaei Panel)"
        echo "5) ⚙️  Apply TCP Optimization"
        echo "6) 🧹 Uninstall Components"
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
            0) echo -e "${GREEN}Exiting TunnelKit. Goodbye!${RESET}"; exit 0 ;;
            *) echo -e "${RED}Invalid option. Try again.${RESET}"; sleep 1 ;;
        esac
    done
}

# ---------------------- Run Main Menu ----------------------
main_menu
