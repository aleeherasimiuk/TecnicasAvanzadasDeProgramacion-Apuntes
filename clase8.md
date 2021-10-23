# Introducción a Objeto-Funcional

Recordemos que un paradigma es un conjunto de reglas/restricciones que guían cómo trabajás y te ofrecen ciertas herramientas. Los lenguajes puros ofrecen herramientas que no se alejan del paradigma en el que fueron pensados. Un paradigma híbrido propone tomar algunas de esas herramientas y mezclarlas.

Lo escencial del paradigma de objetos es el *polimorfismo*, *encapsulamiento*, y la *delegación*. Cosas como mensajes u objetos no pertenecen al CORE del paradigma, ya que se podría, por ejemplo programar en estructurado usando objetos. La herencia tampoco forma parte del core del paradigma. Nos interesa en las ideas con las cuales trabjamos con estas herramientas.

En cuanto al paradigma funcional, nos basamos en el *Pattern Matching* (Trabajar mirando estructura), *Pureza* (Efectlessness + TR) y *Orden Superior* (En términos de pensar una función como dato).
¿Qué pasa con la composición o la aplicación parcial? Son casos particulares, que obtenemos de poder manipular funciones como valores.

Estas ideas no se suelen llevar bien entre ellas.

Delegación:
- Definición de interfaces
- Defino las reponsabilidades
- Reparto la lógica
- Se complica cuando para una determinada cosa hay más de un objeto que interviene
- Cohesión: Un objeto tiene una interfaz suficientemente completa, pero no sobrecargada
- Acoplamiento: Objetos que se conocen. El cambio en un objeto requiere cambios en el otro.
  - Imposible tener 0 acoplamiento
- Las interfaces definen puntos de extensión.


Encapsulamiento:
- Acceder a la estructura a través de la interfaz.
- Se esconde el estado.

Esta definición corresponde a algunas tecnologías como Java (Ej: envolver una variable en getter/setter) sin que sea una solución mejor.

Otra definición:

- Ocultar/Negar acceso a la implementación.
  - Para preservar invariantes: Puedo regular los cambios (Por ejemplo hacer validaciones en un setter)
  - Para resistir el cambio: Yo puedo eliminar el atributo y reemplazarlo por otra cosa, sin modificar mi interfaz.
  - Para disminuir el acoplamiento: Con la interfaz puedo encapsular operaciones y que otros objetos no se acoplen al objeto.


Polimorfismo

- Dos o más objetos pueden ser tratados de forma indistinta por terceros.
- Análogo al Pattern Matching.
- Es preferible trabajar con polimorfismo en cuanto a extensibilidad. (Agregado de nuevos objetos/clases)
- Si aparece una nueva operación, lo más sencillo es usar Pattern Mathing, es agregar un método en cada objeto.


## Ejercicio Microcontroladores.

Queremos ejecutar instrucciones.
Imprimir instrucciones.
Simplificar el código.
Y más.

En objetos quedarían interfaces grandes, contaminadas, y poco extensible.

Patrón Visitor:

- 2 Entidades
  - Elementos
    Representan una estructura compleja y exponen una interfaz magra que permite "recorrerlos"
  - Visitors
    Representan una única operación sobre la estructura y exponen un método para ejecutarlos sobre cada tipo de elemento.

En nuestro caso los Visitor pueden ser las operaciones sobre las instrucciones y los elementos las instrucciones, una clase para cada una.
El punto de entrada es accept que permite hacer que un elemento acepte un visitor.

Esta es la mejor implementación posible en Paradigma de Objetos.

El código queda raro, verboso, incómodo, etc.

El uso de este patrón rompe la delegación, el encapsulamiento y el polimorfismo.

> Usá el patrón Visitor cuando muchas operaciones diferentes deban realizarse sobre una estructura de objetos y quieras evitar **contaminar** sus clases con estas operaciones

> El patrón con frecuencia te fuerza a proveer operaciones públicas para acceder al estado interno de un elemento, lo cual compromete el **encapsulamiento**

> El Visitor hace **difícil** agregar nuevas subclases de elementos. Cada nuevo elemento conlleva una nueva operación en cada Visitor concreto.

En realidad se intenta solucionar un problema como si tuviesemos las herramientas de funcional, pero usando objetos. Entonces se puede empezar a pensar en un híbrido.













