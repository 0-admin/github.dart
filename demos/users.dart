import "dart:html";

import "package:github/browser.dart";
import "common.dart";

GitHub github;
DivElement $users;

void main() {
  init("users.dart", onReady: () {
    github = new GitHub(new BrowserFetcher());
    $users = querySelector("#users");
    loadUsers();
  });
}

void loadUsers() {
  github.users(["kaendfinger", "samrg472", "TrainerGuy22", "logangorence"]).then((List<User> users) {
    users.forEach((User user) {
      var element = new DivElement();
      var out = """
        <img width="64" height="64" src="${user.avatar_url}">&nbsp;&nbsp;<b>${user.login}</b>
      """;
      element.append(new ParagraphElement()..appendHtml(out));
      $users.append(element);
    });
  });
}