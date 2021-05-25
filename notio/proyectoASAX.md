# Proyecto para el módulo de ASAX [E.Leandro Galliano G]

**Base de datos para una empresa de instalación y mantenimiento de paneles solares**

## Índice

* [Enunciado](#bout)

* [Esquema relacional](#esquemaRel)

* [Grafo relacional](#grafoRel)

* [Código T-SQL (DDL + DML)](../proyecto_LeandroGalliano.sql)

  - Código del proceso de creación de la BD.
* [Código T-SQL (DQL)](../consultas_BD-paneles.sql)

  - Código de pruebas de consulta a la BD.

* [Diagrama relacional](#diagram)

  - Obtenido desde el SSMS.

* [Definiciones](#defs)

##
<a name="bout">**Enunciado**</a>

Se necesita la base de datos para una empresa que se dedica a la instalación y mantenimiento de paneles solares.

Existen dos tipos de paneles solares. Uno para el abastecimiento eléctrico (conocido como [panel solar fotovoltaico o placa solar](#diferencias)), y otro para el abastecimiento térmico (conocido como [panel solar térmico o colector solar](#diferencias)).

El **panel solar térmico** está compuesto por unas tuberías (las que conforman el circuito hidráulico), un [acumulador](#acumu) 
(el que almacena agua) y una caldera (la que sirve como sistema auxiliar de calentamiento).

Del panel solar térmico, es necesario guardar la longitud total de las tuberías (en metros), el codigo que lo identifica
y la cantidad a instalar.

Del acumulador al que abastece, es necesario guardar el código, capacidad (volumen de acumulación de agua) marca y modelo, así como también los de la caldera (y además, la caldera se clasifica por tipo).

Un acumulador es abastecido por el circuito hidráulico de un colector solar. Es decir, un colector solar sólamente
abastece a un acumulador, porque sólo hay un acumulador por instalación térmica. Generalmente se trata de la unidad
(colector solar) final de los paneles (en caso de que haya varios paneles conectados entre sí).

Un acumulador es auxiliado por una caldera. Sólamente hay una caldera por instalación solar térmica.

Información detallada: [*Cómo funciona una instalación de paneles solares térmicos*](./expl/instalacionTermicaPaneles.md)


El **panel solar fotovoltaico** está compuesto por una batería, un inversor y un regulador. Ésto significa que hay una batería por placa. Pero la batería no es un componente obligatorio. En lugar de la batería, puede ir cualquier
aparato electrodoméstico enchufable cuyos Watios de potencia requeridos no supere a los del panel.

Del panel fotovoltaico se requiere guardar la potencia (en Watios), código que lo identifica y la cantidad a instalar.

De la batería se requiere el tipo (plomo-ácido o ion-litio) y el código que la identifica.

El regulador y el inversor no constituyen datos que se necesiten almacenar, simplemente se mencionaron como complemento de
información.

El cliente puede comprar uno o varios paneles solares. Los paneles solares son instalados por un técnico instalador.

Del técnico instalador se requiere el DNI, nombre completo y especialidad.

Del cliente se requiere DNI, nombre y apellidos, así como identificar qué tipo de panel compra.

Un cliente puede comprar uno o varios paneles solares. Un panel solar solamente puede ser comprado por un cliente a 
la vez.

Un técnico puede instalar uno o varios paneles solares. Un panel solar sólamente puede ser instalado por un instalador.

<a name="esquemaRel">**Esquema relacional**</a>

[<img src="https://www.mediafire.com/convkey/57ac/bagmzh1d4wpky3bzg.jpg" alt="esquemaRelacional" width="350px" height="350px"/>](https://www.mediafire.com/convkey/57ac/bagmzh1d4wpky3bzg.jpg)


<a name="grafoRel">**Grafo relacional**</a>

[<img src="https://www.mediafire.com/convkey/a288/5z5ysnqwxf4yicazg.jpg" alt="grafoRelacional" width="350px" height="350px"/>](https://www.mediafire.com/convkey/88eb/sbw99v97hxjcpvdzg.jpg)


<a name="diagram">Diagrama relacional</a>

![](https://www.mediafire.com/convkey/35e0/fipvv6lmnadbqw8zg.jpg)

Bateria tiene una "FK oculta" que en realidad apunta mediante un trigger a la FK de la entidad débil "Fotovoltaico"
(ID_fotovoltaico).
Porque como se indicó en el enunciado, no es obligatorio que una placa esté conectada a la batería, sino que en su lugar
puede ir cualquier electrodoméstico.
Cuando se inserta una nueva bateria, se activa el trigger que la relaciona con la placa.
"enchufe" de "Bateria" apunta a la PK de "PanelSolar".

En la Entidad "Tecnico", el atributo "orden_servicio_tecnico" es una FK que apunta a la PK "ID_panel" de la Entidad "PanelSolar".

La Entidad "Pedidos" tiene dos FK; ID_compra, que apunta a la "ID_panel" de "PanelSolar", e "ID_cliente", que apunta al "DNI_cliente" de "Cliente".

Acumulador tiene la FK "auxilio" que apunta a la PK de "Caldera".


<a name="defs"></a>
## Definiciones

**Caldera**

Sistema auxiliar de calentamiento de agua para la tubería de salida final del Acumulador que consiste en una caldera
clasificada según fuente de energía (biomasa, gas o electricidad).

**Acumulador**

Depósito de agua que es calentado por el agua del circuito cerrado con tubos de cobre que proviene del panel solar.

**Sistema Térmico**

El Sistema térmico en una instalación de colectores solares siempre requiere del Acumulador y la Caldera obligatoriamente. De lo contrario no funcionaría. Por lo que en la BD son Tablas importantes.

**Sistema Eléctrico**

En el sistema eléctrico en una instalación de placas solares, la batería es un elemento opcional. La placa fotovoltaica puede enchufarse a cualquier electrodoméstico con una potencia menor o igual a la que produce el panel. El electrodoméstico es un elemento ajeno al conjunto de la instalación solar.
