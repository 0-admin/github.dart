import "dart:html";

void init(String script) {

  document.querySelector("#view-source").onClick.listen((_) {
    var popup = window.open("view_source.html", "View Source");
    
    HttpRequest.getString(script).then((code) {
      popup.postMessage({
        "command": "code",
        "code": code
      }, window.location.href);
    });
  });
}
