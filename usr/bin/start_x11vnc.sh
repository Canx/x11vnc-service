#!/bin/bash

# Encontrar todos los archivos en /var/run/sddm/
echo "Buscando archivos en /var/run/sddm/"
files=$(ls -t /var/run/sddm/*)

# Inicializar variables
highest_display=""
highest_display_value=-1
highest_file=""

# Iterar sobre cada archivo encontrado
for file in $files; do
  echo "Revisando archivo: $file"
  # Listar las cookies de autenticación en el archivo y procesarlas
  xauth_output=$(xauth -f "$file" list)
  while IFS= read -r line; do
    echo "Línea encontrada en xauth: $line"
    # Obtener el display de la línea
    display=$(echo $line | awk '{print $1}' | grep -Eo ':[0-9]+$')

    # Verificar si se encontró un display
    if [ -n "$display" ]; then
      echo "Display encontrado: $display"
      # Convertir el display a un número para comparación
      display_value=$(echo $display | grep -Eo '[0-9]+')
      echo "Valor del display: $display_value"

      # Verificar si el display es el más alto encontrado hasta ahora
      if [ "$display_value" -gt "$highest_display_value" ]; then
        echo "Nuevo display más alto encontrado: $display (archivo: $file)"
        highest_display=$display
        highest_display_value=$display_value
        highest_file=$file
      fi
    else
      echo "No se encontró un display en la línea: $line"
    fi
  done <<< "$xauth_output"
done

# Depuración adicional después del bucle
echo "Display más alto final: $highest_display"
echo "Archivo más alto final: $highest_file"

# Verificar si se encontró un display válido
if [ -z "$highest_display" ]; then
  echo "Error: No se encontró ningún archivo Xauthority válido."
  exit 1
fi

# Configurar las variables de entorno con el display más alto
export SDDMXAUTH=$highest_file
export DISPLAY=$highest_display

echo "SDDMXAUTH configurado en $highest_file"
echo "DISPLAY configurado en $highest_display"

# Ejecutar x11vnc con las variables de entorno configuradas
exec /usr/bin/x11vnc -display $DISPLAY -auth $SDDMXAUTH -forever -shared -bg -o /var/log/x11vnc.log -rfbauth /etc/x11vnc.passwd -noxdamage
