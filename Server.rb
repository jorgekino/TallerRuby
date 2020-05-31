require 'socket'
require_relative 'datos'
require_relative 'validation'
require_relative 'retrieval'
require_relative 'storage'
include Retrieval
include Storage


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
    @data = Datos.new(@hash_value,@hash_flag,@hash_exptime,@hash_bytes,@hash_token,@hash_date)
    @validate = Validation.new
    @connections_details[:server] = @server_socket
    @connections_details[:clients] = @connected_clients

    puts 'Started server.........'
    run

  end

  def run
    loop{
      semaphore = Mutex.new
      client_connection = @server_socket.accept
      Thread.start(client_connection) do |conn| # open thread for each accepted connection
        semaphore.synchronize {
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
        }
      end
    }.join
  end

  def establish_chatting(username, connection)
    loop do
      message = connection.gets.chomp
      (@connections_details[:clients]).keys.each do |client|
        array = message.split(" ")
          if @validate.validate_command(array)
            cm = array[0]
            key = array[1]
            flag = array[2]
            exptime = array[3].to_i
            bytes = array[4].to_i
            noreply = array[5]

            case cm

            when "get"
              get = Get.new
              get.get_void(@connections_details,client,key,@data,username)

            when "gets"
              gets = Gets.new
              gets.gets_void(@connections_details,client,@data,username,array)
            when "set"
              set = Set.new
              set.set_void(@connections_details,client,key,bytes,flag,exptime,noreply,@data,@validate,connection)

            when "add"
                add = Add.new
                add.add_void(@connections_details,client,key,bytes,flag,exptime,noreply,@data,@validate,connection)

            when "replace"
                replace = Replace.new
                replace.replace_void(@connections_details,client,key,bytes,flag,exptime,noreply,@data,@validate,connection)

            when "append"
                append = Append.new
                append.append_void(@connections_details,client,key,bytes,flag,exptime,noreply,@data,@validate,connection)

            when "prepend"
                prepend = Prepend.new
                prepend.prepend_void(@connections_details,client,key,bytes,flag,exptime,noreply,@data,@validate,connection)

            when "cas"
                cas = Cas.new
                token = array[5]
                noreply = array[6]
                cas.cas_void(@connections_details,client,key,token,bytes,flag,exptime,noreply,@data,@validate,connection)

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


Server.new( 3000, "localhost" )