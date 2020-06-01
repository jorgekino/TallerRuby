require 'rspec'

class Validation

  def validate_command(array)
    res = false
    if array[0] == "get"
      if array.length == 2
        res = true
      end
    end
    if array[0] == "gets"
      res = true
    end
    if array[0] == "cas"
      array.length <= 7
      if valid_pin?(array[2]) && valid_pin?(array[3]) && valid_pin?(array[4]) && valid_pin?(array[5])
        res = true
      end
      if array.length == 7
        if array[6] != "noreply"
          res = false
        end
      end
    end
    if array[0] == "set" || array[0] == "add" || array[0] == "replace" || array[0] == "append" || array[0] == "prepend"
      if array.length <= 6
        if valid_pin?(array[2]) && valid_pin?(array[3]) && valid_pin?(array[4])
          res = true
        end
        if array.length == 6
          if array[5] != "noreply"
            res = false
          end
        end
      end
    end
    res
  end

  def valid_pin?(coomand_atribute)
    /^\d{0,100}$/ === coomand_atribute
  end

  def validate_value(value,bytes)
    res = false
    if value.length == bytes
      if value.count('01') == value.size
        res = true
      end
    end
    res
  end

end

describe Validation do

    it 'verify if the command has correct syntax' do
      string = "hey you"
      array = string.split(" ")
      validate = Validation.new
      actual = validate.validate_command(array)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = "set"
      array = string.split(" ")
      validate = Validation.new
      actual = validate.validate_command(array)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = "set clave 1 500"
      array = string.split(" ")
      validate = Validation.new
      actual = validate.validate_command(array)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = "cas clave 1 500 1"
      array = string.split(" ")
      validate = Validation.new
      actual = validate.validate_command(array)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = " "
      array = string.split(" ")
      validate = Validation.new
      actual = validate.validate_command(array)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = "hey you I am a unit test"
      array = string.split(" ")
      validate = Validation.new
      actual = validate.validate_command(array)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = "set key 1 500 2"
      array = string.split(" ")
      validate = Validation.new
      actual = validate.validate_command(array)
      validate = true
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = "add key 1 500 2"
      array = string.split(" ")
      validate = Validation.new
      actual = validate.validate_command(array)
      validate = true
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = "replace key 1 500 2"
      array = string.split(" ")
      validate = Validation.new
      actual = validate.validate_command(array)
      validate = true
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = "prepend key 1 500 2"
      array = string.split(" ")
      validate = Validation.new
      actual = validate.validate_command(array)
      validate = true
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = "append key 1 500 2"
      array = string.split(" ")
      validate = Validation.new
      actual = validate.validate_command(array)
      validate = true
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = "cas key 1 500 2 1"
      array = string.split(" ")
      validate = Validation.new
      actual = validate.validate_command(array)
      validate = true
      expect(actual).to eq validate
    end


    it 'verify if validate_pin works rigth' do
      validate = Validation.new
      actual = validate.valid_pin?("56ad5")
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if validate_pin works rigth' do
      validate = Validation.new
      actual = validate.valid_pin?("01d")
      validate = false
      expect(actual).to eq validate
    end
    it 'verify if validate_pin works rigth' do
      validate = Validation.new
      actual = validate.valid_pin?("d01")
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if validate_pin works rigth' do
      validate = Validation.new
      actual = validate.valid_pin?("011d00")
      validate = false
      expect(actual).to eq validate
    end
    it 'verify if validate_pin works rigth' do
      validate = Validation.new
      actual = validate.valid_pin?("01100")
      validate = true
      expect(actual).to eq validate
    end

    it 'verify if a value has te correct lenth' do
      validate = Validation.new
      actual = validate.validate_value("0111",5)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if a value has te correct lenth' do
      validate = Validation.new
      actual = validate.validate_value("0111",4)
      validate = true
      expect(actual).to eq validate
    end

    it 'verify if a value has te correct lenth' do
      validate = Validation.new
      actual = validate.validate_value("011d1",5)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if a value has te correct lenth' do
      validate = Validation.new
      actual = validate.validate_value("0111d",5)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if a value has te correct lenth' do
      validate = Validation.new
      actual = validate.validate_value("d0111",5)
      validate = false
      expect(actual).to eq validate
    end
end