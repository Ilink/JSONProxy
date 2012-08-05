# Proxy
# JSONP Proxy
# Accepts a the requested URL as a parameter
#   EG: http://localhost:3000/?request=http%3A%2F%2Fwww.google.com%2Ftest.json
#   Note that the request param is a URI encoded version of: http://www.google.com/test.json
# Runs on a single thread, so don't expect super high performance here.


require 'socket'
require 'optparse'
require 'net/http'
require 'cgi'
require 'uri'

# Process arguments
options = {}

# Defaults
options[:port] = 3000

OptionParser.new do |opts|
  opts.banner = "Usage: proxy.rb [options]"

  opts.on("-p p", "--port p", Integer, "Specify port") do |p|
    options[:port] = p
  end
end.parse!

server = TCPServer.new '127.0.0.1', options[:port]

loop do
  client = server.accept
  unless client.nil?
    puts "Incoming client request.."
    request = client.gets.gsub(/GET\ \//, '').gsub(/\ HTTP.*/, '').rstrip
    request.slice!(0)

    params = CGI::parse(request) # get the requested URL parameter

    #uri = URI("http://fake-api.dev.predictiveedge.com/traf_series/gloogle/")

    if params['request'][0].nil? || params['callback'][0].nil?
      puts "nil params, not doing anything else"
    else
      decoded = URI.unescape(params['request'][0])
      uri = URI(decoded)
      begin
        result =  Net::HTTP.get_response(uri)
        callback = params['callback'][0]

        body = callback+'('+result.body+')'
        headers = ["http/1.1 200 ok",
                   "date: #{Time.new.getgm}",
                   "server: ruby",
                   "content-type: text/javascript; charset=iso-8859-1",
                   "content-length: #{body.length}\r\n\r\n"].join("\r\n")

        client.print headers
        client.print body

      rescue => e # there are a bajillion exceptios for net::http
        print e
      end

    end

  end

  client.close
end