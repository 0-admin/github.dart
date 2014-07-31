import "dart:html";

import "package:github/browser.dart";
import "common.dart";

GitHub github;
DivElement $org;

void main() {  
  init("organization.dart", onReady: () {
    github = new GitHub(new BrowserFetcher(), auth: new Authentication.withToken("5fdec2b77527eae85f188b7b2bfeeda170f26883"));
    $org = querySelector("#org");
    loadOrganization();
  });
}

void loadOrganization() {
  github.organization("DirectMyFile").then((Organization org) {
    return org.teams;
  }).then((List<Team> teams) {
    for (var team in teams) {
      var e = new DivElement()..id = "team-${team.name}";
      e.classes.add("team");
      $org.append(e);
      e.append(new HeadingElement.h3()..text = team.name);
      team.members.then((List<TeamMember> members) {
        var divs = members.map((member) {
          var h = new DivElement();
          h.classes.add("box");
          h.classes.add("user");
          h.style.textAlign = "center";
          h.append(new ImageElement(src: member.avatarUrl, width: 64, height: 64)..classes.add("avatar"));
          h.append(new AnchorElement(href: member.url)..append(new ParagraphElement()..text = "${member.login}"));
          return h;
        });
        divs.forEach(e.append);
      });
    }
  });
}