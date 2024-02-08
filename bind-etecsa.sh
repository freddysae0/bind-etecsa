#!/bin/bash

# Obtener la dirección IP del servidor
server_ip=$(hostname -I | awk '{print $1}')

# Desglosar la dirección IP en octetos
IFS='.' read -ra ip_parts <<< "$server_ip"

# Ensamblar los primeros tres octetos en orden inverso
firstIps="${ip_parts[1]}.${ip_parts[2]}.${ip_parts[3]}"
rfirstIps="${ip_parts[3]}.${ip_parts[2]}.${ip_parts[1]}"

# Solicitar al usuario que ingrese su dominio
read -p "Introduce tu dominio: " domain

# Verificar que el dominio ingresado es válido
validate="^([a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.)+[a-zA-Z]{2,}$"
if [[ ! $domain =~ $validate ]]; then
    echo "El nombre de dominio ingresado no es válido."
    exit  1
fi


# Actualización del sistema
echo "Actualizando el sistema..."
sudo apt update
sudo apt upgrade -y

# Instalación de Bind9 y Nano
echo "Instalando Bind9 y Nano..."
sudo apt install -y bind9 bind9-utils nano

# Verificar el estado de Bind9
echo "Verificando el estado de Bind9..."
systemctl status bind9

# Permitir el acceso al puerto y protocolo que utiliza Bind9 en el firewall
echo "Permitiendo el acceso al puerto y protocolo de Bind9 en el firewall..."
sudo ufw allow bind9

# Configuración mínima de Bind9
echo "Configurando Bind9..."
cat > /tmp/named.conf.options <<EOF
listen-on { any; };
allow-query { any; };
dnssec-validation no;
EOF
sudo mv /tmp/named.conf.options /etc/bind/named.conf.options

# Obligar el uso único de IPv4
echo "Obligando el uso de IPv4..."
sudo sed -i 's/OPTIONS=""/OPTIONS="-u bind -4"/' /etc/default/named

# Comprobar la configuración de Bind9 y reiniciar el servicio
echo "Comprobando la configuración de Bind9..."
sudo named-checkconf
sudo systemctl restart bind9
echo "Verificando el estado de Bind9 después del reinicio..."
systemctl status bind9

# Agregar las zonas
echo "Agregando zonas a la configuración de Bind9..."
cat > /tmp/named.conf.local <<EOF
zone "$domain" IN {
    type master;
    file "/etc/bind/zonas/db.$domain";
};

zone "${rfirstIps}.in-addr.arpa" {
    type master;
    file "/etc/bind/zonas/db.${firstsIps}";
};
EOF
sudo mkdir -p /etc/bind/zonas
sudo mv /tmp/named.conf.local /etc/bind/named.conf.local

# Crear los archivos de zona
echo "Creando archivos de zona..."
cat > /etc/bind/zonas/db.$domain <<EOF

\$TTL    1D
@       IN      SOA     ns1.$domain. admin.$domain. (
        1               ; Serial
        12h             ; Refresh
        15m             ; Retry
        3w              ; Expire
        2h  )           ; Negative Cache TTL

;       Registros NS

        IN      NS      ns1.$domain.
ns1     IN      A       $server_ip
www     IN      A       $server_ip
EOF


cat > /etc/bind/zonas/db.${firstIps} <<EOF
\$TTL    1d ;
@       IN      SOA     ns1.$domain admin.$domain. (
                        20210222        ; Serial
                        12h             ; Refresh
                        15m             ; Retry
                        3w              ; Expire
                        2h      )       ; Negative Cache TTL
;
@      IN      NS      ns1.$domain.
1       IN      PTR     www.$domain.
EOF

# Comprobar los archivos de zona
echo "Comprobando los archivos de zona..."
sudo named-checkzone $domain /etc/bind/zonas/db.$domain
sudo named-checkzone db.$rfirstIps.in-addr.arpa /etc/bind/zonas/db.$firstIps

# Reiniciar el servicio Bind9
echo "Reiniciando el servicio Bind9..."
sudo systemctl restart bind9
