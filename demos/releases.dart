import "dart:html";

import "package:github/browser.dart";

import "common.dart";

GitHub github;
DivElement $releases;

void main() {
  initGitHub();
  init("releases.dart", onReady: () {
    github = new GitHub();
    $releases = querySelector("#releases");
    loadReleases();
  });
}

void loadReleases() {
  github.releases(new RepositorySlug("twbs", "bootstrap")).then((releases) {
    for (var release in releases) {
      $releases.appendHtml("""
      <div class="repo box" id="release-${release.id}">
        <h1>${release.name}</h1>
      </div>
      """);
      var rel = $releases.querySelector("#release-${release.id}");
      void append(String key, value) {
        rel.appendHtml("<br/><b>${key}</b>: ${value.toString()}");
      }
      append("Tag Name", release.tagName);
      append("Tarball", '<a href="${release.tarballUrl}">Download</a>');
    }
  });
}