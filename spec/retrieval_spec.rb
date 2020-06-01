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

class Memory
  def initialize(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
    @hash_value = hash_value
    @hash_flag = hash_flag
    @hash_exptime = hash_exptime
    @hash_bytes = hash_bytes
    @hash_token = hash_token
    @hash_date = hash_date
  end

  def hash_value
    @hash_value
  end

  def hash_bytes
    @hash_bytes
  end

  def hash_token
    @hash_token
  end

  def hash_date
    @hash_date
  end

  def hash_exptime
    @hash_exptime
  end

  def hash_flag
    @hash_flag
  end

  def asign_data(key,value,bytes,flag,exptime)
    @hash_value["#{key}"] = value
    @hash_flag["#{key}"] = flag
    @hash_exptime["#{key}"] = exptime
    @hash_bytes["#{key}"] = bytes
    @hash_date["#{key}"] = Time.now
  end

  def delete_data(key)
    @hash_value.delete(key)
    @hash_token.delete(key)
    @hash_date.delete(key)
    @hash_exptime.delete(key)
    @hash_bytes.delete(key)
    @hash_flag.delete(key)
  end
end

class RetrivalCommand
  def put(connections_details,client,key,data,username)
    if data.hash_value.has_key?(key)
      date = Time.now
      date_value = data.hash_date["#{key}"]
      diference = date - date_value
      if diference < data.hash_exptime["#{key}"] || data.hash_exptime["#{key}"] == 0
        if client == username
          puts "#{data.hash_value["#{key}"]} #{key}  #{data.hash_flag["#{key}"]}  #{data.hash_bytes["#{key}"]}"
        end
      else
        data.delete_data(key)
        if client == username
          puts "NOT_STORED"
        end
      end
    else
      if client == username
        puts "NOT_STORED"
      end
    end
  end
end

class Get < RetrivalCommand
  def get_void(connections_details,client,key,data,username)
    put(connections_details,client,key,data,username)
  end
end

class Gets < RetrivalCommand
  def gets_void (connections_details,client,data,username,array)
    array.each do |n|
      if n != "gets"
        put(connections_details,client,n,data,username)
      end
    end
  end
end



describe RetrivalCommand do

    it 'verify if get is correctly working' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key = "key"
      memory.asign_data(key,"0110",4,1,100)
      get = Get.new
      connection = Hash.new
      client = "client"
      ussername = "client"
      expect { get.get_void(connection,client,key,memory,ussername) }.to output("0110 key  1  4\n").to_stdout
    end

    it 'verify if get is correctly working' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key = "key"
      get = Get.new
      connection = Hash.new
      client = "client"
      ussername = "client"
      expect { get.get_void(connection,client,key,memory,ussername) }.to output("NOT_STORED\n").to_stdout
    end

    it 'verify if gets is correctly working' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key1 = "key1"
      key2 = "key2"
      memory.asign_data(key1,"0110",4,1,100)
      memory.asign_data(key2,"10",2,1,100)
      gets = Gets.new
      connection = Hash.new
      client = "client"
      ussername = "client"
      test = "gets key1 key2"
      array = test.split(" ")
      expect { gets.gets_void(connection,client,memory,ussername,array) }.to output("0110 key1  1  4\n10 key2  1  2\n").to_stdout
    end

    it 'verify if gets is correctly working' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key1 = "key1"
      key2 = "key2"
      memory.asign_data(key1,"0110",4,1,100)
      gets = Gets.new
      connection = Hash.new
      client = "client"
      ussername = "client"
      test = "gets key1 key2"
      array = test.split(" ")
      expect { gets.gets_void(connection,client,memory,ussername,array) }.to output("0110 key1  1  4\nNOT_STORED\n").to_stdout
    end

end