# Apuntes Docker

Aquí dispongo los apuntes de Docker de clase.

## Contenido

* [Noción de Docker](#nocion)

* [Uso de Docker (comandos)](#usoDocker)

#
### <a name="nocion">Sobre Docker</a>

Docker es un sandbox. Un sandbox es un contenedor virtual en el que pueden hacerse cambios sin afectar al sistema operativo original.

La palabra "Docker" proviene de "Dock" (puerto) y significa "cargar".

La idea principal de Docker es la creación de imágenes en contenedores.

Los contenedores pueden almacenarse en la nube o de manera local.
Para el almacenamiento de contenedores en la nube, existe un sistema Web de control de versiones similar a [GitHub](https://github.com) pero orientado a Docker; [DockerHub](https://hub.docker.com).
Para los almacenados en la nube, se reserva el término "Storage", mientras que para los almacenados en local, se reserva el térmico "Registry".

La imágen puede descargarse o crearse mediante un comando reservado (se explica más adelante).

### Comandos de Docker

`docker version` : Obtiene la versión de docker que se esté utilizando, entre otros detalles como el Sistema Operativo en el                    que se ejecuta.

`docker --help` : Muestra la lista de comandos-parámetro válidos para utilizar docker, expondiendo la sintaxis de uso:
                  `docker [OPCIONES] COMANDO` .

`docker pull <imagen> <tag>`  : `docker pull` "tira" de una imágen o un repositorio localizado un registro (Registry; se                                      refiere al almacenamiento local).

`<imagen>`: Es ahí donde va el nombre la imagen. Puede ser "ubuntu", "mysql", "debian", etc.

`<tag>` : Etiqueta que es de uso opcional. Si el comando "pull" se ejecuta sin ésta etiqueta, entonces se descarga la                 versión más reciente. Ésta `<tag>` sirve para especificar una versión válida de aquello que queremos virtualizar.

