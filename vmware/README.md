**Instalación de VMware Work Station en mi máquina Ubuntu**

Descargo el archivo Bundle de VMware Workstation 15 para Linux
desde [my.vmware.com](https://my.vmware.com/web/vmware/downloads/info/slug/desktop_end_user_computing/vmware_workstation_pro/15_0)

Yo descargo la [versión 15.0](https://my.vmware.com/web/vmware/downloads/details?downloadGroup=WKST-1500-LX&productId=799&rPId=55768) 
que es la que se estaba usando en clase.

Desde la terminal con el usuario root, ejecuto el archivo bundle que acabo de descargar:

![](https://imgshare.io/images/2021/05/29/a1.png)

Tras seguir el gestor de instalación, debería ser capaz de ejecutar la Workstation:

![](https://imgshare.io/images/2021/05/29/a2.png)

*Importante instalar lo necesario para ejecutar Workstation apropiadamente...*

![](https://imgshare.io/images/2021/05/29/a3.png)

En el caso de que se obtenga éste error, hay que instalar los módulos [manualmente](https://dm0s.wordpress.com/2020/05/05/vmware-kernel-modules-for-linux/):

```
cd /usr/lib/vmware/modules/source
wget https://github.com/mkubecek/vmware-host-modules/archive/player-15.5.1.tar.gz
tar -xzf  player-15.5.1.tar.gz
cd vmware-host-modules-player-15.5.1
cd  vmmon-only/
make
cd ../vmnet-only/
make
cd ..
mkdir /lib/modules/`uname -r`/misc
cp vmmon.o /lib/modules/`uname -r`/misc/vmmon.ko
cp vmnet.o /lib/modules/`uname -r`/misc/vmnet.ko
depmod -a
/etc/init.d/vmware restart
```

```
wget https://github.com/mkubecek/vmware-host-modules/archive/workstation-15.5.1.tar.gz
tar -xzf workstation-15.5.1.tar.gz
cd vmware-host-modules-workstation-15.5.1
sudo make
sudo make install
```

Entonces, probar a ejecutar Workstation desde la GUI:

![](https://imgshare.io/images/2021/05/29/a4.png)

