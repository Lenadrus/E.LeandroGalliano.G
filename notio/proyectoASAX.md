# Proyecto para el módulo de ASAX [E.Leandro Galliano G]

## Índice (en anclas)

* [Enunciado](#enun)

___Navegar por el enunciado:___
 
* Acerca de las entidades

	* [Director ejecutivo](#x)
	* [Gestor](#g)
	* [Supervisor](#z)
	* [Pedidos](#p)
	* [Operarios](#o)

		* [carpintero y especialista en metalurgia](#cm)

* Acerca de los atributos

	* [Ocupación](#ocu)
	* [Horario](#hor)
	* [Código de identificación](#cid)


El <a name="enun">proyecto</a> sobre la base de datos consiste en una fábrica de alas para aviones.

La fábrica dispone de un `director ejecutivo`, `un gestor`, `operarios según categoría (ocupación)` en función de la 
complejidad de la operación, vehículos, máquinaria para todas las actividades de construcción y un supervisor.

De los <a name="o">**_operarios_**</a> se necesita guardar; codigo de identificación, nombre, <a name="ocu">ocupación</a> (la que puede expresarse 
como un subtipo de entidad, en el diseño conceputal, y como una constraint en la base de datos) y vehículo que emplea en caso de 
necesitarlo (por ejemplo, de operario de transporte; carretilla elevadora). 

La fábrica necesitará como máximo un administrador informático para el mantenimiento de la base de datos, de los ordenadores 
(y otros dispositivos informáticos existentes), y de la seguridad (cámaras y sensores de movimiento y temperatura) de cada
área de la fábrica.

Como la <a name="cm">estructura básica de un ala</a> está echa de madera, se necesitarán **_carpinteros_**.
También se necesitarán especialistas en metalurgia para la estructura de aluminio u otras aleaciones del ala, y
un mecánico. De éstos operarios se necesita guardar el diseño del pedido para el que se está trabajando.

Se necesitará al menos un electricista, ya que las alas disponen de unos flaps que se accionan por vía electrónica.
Del electricista no se necesitarán más datos.

De cada operario se necesita guardar la <a name="hor">hora de entrada y de salida</a>.

De los <a name="p">**_pedidos_**</a> se necesita guardar, el código del pedido y tipo de ala a fabricar.

El <a name="g">**_gestor_**</a> ordena los pedidos según coste en tiempo de construcción, y calcúla el presupuesto para cada unidad.
Del **_gestor_** se necesita guardar código de identificación y nombre.

El <a name="z">**_supervisor_**</a>, quien es _ingeniero aeronáutico_, se encarga de vigilar que cada área de la fábrica realice los componentes a las medidas establecidas o necesarias para cada tipo de pedido.

Del supervisor se necesita guardar, el código de identificación, nombre y aprobación.
El atributo "aprobación" para la entidad "supervisor", indica si el ala recién fabricada ha pasado el test de resistencia
al viento y los cambios de fuerza contra la gravedad, que se realizan en una cámara especial situada en una de las áreas
de la fábrica.

`Los` <a name="cid">**_códigos de identificación_**</a> ```consisten en 3 dígitos, de los cuales uno es caractérico en mayúsculas 
y los dos restantes son numéricos; la estructura de los puestos laborales es jerárquica, por lo tanto, el carácter identifíca 
la ocupación o puesto laboral: código de identificación={"Q para Operario, X para director ejecutivo, Z para supervisor,
y G para gestor"}. Por ejemplo: X01 (director ejecutivo; sólo hay 1), Z01 (supervisor; sólo hay 1), G01 (gestor; sólo hay 1), Q01, Q02, Q03 (puede ser operario informático, de limpieza, transporte, etc).```
