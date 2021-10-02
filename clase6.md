# Programación Híbrido: Funcional-Objetos

## Tipado

¿Cómo definimos el tipo de un objeto?

- Aspecto Operacional: El conjunto de los mensajes que entiende ese objeto.
- Aspecto Representacional: Cómo se guarda un valor en la memoria.
- Aspecto Estructural: Cómo se compone un valor y cómo se puede construir/deconstruir


¿Para qué sirven?

Ejemplo:

```ruby

class Persona
  attr_accessor :name


  def initialize(name)
    self.name = name
  end
end

class Saludador

  attr_accessor :cordial

  def initialize(cordial = false)
    self.cordial = cordial
  end

  def saludar(a)
    if(cordial)
      "Buen día estimado " + a.nombre
    else
      "Holiiiis"
    end
  end
end
```

```ruby

> Saludador.new.saludar(Persona.new("Pepe"))
=> "Holiiiis"

> Saludador.new(true).saludar(Persona.new("Pepe"))
=> NoMethodError # No existe 'nombre'

# Si no testeaba esa rama no lo testeaba.
```

Esto fue un error de tipos.

En POO y desde un aspecto operacional, un error de tipos se da cuando se le envía a un objeto un mensaje que no entiende

Es un problema que surje con bastante frecuencia, y que muchas veces se ve "leyendo" el código

¿No hay alguna manera de detectarlo tempranamente?

Replicando el mismo problema en Scala:

```scala
object SaludadorApp extends App{
  println(new Saludador().saludar(new Persona("Pepe")))
}

class Persona(val name: String)

class Saludador(cordial: Boolean = false){
  def saludar(a: Persona) = {
    if(cordial){
      "Buenos días estimado " + a.nombre
    } else {
      "Holiis"
    }
  }
}

```

El IDE marcará error al decir que `a` no entiende `nombre`


## Checkeo Estático de Tipos

Es aquella validación del programa que se hace en función de un análisis estático del código, asignando tipos a los elementos del lenguaje y verificando que sean consistentes.

El checkeo se hace con el código fuente antes de la ejecución. No con el objeto.


## Checkeo estático vs Checkeo "dinámico"

Se suele llamar checkeo dinámico a aquel que se hace en tiempo de ejecución.

Tanto Scala, que es "estático", como Ruby y muchos otros lenguajes llamados "dinámicos" hacen checkeo de tipos. La diferencia es el momento y con qué información lo hacen.


Los lenguajes estáticos usan la información del código. Los lenguajes dinámicos usan el estado en ejecución del programa.

Tanto Scala como Ruby tiene checkeo de tipos. El checkeo de ruby es en ejecución.


## Ventajas del checkeo estático

- Detección temprana de errores de tipo. Suelen ser más seguros de programar.
- La información de tipos ayuda al IDE y a otras herramientas a proveer mejor asistencia al programador.
- Permite expresar parte del dominio desde los tipos.

## Desventajas del checkeo estático

- Ciertas construcciones son muy difíciles de validar estáticamente, y por lo tanto, difíciles de escribir en lenguajes con checkeo estático. Ejemplo, self modification.

- Es necesario proveer más información en el código. Muchos lenguajes tipados son muy verbosos en consecuencia.

- La validación puede llegar a rechazar programas válidos.

## Y el polimorfismo?

Teniendo checkeo en compilación, para que dos objetos puedan usarse polimórficamente, tiene que haber un tipo en común que pueda usar para referenciarlos.

Se relaciona con la idea de **Subtipado**


## Definir tipos y subtipos

- Declarando una clase se define un tipo. Si una clase C hereda de una clase S, entonces el tipo C será un subtipo del tipo S.

- Declarando una "interfaz". Definen firmas de mensajes pero no implementaciones. En Scala se hace con Mixins (Mal llamados Traits)

- Componiendo Mixines. Un Mixin también define un tipo. Si un Mixin compone con otro, entonces es subtipo de ese Mixin. Si una clase usa un Mixin, es subtipo de ese Mixin.

- Usando tipado estructural. `def saludar(a: {def nombre: String}){...}`


## Clasificación/Caracterización de sistemas de tipos.


- Tipado Estructural: Puede definirse un tipo en función de cómo está compuesto. Como lo de recién o por ejemplo desarmando tuplas

- Tipado Nominal: Los tipos se definen en función de entidades nominadas, como clases o mixins.

- Tipado Implícito: No se escribe y no se declara el tipo. El tipado es "ad-hoc". Las variables no tienen un tipo.

- Tipado Explícito: El tipo se declara y se escribe o se infiere. Las variablea, o referencias a entidades, tienen un tipo en particular.

- Dinámico: El checkeo de tipos se hace en tiempo de ejecución

- Estático: El checkeo de tipos se hace antes de la ejecución

Ruby:

- Estructural
- Dinámico
- Implícito

















