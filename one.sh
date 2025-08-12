import time
import os

def barra(valor, maximo, longitud=50):
    proporción = valor / maximo
    llenos = int(proporción * longitud)
    vacíos = longitud - llenos
    return '[' + '#' * llenos + '-' * vacíos + f'] {valor:02d}/{maximo}'

def reloj_barras():
    try:
        while True:
            ahora = time.localtime()
            hora = ahora.tm_hour
            minuto = ahora.tm_min
            segundo = ahora.tm_sec

            os.system('clear')  

            print("🕒  Reloj de Barras de Progreso (Consola)\n")
            print("Horas  :", barra(hora, 23))
            print("Minutos:", barra(minuto, 59))
            print("Segundos:", barra(segundo, 59))

            time.sleep(1)
    except KeyboardInterrupt:
        print("\nReloj detenido.")

if __name__ == "__main__":
    reloj_barras()
