import "package:github/server.dart";

void main() {
  initGitHub();
  
  new GitHub()
    .trendingRepositories(language: "Dart", since: "month")
    .listen((repo) => print("${repo.title}: ${repo.description}"));
}