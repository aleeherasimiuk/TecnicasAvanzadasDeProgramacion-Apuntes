class PrototypeObject

  def initialize(prototype = nil)
    @properties = {}
    @prototype = prototype
  end

  def set_property(property_name, value)
    @properties = @properties.merge(property_name => value) ## Piso los valores, genera un dict nuevo
  end

  def get_property(property_name)
    @properties.fetch(property_name) do 
      if @prototype.nil?
        raise PropertyNotFoundError.new
      end
      @prototype.get_property(property_name)
    end
  end

  def copy
    self.class.new(self)
  end

  private

  def method_missing(method_name, *args, &block)
    if respond_to_missing?(method_name)

      possible_property_name = possible_property_name(method_name)

      if is_setter? method_name
        set_property(possible_property_name, args.first)
      else
        property = get_property(method_name)
        case property
        when Proc
          instance_exec(*args, &property)
        else
          property
        end 
      end
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    possible_property_name = possible_property_name(method_name)
    @properties.has_key?(possible_property_name.to_sym) || @prototype.respond_to?(method_name.to_sym) || super
  end

  def is_setter?(method_name)
    method_name.to_s.end_with?('=')
  end

  def possible_property_name(method_name)
    if is_setter? method_name
      method_name.to_s.chomp("=").to_sym
    else
      method_name.to_sym
    end
  end
end

class PropertyNotFoundError < StandardError
end

describe 'Prototyped Objects' do
  it 'should set/get property' do

    guerrero = PrototypeObject.new
    guerrero.set_property(:energia, 100)

    expect(guerrero.get_property(:energia)).to eq 100

  end

  it 'should raise error when property is undefined' do

    guerrero = PrototypeObject.new

    expect{guerrero.get_property(:energia)}.to raise_error(PropertyNotFoundError)

  end

  it 'should define methods for properties' do

    guerrero = PrototypeObject.new
    guerrero.set_property(:energia, 100)

    expect(guerrero.energia).to eq 100
    expect(guerrero.respond_to?(:energia)).to be true

  end

  it 'should raise NoMethodError if property is not defined' do

    guerrero = PrototypeObject.new

    expect{ guerrero.energia }.to raise_error(NoMethodError)
    expect(guerrero.respond_to?(:energia)).to be false

  end

  it 'should call proc/lambda on set property' do
    guerrero = PrototypeObject.new
    guerrero.set_property(:saludar, proc {"Hola!"})

    expect(guerrero.saludar).to eq "Hola!"
  end

  it 'should access to object properties' do
    
    guerrero = PrototypeObject.new
    guerrero.set_property(:nombre, 'Pepe')
    guerrero.set_property(:saludar, -> { "Hola!, soy #{nombre}" })

    expect(guerrero.saludar).to eq "Hola!, soy Pepe"

  end

  it 'should access to object properties and pass arguments' do
  
    guerrero = PrototypeObject.new
    guerrero.set_property(:nombre, 'Pepe')
    guerrero.set_property(:saludar, proc { |a| "Hola #{a}!, soy #{nombre}" })

    expect(guerrero.saludar('José')).to eq "Hola José!, soy Pepe"
  
  end

  it 'should copy object with properties' do

    guerrero = PrototypeObject.new
    guerrero.set_property(:energia, 100)

    otro_guerrero = guerrero.copy

    expect(otro_guerrero.energia).to eq 100

  end


  it 'should copy object with properties but they are different objects' do

    guerrero = PrototypeObject.new
    guerrero.set_property(:energia, 100)

    otro_guerrero = guerrero.copy
    otro_guerrero.set_property(:energia, 150)

    expect(guerrero.energia).to eq 100
    expect(otro_guerrero.energia).to eq 150

  end

  it 'should return the property of original object if not defined' do
    
    guerrero = PrototypeObject.new

    otro_guerrero = guerrero.copy

    guerrero.set_property(:energia, 150)

    expect(guerrero.energia).to eq 150
    expect(otro_guerrero.energia).to eq 150

  end

  it 'should use right self' do
    guerrero = PrototypeObject.new

    
    guerrero.set_property(:nombre, 'Pepe')
    guerrero.set_property(:saludar, -> { "Hola!, soy #{nombre}" })
    
    otro_guerrero = guerrero.copy
    otro_guerrero.set_property(:nombre, 'Juan')


    expect(guerrero.saludar).to eq "Hola!, soy Pepe"
    expect(otro_guerrero.saludar).to eq "Hola!, soy Juan"
  end

  it 'should define method to set property' do
    guerrero = PrototypeObject.new
    guerrero.set_property(:nombre, 'Jose')
    guerrero.nombre = 'Pepe'
    expect(guerrero.respond_to?(:nombre=)).to be true
    expect(guerrero.nombre).to eq 'Pepe'
  end

end