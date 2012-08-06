/*
JSONProxy
Accepts a the requested URL as a parameter
	EG: http://localhost:3000/?request=http://fake-api.dev.predictiveedge.com/traf_series/gloogle/
	Note that the request param is URI encoded

Requires the Optimist module for parsing command line options.
 */

var http = require('http');
var url = require('url');
var querystring = require('querystring');

// Parse Options
var argv = require('optimist').argv;
var port = argv.port || 4000;

function make_request(raw_url, complete){
	var parsed_url = url.parse(raw_url);
	var chunks = '';

	// aggregate all the chunks for the 'complete' callback
	http.get(parsed_url, function(resp){
		resp.on('data', function(chunk){
			chunks += chunk;
		});
		resp.on('end', function(){
			complete(chunks);
		});
	}).on("error", function(e){
		console.log("Got error: " + e.message);
	});
}

function make_body(js_str, callback){
	return callback+'('+js_str+')';
}

var server = http.createServer(function (req, res) {
	var req_url = url.parse(req.url);
	var query = querystring.parse(req_url.query); // get query parameters from request

	if(typeof query.request !== 'undefined' && typeof query.callback !== 'undefined'){
		make_request(query.request, function(data){
			var body = make_body(data, query.callback);
			res.writeHead(200, {
				'Content-Type': 'text/javascript',
				'Content-Length': Buffer.byteLength(body, 'utf8')
			});
			res.end(body);
		});
	} else {
		res.end();
	}
}).listen(port, '127.0.0.1');