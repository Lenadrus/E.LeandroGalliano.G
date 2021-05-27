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
Para el almacenamiento de contenedores en la nube, existe un sistema de control de versiones online similar a GitHub pero
orientado a Docker; [DockerHub](https://hub.docker.com).

La imágen puede descargarse o crearse mediante un comando reservado (se explica más adelante).

### Comandos de Docker

`docker version` : Obtiene
