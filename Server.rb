require 'socket'

class Server
  def initialize(socket_address, socket_port)
    @server_socket = TCPServer.open(socket_port, socket_address)

    @connections_details = Hash.new
    @connected_clients = Hash.new
    @connections_details = Hash.new
    @connected_clients = Hash.new
    @hash_value = Hash.new
    @hash_flag = Hash.new
    @hash_exptime = Hash.new
    @hash_bytes = Hash.new
    @hash_token = Hash.new
    @hash_date = Hash.new
    @connections_details[:server] = @server_socket
    @connections_details[:clients] = @connected_clients

    puts 'Started server.........'
    run

  end

  def run
    loop{
      client_connection = @server_socket.accept
      Thread.start(client_connection) do |conn| # open thread for each accepted connection
        conn_name = conn.gets.chomp.to_sym
        if @connections_details[:clients][conn_name] != nil # avoid connection if user exits
          conn.puts "This username already exist"
          conn.puts "quit"
          conn.kill self
        end

        puts "Connection established #{conn_name} => #{conn}"
        @connections_details[:clients][conn_name] = conn
        conn.puts "Connection established successfully #{conn_name} => #{conn}"

        establish_chatting(conn_name, conn) # allow chatting
      end
    }.join
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

  def validate_exptime(expetime)
    res = true
    @connections_details[:clients][client].puts " seconds: #{expetime} "
    date = Time.now
    date = date + seconds

    if date > Time.now
      @connections_details[:clients][client].puts "hola bebe"
      @hash_value.delete("#{key}")
      @hash_flag.delete("#{key}")
      @hash_exptime.delete("#{key}")
      @hash_bytes.delete("#{key}")
      @hash_date.delete("#{key}")
      @hash_token.delete("#{key}")
      res = true
    end
    res
  end

  def establish_chatting(username, connection)
    loop do
      message = connection.gets.chomp
      (@connections_details[:clients]).keys.each do |client|
        if message == "quit"
          socket.close
        else
          array = message.split(" ")
          if validate_command(array)
            cm = array[0]
            key = array[1]
            flag = array[2]
            exptime = array[3].to_i
            bytes = array[4].to_i
            noreply = array[5]
            case cm
            when "set"
              value = connection.gets.chomp
              if validate_value(value,bytes)
                @hash_value["#{key}"] = value
                @hash_flag["#{key}"] = flag
                @hash_exptime["#{key}"] = exptime
                @hash_bytes["#{key}"] = bytes
                @hash_date["#{key}"] = Time.now
                if noreply != "noreply"
                  @connections_details[:clients][client].puts "STORED"
                end
                else
                  @connections_details[:clients][client].puts "CLIENT-ERROR"
                end
            when "get"
              if @hash_value.has_key?(key)
                date = Time.now
                date_value = @hash_date["#{key}"]
                diference = date - date_value
                if diference < @hash_exptime["#{key}"] || @hash_exptime["#{key}"] == 0
                  @connections_details[:clients][client].puts "#{@hash_value["#{key}"]} #{key}  #{@hash_flag["#{key}"]}  #{@hash_bytes["#{key}"]}"
                else
                  @hash_value.delete(key)
                  @hash_token.delete(key)
                  @hash_date.delete(key)
                  @hash_exptime.delete(key)
                  @hash_bytes.delete(key)
                  @hash_flag.delete(key)
                  @connections_details[:clients][client].puts "NOT_STORED"
                end
              else
                @connections_details[:clients][client].puts "NOT_STORED"
              end
            when "gets"
              array.each do |n|
                if @hash_value.has_key?(n)
                  date = Time.now
                  date_value = @hash_date["#{key}"]
                  diference = date - date_value
                  if diference < @hash_exptime["#{key}"] || @hash_exptime["#{key}"] == 0
                    @connections_details[:clients][client].puts "#{@hash_value["#{key}"]} #{key}  #{@hash_flag["#{key}"]}  #{@hash_bytes["#{key}"]}"
                  else
                    @hash_value.delete(key)
                    @hash_token.delete(key)
                    @hash_date.delete(key)
                    @hash_exptime.delete(key)
                    @hash_bytes.delete(key)
                    @hash_flag.delete(key)
                  end
                end
              end
            when "add"
              if !@hash_value.has_key?(key)
                value = connection.gets.chomp
                if validate_value(value,bytes)
                  @hash_value["#{key}"] = value
                  @hash_flag["#{key}"] = flag
                  @hash_exptime["#{key}"] = exptime
                  @hash_bytes["#{key}"] = bytes
                  @hash_date["#{key}"] = Time.now
                  if noreply != "noreply"
                    @connections_details[:clients][client].puts "STORED"
                  end
                else
                  @connections_details[:clients][client].puts "CLIENT-ERROR"
                end
              else
                @connections_details[:clients][client].puts "NOT_STORED"
              end
            when "replace"
              if @hash_value.has_key?(key)
                value = connection.gets.chomp
                if validate_value(value,bytes)
                  @hash_value["#{key}"] = value
                  @hash_flag["#{key}"] = flag
                  @hash_exptime["#{key}"] = exptime
                  @hash_bytes["#{key}"] = bytes
                  @hash_date["#{key}"] = Time.now
                  if noreply != "noreply"
                    @connections_details[:clients][client].puts "STORED"
                  end
                else
                  @connections_details[:clients][client].puts "CLIENT-ERROR"
                end
              else
                @connections_details[:clients][client].puts "NOT_STORED"
              end
            when "append"
              if @hash_value.has_key?(key)
                value = connection.gets.chomp
                if validate_value(value,bytes)
                  @hash_value["#{key}"] = @hash_value["#{key}"] + value
                  @hash_flag["#{key}"] = flag
                  @hash_exptime["#{key}"] = exptime
                  @hash_bytes["#{key}"] = @hash_bytes["#{key}"] + bytes
                  @hash_date["#{key}"] = Time.now
                  if noreply != "noreply"
                    @connections_details[:clients][client].puts "STORED"
                  end
                else
                  @connections_details[:clients][client].puts "CLIENT-ERROR"
                end
              else
                @connections_details[:clients][client].puts "NOT_STORED"
              end
            when "prepend"
              if @hash_value.has_key?(key)
                value = connection.gets.chomp
                if validate_value(value,bytes)
                  @hash_value["#{key}"] = value + @hash_value["#{key}"]
                  @hash_flag["#{key}"] = flag
                  @hash_exptime["#{key}"] = exptime
                  @hash_bytes["#{key}"] = @hash_bytes["#{key}"] + bytes
                  @hash_date["#{key}"] = Time.now
                  if noreply != "noreply"
                    @connections_details[:clients][client].puts "STORED"
                  end
                else
                  @connections_details[:clients][client].puts "CLIENT-ERROR"
                end
              else
                @connections_details[:clients][client].puts "NOT_STORED"
              end
            when "cas"
              if @hash_value.has_key?(key)
                token = array[5]
                unless @hash_token.has_key?(key)
                  @hash_token["#{key}"] = token
                end
                if @hash_token["#{key}"] == token
                  value = connection.gets.chomp
                  if validate_value(value,bytes)
                    noreply = array[6]
                    @hash_value["#{key}"] = value
                    @hash_flag["#{key}"] = flag
                    @hash_exptime["#{key}"] = exptime
                    @hash_bytes["#{key}"] = bytes
                    @hash_date["#{key}"] = Time.now
                    if noreply != "noreply"
                      @connections_details[:clients][client].puts "STORED"
                    end
                  else
                    @connections_details[:clients][client].puts "CLIENT-ERROR"
                  end
                else
                  @connections_details[:clients][client].puts "EXIST"
                end
              else
                @connections_details[:clients][client].puts "NOT_FOUND"
              end
            else
              @connections_details[:clients][client].puts "ERROR SYNTAX ERROR"
            end
          else
            @connections_details[:clients][client].puts "ERROR SYNTAX ERROR"
          end
        end
      end
    end
  end
end


Server.new( 8080, "localhost" )