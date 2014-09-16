part of github.server;

class HookMiddleware {
  final StreamController<HookEvent> _eventController = new StreamController<HookEvent>();
  Stream<HookEvent> get onEvent => _eventController.stream;
  
  void handleHookRequest(HttpRequest request) {
    
    if (request.method != "POST") {
      request.response
          ..write("Only POST is Supported")
          ..close();
      return;
    }
    
    if (request.headers['x-github-event'] == null) {
      request.response
          ..write("X-GitHub-Event must be specified.")
          ..close();
      return;
    }
    
    request.transform(UTF8.decoder).join().then((content) {
      _eventController.add(new HookEvent(request.headers['x-github-event'].first, JSON.decode(content)));
      request.response
          ..write(JSON.encode({
            "handled": _eventController.hasListener
          }))
          ..close();
    });
  }
}

class HookServer extends HookMiddleware {
  final String host;
  final int port;
  
  HttpServer _server;
  
  HookServer(this.port, [this.host = "0.0.0.0"]);
  
  void start() {
    HttpServer.bind(host, port).then((HttpServer server) {
      _server = server;
      server.listen((request) {
        if (request.uri.path == "/hook") {
          handleHookRequest(request);
        } else {
          request.response
              ..statusCode = 404
              ..write("404 - Not Found")
              ..close();
        }
      });
    });
  }
  
  Future stop() => _server.close();
}

class HookEvent {
  final String event;
  final Map<String, Object> data;
  
  HookEvent(this.event, this.data);
}