#!/Users/Casey/.rvm/rubies/ruby-2.0.0-p0/bin/ruby
 
require 'net/ftp'
require 'highline/import'

def display_help
	help = 
	"Usage: ruby ftp.rb [-?|-h|[user@host]]\n
Parameters:
     -?           displays the usage information
     -h           displays the usage information
     user@host    attempts to make a connection to the specified host
                  using the username provided"
  	abort help
end

def open_connection(server_name, username, password)
	begin
		ftp = Net::FTP.open(server_name)
		ftp.login(username, password)
		puts ftp.welcome
	rescue
		abort "Unable to access server. Please check credentials."
	end
	return ftp
end

def get_file(dir)
	begin
		puts "Retrieving file #{file}..."
		$ftp.get(file)
		puts "File successfully retrieved!"
	rescue
		puts "Could not retrieve remote file."
	end
end

def change_directory(dir)
	# begin
		if(dir.end_with?("/"))
			$ftp.chdir(dir)
		else
			$ftp.chdir(dir + "/")
		end
	# rescue
	# 	puts "Directory does not exist!"
	# end
end

def delete_file(file_to_delete)
	user_input = ""
	list = $ftp.list
	list.each do |file|
		if (file.end_with?(file_to_delete))
			until (user_input == "Y" || user_input == "N")
				print "Are you sure you want to delete the file? You cannot undo this action. [Y/N]: "
				user_input = $stdin.gets.strip.upcase
			end
			if (user_input == "Y")
				begin
					$ftp.delete(file_to_delete)
					puts "File deleted successfully!"
				rescue
					puts "Unable to delete file!"
				end
			end
		end 
	end
end

def prompt
	user_input = ""
	until (user_input == "exit")
		print "ftp > "
		user_input = $stdin.gets.strip
		if (user_input == "ls")
			ls = $ftp.list
			ls.each do |a|
				puts a
			end
		elsif (user_input.start_with?("cd "))
			dir = user_input.gsub(/cd /, '')
			change_directory(dir)
		elsif (user_input.start_with?("get "))
			file = user_input.gsub(/get /, '')
			get_file(file)
		elsif (user_input.start_with?("rm "))
			file = user_input.gsub(/rm /, '')
			puts file
			delete_file(file)
		elsif (user_input == "pwd")
			puts $ftp.pwd
		elsif (user_input == "exit")
			puts "Closing connection... Goodbye!"
			abort $ftp.close
		else
			puts "Invalid command - please try again."
		end
	end
end

if (ARGV[0] == "-?" || ARGV[0] == "-h")
	display_help
elsif (/[A-Za-z0-9]@[A-Za-z0-9]/.match(ARGV[0]))
	username_hostname = ARGV[0]
	username = username_hostname.gsub(/@[A-Za-z0-9]{0,255}.[A-Za-z0-9]{2,4}/, '')
	hostname = username_hostname.gsub(/[A-Za-z0-9]{0,255}@/, '')
	password = ask("Enter password: ") { |p| p.echo = false }
	$ftp = open_connection(hostname, username, password)
	if($ftp)
		prompt
	end
end

 