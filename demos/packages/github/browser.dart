library github.browser;

import 'dart:async';
import 'dart:html';

import 'common.dart';
import 'http.dart' as http;
export 'common.dart';

class _BrowserHttpClient extends http.Client {
  
  @override
  Future<http.Response> request(http.Request request) {
    var req = new HttpRequest();
    var completer = new Completer<http.Response>();
    
    req.open(request.method, request.url);
    
    if (request.headers != null) {
      for (var header in request.headers.keys) {
        req.setRequestHeader(header, request.headers[header]);
      }
    }
    
    req.onReadyStateChange.listen((event) {
      if (req.readyState == HttpRequest.DONE) {
        completer.complete(new http.Response(req.responseText, req.responseHeaders, req.status));
      }
    });
    
    req.send(request.body);
    
    return completer.future;
  }
}

void initGitHub() {
  GitHub.defaultClient = () => new _BrowserHttpClient();
}