Ruby FTP Application
--------------------

This is a simple FTP application written in Ruby v2.0.0 that allows a user to connect to an FTP server and remove, upload, and download files.

The program is run by specifying either the help arguments (-? or -h) or by specifying a username and hostname through the command line. If the user runs the program using the help argument, the following dialog is displayed:

<pre>Casey:~$ ruby ftp.rb -?
Usage: ruby ftp.rb [-?|-h|[user@host <file>]]
Parameters:
     -?                displays the usage information
     -h                displays the usage information
     user@host         attempts to make a connection to the specified host
                       using the username provided
     user@host &lt;file&gt;  connects to the specified host and uploads the 
                       file if it exists
Once connected the user has the following options:
     ls                   displays a list of the current directory's contents
     pwd                  displays the path to the current working directory
     cd [directory]       changes to the specified directory
     get [file]           downloads the specified file
     put [file]           uploads the specified file from the local system
     rm [file]            deletes the specified file in the current directory
     rename [file] [file] renames the first file to the name of the second file
     exit                 close the ftp connection and exit the application</pre>

This dialog gives the user the information that is needed to run the application.

Logging in and using the application
------------------------------------

To log in and use the application, run the program specifying a username and hostname as the first argument:

<pre>Casey:~$ ruby ftp.rb casey@hostname.com</pre>

You will then be prompted for a password. After authenticating, you then have the ability to use familiar commands such as ls, pwd, cd, rm, etc. See the help display above for more information.
