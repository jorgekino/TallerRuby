module Retrieval

  class RetrivalCommand
    def put(connections_details,client,key,data,username)
      if data.hash_value.has_key?(key)
        date = Time.now
        date_value = data.hash_date["#{key}"]
        diference = date - date_value
        if diference < data.hash_exptime["#{key}"] || data.hash_exptime["#{key}"] == 0
          if client == username
            connections_details[:clients][client].puts "#{data.hash_value["#{key}"]} #{key}  #{data.hash_flag["#{key}"]}  #{data.hash_bytes["#{key}"]}"
          end
        else
          data.delete_data(key)
          if client == username
            connections_details[:clients][client].puts "NOT_STORED"
          end
        end
      else
        if client == username
          connections_details[:clients][client].puts "NOT_STORED"
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
        put(connections_details,client,key,data,username)
      end
    end
  end
end