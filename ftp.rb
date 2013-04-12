#!/Users/Casey/.rvm/rubies/ruby-2.0.0-p0/bin/ruby
 
require 'net/ftp'
begin
	require 'highline/import'
rescue
	puts "Rubygem highline not found. Password will be shown in plain text."
end

def display_help
	abort "Usage: ruby ftp.rb [-?|-h|[user@host]]
Parameters:
     -?           displays the usage information
     -h           displays the usage information
     user@host    attempts to make a connection to the specified host
                  using the username provided
Once connected the user has the following options:
     ls                   displays a list of the current directory's contents
     pwd                  displays the path to the current working directory
     cd [directory]       changes to the specified directory
     get [file]           downloads the specified file
     put [file]           uploads the specified file from the local system
     rm [file]            deletes the specified file
     rename [file] [file] renames the first file to the name of the second file
     exit                 close the ftp connection and exit the application"
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

def put_file(file)
	if(File.exist?(file))
		begin
			puts "Uploading file..."
			$ftp.put(file)
			puts "File successfully uploaded!"
		rescue
			puts "There was an error trying to upload the file."
		end
	else
		puts "The specified file does not exist on the local system."
	end
end

def change_directory(dir)
	begin
		if(dir.end_with?("/"))
			$ftp.chdir(dir)
		else
			$ftp.chdir(dir + "/")
		end
	rescue
		puts "Directory does not exist!"
	end
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

def rename_file(file1, file2)
	list = $ftp.list
	list.each do |file|
		if (file.end_with?(file1))
			begin
				$ftp.rename(file1, file2)
				prompt
			rescue
				puts "Unable to rename file."
			end
		end
	end
	puts "File #{file1} not found."
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
		elsif (user_input.start_with?("put "))
			file = user_input.gsub(/put /, '')
			put_file(file)
		elsif (user_input.start_with?("rm "))
			file = user_input.gsub(/rm /, '')
			puts file
			delete_file(file)
		elsif (user_input == "pwd")
			puts $ftp.pwd
		elsif (user_input.start_with?("rename "))
			files = user_input.gsub(/rename /, '')
			file1 = files.gsub(/\s[A-Za-z0-9%&#$@!*()_.]{0,255}/, '')
			file2 = files.gsub(/[A-Za-z0-9%&#$@!*()_.]{0,255}\s/, '')
			rename_file(file1, file2)
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
	begin
		password = ask("#{username_hostname}\'s password: ") { |p| p.echo = false }
	rescue
		print "#{username_hostname}\'s password: "
		password = $stdin.gets.strip
	end
	$ftp = open_connection(hostname, username, password)
	if($ftp)
		prompt
	end
else
	puts "ftp.rb: illegal option -- #{ARGV[0]}"
	display_help
end

 