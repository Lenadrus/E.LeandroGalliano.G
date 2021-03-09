# Proyecto para el módulo de ASAX [E.Leandro Galliano G]

## Índice

* [Enunciado](#bout)

* [Esquema relacional]()

* [Grafo relacional]()

* [Diagrama relacional]()

* [Código SQL]()

<a name="bout"></a>
**Base de datos para una empresa de instalación y mantenimiento de paneles solares**

Se necesita la base de datos para una empresa que se dedica a la instalación y mantenimiento de paneles solares.

Existen dos tipos de paneles solares. Uno para el abastecimiento eléctrico (conocido como [panel solar fotovoltaico](#diferencias)), 
y otro para el abastecimiento térmico (conocido como [panel solar térmico o colector solar](#diferencias)).

El **panel solar térmico** está compuesto por unas tuberías (las que conforman el circuito hidráulico), un [acumulador](#acumu) 
(el que almacena agua) y una caldera (la que sirve como sistema auxiliar de calentamiento).

Del panel solar térmico, es necesario guardar la longitud total de las tuberías (en metros), el codigo que lo identifica
y la cantidad a instalar. La cantidad de colectores solares sólo determina la longitud del circuito hidráulico, siendo mayor
cuanto más colectores haya.

Del acumulador [al que abastece](expl/instalacionTermicaPaneles.md/#acumu), es necesario guardar el código, marca y modelo, así como también los de la
caldera (y además, la caldera se clasifica por tipo).

Un acumulador es abastecido por el circuito hidráulico de un colector solar. Es decir, un colector solar sólamente
abastece a un acumulador, porque sólo hay un acumulador por instalación térmica. Generalmente se trata de la unidad
(colector solar) final de los paneles (en caso de que haya varios paneles conectados entre sí).

Un acumulador es auxiliado por una caldera. Sólamente hay una caldera por instalación solar térmica.

Información detallada: [*Cómo funciona una instalación de paneles solares térmicos*](./expl/instalacionTermicaPaneles.md)


El **panel solar fotovoltaico** está compuesto por una batería, un inversor y un regulador. Ésto significa que hay una batería 
por panel fotovoltaico.

Del panel fotovoltaico se requiere guardar la potencia (en Watios), código que lo identifica y la cantidad a instalar.

De la batería se requiere el tipo (plomo-ácido o ion-litio) y el código que la identifica.

El regulador y el inversor no constituyen datos que se necesiten almacenar, simplemente se mencionaron como complemento de
información.

El cliente puede comprar uno o varios paneles solares. Los paneles solares son instalados por un técnico instalador.

Del técnico instalador se requiere el DNI, nombre completo y especialidad.

Del cliente se requiere DNI, nombre completo y número de orden.

Un cliente puede comprar uno o varios paneles solares. Un panel solar solamente puede ser comprado por un cliente a 
la vez.

Un técnico puede instalar uno o varios paneles solares. Un panel solar sólamente puede ser instalado por un instalador.


## Definiciones

<a name="caldera">**Caldera**</a>

Sistema auxiliar de calentamiento de agua para la tubería de salida final del Acumulador que consiste en una caldera
clasificada según fuente de energía (biomasa, gas o electricidad).

<a name="acumu">**Acumulador**</a>

Depósito de agua que es calentado por el agua del circuito de cerrado con tubos de cobre que proviene del panel solar.

<a name="schema">
</a>

<a name="graph">
</a>

<a name="diferencias">
</a>
