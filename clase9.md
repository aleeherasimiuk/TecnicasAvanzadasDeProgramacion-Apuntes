# Abstracción y Mónadas

## Niveles de Abstracción

Dominio:

Tenemos una materias que saben si son electivas. Cada materia tiene un conjunto de cursos y cada curso conoce su código de curso y sus incriptos, los cuales saben su legajo y sabe si es regular.

Queremos los legajos de los alumnos regulares inscriptos a electivas.


La implementación más sencilla puede ser una Lista y la capacidad de definir funciones.

Una lista puede ser Nil (Vacía) o bien el (::) (cons) que es una construcción de una lista como cabeza::cola.

```scala

def append[T](izq:List[T], der:List[T]):List[T] = izq match {
  case Nil => der
  case cabeza::cola => cabeza::append(cola, der)
}

def electivas(materias: List[Materia]): List[Materia] = materias match{
  case Nil => Nil
  case materia::otras if(materia.electiva) => materia::electivas(cola)
  case _::otras => electivas(otras)
}

def cursos(materias: List[Materia]): List[Curso] = materias match{
  case Nil => Nil
  case materia::otras => append(materia.cursos, cursos(otras))
}

def inscriptos(cursos:List[Curso]):List[Alumno] = cursos match{
  case Nil => Nil
  case curso::otros => append(curso.inscriptos, inscriptos(otros))
}

def regulares(alumnos:List[Alumno]):List[Alumno] = alumnos match{
  case Nil => Nil
  case alumno::otros if(alumno.regular) => alumno::regulares(otros)
  case _::otros => regulares(otros)
}

def legajos(alumnos:List[Alumno]):List[Int] = alumnos match{
  case Nil => Nil
  case alumno::otros => alumno.legajo::legajos(otros)
}

legajos(regulares(inscriptos(cursos(electivas(todasLasMaterias)))))

```

Vemos que la única construcción que vemos son funciones auxiliares usando pattern matching.

Existe repetición de lógica, mucho código y todo acoplado a la implementación de una Lista.


Otra implementación de lista puede ser por ejemplo Nil como lista vacía pero (snoc):  `(:+) : (init: List[T], last: T) => List'[T]`

Separa los primeros elementos de la lista con el último.

Con esta implementación, nuestro código ya no serviría.


¿Cómo puedo hacer para desprenderme de esta abstracción?

Puedo pensar a la lista como un Tipo Abstracto de Dato.

```
List[T]

- empty[T](): List[T]
- ::(elem: T): List[T]
- head() : T
- tail(): List[T]
- isEmpty(): Boolean

```

Y pensar a la lista a través de su interfaz.


```scala

def append[T](izq:List[T], der:List[T]):List[T] =  
  if(izq.isEmpty) der
  else izq.head::append(izq.tail, der)


def electivas(materias: List[Materia]): List[Materia] =
  if(materias.isEmpty) List.empty
  else if(materias.head.electiva) 
    materias.head::electivas(materias.tail)
  else electivas(materias.tail)


def cursos(materias: List[Materia]): List[Curso] =
  if(materias.isEmpty) List.empty
  else append(materias.head.cursos::cursos(materias.tail))

def inscriptos(cursos:List[Curso]):List[Alumno] =
  if(cursos.isEmpty) List.empty
  else append(cursos.head.inscriptos::inscriptos(cursos.tail))

def regulares(alumnos:List[Alumno]):List[Alumno] = 
  if(alumnos.isEmpty) List.empty
  else if(alumnos.head.regular) 
    alumnos.head::regulares(alumnos.tail)
  else regulares(alumnos.tail)

def legajos(alumnos:List[Alumno]):List[Int] = 
  if(alumnos.isEmpty) List.empty
  else alumnos.head.legajo::legajos(alumnos.tail)

legajos(regulares(inscriptos(cursos(electivas(todasLasMaterias)))))

```

Ahora si uso otra implementación de lista:


```
List'[T]

- empty[T](): List'[T]
- :+(elem: T): List'[T]
- last() : T
- init(): List'[T]
- isEmpty(): Boolean

```

Esta nueva interfaz NO calza con nuestro código, pero sí puedo definir todas las otras operaciones en términos de estas:

```scala

def head[T](): T = if(init.isEmpty) last else init.head

def tail(): List'[T] = if(init.isEmpty) init else init.tail :+ last

def ::(elem: T): List'[T] =
  if(isEmpty) this :+ elem else elem :: init :+ last
```

Éste nivel de abstracción permite trabajar y pensar sin estar acoplados a la estructura. Ya no usamos pattern matching.


Aún así hay mucho código repetido en la solución. 
Hay un patron que se repite. La evaluación de lista vacía/paso recursivo.
Es básicamente iterar un conjunto.
Esta iteración se puede abstraer con orden superior.
Es la implementación de fold.

Dejo de pensar en la lista como algo que tiene cabeza/cola y que le puedo preguntar si está vacía.
Y la comienzo a pensar como algo que puede ser `foldeado` 

```

List[T]

- empty[T](): List[T]
- ::(elem: T): List[T]

Foldable[T]

- foldLeft[R](semilla: R)(f: (R, T) => R): R
- foldRight[R](semilla: R)(f: (T, R) => R): R

```

```scala

def append[T](izq:List[T], der:List[T]):List[T] =  
  izq.foldRight(der)((elem, lista) => elem :: lista)


def electivas(materias: List[Materia]): List[Materia] =
  materias.foldRight(List.empty[Materia])((materia, electivas) => 
    if(materia.electiva) materia::electivas else electivas)


def cursos(materias: List[Materia]): List[Curso] =
  materias.foldRight(List.empty[Curso])((materia, cursos) => 
    append(materia.cursos, cursos))

def inscriptos(cursos:List[Curso]):List[Alumno] =
  cursos.foldRight(List.empty[Alumno])((curso, inscriptos) => 
    append(curso.inscriptos, inscriptos))

def regulares(alumnos:List[Alumno]):List[Alumno] = 
  alumnos.foldRight(List.empty[Alumno])((alumno, regulares) => 
    if(alumno.regular) alumno::regulares else regulares)

def legajos(alumnos:List[Alumno]):List[Int] =
  alumnos.foldRight(List.empty[Int])((alumno, legajos) => 
    alumno.legajo::legajos)

legajos(regulares(inscriptos(cursos(electivas(todasLasMaterias)))))

```

Este sería el tipo de `fold`

```haskell
fold :: (a -> b -> a) -> b -> [a] -> a
```

Aunque en realidad nos va a convenir pensarlo de esta manera


```haskell
fold :: (a -> b -> a) -> b -> ([a] -> a)
```

Es decir, hacer uso de la aplicación parcial, recibe 2 parámetros y devuelve algo que sabe convertir a una lista en otra cosa.

Lo interesante de esto es que ya no estoy acoplado a la definicion de lista sino a algo que es "recorrible", pudiendo ser por ejemplo un set o un árbol.

Sigue habiendo repetición, por ejemplo en las funciones electivas y regulares.
Lo mismo sucede con cursos e inscriptos.

Si veo a la lista como algo que sabe hacer map, flatMap y filter, logro tener todas las operaciones que necesito.

```haskell
map :: (a -> b) -> [a] -> [b]
flatMap :: (a -> [b]) -> [a] -> [b]
filter :: (a -> Bool) -> [a] -> [a]
```

Nuevamente, es conveniente verlas como funciones parcialmente aplicadas



```haskell
map :: (a -> b) -> ([a] -> [b])
flatMap :: (a -> [b]) -> ([a] -> [b])
filter :: (a -> Bool) -> ([a] -> [a])
```


```scala

def electivas(materias: List[Materia]): List[Materia] =
  materias.filter(materia => materia.electiva)

def cursos(materias: List[Materia]): List[Curso] =
  materias.flatMap(materia => materia.cursos)

def inscriptos(cursos:List[Curso]):List[Alumno] =
  cursos.flatMap(curso => curso.inscriptos)

def regulares(alumnos:List[Alumno]):List[Alumno] = 
  alumnos.filter(alumno => alumno.regular)

def legajos(alumnos:List[Alumno]):List[Int] =
  alumnos.map(alumno => alumno.legajo)

legajos(regulares(inscriptos(cursos(electivas(todasLasMaterias)))))
```



Finalmente, nos dimos cuenta que al tener operaciones de tan alto nivel, las funciones auxiliares ya no tienen sentido:


```scala

todasLasMaterias.filter(materia => materia.electiva)
                .flatMap(materia => materia.cursos
                  .flatMap(curso => curso.inscriptos
                    .filter(alumno => alumno.regular)
                    .map(alumno => alumno.legajo)
                  )
                )

```

## Mónadas

Son *contenedores* que pueden ser *secuenciados* con operaciones que trabajan desde un contenedor hacia otro contenedor.

```haskell

unit :: T -> Monad[T] -- Guarda un valor en una caja
bind :: (T -> Monad[R]) -> Monad[T] -> Monad[R] -- Transformación del contenido de la caja

```

Deben cumplir 3 restricciones:

- Identidad Izquierda
  - `bind f (unit v) == f v`
- Identidad Derecha
  - `bind unit m == m`
- Asociatividad
  - `bind g (bind f m) == bind (bind g . f) m`


```scala

Monad[T]

apply[T](v: T): Monad[T] // Construir una caja
flatMap[R](f: T => List[R]): List[R] // Transformar el contenido de la caja
```

Si agregamos dos operaciones más:

```haskell

zero :: Monad[T] -- Caja vacía
plus :: Monad[T] -> Monad[T] -> Monad[T] -- Combinar 2 cajas

```

Es una mónada plus(MonadPlus). (plus y zero forman un Monoide)

plus zero m == m
plus m zero == m

plus (plus m1 m2) m3 == plus m1 (plus m2 m3)

bind f zero = zero

...

Finalmente en Scala:

```scala

MonadPlus[T]

empty[T]() : Monad[T]
++(other: Monad[T]) : Monad[T]
```

Lo bueno de MonadPlus es que todas las operaciones de listas que ya conocíamos se pueden implementar en términos de estas operaciones.

```scala

def map[R](f: T => R) = this.flatMap(v => unit(f(v)))

def filter(f: T => Boolean) = this.flatMap(v => if(f(v)) unit(v) else zero)

```

Finalmente, una Lista es en realidad, un caso particular de Mónada Plus.

Por lo tanto, el código que hicimos:

```scala

todasLasMaterias.filter(materia => materia.electiva)
                .flatMap(materia => materia.cursos
                  .flatMap(curso => curso.inscriptos
                    .filter(alumno => alumno.regular)
                    .map(alumno => alumno.legajo)
                  )
                )

```
funciona no sólamente con listas, sino con cualquier mónada.

## Algunas construcciones sobre mónadas.

### Option

Es un cómputo que tiene un resultado opcional

```scala

apply[T](v: T): Option[T]
empty[T]() : Option[T]

map[R](f: T => R) : Option[R]
flatMap[R](f: T => Option[R]) : Option[R]
filter(f: T => Boolean) : Option[T]
++(other: Option[T]) : Option[T]

```

Su equivalente en haskell sería Maybe.

Tiene el mismo contrato para listas.
Tiene dos formas posibles:

- Un `None[T]`, que representa una caja vacía
- Un `Some[T](value: T)`, que representa una caja con un valor

El option tiene su propio fold, no es una reducción pero cumple el mismo rol que en las listas, rompe la caja:

```scala
fold[R](ifEmpty: => R)(f: T => R) : R // La flecha indica lazy
```

También incluye un `getOrElse(default: T): T` que me da el contenido, o bien un valor en caso de que no lo tenga.

Nunca me preocupo si la caja está o no vacía.


### Try

Representa un cómputo que puede fallar.

Ya no es una mónada plus.

```scala

apply[T](v: T): Try[T]

map[R](f: T => R) : Try[R]
flatMap[R](f: T => Try[R]) : Try[R]
filter(f: T => Boolean) : Try[T]

fold[R](f: Throwable => R)(f: T => R) : R
getOrElse(default: T): T
recover[R](f: Throwable => R): Try[R]
toOption(): Option[T]

```

Try tiene 2 formas posibles:

- `Success[T](value: T)`. Tengo un valor T
- `Failure[T](err: Throwable)`. Tengo la excusa de por qué falló.

También tiene su implementación de Fold, que es distinta y de hecho ni siquiera son polimórficos.
También tiene un `getOrElse(default: T): T`.

Tiene una función `recover` que en lugar de trabajar con el valor, trabaja sobre una excepción.

Por último tenemos la operación `toOption` para descartar la excepción y pasarlo a una opción.

### Otras:

- Either --> Una caja con una cosa u otra
- State --> Simula estado en funcional
- I/O --> Efecto sobre el mundo real
- Future* --> En discusión.
- Transformadores --> Combina distintas mónadas.
- ...


Nuestro código ya quedó en términos de Mónadas. Pero se puede dar un pasito más.

```scala

todasLasMaterias.filter(materia => materia.electiva)
                .flatMap(materia => materia.cursos
                  .flatMap(curso => curso.inscriptos
                    .filter(alumno => alumno.regular)
                    .map(alumno => alumno.legajo)
                  )
                )

```

Es una forma de escribir un poco engorrosa. *Callback hell*

La gente de Haskell inventó la sintaxis de `do`, lo que en escala es la for comprehention
Por lo tanto puede quedar así:

```scala

for{
  materia <- todasLasMaterias if materia.electiva
  curso <- materia.cursos
  alumno <- curso.inscriptos if alumno.regular
} yield alumno.legajo


```

Usamos la flecha para sacar algo de una caja, y el `yield` para envolverlo en una caja.
Es un azucar sintáctico que luego se convierte en map/flatmap/filter.
Se piensa en términos de meter y sacar algo de una caja.





































