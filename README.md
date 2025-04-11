# segrouter-debian

Script interactivo en Bash para configurar un sistema Debian como **router de múltiples segmentos de red**, incluyendo NAT para acceso a Internet. Diseñado para administradores de red, técnicos o estudiantes que necesiten implementar rápidamente un entorno de red segmentado.

## 📦 Características

- Detección de interfaces de red disponibles con detalles (MAC, nombre).
- Asignación de segmentos estáticos:
  - `10.160.200.254` – Servidores
  - `10.160.130.254` – Alumnos
  - `10.160.140.254` – Tutores
  - `10.160.150.254` – Administrativos
  - `172.16.1.254` – Proxys
- Configuración de una interfaz externa con IP, GW y DNS personalizados.
- Habilita reenvío de paquetes IP (`IP forwarding`).
- Configura NAT (`iptables`) para compartir Internet.
- Confirmación de cada paso antes de aplicar cambios.
- Script de desinstalación para revertir todos los cambios realizados.

## 🚀 Requisitos

- Sistema operativo: **Debian** (recomendado: Debian 11 o superior).
- Permisos de **root** o usuario con `sudo`.
- Paquetes:
  - `iptables`
  - `net-tools` (opcional, para salida más detallada)
  - `iptables-persistent` (se instala automáticamente si no está)

## 🛠️ Instalación

1. Clona este repositorio:
   ```bash
   git clone https://github.com/juanii64/segrouter-debian.git
   cd segrouter-debian
Da permisos de ejecución a los scripts:

bash
Copiar
Editar
chmod +x instalar_router.sh
chmod +x desinstalar_router.sh
Ejecuta el script de instalación:

bash
Copiar
Editar
sudo ./instalar_router.sh
Si necesitas revertir la configuración:

bash
Copiar
Editar
sudo ./desinstalar_router.sh
📋 Ejemplo de uso
Durante la ejecución, el script te permitirá:

Ver las interfaces disponibles.

Confirmar a qué segmento deseas asignar cada una.

Ingresar manualmente la IP, máscara, puerta de enlace y DNS de la interfaz de Internet.

Ver un resumen antes de aplicar cambios.

📁 Estructura
bash
Copiar
Editar
segrouter-debian/
├── instalar_router.sh       # Script principal de configuración
├── desinstalar_router.sh    # Script para eliminar configuraciones
└── README.md                # Este archivo
🧑‍💻 Autor
Desarrollado por Juan Vega (@juanii64)
Auxiliar de servicios informaticos | SABES TI COMONFORT
💻 Apasionado por la automatización, redes y soluciones Bash eficientes.

📝 Licencia
Este proyecto está bajo la Licencia MIT. Libre para usar, modificar y distribuir.

⚠️ Aviso: Este script modifica configuraciones de red y habilita NAT. Úsalo con precaución en entornos productivos. Asegúrate de tener respaldo de tu archivo /etc/network/interfaces.
