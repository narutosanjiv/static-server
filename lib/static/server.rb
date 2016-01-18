#require "static/server/version"
require "socket"
require 'ostruct'
require 'optparse'

module Static
  module Server
    # Your code goes here...
    class << self
      def parse_options(argv)
        
        options = OpenStruct.new
        parser = OptionParser.new
        
        parser.on("-p", "--port PORT") { |opt| options.port = opt}
        parser.on("-r", "--root WEBROOT"){|opt| options.root = opt}
        parser.on("-i", "--indexFile INDEXFILE"){|opt| options.index_file = opt}

        files = parser.parse(argv)  
          
        [options, files] 
      end 
      
      def parse_path(root_directory, request_content)
        path = request_content.split[1] 
        full_path = root_directory + path     
        return full_path
      end      

      def run(argv)
        options, files = parse_options(argv)   
          
        server = TCPServer.new('localhost', options.port || 8080) 
        loop do
          socket = server.accept
          request_content = socket.gets
          file  = parse_path(options.root || Dir.pwd, request_content)
          puts "content #{file}"           
          File.open(file, "rb") do |file|
            socket.print "HTTP/1.1 200 OK\r\n" +
                   "Content-Type: text/html\r\n" +
                   "Content-Length: #{file.size}\r\n" +
                   "Connection: close\r\n"

            socket.print "\r\n"

            # write the contents of the file to the socket
            IO.copy_stream(file, socket)
          end             
      
        end            
      end 
   
    end   
  end
end

Static::Server.run(ARGV)
