var http = require("http"),
    url = require("url"),
    path = require("path"),
    fs = require("fs"),
    querystring = require("querystring"),
    port = process.argv[2] || 3030;

function processPost(request, response, callback) {
    var queryData = "";
    if(typeof callback !== 'function') return null;

    if(request.method == 'POST') {
        request.on('data', function(data) {
            queryData += data;
            if(queryData.length > 1e6) {
                queryData = "";
                response.writeHead(413, {'Content-Type': 'text/plain'}).end();
                request.connection.destroy();
            }
        });

        request.on('end', function() {
            response.post = queryData; //querystring.parse(queryData);
            callback();
        });

    } else {
        response.writeHead(405, {'Content-Type': 'text/plain'});
        response.end();
    }
}

function writeReport(json) {
  var fs = require('fs');
  var istanbul = require('istanbul');
  var cov = JSON.parse(json);
  var keys = Object.keys(cov);
  var store = {
    files: function() { return keys; },
    keys: function() { return keys; },
    hasKey: function() { return true; },
    getObject: function(key) { return cov[key]; }
  };
  var collector = new istanbul.Collector({ store: store });
  var report = istanbul.Report.create('lcov');
  report.writeReport(collector, true);
}

http.createServer(function(request, response) {
  processPost(request, response, function() {
    writeReport(response.post);
    fs.unlinkSync('lcov.info');

    response.writeHead(200, { 'Access-Control-Allow-Origin': "*"});
    response.write("hello\n");
    response.end();
  });
}).listen(parseInt(port, 10));

console.log("Web server running at\n  => http://localhost:" + port + "/\nCTRL + C to shutdown");
