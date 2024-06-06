#!/bin/bash

# Encontrar todos los archivos en /var/run/sddm/
files=$(ls -tr /var/run/sddm/*)

# Iterar sobre cada archivo encontrado
for file in $files; do
  # Obtener el display asociado al archivo de Xauthority
  display=$(xauth -f "$file" list | awk '{print $1}' | grep -Eo ':[0-9]+$')
  
  # Verificar si se encontró un display
  if [ -n "$display" ]; then
    export SDDMXAUTH=$file
    export DISPLAY=$display
    
    echo "SDDMXAUTH configurado en $file"
    echo "DISPLAY configurado en $display"
    
    break
  fi
done

# Verificar si no se encontró ningún archivo válido
if [ -z "$display" ]; then
  echo "Error: No se encontró ningún archivo Xauthority válido."
  exit 1
fi

# Ejecutar x11vnc con las variables de entorno configuradas
exec /usr/bin/x11vnc -display $DISPLAY -auth $SDDMXAUTH -forever -shared -bg -o /var/log/x11vnc.log -rfbauth /etc/x11vnc.passwd -noxdamage
