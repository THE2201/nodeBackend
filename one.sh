#!/bin/sh

OS=$(uname -s)

SO_VERSION=$(uname -sr)

if [ "$OS" = "FreeBSD" ]; then
    CPU=$(sysctl -n hw.model)
else
    CPU=$(grep -m 1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')
fi

if [ "$OS" = "FreeBSD" ]; then
    USO_CPU=$(top -d1 | grep "CPU:" | awk '{print $3}' | cut -d% -f1)
else
    USO_CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
fi

if command -v ip >/dev/null 2>&1; then
    IP=$(ip addr show | awk '/inet / && !/127.0.0.1/ {print $2}' | cut -d/ -f1 | head -n1)
    GATEWAY=$(ip route | awk '/default/ {print $3}' | head -n1)
    MASCARA=$(ipcalc "$IP" 2>/dev/null | grep Netmask | awk '{print $2}')
else
    IP=$(ifconfig | awk '/inet / && $2 != "127.0.0.1" {print $2}' | head -n1)
    GATEWAY=$(netstat -rn | awk '/default/ {print $2}' | head -n1)
    MASCARA=$(ifconfig | awk '/inet / && $2 != "127.0.0.1" {print $4}' | head -n1)
fi


USUARIO=$(whoami)

TIEMPO_ENCENDIDO=$(uptime -p 2>/dev/null || uptime | cut -d',' -f1)

MENSAJE=$(cat <<EOF
Sistema Operativo  : $SO_VERSION
Procesador         : $CPU
Uso de CPU         : ${USO_CPU:-N/D}%
IP                 : ${IP:-N/D}
Máscara de red     : ${MASCARA:-N/D}
Gateway            : ${GATEWAY:-N/D}
Usuario actual     : $USUARIO
Tiempo encendido   : $TIEMPO_ENCENDIDO
EOF
)

# Mostrar cuadro de diálogo
dialog --title "Informe del Sistema" --msgbox "$MENSAJE" 20 72
clear
