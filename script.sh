#!/bin/bash

# Check for dialog
if ! command -v dialog >/dev/null; then
    echo "Falta Dialog, instalalo porfa"
    exit 1
fi

# Funcion para submenu al entrar
show_info() {
    temp_service_list="/tmp/opened_services.txt"
    > "$temp_service_list"  # Limpiar o actualizar lista

    while true; do
        dialog --clear --title "Gestor de Cortafuegos - Opciones" \
        --menu "Selecciona una accion:" 20 60 9 \
        1 "Abrir un puerto" \
        2 "Abrir puerto según servicio" \
        3 "Mostrar puertos abiertos" \
        4 "Guardar configuracion actual del cortafuegos" \
        5 "Cargar configuracion del cortafuegos desde archivo" \
        6 "Mostrar estado del cortafuegos" \
        7 "Cerrar todos los puertos" \
        8 "Cerrar un puerto" \
        9 "Volver al menú principal" 2>info_choice.txt



        choice=$(<info_choice.txt)
        rm -f info_choice.txt
        clear

        case $choice in
            1)
                # Abrir puerto por numero
                dialog --inputbox "Ingresar puerto a abrir:" 8 40 2>port_input.txt
                port=$(<port_input.txt)
                rm -f port_input.txt

                if [ -n "$port" ]; then
                    sudo ufw allow "$port" && dialog --msgbox "Puerto $port ha sido abierto." 6 40
                else
                    dialog --msgbox "No se ingreso un puerto valido." 6 40
                fi
                ;;
            2)
                dialog --clear --title "Abrir puerto segun tarea" \
                --menu "Selecciona un servicio para abrir su puerto" 20 60 11 \
                1 "HTTP (80)" \
                2 "HTTPS (443)" \
                3 "FTP (21)" \
                4 "SSH (22)" \
                5 "SMTP (25)" \
                6 "DNS (53)" \
                7 "MySQL (3306)" \
                8 "PostgreSQL (5432)" \
                9 "RDP (3389)" \
                10 "VNC (5900)" \
                11 "Otro (Justifique dijo aquel)" \
                12 "Cancelar" 2>task_choice.txt


                task=$(<task_choice.txt)
                rm -f task_choice.txt
                clear

                case $task in
                1) sudo ufw allow 80 && echo "HTTP (80)" >> "$temp_service_list";;
                2) sudo ufw allow 443 && echo "HTTPS (443)" >> "$temp_service_list";;
                3) sudo ufw allow 21 && echo "FTP (21)" >> "$temp_service_list";;
                4) sudo ufw allow 22 && echo "SSH (22)" >> "$temp_service_list";;
                5) sudo ufw allow 25 && echo "SMTP (25)" >> "$temp_service_list";;
                6) sudo ufw allow 53 && echo "DNS (53)" >> "$temp_service_list";;
                7) sudo ufw allow 3306 && echo "MySQL (3306)" >> "$temp_service_list";;
                8) sudo ufw allow 5432 && echo "PostgreSQL (5432)" >> "$temp_service_list";;
                9) sudo ufw allow 3389 && echo "RDP (3389)" >> "$temp_service_list";;
                10) sudo ufw allow 5900 && echo "VNC (5900)" >> "$temp_service_list";;
                11)
                    dialog --inputbox "Ingresa numero puerto personalizado" 8 40 2>custom_port.txt
                    custom_port=$(<custom_port.txt)
                    rm -f custom_port.txt
                    if [ -n "$custom_port" ]; then
                        sudo ufw allow "$custom_port"
                        echo "Custom ($custom_port)" >> "$temp_service_list"
                        dialog --msgbox "Puerto $custom_port abierto." 6 40
                    else
                        dialog --msgbox "Puerto invalido." 6 40
                    fi
                    ;;

                12) ;; 
                
                esac


                # Menu de servicios abiertos
                if [ -s "$temp_service_list" ]; then
                    awk '{print NR, $0}' "$temp_service_list" > /tmp/service_menu.txt
                    dialog --title "Puertos Abiertos por Tarea" --menu "Puertos abiertos recientemente:" 15 50 10 $(cat /tmp/service_menu.txt) 2>/dev/null
                    rm -f /tmp/service_menu.txt
                fi
                ;;
            3)
                # Puertos abiertos
                open_ports=$(sudo ufw status | grep ALLOW || echo "No hay puertos abiertos.")
                dialog --title "Puertos Abiertos" --msgbox "$open_ports" 20 70
                ;;
            4)
                # Guardar configuracion de Cortaguegos
                dialog --inputbox "Nombre del archivo para guardar (sin extension):" 8 50 2>filename.txt
                fname=$(<filename.txt)
                rm -f filename.txt

                if [ -n "$fname" ]; then
                    sudo ufw status numbered > "${fname}.ufw"
                    dialog --msgbox "Configuracion guardada como ${fname}.ufw" 6 50
                else
                    dialog --msgbox "Nombre de archivo invalido." 6 40
                fi
                ;;
            5)
                # Cargar Archivo de cortaguegos
                dialog --fselect "./" 10 60 2>loadfile.txt
                loadfile=$(<loadfile.txt)
                rm -f loadfile.txt

                if [ -f "$loadfile" ]; then
                    dialog --yesno "Esto reiniciara las reglas actuales del cortafuegos. ¿Continuar?" 8 60
                    if [ $? -eq 0 ]; then
                        sudo ufw reset
                        while IFS= read -r port; do
                            # Validar que no sea línea vacia
                            [[ "$port" =~ ^#.*$ || -z "$port" ]] && continue
                            sudo ufw allow "$port"
                        done < "$loadfile"
                        sudo ufw enable
                        dialog --msgbox "Configuracion cargada desde $loadfile" 6 50
                    else
                        dialog --msgbox "Carga cancelada por el usuario." 6 40
                    fi
                else
                    dialog --msgbox "Archivo no encontrado." 6 40
                fi
                ;;

            6)
                # Show ufw status
                status=$(sudo ufw status verbose)
                dialog --title "Estado del Cortafuegos" --msgbox "$status" 20 70
                ;;
            7)
                dialog --yesno "Cerrar todos los puertos\nEsto resetea la config de los cortafuegos" 8 60
                response=$?
                if [ "$response" -eq 0 ]; then
                    sudo ufw reset && sudo ufw enable
                    dialog --msgbox "Todos los puertos cerrados y el cortafuegos fue reseteado." 6 60
                else
                    dialog --msgbox "Operacion cancelada." 6 40
                fi
                ;;
               

            8)
                dialog --inputbox "Ingresar puerto a cerrar (numero)" 8 40 2>close_port.txt
                close_port=$(<close_port.txt)
                rm -f close_port.txt

                if [ -n "$close_port" ]; then
                    sudo ufw deny "$close_port" && dialog --msgbox "Puerto $close_port ha sido cerrado." 6 40
                else
                    dialog --msgbox "No se ingreso un puerto valido." 6 40
                fi
                ;;


            9)  
                break
                ;;

            *)
                break
                ;;
        esac
    done
}

# pagina de miembros
show_members() {
    dialog --title "Miembro de quipo" --msgbox "Abel Solorzano 202110080028" 8 50
}


# Main
while true; do

    choice=$(dialog --clear --title "Gestor de Cortafuegos" \
        --menu "\nSeleccionar opciones" 15 50 3 \
        1 "Gestionar reglas" \
        2 "Miembro de grupo" \
        3 "Salir" 2>&1 >/dev/tty)

    clear

    # No empty espacio
    if [ -z "$choice" ]; then
        dialog --msgbox "No se selecciono ninguna opcion valida." 6 40
        continue
    fi

    # Actuar según la opcion seleccionada
    case $choice in
        1)
            show_info  
            ;;
        2)
            show_members  
            ;;
        3)
            break  
            ;;
        *)
            dialog --msgbox "Opcion no valida." 6 40
            ;;
    esac
done

clear
echo "ScriptCortafuego Terminado"
