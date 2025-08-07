#!/bin/bash

# Check for dialog
if ! command -v dialog >/dev/null; then
    echo "This script requires 'dialog'. Please install it."
    exit 1
fi

# Function: Get CPU usage
get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | awk '{print "CPU Usage: " $2 "% user, " $4 "% system, " $8 "% idle"}'
}

# Function: Get open ports
get_open_ports() {
    ss -tuln | awk 'NR>1 {print $1, $5}' | sort | uniq
}

# Function: Get IPv4 address (non-loopback)
get_ipv4() {
    ip -4 addr show | awk '/inet/ && !/127.0.0.1/ {print $2}' | cut -d/ -f1
}

# Function: Show system info
show_info() {
    cpu=$(get_cpu_usage)
    ports=$(get_open_ports)
    ip=$(get_ipv4)

    dialog --title "System Info" --msgbox "📊 $cpu\n\n🌐 IPv4 Address(es):\n$ip\n\n🔓 Open Ports:\n$ports" 20 70
}

# Main menu
while true; do
    dialog --clear --title "System Info Script" \
        --menu "Choose an option:" 12 40 2 \
        1 "Start" \
        2 "Exit" 2>choice.txt

    choice=$(<choice.txt)
    rm -f choice.txt
    clear

    case $choice in
        1)
            show_info
            ;;
        2)
            break
            ;;
        *)
            break
            ;;
    esac
done

clear
echo "Goodbye!"
