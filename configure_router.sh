#!/bin/bash

# Función para listar interfaces de red y sus características
list_interfaces() {
    echo "Interfaces de red disponibles:"
    ip link show | grep -E "^[0-9]" | while read -r line; do
        interface=$(echo $line | awk -F': ' '{print $2}')
        mac_address=$(cat /sys/class/net/$interface/address)
        echo "$interface - MAC: $mac_address"
    done
}

# Función para seleccionar la interfaz de red
select_interface() {
    local prompt=$1
    local selected_interface
    list_interfaces
    echo -n "$prompt: "
    read selected_interface
    echo "$selected_interface"
}

# Función para confirmar la elección
confirm_selection() {
    local interface=$1
    local ip=$2
    local segment=$3
    echo "Has seleccionado la interfaz $interface con la dirección MAC: $(cat /sys/class/net/$interface/address) para el segmento $segment con la IP $ip."
    read -p "¿Confirmas que esta es la selección correcta? (s/n): " confirmation
    if [[ $confirmation != "s" ]]; then
        echo "Por favor, selecciona otra interfaz."
        return 1
    fi
    return 0
}

# Función para configurar la interfaz de Internet
configure_internet_interface() {
    echo "Configurando la interfaz de Internet..."
    internet_interface=$(select_interface "Selecciona la interfaz de Internet")
    echo -n "Ingresa la IP estática para la interfaz de Internet (Ejemplo: 192.168.1.100): "
    read internet_ip
    echo -n "Ingresa la máscara de subred (Ejemplo: 255.255.255.0): "
    read internet_mask
    echo -n "Ingresa la puerta de enlace (GW) de la red (Ejemplo: 192.168.1.1): "
    read internet_gateway
    echo -n "Ingresa el DNS preferido (Ejemplo: 8.8.8.8): "
    read dns_primary
    echo -n "Ingresa el DNS alternativo (Ejemplo: 8.8.4.4): "
    read dns_secondary

    # Configuración estática de la interfaz de Internet
    echo "Configurando $internet_interface..."
    cat <<EOT >> /etc/network/interfaces

# Configuración estática para la interfaz de Internet
auto $internet_interface
iface $internet_interface inet static
    address $internet_ip
    netmask $internet_mask
    gateway $internet_gateway
    dns-nameservers $dns_primary $dns_secondary
EOT

    # Reiniciar el servicio de red para aplicar los cambios
    systemctl restart networking
}

# Función para configurar NAT (mascarado)
configure_nat() {
    echo "Configurando NAT (mascarado)..."
    iptables -t nat -A POSTROUTING -o $(ip route | grep default | awk '{print $5}') -j MASQUERADE
    iptables-save > /etc/iptables/rules.v4
}

# Habilitar reenvío de paquetes IP
enable_ip_forwarding() {
    echo "Habilitando reenvío de paquetes IP..."
    sysctl -w net.ipv4.ip_forward=1
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    sysctl -p
}

# Eliminar configuraciones de las interfaces de red
remove_network_config() {
    echo "Eliminando configuraciones de las interfaces de red..."
    sed -i '/# Configuración estática para/d' /etc/network/interfaces

    # Desactivar NAT (mascarado)
    echo "Eliminando reglas de NAT (mascarado)..."
    iptables -t nat -D POSTROUTING -o $(ip route | grep default | awk '{print $5}') -j MASQUERADE
    iptables-save > /etc/iptables/rules.v4

    # Deshabilitar reenvío de paquetes IP
    echo "Deshabilitando reenvío de paquetes IP..."
    sysctl -w net.ipv4.ip_forward=0
    sed -i '/net.ipv4.ip_forward = 1/d' /etc/sysctl.conf

    # Reiniciar el servicio de red para aplicar los cambios
    systemctl restart networking

    echo "Las configuraciones de red han sido eliminadas correctamente."
}

# Función principal para configurar todo
configure_router() {
    # Configurar interfaces de segmento
    configure_internet_interface

    # Habilitar NAT (mascarado)
    configure_nat

    # Habilitar el reenvío de paquetes IP
    enable_ip_forwarding

    echo "El router está configurado para enrutar tráfico entre los segmentos y el acceso a Internet."
}

# Menú para elegir si configurar o eliminar configuraciones
echo "Elige una opción:"
echo "1) Configurar router con acceso a Internet"
echo "2) Eliminar configuraciones de red"
read -p "Opción: " option

if [[ $option -eq 1 ]]; then
    configure_router
elif [[ $option -eq 2 ]]; then
    remove_network_config
else
    echo "Opción no válida. Saliendo."
fi
