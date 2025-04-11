#!/bin/bash

echo "==== DESINSTALADOR DEL ROUTER ===="

# Respaldar archivo de interfaces antes de modificar
cp /etc/network/interfaces /etc/network/interfaces.backup.$(date +%F-%H%M%S)

# Eliminar configuraciones estáticas de interfaces de red
echo "Eliminando configuraciones de interfaces de red personalizadas..."
sed -i '/# Configuración estática para/,/dns-nameservers .*/d' /etc/network/interfaces

# Restaurar configuración original de NAT
echo "Eliminando reglas de NAT (masquerade)..."
iptables -t nat -D POSTROUTING -o $(ip route | grep default | awk '{print $5}') -j MASQUERADE 2>/dev/null
iptables -F
iptables -t nat -F
iptables-save > /etc/iptables/rules.v4

# Deshabilitar el reenvío de IP
echo "Deshabilitando reenvío de paquetes IP..."
sysctl -w net.ipv4.ip_forward=0
sed -i '/net.ipv4.ip_forward\s*=\s*1/d' /etc/sysctl.conf
sysctl -p

# Reiniciar el servicio de red
echo "Reiniciando servicios de red..."
systemctl restart networking

echo "✅ Desinstalación completa. Las configuraciones han sido eliminadas."
echo "ℹ️ El archivo original fue respaldado como: /etc/network/interfaces.backup.<fecha-hora>"
