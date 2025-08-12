#!/bin/bash

# Versión del sistema operativo
SO_VERSION=$(uname -sr)

# Procesador
CPU=$(grep -m 1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')

# Uso de CPU (sumando user + system)
USO_CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')

# Información de red
IP=$(ip addr show | awk '/inet / && !/127.0.0.1/ {print $2}' | head -n1 | cut -d/ -f1)
GATEWAY=$(ip route | awk '/default/ {print $3}' | head -n1)
MASCARA=$(ipcalc "$IP" 2>/dev/null | grep Netmask | awk '{print $2}')

# Usuario actual
USUARIO=$(whoami)

# Tiempo desde arranque
TIEMPO_ENCENDIDO=$(uptime -p)

# Construir mensaje con heredoc para evitar errores
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
dialog --title "Informe del Sistema Linux" --msgbox "$MENSAJE" 15 70
clear
