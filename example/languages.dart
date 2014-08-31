import "dart:html";

import "package:github/browser.dart";
import "common.dart";

GitHub github;
DivElement $table;

LanguageBreakdown breakdown;

void main() {
  initGitHub();
  init("languages.dart", onReady: () {
    $table = querySelector("#table");
    loadRepository();
  });
}

void loadRepository() {
  var user = "dart-lang";
  var reponame = "bleeding_edge";
  var token = "5fdec2b77527eae85f188b7b2bfeeda170f26883";
  var url = window.location.href;

  if (url.contains("?")) {
    var params = Uri.splitQueryString(url.substring(url.indexOf('?') + 1));
    if (params.containsKey("user")) {
      user = params["user"];
    }

    if (params.containsKey("token")) {
      token = params["token"];
    }

    if (params.containsKey("repo")) {
      reponame = params["repo"];
    }
  }
  
  document.getElementById("name").setInnerHtml("${user}/${reponame}");

  github = new GitHub(auth: new Authentication.withToken(token));

  github.languages(new RepositorySlug(user, reponame)).then((b) {
    breakdown = b;
    reloadTable();
  });
}

bool isReloadingTable = false;

void reloadTable({int accuracy: 4}) {
  
  if (isReloadingTable) {
    return;
  }
  
  isReloadingTable = true;
  
  github.renderMarkdown(generateMarkdown(accuracy)).then((html) {
    $table.innerHtml = html;
    isReloadingTable = false;
  });
}

int totalBytes(LanguageBreakdown breakdown) {
  return breakdown.info.values.reduce((a, b) => a + b);
}

String generateMarkdown(int accuracy) {
  int total = totalBytes(breakdown);
  var buff = new StringBuffer();
  
  buff.writeln("| Language | Bytes | Percentage |");
  buff.writeln("|----------|-------|------------|");
  
  var data = breakdown.toList();
  
  data.sort((a, b) => b[1].compareTo(a[1]));
  
  data.forEach((info) {
    var name = info[0];
    var bytes = info[1];
    var percentage = ((bytes / total) * 100);
    buff.writeln("| ${name} | ${bytes} | ${percentage.toStringAsFixed(accuracy)}%");
  });
  print(buff);
  return buff.toString();
}
