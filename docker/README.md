# Apuntes Docker

Aquí dispongo los apuntes de Docker de clase.

## Contenido

* [Noción de Docker](#nocion)

* [Uso de Docker (comandos)](#usoDocker)

* [Instalando Docker en Ubuntu](#instalar)

#
### <a name="nocion">Sobre Docker</a>

Docker es un sandbox. Un sandbox es un contenedor virtual en el que pueden hacerse cambios sin afectar al sistema operativo original.

La palabra "Docker" proviene de "Dock" (puerto) y significa "cargar".

La idea principal de Docker es la creación de imágenes en contenedores.

Los contenedores pueden almacenarse en la nube o de manera local.
Para el almacenamiento de contenedores en la nube, existe un sistema Web de control de versiones similar a [GitHub](https://github.com) pero orientado a Docker; [DockerHub](https://hub.docker.com).
Para los almacenados en la nube, se reserva el término "Storage", mientras que para los almacenados en local, se reserva el término "Registry".

La imágen puede descargarse o crearse mediante un comando reservado (se explica más adelante).

### <a name="usoDocker">Comandos de Docker</a>

- `docker version` : Obtiene la versión de docker que se esté utilizando, entre otros detalles como el Sistema Operativo en el                    que se ejecuta.

- `docker --help` : Muestra la lista de comandos-parámetro válidos para utilizar docker, expondiendo la sintaxis de uso:
                  `docker [OPCIONES] COMANDO` .

- `docker pull <imagen> <tag>`  : `docker pull` "tira" de una imágen o un repositorio localizado un registro (Registry; se                                      refiere al almacenamiento local).

· `<imagen>`: El nombre de la imagen. Puede ser "ubuntu", "mysql", "debian", etc.

· `<tag>` : Etiqueta que es de uso opcional. Si el comando "pull" se ejecuta sin ésta etiqueta, entonces se utiliza la                 versión más reciente. Ésta `<tag>` sirve para especificar una versión válida de aquello que queremos virtualizar.


- `docker <imagen>` : Muestra información sobre la imagen.

- `docker rm <imagen>` : Elimina la imagen.

- `docker ps` : Muestra los contenedores en ejecución.

- `docker ps -a` : Muestra tantos los contenedores que están en ejecución como los contenedores almacenados.

Los contenedores se identifican por un identificador "bash".

- `docker stop <identificador>` : Detiene una imagen en ejecución, que cumpla con el identificador que se le pasa por parámetro al comando.

- `docker start <identificador>` : Inicia o arranca una imagen almacenada (que no está en ejecución), que cumpla con el identificador que se le pasa por parámetro al comando.

- `Docker inspect [OPCIONES] <identificador>` : Muestra información detallada sobre la imagen.


### <a name="intalar">Instalación de Docker en Ubuntu</a>

Ésta información la he obtenido con ayuda de la [documentación de Docker](https://docs.docker.com/engine/install/ubuntu/).

Abrir la terminal de Ubuntu (atajo del teclado: CTRL+ALT+T), y seguir los siguientes pasos:

**Pasos:**

1. Actualizar el repositorio APT: `sudo apt-get update`

2. Instalar las herramientas que permiten a APT utilizar su repositorio a través de HTTPS:
```
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```
