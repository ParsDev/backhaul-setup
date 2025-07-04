
#!/bin/bash

# TunnelKit Installer Script
# Author: parsdev
# Version: 1.1

while true; do
  clear
  echo -e "\e[1;36m🔧 TunnelKit Installation Menu\e[0m"
  echo -e "\e[1;32m1)\e[0m Backhaul"
  echo -e "\e[1;32m2)\e[0m Chisel"
  echo -e "\e[1;32m3)\e[0m FRP"
  echo -e "\e[1;32m4)\e[0m V2Ray (Sanaei Panel)"
  echo -e "\e[1;31m0)\e[0m Exit"
  echo ""
  read -p "👉 Select an option: " opt

  case $opt in
    1)
      while true; do
        clear
        echo -e "\e[1;34m🔹 Backhaul Versions:\e[0m"
        echo -e "\e[1;33m1)\e[0m Normal"
        echo -e "\e[1;33m2)\e[0m Optimized"
        echo -e "\e[1;33m3)\e[0m TCPMUX Version"
        echo -e "\e[1;33m4)\e[0m Custom"
        echo -e "\e[1;31m0)\e[0m Return to Main Menu"
        read -p "🔍 Choose a version: " backhaul_opt
        case $backhaul_opt in
          1) echo -e "\e[1;36mInstalling Backhaul (Normal)...\e[0m"; sleep 2 ;;
          2) echo -e "\e[1;36mInstalling Backhaul (Optimized)...\e[0m"; sleep 2 ;;
          3) echo -e "\e[1;36mInstalling Backhaul (TCPMUX)...\e[0m"; sleep 2 ;;
          4) echo -e "\e[1;36mInstalling Backhaul (Custom)...\e[0m"; sleep 2 ;;
          0) break ;;
          *) echo -e "\e[1;31mInvalid option. Try again.\e[0m"; sleep 1 ;;
        esac
        read -p "✔️ Press enter to return to Backhaul Menu..."
      done
      ;;
    2)
      while true; do
        clear
        echo -e "\e[1;34m🔹 Chisel Versions:\e[0m"
        echo -e "\e[1;33m1)\e[0m Standard"
        echo -e "\e[1;33m2)\e[0m Optimized"
        echo -e "\e[1;33m3)\e[0m MUX Version"
        echo -e "\e[1;33m4)\e[0m Custom TCP Handling"
        echo -e "\e[1;31m0)\e[0m Return to Main Menu"
        read -p "🔍 Choose a version: " chisel_opt
        case $chisel_opt in
          1) echo -e "\e[1;36mInstalling Chisel (Standard)...\e[0m"; sleep 2 ;;
          2) echo -e "\e[1;36mInstalling Chisel (Optimized)...\e[0m"; sleep 2 ;;
          3) echo -e "\e[1;36mInstalling Chisel (MUX)...\e[0m"; sleep 2 ;;
          4) echo -e "\e[1;36mInstalling Chisel (Custom TCP)...\e[0m"; sleep 2 ;;
          0) break ;;
          *) echo -e "\e[1;31mInvalid option. Try again.\e[0m"; sleep 1 ;;
        esac
        read -p "✔️ Press enter to return to Chisel Menu..."
      done
      ;;
    3)
      while true; do
        clear
        echo -e "\e[1;34m🔹 FRP Installation:\e[0m"
        echo -e "\e[1;33m1)\e[0m Setup FRP Client"
        echo -e "\e[1;33m2)\e[0m Setup FRP Server"
        echo -e "\e[1;31m0)\e[0m Return to Main Menu"
        read -p "🔍 Choose a setup: " frp_opt
        case $frp_opt in
          1) echo -e "\e[1;36mInstalling FRP Client...\e[0m"; sleep 2 ;;
          2) echo -e "\e[1;36mInstalling FRP Server...\e[0m"; sleep 2 ;;
          0) break ;;
          *) echo -e "\e[1;31mInvalid option. Try again.\e[0m"; sleep 1 ;;
        esac
        read -p "✔️ Press enter to return to FRP Menu..."
      done
      ;;
    4)
      echo -e "\e[1;36mInstalling V2Ray Sanaei Panel...\e[0m"
      sleep 2
      read -p "✔️ Press enter to return to main menu..."
      ;;
    0)
      echo -e "\e[1;31m👋 Exiting TunnelKit... Goodbye!\e[0m"
      break
      ;;
    *)
      echo -e "\e[1;31m❌ Invalid option. Please try again.\e[0m"
      sleep 2
      ;;
  esac
done

