http = require 'http'
url = require 'url'
querystring = require 'querystring'
mongoClient = require('mongodb').MongoClient

port = process.env.PORT or 8080
process.env.MAIN_DB ?= 'mongodb://where:BjCJPkHpx8yp3nanzjNmot@dharma.mongohq.com:10012/where'

headers =
	'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:24.0) Gecko/20100101 Firefox/24.0'
	'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
	'Accept-Language': 'ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4'
	'Connection': 'keep-alive'

options =
	strictSSL: true
	uri: url
	headers: headers
	method: 'GET'
	encoding: 'utf-8'
	followAllRedirects: true
	timeout: 15000

getURL = (url, proxyResponse) ->
	request = require('request')
	options.uri = url
	
	request options, (err, res, body) ->
		if !err
			proxyResponse.writeHead 200, 'Content-Type': 'text/plain'
			proxyResponse.end body, 'utf8'
		else
			console.log "ERROR", err
			proxyResponse.writeHead 200, 'Content-Type': 'text/plain'
			proxyResponse.end "ERROR", 'utf8'
		

server = http.createServer (req, res) ->
	console.log "Request URL #{req.url}"
	if req.method is 'GET'
		URL = url.parse req.url, true
	
		if URL.query.url
			console.log URL.query.url
			getURL URL.query.url, res
		else
			res.writeHead 404, 'Content-Type': 'text/plain'
			res.end "", 'utf8'
	else if req.method is 'POST'
		postData = null
		req.addListener "data", (postDataChunk) ->
			postData += postDataChunk
			console.log("POST Chunk")
		req.addListener "end", () ->
			query = querystring.parse(postData)
			console.log query
			if query.url
				console.log query.url
				getURL query.url, res
			else
				res.writeHead 404, 'Content-Type': 'text/plain'
				res.end "", 'utf8'
	else
		console.log "Error method", req.method

server.listen(port, process.env.IP)
console.log port
