# Instrucciones para configurar la RPi como pasarela

Esta RaspberryPi es la pasarela para enviar los datos a la nube a través de una red 3G con la 
plataforma Blues.io. Para poder hacer el proceso de configuración se tiene que habilitar `ssh`
en la RPi desde la instalación y si es necesario la configuración de wifi para hacer el acceso
remoto.

## Configuración inicial

Para poder instalar la mayoría del software necesario hay cumplir algunos prerequisitos como contar con `pip`, `git` y otras utilidades.

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install python3 python3-pip
sudo apt install i2c-tools git
sudo pip3 install smbus
```

Instalado el software es necesario habilitar la comunicación por I2C en la RPi entrando en `sudo raspi-config` en el menú de opciones de interfaces.

Despues hay que reiniciar y comprobar que el acceso a i2c esta funcionando `sudo i2cdetect -y 1` y clonar el repositorio de los scripts para controlar la UPS.

```bash
git clone https://github.com/geekworm-com/x728
chmod +x ./x728/*.sh
cd x728
sudo ./x728-v2.0.sh
```

Para después reiniciar el sistema y que se habilite el modo de apagado seguro del UPS.

## Configuración de *blues*

Para acceder y configurar el servicio de `blues` hay que descargar la versión más reciente de la
herramienta de linea de comando `Notecard CLI` en el (respositorio de GitHub)[https://github.com/blues/note-go/releases] o con los siguientes comandos:

```bash
wget https://github.com/blues/note-go/releases/download/v1.4.9/notehubcli_linux_arm.tar.gz
wget https://github.com/blues/note-go/releases/download/v1.4.9/notecardcli_linux_arm.tar.gz
tar xzf notecardcli_linux_arm.tar.gz
PATH=$PATH:/home/pi
notecard -interface i2c
sudo pip3 install note-python python-periphery
```

Ya en la `Notecard CLI` ya que registrar la terminal para que pueda enviar datos a la nube. Para ello primero se ejecuta el comando `notecard -play` que genera una terminal interactiva para ingresar
los comandos de la API en formato JSON.

```json
{"req":"card.version"}
{"req":"hub.set", "product":"com.gmail.mauriciobenjamin:templomayor"}
{"req":"hub.sync"}
```

La primera solicitud retorna los datos de la versión de la tarjeta, la segunda registra la tarjeta en el proyecto respectivo y la tercera inica la sincronización entre la Notecard y el Notehub.

## Comunicación entre los RPi con MQTT

Los datos que recopila la RPi que funciona como controladora se van a enviar a través de MQTT donde 
la RPi pasarela funcionara como *broker* del sistema. Para ello es necesario instalar los siguientes paquetes
(Las librerias de Python hay que instalarlas con `sudo` para que puedan cargarse por `systemd`):

```bash
sudo apt install mosquitto mosquitto-clients
sudo pip3 install paho-mqtt
```

Después de instalar `mosquitto` se tiene que copiar el repositorio con el script para generar el cliente de MQTT y comenzar a
recibir mensajes de RPi-hub.

```bash
git clone https://github.com/mauriciobenjamin/mosquitto_rpivsrpi.git
```

Ahora es necesario habilitar el script para que inicie automáticamente al reiniciar la RPi-gateway. Para ello lo recomendable es incluirla en `systemd` con creando una unidad en `/lib/systemd/system/mqtt_listener.service` e incluyendo la siguiente información en el archivo:

```service
[UNIT]
Description=Cliente de MQTT que recibe los mensajes y los transmite a BlueHub
After=multi-user.target

[SERVICE]
Type=idle
ExecStart=/user/bin/python3 /home/pi/mosquitto/main.py 
StandardOutput=/home/pi/mosquitto/mqtt.log
StandardError=/home/pi/mosquitto/errors.log

[Install]
WantedBy=multi-user.target
```

En seguida se tiene que dar los permisos necesarios al servicio con:

```bash
sudo chmod 664 /lib/systemd/system/mqtt_listener.service
sudo systemctl daemon-reload
sudo systemctl enable mqtt_listener.service
```

El respostitorio con todos los datos para la instalación quedaría en github

### Reducción del consumo de energía

Para evitar que las baterías se consuman demasiado rápido, se tienen que realizar los siguientes ajustes en la configuración de la RaspberryPi.

#### Apagar puertos USB

Para controlar el encendido y apagado de los puertos USB se empleó la utilidad `uhubctl` que permite controla la energía de los puertos USB.

```Bash
sudo apt intall libusb-1.0-0-dev
git clone https://github.com/mvp/uhubctl
cd uhubctl
sudo make install
```

Para inahabilitar los puertos USB en una RPi3 se usa el comando:

```Bash
sudo uhubctl -l 1-1 -p 2 -a 0
```

Si se quisiera inhabilitar lo wifi y ethernet se puede usar:

```Bash
sudo uhubctl -l 1-1 -p 1 -a 0
```
Estos comandos se pueden usar en `.bashrc` para que se inactiven en cada reinicio.
En `config.txt` se pueden activar las siguientes opciones para reducir la frecuencia del CPU y la memoria.

```
arm_freq_min=250
core_freq_min=100
sdram_freq_min=150
over_voltage_min=0

hdmi_blanking=1
```
