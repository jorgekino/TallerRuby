require 'socket'
require_relative 'memory'
require_relative 'validation'
require_relative 'retrieval'
require_relative 'storage'
include Retrieval
include Storage


CONST_SET = "set"
CONST_ADD = "add"
CONST_REPLACE = "replace"
CONST_APPEND = "append"
CONST_PREPEND = "prepend"
CONST_CAS = "cas"
CONST_GET = "get"
CONST_GETS = "gets"

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
    @data = Memory.new(@hash_value, @hash_flag, @hash_exptime, @hash_bytes, @hash_token, @hash_date)
    @validate = Validation.new
    @connections_details[:server] = @server_socket
    @connections_details[:clients] = @connected_clients
    @set = Sets.new
    @add = Add.new
    @replace = Replace.new
    @prepend = Prepend.new
    @append = Append.new
    @cas = Cas.new
    @get = Get.new
    @gets = Gets.new

    puts 'Started server.........'
    run
  end

  def run
    loop{
      client_connection = @server_socket.accept
      Thread.start(client_connection) do |conn|
          conn_name = conn.gets.chomp.to_sym
          if @connections_details[:clients][conn_name] != nil
            conn.puts "This username already exist"
            conn.puts "quit"
            conn.kill self
          end
          puts "Connection established #{conn_name} => #{conn}"
          @connections_details[:clients][conn_name] = conn
          conn.puts "Connection established successfully #{conn_name} => #{conn}"
        establish_chatting(conn_name, conn)
      end
    }.join
  end

  def establish_chatting(username, connection)
    loop do
      message = connection.gets.chomp
      (@connections_details[:clients]).keys.each do |client|
        if client == username
          array = message.split(" ")
          if @validate.validate_command(array)
            cm = array[0]
            key = array[1]
            flag = array[2]
            exptime = array[3].to_i
            bytes = array[4].to_i
            noreply = array[5]

            case cm

            when CONST_GET

              @get.get_void(@connections_details, client, key, @data)

            when CONST_GETS

              @gets.gets_void(@connections_details,client,@data,array)

            when CONST_SET

              @set.set_void(@connections_details,client,key,bytes,flag,exptime,noreply,@data,@validate,connection)

            when CONST_ADD

              @add.add_void(@connections_details,client,key,bytes,flag,exptime,noreply,@data,@validate,connection)

            when CONST_REPLACE

              @replace.replace_void(@connections_details,client,key,bytes,flag,exptime,noreply,@data,@validate,connection)

            when CONST_APPEND

              @append.append_void(@connections_details,client,key,bytes,flag,exptime,noreply,@data,@validate,connection)

            when CONST_PREPEND

              @prepend.prepend_void(@connections_details,client,key,bytes,flag,exptime,noreply,@data,@validate,connection)

            when CONST_CAS

              token = array[5]
              noreply = array[6]
              @cas.cas_void(@connections_details,client,key,token,bytes,flag,exptime,noreply,@data,@validate,connection)

            else

              @connections_details[:clients][client].puts "ERROR"

            end
          else
            @connections_details[:clients][client].puts "ERROR"
          end
        end
      end
    end
  end
end

Server.new( 3000, "localhost" )