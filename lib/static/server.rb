require "static/server/version"
require "socket"
require 'ostruct'
require 'optparse'

module Static
  module Server
    # Your code goes here...
    class << self
      def parse_options(argv)
        
        options = OpenStruct.new(port: 8080, root: Dir.pwd, index_file: 'index.html')
        parser = OptionParser.new
        
        parser.on("-p", "--port PORT") { |opt| options.port = opt}
        parser.on("-r", "--root WEBROOT"){|opt| options.root = opt}
        parser.on("-i", "--indexFile INDEXFILE"){|opt| options.index_file = opt}

        files = parser.parse(argv)  
          
        [options, files] 
      end 
      
      def parse_path(request_content)
        path = request_content.split[1] 
        return path
      end      

      def run(argv)
        options, files = parse_options(argv)   
        puts "options #{options}" 
        server = TCPServer.new('localhost', options.port) 
        loop do
          socket = server.accept
          request_content = socket.gets
          file  = parse_path(request_content)
          full_path = ""
          if file == "/"
            full_path = options.root + "/index.html"
          else
            full_path = options.root + file
          end
          puts "content #{file}"           
          File.open(full_path, "rb") do |file|
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
