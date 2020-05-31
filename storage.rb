module Storage

  class StorageCommand
    def set(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,value)
      if validate.validate_value(value,bytes)
        data.asign_data(key,value,bytes,flag,exptime)
        if noreply != "noreply"
          connections_details[:clients][client].puts "STORED"
        end
      else
        connections_details[:clients][client].puts "CLIENT-ERROR"
      end
    end
  end

  class Set < StorageCommand
    def set_void(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,connection)
      value = connection.gets.chomp
      set(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,value)
    end
  end

  class Add < StorageCommand
    def add_void(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,connection)
      if !data.hash_value.has_key?(key)
        value = connection.gets.chomp
        set(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,value)
      else
        connections_details[:clients][client].puts "NOT_STORED"
      end
    end
  end

  class Replace < StorageCommand
    def replace_void(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,connection)
      if data.hash_value.has_key?(key)
        value = connection.gets.chomp
        set(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,value)
      else
        connections_details[:clients][client].puts "NOT_STORED"
      end
    end
  end

  class Append < StorageCommand
    def append_void(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,connection)
      if data.hash_value.has_key?(key)
        value = connection.gets.chomp
        new_value = data.hash_value["#{key}"] + value
        new_bytes = data.hash_bytes["#{key}"] + bytes
        set(connections_details,client,key,new_bytes,flag,exptime,noreply,data,validate,new_value)
      else
        connections_details[:clients][client].puts "NOT_STORED"
      end
    end
  end

  class Prepend < StorageCommand
    def prepend_void(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,connection)
      if data.hash_value.has_key?(key)
        value = connection.gets.chomp
        new_value = value + data.hash_value["#{key}"]
        new_bytes = data.hash_bytes["#{key}"] + bytes
        set(connections_details,client,key,new_bytes,flag,exptime,noreply,data,validate,new_value)
      else
        connections_details[:clients][client].puts "NOT_STORED"
      end
    end
  end

  class Cas < StorageCommand
    def cas_void(connections_details,client,key,token,bytes,flag,exptime,noreply,data,validate,connection)
      if data.hash_value.has_key?(key)
        unless data.hash_token.has_key?(key)
          data.hash_token["#{key}"] = token
        end
        if data.hash_token["#{key}"] == token
          value = connection.gets.chomp
          set(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,value)
        else
          connections_details[:clients][client].puts "EXIST"
        end
      else
        connections_details[:clients][client].puts "NOT_FOUND"
      end
    end
  end

end