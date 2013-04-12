#!/usr/bin/env ruby

require 'net/ftp'
begin
	require 'highline/import'
rescue
	puts "Rubygem highline not found. Password will be shown in plain text."
end

# This function displays the help menu for the application.
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
     rm [file]            deletes the specified file in the current directory
     rename [file] [file] renames the first file to the name of the second file
     exit                 close the ftp connection and exit the application"
end

# This function opens the connection to the FTP server using the
# server name, username, and password passed into it.
def open_connection(server_name, username, password)
	begin # Attempt to open the connection and log in
		ftp = Net::FTP.open(server_name)
		ftp.login(username, password)
		puts ftp.welcome
	rescue # Catch any errors
		abort "Unable to access server. Please check credentials."
	end
	return ftp
end

# This function is used to download a remote file to the user's machine.
def get_file(file)
	begin # Attempt to retrieve the remote file
		puts "Retrieving file #{file}..."
		$ftp.get(file)
		puts "File successfully retrieved!"
	rescue # Catch any errors
		puts "Could not retrieve remote file. Check pathname."
	end
end

# This function is used to upload a file from the user's local machine.
def put_file(file)
	# Check to see if the file exists locally
	if(File.exist?(file))
		begin # If so, begin uploading the file
			puts "Uploading file..."
			$ftp.put(file)
			puts "File successfully uploaded!"
		rescue # Catch any errors
			puts "There was an error trying to upload the file."
		end
	else # If it does not exist, let the user know
		puts "The specified file does not exist on the local system."
	end
end

# This function is used for changing the directory.
def change_directory(dir)
	begin # If the directory does not end with a '/', add it
		if(dir.end_with?("/"))
			$ftp.chdir(dir)
		else
			$ftp.chdir(dir + "/")
		end
	rescue # Let the user know if the directory doesn't exist
		puts "Directory does not exist!"
	end
end

# This function is for deleting files in the current directory.
def delete_file(file_to_delete)
	user_input = ""
	# Get a list of the files in the current directory
	list = $ftp.list
	list.each do |file| # Check if the file exists
		if (file.end_with?(file_to_delete))
			# Prompt the user for confirmation
			until (user_input == "Y" || user_input == "N")
				print "Are you sure you want to delete the file? You cannot undo this action. [Y/N]: "
				user_input = $stdin.gets.strip.upcase
			end
			if (user_input == "Y")
				begin # Delete the file
					$ftp.delete(file_to_delete)
					puts "File deleted successfully!"
				rescue # Catch any errors
					puts "Unable to delete file!"
				end
			end
		end 
	end
end

# This function is for renaming files in the current directory.
def rename_file(file1, file2)
	# Get the list of files in the current directory
	list = $ftp.list
	list.each do |file| # Check if it exists
		if (file.end_with?(file1))
			begin # Rename the file
				$ftp.rename(file1, file2)
				prompt
			rescue
				puts "Unable to rename file."
			end
		end
	end
	puts "File #{file1} not found."
end

# This function is the main prompt for the program, and allows the
# user to enter their commands. This function ends when the user
# types 'exit'.
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

# Display the help screen
if (ARGV[0] == "-?" || ARGV[0] == "-h")
	display_help
# Check if the user entered a proper username/hostname combination
elsif (/[A-Za-z0-9]@[A-Za-z0-9]/.match(ARGV[0]))
	username_hostname = ARGV[0]
	# Get the username and hostname
	username = username_hostname.gsub(/@[A-Za-z0-9]{0,255}.[A-Za-z0-9]{2,4}/, '')
	hostname = username_hostname.gsub(/[A-Za-z0-9]{0,255}@/, '')
	begin # Retrieve password using highline if available
		password = ask("#{username_hostname}\'s password: ") { |p| p.echo = false }
	rescue # If not, retrieve it in plain text
		print "#{username_hostname}\'s password: "
		password = $stdin.gets.strip
	end # Open the ftp connection
	$ftp = open_connection(hostname, username, password)
	if($ftp) # If it was successful, start the prompt
		prompt
	end
else # Illegal action
	puts "ftp.rb: illegal option -- #{ARGV[0]}"
	display_help
end

 