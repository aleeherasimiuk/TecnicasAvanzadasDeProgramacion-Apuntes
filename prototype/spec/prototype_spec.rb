class PrototypeObject

  def initialize()
    @properties = {}
  end

  def set_property(property_name, value)
    @properties[property_name] = value
  end

  def get_property(property_name)
    @properties[property_name]
  end
end

describe '' do
  it '' do

    guerrero = PrototypeObject.new
    guerrero.set_property(:energia, 100)

    expect(guerrero.get_property(:energia)).to eq 100

  end
end