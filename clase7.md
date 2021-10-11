# Tipos Compuestos y Varianza

Ejemplo:

Tenemos la clase Animal que sabe comer y decirnos si está gordo.
De ella heredan Vaca y Caballo que saben ordeñarse y relinchar respectivamente
De vaca hereda VacaLoca que sabe además reirse.


```scala

var animal: Animal = ???
var vaca: Vaca = ???

animal.come
vaca.ordeñate

```

Qué cosas se pueden guardar en esas variables?

```scala

var animal: Animal = new Vaca // ok
var vaca: Vaca = new Animal // Rompe.

```

## Principio de Sustitución de Liskov

> Si S es un subtipo de T, entonces los objetos de tipo T pueden ser reemplazados por objetos de tipo S.


## LSP: Ruptura del Principio de Sustitución de Liskov

Tenemos la clase Ave que sabe volar y comer, y de ella hereda avestruz que sabe meter la cabeza bajo la tierra pero no sabe volar.

```scala

class Avestruz extends Ave {
  override def vola() = throw new UnsupportedOperationException()
}

```

El problema de esto es que puedo tener una variable de tipo Ave, y guardar en ella un Avestruz, esperando que entienda `vola()`, pero va a explotar.


Un corolario importante de este principio es que para S pueda ser un subtipo de T (y por lo tanto pueda reemplazarlo), S tiene que poder hacer lo mismo que define T en su interfaz sin romper la funcionalidad.

Es una restricción mucho más fuerte al polimorfismo.


## Colecciones:

```scala

var unaColeccion: Set = Set(new Vaca, new Caballo, new Granero)

unaColeccion.filter {
  unElemento => unElemento.estaGordo
}

```

En un lenguaje con tipado fuerte, no se puede asegurar que todos los elementos entiendan ese mensaje.


Vemos que en este ejemplo no alcanza con decir que algo es una colección: Me va a importar también el tipo de las cosas que contiene.

De hecho, si recordamos el tipo de filter en Haskell era:

```hs

filter :: [a] -> (a -> Bool) -> [a]

```

`a` es un parámetro de tipo.

A los tipos que requieren uno o más parámetros los llamamos tipos genéricos.

En Scala:

```scala

var unaColeccion: Set[Animal] = Set(new Vaca, new Caballo, new VacaLoca)

unaColeccion.filter { unElemento => unElemento.estaGordo }
```

Ahora el compilador tiene toda la información necesaria para saber que unElemento es de tipo animal

## Ejercicio

```scala

class Animal{

  var peso = 100

  def come = peso += 10
  def estaGordo = peso >= 150

}

class Vaca exteds Animal {
  def ordeñate = peso -= 10
}

class VacaLoca extends Vaca {
  def reite = "Muajajaj"
}

class Caballo extends Animal {
  def relincha = "IEIEIEIEEEEI"
}

class Granero{
  var granos = 10000
}

// Parte 2

class Corral(val animales: Set[Animal])

class Pastor{
  def pastorear(animales: Set[Animal]) = animales.foreach(_.come) // Sugar Syntax para un lambda
}

class Lechero{
  def ordeñar(corral: Corral) = corral.animales.foreach(_.ordeñate) // No compila porque Animal no sabe ordeñarse
}

// Solución con Generics

class Corral[T<: Animal](val animales: Set[T])

class Lechero {
  def ordeñar(corral: Corral[Vaca]) = corral.animales.foreach(animal => animal.ordeñate)
}
```


```scala

object GranjaApp extends App {
  var animal: Animal = new Vaca
  var vaca: Vaca = new Vaca

  animal.come
  vaca.ordeñate

  vaca = new VacaLoca

  vaca.ordeñate

  vaca.reite // Esta línea no compilará. La variable de tipo Vaca no tiene la info suficiente para saber que se puede reir

  var unaColeccion = Set(new Vaca, new Caballo, new Granero) // Infiere un Set de Object
  unaColeccion.filter{unElemento => unElemento.estaGordo } // unElemento no entiende estaGordo (Object no entiende)

  var unaColeccion = Set[Animal](new Vaca, new Caballo, new Granero) // No compila porque Granero no es un Animal
  unaColeccion.filter{unElemento => unElemento.estaGordo }

  var unaColeccion = Set[Animal](new Vaca, new Caballo)
  unaColeccion.filter{unElemento => unElemento.estaGordo }


  // Parte 2

  val corralito = new Corral(Set(new Vaca, new Vaca, new Vaca))
  val lechero = new Lechero
  val pastor = new Pastor


  val corralRaro = new Corral(Set(1,2,3)) // Queremos que el compilador no deje pasar estas cosas (T<: Animal) --> UpperBound

}

```

Límites de Tipado

- Cuando tenemos parámetros de tipos, podemos limitar de qué tipo pueden ser dichos parámetros
- Podemos limitarlos de dos formas:
  - Límites superiores -> El parámetro tiene que ser *subtipo* de X
  `class Corral[T <: Animal](Val animales: Set[T])`
  - Límites inferiores -> El parámetro tiene que ser *supertipo* de X
  `class Corral[T >: VacaLoca](val animales: Set[T])`


```scala

val corralito: Corral[Vaca] = new Corral(Set(new Vaca, new Vaca, new Vaca))


pastor.pastorear(corralito.animales) // No anda porque esperaba un Set de Animales.


var vacas: Set[Vaca] = Set[Vaca]()
var animales: Set[Animal] = Set[Vaca]() // No compilaría
var animales: Set[Animal] = vacas // ¿Qué pasaría si esto funcionase?

animales.foreach {animal => animal.come} // Todo ok

vacas.foreach {vaca => vaca.ordeñate} // Todo ok

animales.add(new Caballo) // Válido para Set de animales
vacas.foreach{vaca => vaca.ordeñate} // Cuando intente ordeñar al caballo explotaría (EN EJECUCIÓN)

```

Una solución podría ser trabajar con Listas que son objetos INMUTABLES.
Las Listas no entienden el mensaje add()

```scala
var vacas: List[Vaca] = List[Vaca]()
var animales: List[Animal] = vacas // Funciona

animales.foreach {animal => animal.come} // Todo ok

vacas.foreach {vaca => vaca.ordeñate} // Todo ok

//animales.add(new Caballo) <-- Esta situación jamás ocurrirá
vacas.foreach{vaca => vaca.ordeñate} // El compilador está seguro que solo hay Vacas
```

## Varianza

El análisis de Varianza es la relación entre el subtipado de los tipos compuestos en relación al Subtipado de los tipos que los componen.

En el caso de los Set, los Set de Vacas NO son subtipos del Set de Animal, y esta relación es una **Invarianza**.
Aunque haya relación entre los tipos simples.

En el caso de las Listas, la lista de vacas es un subtipo de la lista de animales así como la vaca es un subtipo de animal. Es una **Covarianza**


## Funciones

```scala

object GranjaApp2 extends App{

  var f: Vaca => Vaca = null // Función que va de Vaca a Vaca
  var f: Function[Vaca, Vaca] = null // Lo otro era Sugar Syntax. Function es un Alias de Tipo a Function1.

  def g(vaca: Vaca): Vaca = ???
  def h(vaca: Vaca): Animal = ???
  def i(vaca: Vaca): VacaLoca = ???
  def j(vacaLoca: VacaLoca): Vaca = ???
  def k(animal: Animal): Vaca = ???

  f = ???

  f(new Vaca).ordeñate

}

```

Qué funciones *entran* en f?

- g. OK
- h. No todos los animales saben ordeñarse.
- i. OK --> Es subtipo de f. Las funciones son covariantes con respecto al tipo de retorno
  - `class Function[P, +R] {...} // + quiere decir covariante`
- j. No son subtipos de las funciones que reciben Vaca, aunque VacaLoca sea subtipo de Vaca.
  - Las funciones no son covariantes con respecto al tipo de parámetro
- k. OK --> Las funciones que reciben Animal son subtipo de las funciones que reciben Vaca.
  - Es una **CONTRAVARIANZA** `class Function[-P, +R] {...} // - quiere decir contravariante`


En Resumen:

La varianza es el análisis de la forma en que varía el subtipado de un tipo compuesto con relación al subtipado de sus parámetros de tipos.

Hay 3 tipos*:

- Invarianza
- Covarianza
- Contravarianza

* También existe la Bivarianza

## Invarianza

Dados:

- `S` es un subtipo de `T`
- `G` es un tipo genérico

Entonces:

- `G[S]` no es subtipo de `G[T]`
- `G[T]` no es subtipo de `G[S]`

```scala
class T
class S extends T
class G[P]

val g1: G[T] = new G[S]() // NO

val g2: G[S] = new G[T]() // NO

```


## Covarianza

Dados:

- `S` es un subtipo de `T`
- `G` es un tipo genérico

Entonces:

- `G[S]` es subtipo de `G[T]`

```scala
class T
class S extends T
class G[+P]

val g: G[T] = new G[S]() // Ok

```

## Contravarianza

Dados:

- `S` es un subtipo de `T`
- `G` es un tipo genérico

Entonces:

- `G[T]` es subtipo de `G[S]`

```scala
class T
class S extends T
class G[-P]

val g: G[S] = new G[T]() // Ok

```


Ejemplo de Covarianza:

```scala

object GranjaApp extends App{
  
  abstract class Printer[-T]{
    def print(t: T): Unit
  }

  class AnimalPrinter extends Printer[Animal] {
    override def print(t: Animal): Unit = println(s"Este animal pesa: ${t.peso}")
  }

  class VacaLocaPrinter extends Printer[VacaLoca]{
    override def print(t: VacaLoca): Unit = println(s"Una vaca loca se ríea así: ${t.reite}")
  }

  val printer: Printer[VacaLoca] = new VacaLocaPrinter // Ok
  val printer: Printer[VacaLoca] = new AnimalPrinter // Funciona sólamente con -T

  printer.print(new VacaLoca) // "Este animal pesa 100". Solo le puedo pasar vacas locas

}

```

Volviendo al ejercicio:

Queremos que el corral sea Covariante

```scala

class Corral[+T <: Animal](val animales: List[T])

class Pastor {
  def pastorear(animales: List[Animal]) = animales.foreach(animal => animal.come)
}


val corralito: Corral[Vaca] = new Corral(List(new Vaca, new Vaca, new Vaca))
val lechero = new Lechero
val pastor = new Pastor

// Las listas de vacas son subtipos de las listas de Animal.
```

Gran desventaja del uso de la Covarianza:

```scala

class Corral[+T <: Animal](val animales: List[T]){
  def contiene(t: T): Boolean = animales.contains(t) // El tipo covariante T está en una posición contravariante.
}

// Si T es Covariante no puedo recibir por parámetro ese mismo tipo


class Corral[+T <: Animal](val animales: List[T]){
  def contiene[T1](t: T1): Boolean = animales.contains(t) // Funcion Ahora podría llamar a contiene con cualquier objeto
}

class Corral[+T <: Animal](val animales: List[T]){
  def contiene[T1 <: T](t: T1): Boolean = animales.contains(t) // El tipo T es covariante y aparece en una posición contravariante
}

class Corral[+T <: Animal](val animales: List[T]){
  def contiene[T1 >: T](t: T1): Boolean = animales.contains(t) // Evita que le pase cualquier cosa. Pero todavía acepta superclases (Como AnyRef)
}

class Corral[+T <: Animal](val animales: List[T]){
  def contiene[T1 <: Animal](t: T1): Boolean = animales.contains(t) // Esto funciona pero no es del todo restrictivo, a un corral de Vacas le puedo preguntar si contiene un Caballo
}

```

















