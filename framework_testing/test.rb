require 'colorize'
require_relative 'framework'

test_suite do
  
  ejecutado = false
  test do
    test_suite = TestSuite.new do
      test do
        assert false
        ejecutado = true
      end
    end

    test_suite.ejecutar(notificar_resultado: false)
    assert !ejecutado
  end
end
