JSONProxy
=========

Simple proxy for JSONP requets. Originally, I wrote this in Ruby but then decided I wanted to try it in Node. 
I figured Node's architecture would be pretty fast for this. At least, much faster than my single-threaded Ruby implementation.

Usage
--------
The Ruby and Node versions are pretty similar. Both accept -p or --port to specify the port number.

$ node proxy.js
$ node proxy.js --port 1400

or

$ ruby proxy.rb
$ ruby proxy.rb -p 3000
