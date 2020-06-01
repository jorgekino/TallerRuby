module Retrieval

  class RetrivalCommand
    def put(connections_details,client,key,data)
      if data.hash_value.has_key?(key)
        date = Time.now
        date_value = data.hash_date["#{key}"]
        diference = date - date_value
        if diference < data.hash_exptime["#{key}"] || data.hash_exptime["#{key}"] == 0
          connections_details[:clients][client].puts "#{data.hash_value["#{key}"]} #{key}  #{data.hash_flag["#{key}"]}  #{data.hash_bytes["#{key}"]}"
        else
          data.delete_data(key)
          connections_details[:clients][client].puts "NOT_STORED"
        end
      else
        connections_details[:clients][client].puts "NOT_STORED"
      end
    end
  end

  class Get < RetrivalCommand
    def get_void(connections_details,client,key,data)
      put(connections_details,client,key,data)
    end
  end

  class Gets < RetrivalCommand
    def gets_void (connections_details,client,data,array)
      array.each do |n|
        if n != "gets"
          put(connections_details,client,n,data)
        end
      end
    end
  end
end