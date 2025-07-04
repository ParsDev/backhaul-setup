
#!/bin/bash

# TunnelKit Installer Script
# Author: parsdev (customized by ChatGPT)
# GitHub: https://github.com/parsdev/tunnelkit

clear
echo -e "\e[1;36mTunnelKit Installation Menu\e[0m"
echo "1) Install Backhaul"
echo "2) Install Chisel"
echo "3) Install FRP"
echo "4) Install V2Ray (Sanaei Panel)"
echo "0) Exit"
read -p "Select an option: " opt

case $opt in
  1)
    echo -e "\e[1;33mInstalling Backhaul...\e[0m"
    # Installation steps placeholder
    ;;
  2)
    echo -e "\e[1;33mInstalling Chisel...\e[0m"
    # Installation steps placeholder
    ;;
  3)
    echo -e "\e[1;33mInstalling FRP...\e[0m"
    # Installation steps placeholder
    ;;
  4)
    echo -e "\e[1;33mInstalling V2Ray Sanaei Panel...\e[0m"
    # Installation steps placeholder
    ;;
  0)
    echo -e "\e[1;31mExiting...\e[0m"
    exit 0
    ;;
  *)
    echo -e "\e[1;31mInvalid option. Try again.\e[0m"
    ;;
esac
