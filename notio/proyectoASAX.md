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

El panel solar térmico está compuesto por unas tuberías (las que conforman el circuito hidráulico), un [acumulador](#acumu) 
(el que almacena agua) y una caldera (la que sirve como sistema auxiliar de calentamiento).

De los paneles solares térmicos, es necesario guardar la longitud total de las tuberías (las que se miden en metros),
la capacidad del acumulador (en Litros de agua), y el tipo de [caldera](#caldera) (de biomasa, a gas o eléctrica).

Información detallada: [*Cómo funciona una instalación de paneles solares térmicos*](./expl/instalacionTermicaPaneles.md)



El panel solar fotovoltaico está compuesto por una batería, un inversor y un regulador. Ésto significa que hay una batería 
por panel fotovoltaico.

Del panel fotovoltaico se requiere guardar la potencia y su precio unitario, así como de la batería
el tipo, precio y el código que la identifica.

De los paneles fotovoltaicos se necesita conocer cantidad y precio unitario.

El regulador y el inversor no constituyen datos que se necesiten almacenar, simplemente se mencionaron como complemento de
información.


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
