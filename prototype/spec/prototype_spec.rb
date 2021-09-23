class PrototypeObject

  def initialize()
    @properties = {}
  end

  def set_property(property_name, value)
    @properties[property_name] = value
  end

  def get_property(property_name)
    @properties.fetch(property_name) {raise PropertyNotFoundError.new}
  end

  def method_missing(method_name, *params, &block)
    if respond_to_missing?(method_name)
      get_property(method_name)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    @properties.has_key?(method_name) || super
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

end