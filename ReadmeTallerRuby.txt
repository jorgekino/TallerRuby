Memcached TCP/IP server how to use:

1- Open cmd terminal and run Server.rb
2- Open a new terminal and run Client.rb
3- In terminal that you are running Client.rb write your username and write the memcached commands


Bugs and things that I know there are wrong

-Sometimes when two or more clients are using the server, when one client puts a command
the reply may appear in the other client.

-I did not find the correct way to use rspec in this challenge, so I use rspec to test
methods like validating the syntax of a command or validating if the value has the
correct length, etc.
