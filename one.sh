import psutil
import time
import os

def mostrar_uso():
    try:
        while True:
            uso_cpu = psutil.cpu_percent(interval=1)
            mem = psutil.virtual_memory()
            total = mem.total / (1024 ** 2) 
            usado = mem.used / (1024 ** 2)
            libre = mem.available / (1024 ** 2)
            porcentaje_mem = mem.percent

            # Limpiar pantalla
            os.system('clear')

            print("Visor de Uso de CPU y Memoria RAM\n")
            print(f"Uso de CPU      : {uso_cpu:.2f}%")
            print(f"Memoria Total   : {total:.2f} MB")
            print(f"Memoria Usada   : {usado:.2f} MB")
            print(f"Memoria Libre   : {libre:.2f} MB")
            print(f"Uso de Memoria  : {porcentaje_mem:.2f}%")

            print("\n(Actualizando cada 3 s)")
            time.sleep(3)

    except KeyboardInterrupt:
        print("\nMonitoreo detenido.")

if __name__ == "__main__":
    mostrar_uso()
