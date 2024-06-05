# Encontrar todos los archivos en /var/run/sddm/
files=$(sudo ls -tr /var/run/sddm/*)

# Iterar sobre cada archivo encontrado
for file in $files; do
  # Obtener el display asociado al archivo de Xauthority
  display=$(sudo xauth -f "$file" list | awk '{print $1}' | grep -Eo ':[0-9]+$')
  
  # Verificar si se encontró un display
  if [ -n "$display" ]; then
    # Establecer la variable de entorno SDDMXAUTH
    sudo /bin/systemctl set-environment SDDMXAUTH=$file
    
    # Establecer la variable de entorno DISPLAY
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
