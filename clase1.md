
# Problemas con la Herencia

Vamos a comenzar pensando un juego de estrategia, similar al Age of Empires. En este juego
existen guerreros que pueden atacarse entre sí. Cada Guerrero tiene un potencial ofensivo y un
potencial defensivo y una cantidad de energía. Cuando un guerrero ataca a otro compara el
potencial ofensivo suyo contra el potencial defensivo del otro. Si el potencial ofensivo del
atacante es mayor o igual al del defensor, entonces el defensor resta la diferencia entre ambos en
energía.

Lo más obvio es modelar a los guerreros como objetos, que sean instancias de la clase Guerrero y 
que tengan como variables de instancia potencial_ofensivo, potencial_defensivo y energia.

Cada Guerrero entiende el mensaje atacar, que recibe por parámetro a otro guerrero y se
implementa de la siguiente manera:

```rb
class Guerrero
  attr_accessor :energia, :potencial_ofensivo, :potencial_defensivo ## Define getters y setters para variables de instancia

  def atacar(otroGuerrero)
    if(self.potencial_ofensivo >= otroGuerrero.potencial_defensivo)
      danio = self.potencial_ofensivo - otroGuerrero.potencial_defensivo
      otro_gerrero.sufrir_danio(danio)
    end
  end

  def sufrir_danio(danio)
    self.energia -= danio
  end
end
```

> Símbolos:
> No tienen nada que ver con las variables
> La diferencia entre los String y los Símbolos es que los Strings son usados para trabajar con datos
> Los símbolos son identificadores: ":energía" es un símbolo que representa a la variable @energía

> Los símbolos son:
> - Inmutables
> - Se ven mejor
> - Son más rápidos

Ahora aparecen los Espadachines, que son básicamente guerreros que saben usar espadas.
O sea que cambia ligeramente el cálculo de su comportamiento ofensivo 

Solucion #1 
> Copiar y pegar el código de guerrero. Sabemos que copiar y pegar es malo. Pero ¿Por qué?

* ¿No escala? La realidad es que es una solución sencilla de usar
* ¿Qué pasa si hay que hacer un cambio? Se puede seguir cambiando el resto del código
* Es propenso a errores: Puedo tener errores aunque los tests den ok
* Semántica: No es lo mismo que dos cosas sean iguales a que sean la misma cosa
* Hay alternativas mejores: Herencia

Solución #2
> Herencia
- ¿Quién hereda de quien?
- Se usa herencia por básicamente 2 motivos
  * Method LookUp --> Cualquier camino aprovecha esta mecánica 
  * Semántica --> Un guerrero NO es un espadachin. Pero un Espadachin es un guerrero.

```rb
class Espada
  attr_accessor :potencial_ofensivo
end

class Espadachin < Guerrero
  attr_accessor :espada

  def potencial_ofensivo
    self.espada.potencial_ofensivo * super.potencial_ofensivo
  end
end
```

Luego agregamos las Murallas, que son una especie de guerreros que no pueden atacar ni defenderse, solo recibir Daño.

Al igual de lo que pasaba con el Espadachin, del Guerrero solo vamos a querer una porción. Va a ser solo 2 de las 4 cosas que sabe hacer el guerrero.

Solución #1 
> Muralla hereda de Guerrero

* Muralla tiene comportamiento que no debería tener. 
* No queremos ensuciar la Interfaz. 
* No queremos que el objeto haga cosas que no debería hacer.

Solución #2
> Guerrero hereda de Muralla

* Mecánicamente correcta, 
* Semánticamente obtenemos que Guerrero es una Muralla que ataca y eso también está mal.

Ambos escenarios tienen problemas

Para resolverlo se puede **Generalizar**, es decir, crear una clase nueva de la que hereden ambas. 
Busco aquel comportamiento que tienen en común y lo encapsulo en la nueva clase Padre

```rb
class Defensor
  attr_accessor :energia, :potencial_defensivo

  def sufrir_danio(danio)
    self.energia -= danio
  end
end

class Guerrero < Defensor
  attr_accessor :potencial_ofensivo 

  def atacar(otroGuerrero)
    if(self.potencial_ofensivo >= otroGuerrero.potencial_defensivo)
      danio = self.potencial_ofensivo - otroGuerrero.potencial_defensivo
      otro_gerrero.sufrir_danio(danio)
    end
  end
end


class Muralla < Defensor
  # ¿Y esto?
end

```

¿Qué hacemos con las clases vacías? ¿Están mal?

- Podría evitarse hacer la clase Muralla y que las Murallas sean instancias de Defensor, sin ser Defensor una clase abstracta.
- Si además de guerreros y murallas, estatuas, podrían ser también instancias de Defensor y funcionaría perfecto.
- En el momento de que el comportamiento de alguno cambie, ahora mismo son indistinguibles.
- Si modelamos la Muralla, aunque sea como una clase vacía, si bien es un Warning, no es del todo un error. 
- ¿Sería un sobrediseño? No sabemos qué pasará en el futuro. No nos sirve siempre para justificar la toma de muchas decisiones.

Generalizar, es una solución que de momento funciona perfecto. Gastando la herencia.

Ahora aparecen los Misiles, que es algo que no hay que atacar, pero sí sabe atacar. No sabe recibir daño. Es la contraparte de la muralla.

Si partimos de Guerrero y generalizamos para tener la clase Defensor, esto sólo lo podemos hacer una sola vez. No podemos generar la clase Atacante, porque no podemos hacer que Guerrero herede de 2 clases.

La herencia simple no tiene una forma elegante de resolver este problema

Posibles soluciones:

Solución #1
> Jerarquía Forzada: Defensor hereda de Atacante

* Todos tienen los métodos que necesitan.
* La muralla tiene métodos de más. (Además será un Atacante).
* Antinatural
* Ensucia la interfaz
* Se puede mitigar overrideando métodos que no necesita, para usar excepciones. (Solución utilizada en múltiples lugares)
* Aún así queda una interfaz muy contamiada.

Solución #2
> Composición de Lógica

* Atacante y Defensor, en lugar de ser clases abstractas, pasan a ser clases concretas.
* Misil va a tener una instancia de Atacante
* Muralla va a tener una instancia de Defensor
* Guerrero tendrá 2 variables con instancias de Atacante y Defensor
* No hace que las clases implementen esa interfaz.
* Se crean mensajes en cada clase Guerrero, Muralla, y Misil que deleguen el comportamiento en Defensor o Atacante.
* Genera código repetido. Molesto de escribir, verboso, propenso a errores.

Solución #3
> Repetir código

* Copiar y pegar los métodos necesarios.
* Puede ser ahora mismo una solución simple.
* Podría traer más problemas a futuro.


Solución #4
> Mixin y Traits

* Complemento de la Herencia Simple
* Flexibilidad para resolver problemas como el descrito.

Un mixin es similar a una clase, en el sentido de que permite definir un conjunto de métodos dentro de él, pero con la diferencia que, en lugar de ser instanciable, otras clases pueden incorporarlos como parte de sus métodos. En este caso podemos definir Defensor como un mixin que provea el método sufrir_danio y atacante que nos permita atacar.

```rb
module Defensor
  def sufrir_danio(danio)
    ...
  end
end

module Atacante
  def atacar(un_defensor)
    ...
  end
end


class Guerrero
  include Defensor
  include Atacante
end
  
```
<br>
<div align="center">
  <img src="diagrams/clase1/clase1.png" alt="">
</div>
<br>

Más sobre los Mixin's

* Permiten definir estado
* Si varios mixin's definen el mísmo método se produce un conflicto y el lenguaje define una forma de resolverlos automáticamente.
* Linearization





Papers:

- "Mixin-based Inheritance" - Bracha, Cook
- "Traits: Composable Unitrs of Behaviour" - Scharli, Ducasse, Nierstrasz y Black
- "Stateful Traits" - Bergel, Ducasse, Niertrasz y Wuyts














