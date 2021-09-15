

class TestSuite

  def initialize(&definicion_suite)
    @tests = []
    self.instance_eval(&definicion_suite)
  end

  def test(&contenido)
    @tests << Test.new(contenido)
  end

  def ejecutar(notificar_resultado: true)
    @tests.each do |test| 
      resultado = test.ejecutar
      if notificar_resultado
        mostrar_resultado(resultado)
      end
      
    end
  end

  def mostrar_resultado(resultado)
    if resultado == :pass
      puts "PASS".green
    else
      puts "FAIL".red
    end
  end
  
end


def test_suite(&definicion_test)
  test_suite = TestSuite.new(&definicion_test)
  test_suite.ejecutar
end

class Test

  def initialize(definicion_test)
    @test = definicion_test
  end

  def ejecutar
    @fallar = proc { return :fail }
    instance_eval(&@test)
    :pass
  end

  def assert(un_booleano)
    if !un_booleano
      @fallar.call
    end
  end
end