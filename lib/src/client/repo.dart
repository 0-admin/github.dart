part of github.client;

/**
 * The Repository Model
 */
class Repository {
  final GitHub github;
  
  String name;
  int id;
  
  @ApiName("full_name")
  String fullName;
  RepositoryOwner owner;
  bool private;
  bool fork;
  String url;
  String description;
  CloneUrls cloneUrls;
  String homepage;
  int size;
  
  @ApiName("stargazers_count")
  int stargazersCount;
  
  @ApiName("watchers_count")
  int watchersCount;
  
  String language;
  
  @ApiName("has_issues")
  bool hasIssues;
  
  @ApiName("has_wiki")
  bool hasWiki;
  
  @ApiName("has_downloads")
  bool hasDownloads;
  
  @ApiName("forks_count")
  int forksCount;
  
  @ApiName("open_issues_count")
  int openIssuesCount;
  
  String defaultBranch;
  
  @ApiName("subscribers_count")
  int subscribersCount;
  
  @ApiName("network_count")
  int networkCount;
  
  @ApiName("created_at")
  DateTime createdAt;
  
  @ApiName("pushed_at")
  DateTime pushedAt;
  
  Map<String, dynamic> json;
  
  Repository(this.github);
  
  static Repository fromJSON(GitHub github, input) {
    var repo = new Repository(github);
    repo.name = input['name'];
    repo.id = input['id'];
    repo.fullName = input['full_name'];
    repo.fork = input['fork'];
    repo.url = input['html_url'];
    repo.description = input['description'];
    repo.cloneUrls = new CloneUrls();
    repo.cloneUrls.git = input['git_url'];
    repo.cloneUrls.ssh = input['ssh_url'];
    repo.cloneUrls.https = input['clone_url'];
    repo.cloneUrls.svn = input['svn_url'];
    repo.homepage = input['homepage'];
    repo.size = input['size'];
    repo.stargazersCount = input['stargazers_count'];
    repo.watchersCount = input['watchers_count'];
    repo.language = input['language'];
    repo.hasIssues = input['has_issues'];
    repo.hasDownloads = input['has_downloads'];
    repo.hasWiki = input['has_wiki'];
    repo.defaultBranch = input['default_branch'];
    repo.openIssuesCount = input['open_issues_count'];
    repo.networkCount = input['network_count'];
    repo.subscribersCount = input['subscribers_count'];
    repo.forksCount = input['forks_count'];
    repo.createdAt = parse_date(input['created_at']);
    repo.pushedAt = parse_date(input['pushed_at']);
    repo.private = input['private'];
    repo.json = input;
    repo.owner = RepositoryOwner.fromJSON(input['owner']);
    return repo;
  }
  
  Future<List<Issue>> get issues => github.getJSON("/repos/${fullName}/issues").then((json) {
    return json.map((it) => Issue.fromJSON(github, it));
  });
  
  Future<List<Commit>> get commits => github.getJSON("/repos/${fullName}/commits", convert: (github, it) => it.map((i) => Commit.fromJSON(github, i)));
  
  Future<List<ContributorStatistics>> get contributorStatistics {
    var completer = new Completer<List<ContributorStatistics>>();
    var path = "/repos/${fullName}/stats/contributors";
    var handle;
    handle = (GitHub gh, json) {
      if (json is Map) {
        new Future.delayed(new Duration(milliseconds: 200), () {
          github.getJSON(path, convert: handle);
        });
        return null;
      } else {
        completer.complete(json.map((it) => ContributorStatistics.fromJSON(github, it)));
      }
    };
    github.getJSON(path, convert: handle);
    return completer.future;
  }
  
  Future<List<Repository>> get forks {
    return github.getJSON("/repos/${fullName}/forks").then((forks) {
      return forks.map((it) => Repository.fromJSON(github, it));
    });
  }
  
  Future<RepositoryPages> get pages {
    return github.getJSON("/repos/${fullName}/pages", convert: RepositoryPages.fromJSON);
  }
}

class CloneUrls {
  String git;
  String ssh;
  String https;
  String svn;
}

class RepositoryOwner {
  String login;
  int id;
  
  @ApiName("avatar_url")
  String avatarUrl;
  
  @ApiName("html_url")
  String url;

  static RepositoryOwner fromJSON(input) {
    var owner = new RepositoryOwner();
    owner
        ..login = input['login']
        ..id = input['id']
        ..avatarUrl = input['avatar_url']
        ..url = input['html_url'];
    return owner;
  }
}

class RepositorySlug {
  final String owner;
  final String name;
  
  RepositorySlug(this.owner, this.name);
}

class CreateRepositoryRequest {
  final String name;
  String description;
  String homepage;
  bool private = false;
  
  @ApiName("has_issues")
  bool hasIssues = true;
  
  @ApiName("has_wiki")
  bool hasWiki = true;
  
  @ApiName("has_downloads")
  bool hasDownloads = true;

  @OnlyWhen("Creating a repository for an organization")
  @ApiName("team_id")
  int teamID;
  
  @ApiName("auto_init")
  bool autoInit = false;
  
  @OnlyWhen("autoInit is true")
  String gitignoreTemplate;
  
  @OnlyWhen("autoInit is true")
  String licenseTemplate;
  
  CreateRepositoryRequest(this.name);
  
  String toJSON() {
    return JSON.encode({
      "name": name,
      "description": description,
      "homepage": homepage,
      "private": private,
      "has_issues": hasIssues,
      "has_wiki": hasWiki,
      "has_downloads": hasDownloads,
      "team_id": teamID,
      "auto_init": autoInit,
      "gitignore_template": gitignoreTemplate,
      "license_template": licenseTemplate
    });
  }
}
