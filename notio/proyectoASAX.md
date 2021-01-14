# Proyecto para el módulo de ASAX [E.Leandro Galliano G]

## Índice

* [Enunciado](#bout)

* [Esquema relacional]()

* [Grafo relacional]()

* [Diagrama relacional]()

* [Código SQL]()

<a name="bout"></a>
**Base de datos para empresa de instalación y mantenimiento de paneles solares**

Se necesita una base de datos para la instalación y mantenimiento de paneles solares.
Para tal propósito, sólo se cuenta con un instalador.
Se instalan diferetes paneles en función de la demanda del cliente, si el cliente requiere abastecimiento eléctrico, se necesitan paneles fotovoltaicos. Si el cliente requiere calefacción, se requiere paneles térmicos.

Sólamente se puede realizar una instalación por cliente.
El cliente puede instalar más de un panel y de diferentes tipos.

La instalación de paneles térmicos está compuesta por un "kit térmico" que consiste en una caldera, un acumulador, las tuberías para el circuito hidráulico y los paneles.
Existen diferentes tipos de calderas; calderas a gas (mantenimiento bajo), a biomasa (mantenimiento caro) ó eléctricas (mantenimiento caro).
Cuantos más paneles térmicos haya, más capacidad debe tener el acumulador y más longitud la tubería.
Los paneles solares térmicos son conocidos también como colectores solares. Éstos paneles pueden ser instalados en serie o en paralelo.

De los paneles se necesita conocer cómo van instalados (serie o paralelo), su cantidad y el precio unitario.
De la caldera se necesita conocer el tipo de caldera y el precio (determinado por el tipo).
Del acumulador se necesita conocer su capacidad y el precio (determinado por la capacidad).
De la tubería se necesita conocer su longitud total para el circuito hidráulico y el precio (determinado por la longitud).

La instalación de paneles fotovoltaicos requiere de una batería, un regulador y un inversor. Éste tipo de instalación eléctrica será aislada.
La batería puede ser de ion-litio (mantenimiento caro) o de plomo-ácido (mantenimiento barato).

De los paneles fotovoltaicos se necesita conocer cantidad y precio unitario.
De la batería se necesita conocer el tipo de batería (plomo-ácido u ion-litio) y el precio (determinado por el tipo).
Del regulador y del inversor sólo se necesita conocer el precio.

<a name="schema">
</a>

<a name="graph">
</a>

<a name="">
</a>
