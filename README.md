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

Despues hay que reiniciar y comprobar que el acceso a i2c esta funcionando `sudo i2cdetect -y 1` y clonar el repositorio de los scripts para controlar la UPS.

```bash
git clone https://github.com/geekworm-com/x728
chmod +x ./x728/*.sh
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
pip3 install note-python python-periphery
```

Ya en la `Notecard CLI` ya que registrar la terminal para que pueda enviar datos a la nube. Para ello primero se ejecuta el comando `notecard -play` que genera una terminal interactiva para ingresar
los comandos de la API en formato JSON.

```json
{"req":"card.version"}
{"req":"hub.set", "product":"com.gmail.mauriciobenjamin:templomayor"}
{"req":"hub.sync"}
```

La primera solicitud retorna los datos de la versión de la tarjeta, la segunda registra la tarjeta en el proyecto respectivo y la tercera inica la sincronización entre la Notecard y el Notehub.
