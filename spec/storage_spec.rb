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



  class StorageCommand
    def set(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,value,username)
      if validate.validate_value(value,bytes)
        data.asign_data(key,value,bytes,flag,exptime)
        if noreply != "noreply"
          if client == username
            puts "STORED"
          end
        end
      else
        if client == username
          puts "CLIENT_ERROR"
        end
      end
    end
  end

  class Sets < StorageCommand
    def set_void(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,connection,username)
      value = "01110"
      set(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,value,username)
    end
  end

class Add < StorageCommand
  def add_void(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,connection,username)
    if !data.hash_value.has_key?(key)
      value = "0101"
      set(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,value,username)
    else
      if client == username
        puts "NOT_STORED"
      end
    end
  end
end

class Replace < StorageCommand
  def replace_void(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,connection,username)
    if data.hash_value.has_key?(key)
      value = "01"
      set(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,value,username)
    else
      if client == username
        puts "NOT_STORED"
      end
    end
  end
end

class Append < StorageCommand
  def append_void(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,connection,username)
    if data.hash_value.has_key?(key)
      value = "11"
      new_value = data.hash_value["#{key}"] + value
      new_bytes = data.hash_bytes["#{key}"] + bytes
      set(connections_details,client,key,new_bytes,flag,exptime,noreply,data,validate,new_value,username)
    else
      if client == username
        puts "NOT_STORED"
      end
    end
  end
end

class Prepend < StorageCommand
  def prepend_void(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,connection,username)
    if data.hash_value.has_key?(key)
      value = "11"
      new_value = value + data.hash_value["#{key}"]
      new_bytes = data.hash_bytes["#{key}"] + bytes
      set(connections_details,client,key,new_bytes,flag,exptime,noreply,data,validate,new_value,username)
    else
      if client == username
        puts "NOT_STORED"
      end
    end
  end
end

class Cas < StorageCommand
  def cas_void(connections_details,client,key,token,bytes,flag,exptime,noreply,data,validate,connection,username)
    if data.hash_value.has_key?(key)
      unless data.hash_token.has_key?(key)
        data.hash_token["#{key}"] = token
      end
      if data.hash_token["#{key}"] == token
        value = "10"
        set(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,value,username)
      else
        if client == username
          puts "EXIST"
        end
      end
    else
      if client == username
        puts "NOT_FOUND"
      end
    end
  end
end

describe StorageCommand do

    it 'verify if set is correctly working' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key = "key"
      set = Sets.new
      connection = Hash.new
      validate = Validation.new
      client = "client"
      ussername = "client"
      expect { set.set_void(connection,client,key,4,1,500,"",memory,validate,"",ussername) }.to output("CLIENT_ERROR\n").to_stdout
    end

    it 'verify if set is correctly working' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key = "key"
      set = Sets.new
      connection = Hash.new
      validate = Validation.new
      client = "client"
      ussername = "client"
      expect { set.set_void(connection,client,key,5,1,500,"",memory,validate,"",ussername) }.to output("STORED\n").to_stdout
    end

    it 'verify if set is correctly working' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key = "key"
      set = Sets.new
      connection = Hash.new
      validate = Validation.new
      client = "client"
      ussername = "client"
      expect { set.set_void(connection,client,key,"D",1,500,"",memory,validate,"",ussername) }.to output("CLIENT_ERROR\n").to_stdout
    end

    it 'verify if set is correctly working' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key = "key"
      set = Sets.new
      connection = Hash.new
      validate = Validation.new
      client = "client"
      ussername = "client"
      expect { set.set_void(connection,client,key,5,1,500,"noreply",memory,validate,"",ussername) }.to output("").to_stdout
    end

    it 'verify if add is correctly working' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key = "key"
      add = Add.new
      connection = Hash.new
      validate = Validation.new
      client = "client"
      ussername = "client"
      expect { add.add_void(connection,client,key,4,1,500,"",memory,validate,"",ussername) }.to output("STORED\n").to_stdout
    end

    it 'verify if add is correctly working' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key = "key"
      memory.asign_data(key,"0110",4,1,100)
      add = Add.new
      connection = Hash.new
      validate = Validation.new
      client = "client"
      ussername = "client"
      expect { add.add_void(connection,client,key,4,1,500,"",memory,validate,"",ussername) }.to output("NOT_STORED\n").to_stdout
    end

    it 'verify if add is correctly working' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key = "key"
      add = Add.new
      connection = Hash.new
      validate = Validation.new
      client = "client"
      ussername = "client"
      expect { add.add_void(connection,client,key,3,1,500,"",memory,validate,"",ussername) }.to output("CLIENT_ERROR\n").to_stdout
    end

    it 'verify if replace is correctly working' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key = "key"
      replace = Replace.new
      connection = Hash.new
      validate = Validation.new
      client = "client"
      ussername = "client"
      expect { replace.replace_void(connection,client,key,4,1,500,"",memory,validate,"",ussername) }.to output("NOT_STORED\n").to_stdout
    end

    it 'verify if replace is correctly working' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key = "key"
      memory.asign_data(key,"0110",4,1,100)
      replace = Replace.new
      connection = Hash.new
      validate = Validation.new
      client = "client"
      ussername = "client"
      expect { replace.replace_void(connection,client,key,2,1,500,"",memory,validate,"",ussername) }.to output("STORED\n").to_stdout
    end

    it 'verify if append is correctly working' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key = "key"
      memory.asign_data(key,"0110",4,1,100)
      append = Append.new
      connection = Hash.new
      validate = Validation.new
      client = "client"
      ussername = "client"
      expect { append.append_void(connection,client,key,2,1,500,"",memory,validate,"",ussername) }.to output("STORED\n").to_stdout
    end

    it 'verify if append is correctly working' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key = "key"
      append = Append.new
      connection = Hash.new
      validate = Validation.new
      client = "client"
      ussername = "client"
      expect { append.append_void(connection,client,key,2,1,500,"",memory,validate,"",ussername) }.to output("NOT_STORED\n").to_stdout
    end

    it 'verify if prepend is correctly working' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key = "key"
      memory.asign_data(key,"0110",4,1,100)
      prepend = Prepend.new
      connection = Hash.new
      validate = Validation.new
      client = "client"
      ussername = "client"
      expect { prepend.prepend_void(connection,client,key,2,1,500,"",memory,validate,"",ussername) }.to output("STORED\n").to_stdout
    end

    it 'verify if prepend is correctly working' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key = "key"
      prepend = Prepend.new
      connection = Hash.new
      validate = Validation.new
      client = "client"
      ussername = "client"
      expect { prepend.prepend_void(connection,client,key,2,1,500,"",memory,validate,"",ussername) }.to output("NOT_STORED\n").to_stdout
    end

    it 'verify if cas is correctly working' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key = "key"
      memory.asign_data(key,"0110",4,1,100)
      cas = Cas.new
      connection = Hash.new
      validate = Validation.new
      client = "client"
      ussername = "client"
      expect { cas.cas_void(connection,client,key,1,2,1,500,"",memory,validate,"",ussername,) }.to output("STORED\n").to_stdout
    end

    it 'verify if cas is correctly working' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key = "key"
      memory.asign_data(key,"0110",4,1,100)
      memory.hash_token["#{key}"] = 3
      cas = Cas.new
      connection = Hash.new
      validate = Validation.new
      client = "client"
      ussername = "client"
      expect { cas.cas_void(connection,client,key,1,2,1,500,"",memory,validate,"",ussername,) }.to output("EXIST\n").to_stdout
    end

    it 'verify if cas is correctly working' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key = "key"
      cas = Cas.new
      connection = Hash.new
      validate = Validation.new
      client = "client"
      ussername = "client"
      expect { cas.cas_void(connection,client,key,1,2,1,500,"",memory,validate,"",ussername,) }.to output("NOT_FOUND\n").to_stdout
    end
end