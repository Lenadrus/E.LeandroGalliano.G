# Apuntes Docker

Aquí dispongo los apuntes de Docker de clase y trabajo propio.

## Contenido

* [Noción de Docker](#nocion)

* [Uso de Docker (comandos)](#usoDocker)

* [Instalando Docker en Ubuntu](#instalar)

* [Volumen persistente. ¡Cuidado al detener una imagen!](#persistente)

* [Usando Docker](#usoDock)
  * Descargo una imagen
  * Creo un nuevo contenedor
  * Utilizo un contenedor (+ creación del volumen persistente)

#
### <a name="nocion">Sobre Docker</a>

Docker es un sandbox. Un sandbox es un contenedor virtual en el que pueden hacerse cambios sin afectar al sistema operativo original.

La palabra "Docker" proviene de "Dock" (puerto) y significa "cargar".

La idea principal de Docker es la creación de imágenes en contenedores.

Los contenedores pueden almacenarse en la nube o de manera local.
Para el almacenamiento de contenedores en la nube, existe un sistema Web de control de versiones similar a [GitHub](https://github.com) pero orientado a Docker; [DockerHub](https://hub.docker.com).
Para los almacenados en la nube, se reserva el término "Storage", mientras que para los almacenados en local, se reserva el término "Registry".

La imágen puede descargarse o crearse mediante un comando reservado (se explica más adelante).

### <a name="usoDocker">Comandos importantes de Docker</a>

- `docker version` : Obtiene la versión de docker que se esté utilizando, entre otros detalles como el Sistema Operativo en el                    que se ejecuta.

- `docker --help` : Muestra la lista de comandos-parámetro válidos para utilizar docker, expondiendo la sintaxis de uso:
                  `docker [OPCIONES] COMANDO` .

- `docker push <imagen>:<tag>` : "descarga" una imagen publicada en el DockerHub a un nuevo Registry.

- `docker pull <imagen>:<tag>`  : "tira" de una imágen o un repositorio localizado en un Registry,

  - `<imagen>`: El nombre de la imagen. Puede ser "ubuntu", "mysql", "debian", etc.

  - `<tag>` : Etiqueta que es de uso opcional. Si el comando "pull, push, run, etc" se ejecutan sin ésta etiqueta, entonces                se utiliza la versión más reciente. Ésta `<tag>` sirve para especificar una versión válida de   aquello que                  queremos virtualizar.

- `docker run --name <nombreNuevoContenedor> -it <imagen>:<tag>` : Crea un nuevo contenedor. `:<tag>` es opcional.
                                                                   `-it` indica a Docker de colocar una pseudo-TTY conectada
                                                                    al stdin del contenedor.

- `docker exec [OPCION] <contenedor> [COMANDO]` : Ejecuta un nuevo comando en un contenedor. Sirve para "meterse" al                                                           contenedor y empezar a ejecutar comandos propios del contenedor.

- `docker <imagen>` : Muestra información sobre la imagen.

- `docker rm <imagen>` : Elimina la imagen.

- `docker ps` : Muestra los contenedores en ejecución.

- `docker ps -a` : Muestra tantos los contenedores que están en ejecución como los contenedores almacenados.

Los contenedores se identifican por un identificador "bash".

- `docker stop <identificador>` : Detiene una imagen en ejecución, que cumpla con el identificador que se le pasa por parámetro al comando.

- `docker start <identificador>` : Inicia o arranca una imagen almacenada (que no está en ejecución), que cumpla con el identificador que se le pasa por parámetro al comando.

- `Docker inspect [OPCIONES] <identificador>` : Muestra información detallada sobre la imagen.

<a name="instalar"></a>
### Instalación de Docker en Ubuntu

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

3. Agregar la llave GPG oficial de docker:

` curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg`

4. Instalar el motor de Docker:

```
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```
5. Finalmente comprueba que Docker se ha instalado correctamente, ejecutando:

` sudo docker run hello-world`

### <a name="persistente">Volumen persistente</a>

Cuando detenemos una imagen que hemos estado utilizando. Los cambios que hemos efectuado en ella, se eliminan. Ésto ocurre tanto al detener la imágen como al eliminarla.
Por ejemplo, si en mi contenedor tengo Mysql y en él tengo una base de datos en la que he estado trabajando y detengo ésta imagen. Tras detenerla he eliminado todo el progreso.

Para evitar éste problema, existe en Docker una funcionalidad denominada "Volumen persistente". Ésto permite 
reservar parte de la capacidad de almacenamiento de nuestro disco, para guardar snapshots de nuestro contenedor.

Para crear un volumen, durante la creación de un contenedor:

```
docker run -d \
--name <nombreNuevoContenedor> \
-p <numPuertuLocal>:<numPuertoContenedor>
-e <variableEntorno> \
-v <directorio>:<ruta> \
<imagen>:<tag>
```

_La barra invertida '\\' me sirve para llevar el prompt de la terminal a un nuevo salto de línea sin perder la entrada de parámetros._

Ejemplo de uso del parámetro *-p* : `-p 8080:8080`

Ejemplo de uso del parámetro *-e* : `-e MYSQL_ROOT_PASSWORD=Abcd1234.`

*-v* es el parámetro que indica el volumen. *-v* de "volume". Entonces el volumen, es el directorio en el que decido que se encuentra mi persistente (debe de ser obligatoriamente una carpeta creada por mí mismo para guardar allí el volumen), mapeado a la ruta. Por ejemplo: `-v volumen_mysql:/var/lib/mysql`
#

Crear primero el volumen y después configurar el contenedor para utilizar al volumen:

```
docker volume create <nombreVolumen>
<nombreVolumen>
```

Con el comando `docker volume ...` he creado el volumen.

```
docker run -d -v <nombreVolumen>:<contenedorDirectorio>
```

`<contenedorDirectorio>` es el directorio del contenedor al que deseo mapear el nuevo volumen.

### <a name="usoDock">Utilizando Docker para pruebas de ejemplo.</a>

`sudo su` para utilizar la terminal con el usuario root.

Primero utilizo `docker ps -a` para comprobar que no tengo ninguna imagen o contenedor.

![](https://imgshare.io/images/2021/05/27/a160d54014e2d5bc84.png)

Busco imágenes relacionadas con "mysql" con el comando `docker search mysql`.

![](https://imgshare.io/images/2021/05/27/a2.png)

Utilizo `docker push mysql` para obtener la imágen oficial de mysql. Pero Docker me notifica que no tengo ninguna imagen local con el tag de mysql. Así que utilizo `docker pull mysql` para descargar la última versión de mysql.

![](https://imgshare.io/images/2021/05/27/a3.png)

Ahora ya puedo ejecutar `docker run --name conMysql -e MYSQL_ROOT_PASSWORD=Abcd1234. -it mysql` para crear un nuevo contenedor. No lo ejecuto con `detach` de momento:

![](https://imgshare.io/images/2021/05/27/a4.png)

Compruebo que el contenedor está en ejecución `docker ps -a`, a pesar de haber cerrado la terminal tras haber cambiado de decisión de no haber utilizado `detach`:

![](https://imgshare.io/images/2021/05/27/a5.png)

<a name="exec">Utilizo</a> el contenedor para empezar a trabajar con él mediante el comando `docker exec -it <ID> bash`:

![](https://imgshare.io/images/2021/05/27/a6.png)

Puede apreciarse que he iniciado una sesión Bash, y que puedo listar el directorio root ('\\') del contenedor "conMysql".


Ahora inicio mysql server y creo una base de datos `pruebaLeandro` a través de `mysql -u root -p`:

![](https://imgshare.io/images/2021/05/27/a7.png)

Cuando cierro `docker stop <ID>` éste contenedor. Los datos se perderán. Por lo que tendré que crear un volumen persistente:

![](https://imgshare.io/images/2021/05/27/a8.png)

Compruebo que los datos se pierden:

![](https://imgshare.io/images/2021/05/27/a9.png)

Sopresivamente la Base de Datos de prueba que he creado sigue allí, a pesar de haber detenido la imagen.
El motivo lo encuentro haciendo `docker inspect conMysql`, donde obtendo que en realidad ya hay un volumen:

![](https://imgshare.io/images/2021/05/27/b1.png) línea "Volumes" al final de la imágen PNG.
