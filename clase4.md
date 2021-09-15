# Recepción dinámica de mensajes y bloques

## Repaso del MetaModelo

- Todo objeto es una instancia de una clase. Incluso las clases son instancias de la clase Class. (Flecha Azul)
- Todo objeto tiene su singleton class 
  - Creada de forma Lazy
  - Hay una jerarquía paralela entre clases y singleton clases
    - Exepto para la singleton class de Basic Object y la clase Class
      - La clase Basic Object no tiene superclase
- Para los objetos, la singleton class está entre el objeto y su clase.


# Method Lookup

- Un objeto recibe un mensaje

- Paso a la Singleton Class del objeto
- Paso a la superclase de la Singleton Class
- Paso a la clase del objeto
  - También en sus mixins en orden
- Paso a la superclase de la clase del objeto (hasta Object)
- Paso a Basic Object
- Envio al objeto el mensaje `method_missing(:msg)`
- Sigue el camino hasta Basic Object
- Lanza excepción.


```ruby

def ir_de_compras_con(un_carrito)... end 

carrito = CarritoDeCompra.new
ir_de_compras_con(carrito)

# Queremos capturar todos los mensajes que recibe el objeto.

class RegistradorDeMensajes

  attr_reader :mensajes_recibidos

  def initialize(objeto_original)
    @objeto_original = objeto_original
    @mensajes_recibidos = []
  end

  def method_missing(nombre_mensaje, *args, &block)
    @mensajes_recibidos << {mensaje: nombre_mensaje, argumentos: args }
    @objeto_original.send(nombre_mensaje, *args, &block)
  end
end

carrito = CarritoDeCompra.new
registrador_mensajes = RegistradorDeMensajes.new(carrito)
ir_de_compras_con(registrador_mensajes)

puts registrador_mensajes.mensajes_recibidos
## Todos los mensajes se loguean y luego se delegan al carrito.


puts carrito.respond_to? :total_a_pagar # True
puts registrador_mensajes.respond_to? :total_a_pagar # False

# Siempre que se redefine method_missing, se debe redefinir el método respond_to_missing?
class RegistradorDeMensajes

  def respond_to_missing?(nombre_mensaje, include_private = false)
    @objeto_original.respond_to?(nombre_mensaje)
  end
end


puts carrito.is_a? CarritoDeCompra # True
puts registrador_mensajes.is_a? CarritoDeCompra # False, aunque debería responder true.

# El method lookup no falla porque is_a? está definido en object

# Para solucionarlo puedo saltarme esa herencia y hacer que RegistradorMensajes herede de BasicObject

class RegistradorDeMensajes < BasicObject
...
end

```

Nota
> Siempre delegar a Super si no entiende el mensaje


# Bloques - Lambdas - Closures

```ruby

imprimir_hola = proc { puts "Hola" }

imprimir_hola.call ## Recién ahora se imprime. Y se puede ejecutar varias veces.
 
[1,2,3].each{ |numero| puts numero } ## No es un objeto!
```

## Bloques

- Todo método en ruby recibe implícitamente un bloque
- Para capturar ese bloque y poder usarlo hay dos formas:
  - `yield` ejecuta el bloque recibido.
  - Capturarlo como un Proc usando `&bloque`

```ruby

def m1
  yield
end

m1 do
  puts "Chau"
end
```

```ruby

def m1(&bloque)
  bloque.call
end

m1 do
  puts "Chau"
end
```
Los Procs comparten el contexto que tenía el programa en el cual definimos el proc.


En el caso de los métodos:

```ruby

nombre = "Pepe"

def m1
  puts nombre ## No existe
end

define_method(:m1) do
  puts nombre ## Acá tiene acceso al contexto.
end

```

## Proc vs Lambdas

```ruby

proc = proc {|x| puts x}
proc.call() ## Devuelve nil, que se imprime como nada
proc.call(2)
proc.call(2,3,4) ## Solo imprime 2.

lamb = lambda {|x| puts x.inspect}

proc.call() ## Falla
proc.call(2)
proc.call(2,3,4) ## Falla



def m1
  lam = lambda {|x| return x}
  lam.call(2)
  44
end

puts m1 ## 44

def m1
  pro = proc {|x| return x}
  pro.call(2)
  44
end

puts m1 ## 2
```

## Self en proc

```ruby

un_bloque = proc {puts self}

puts self ## main

un_bloque.call ## main


## Quiero cambiar ese self:

"hola".instance_eval do
  puts self ## hola
end

"hola".instance_eval(&un_bloque) ## "hola"

```

# Inline Objects

Queremos poder crear objetos en una línea:

```ruby

pepe = objeto do
  def nombre
    "Pepe"
  end

  def saludar
    "Hola, soy #{nombre}"
  end
end

assert pepe.saludar == "Hola, soy Pepe"

```


```ruby

def objeto(&definicion_del_objeto)
  objeto_nuevo = Object.new
  objeto_nuevo.instance_eval(&definicion_del_objeto) ## Agregamos los métodos a su Singleton Class
  objeto_nuevo
end

```

Queremos poder crear clases en una línea:

```ruby

def clase(&definicion_de_la_clase)
  clase_nueva = Class.new
  clase_nueva.class_eval(&definicion_de_la_clase) ## Equivalente a instance_eval, pero lo define en la misma clase
  clase_nueva
end

```

## En resumen

instance_eval

>Evalúa un bloque en el contexto de un objeto, (es decir, `self` dentro del bloque será una referencia al objeto receptor del instance_eval). Los métodos se definen en la **singleton class** del objeto receptor del mensaje

instance_exec

>Ídem a `instance_eval`, pero con la posibilidad de pasarle argumentos al bloque que se va a ejecutar


class_eval/module_eval
> Evalúa un bloque en el contexto de una clase o un módulo (es decir, `self` dentro del bloque será una referencia al objeto receptor del class_eval). Los métodos se definen en la clase/modulo receptor del mensaje


class_exec/module_exec
> Ídem a class_eval/module_eval, pero con la posibilidad de pasarle argumentos al bloque que se va a ejecutar





