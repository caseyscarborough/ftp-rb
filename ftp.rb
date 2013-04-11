#!/Users/Casey/.rvm/rubies/ruby-2.0.0-p0/bin/ruby
 
require 'net/ftp'
require 'highline/import'


def open_connection(server_name, username, password)
	ftp = Net::FTP.open(server_name)
	ftp.login(username, password)
	return ftp
end


print "Enter the server name: "
server_name = $stdin.gets.strip
print "Username: "
username = $stdin.gets.strip
password = ask("Enter password: ") { |p| p.echo = false }

ftp = open_connection(server_name, username, password)
user_input = ""
until (user_input == "exit")
	print "ftp > "
	user_input = $stdin.gets.strip
	if (user_input == "ls")
		ls = ftp.list
		ls.each do |a|
			puts a
		end
	elsif (user_input.start_with?("cd"))
		dir = user_input.gsub(/cd /, '')
		begin
			ftp.chdir(dir)
		rescue
			puts "Directory does not exist!"
		end
	elsif (user_input == "exit")
		puts "Closing connection... Goodbye!"
		abort ftp.close
	else
		puts "Invalid command."
	end
end
 