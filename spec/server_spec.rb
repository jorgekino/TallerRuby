require 'rspec'

class Server

  def valid_pin?(coomand_atribute)
    /^\d{0,100}$/ === coomand_atribute
  end

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

describe Server do

    it 'verify if the command has correct syntax' do
      string = "hey you"
      array = string.split(" ")
      server = Server.new
      actual = server.validate_command(array)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = "add key 1 900"
      array = string.split(" ")
      server = Server.new
      actual = server.validate_command(array)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = "add key 1 a 900"
      array = string.split(" ")
      server = Server.new
      actual = server.validate_command(array)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = "add key 1 a 900"
      array = string.split(" ")
      server = Server.new
      actual = server.validate_command(array)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = "add key a 1 900"
      array = string.split(" ")
      server = Server.new
      actual = server.validate_command(array)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = "ad key 1 900 5"
      array = string.split(" ")
      server = Server.new
      actual = server.validate_command(array)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = "add key 1 900"
      array = string.split(" ")
      server = Server.new
      actual = server.validate_command(array)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = "add key 1 900 5 hey"
      array = string.split(" ")
      server = Server.new
      actual = server.validate_command(array)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = "cas key 1 900 60"
      array = string.split(" ")
      server = Server.new
      actual = server.validate_command(array)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = "cas key 1 900 60 hey"
      array = string.split(" ")
      server = Server.new
      actual = server.validate_command(array)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = "cas key 1 900 60 1 noreply"
      array = string.split(" ")
      server = Server.new
      actual = server.validate_command(array)
      validate = true
      expect(actual).to eq validate
    end

    it 'verify if the command has correct syntax' do
      string = "add key 1 900 60"
      array = string.split(" ")
      server = Server.new
      actual = server.validate_command(array)
      validate = true
      expect(actual).to eq validate
    end

    it 'verify if the value has the spected length' do
      server = Server.new
      actual = server.validate_value("0110",5)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if the value has the spected length' do
      server = Server.new
      actual = server.validate_value("0d10",5)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if the value has the spected length' do
      server = Server.new
      actual = server.validate_value("0d10",5)
      validate = false
      expect(actual).to eq validate
    end

    it 'verify if the value has the spected length' do
      server = Server.new
      actual = server.validate_value("0110",4)
      validate = true
      expect(actual).to eq validate
    end
end