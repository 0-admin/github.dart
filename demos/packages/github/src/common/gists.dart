part of github.common;

class Gist {
  final GitHub github;

  String description;
  bool public;
  User owner;
  User user;
  List<GistFile> files;

  @ApiName("html_url")
  String url;

  @ApiName("comments")
  int commentsCount;

  @ApiName("git_pull_url")
  String gitPullUrl;

  @ApiName("git_push_url")
  String gitPushUrl;

  @ApiName("created_at")
  DateTime createdAt;

  @ApiName("updated_at")
  DateTime updatedAt;

  Map<String, dynamic> json;

  Gist(this.github);

  static Gist fromJSON(GitHub github, input) {
    if (input == null) return null;

    var gist = new Gist(github)
        ..json = input
        ..description = input['description']
        ..public = input['public']
        ..owner = User.fromJSON(github, input['owner'])
        ..user = User.fromJSON(github, input['user']);

    if (input['files'] != null) {
      gist.files = [];

      for (var key in input['files'].keys) {
        var map = copyOf(input['files'][key]);
        map['name'] = key;
        gist.files.add(GistFile.fromJSON(github, map));
      }
    }

    gist
        ..url = input['html_url']
        ..commentsCount = input['comments']
        ..gitPullUrl = input['git_pull_url']
        ..gitPushUrl = input['git_push_url']
        ..createdAt = parseDateTime(input['created_at'])
        ..updatedAt = parseDateTime(input['updated_at']);

    return gist;
  }
  
  Stream<GistComment> comments() => github.gistComments(json['id']);
  
  Future<GistComment> comment(CreateGistComment request) {
    return github.postJSON("/gists/${json['id']}/comments", body: request.toJSON(), convert: GistComment.fromJSON);
  }
}

class GistFile {
  final GitHub github;

  GistFile(this.github);

  String name;
  int size;
  String url;
  String type;
  String language;
  bool truncated;
  String content;

  static GistFile fromJSON(GitHub github, input) {
    if (input == null) return null;
    return new GistFile(github)
        ..name = input['name']
        ..size = input['size']
        ..url = input['raw_url']
        ..type = input['type']
        ..language = input['language']
        ..truncated = input['truncated']
        ..content = input['content'];
  }
}

class GistFork {
  final GitHub github;

  User user;
  int id;

  @ApiName("created_at")
  DateTime createdAt;

  @ApiName("updated_at")
  DateTime updatedAt;

  GistFork(this.github);

  static GistFork fromJSON(GitHub github, input) {
    if (input == null) return null;

    return new GistFork(github)
        ..user = User.fromJSON(github, input['user'])
        ..id = input['id']
        ..createdAt = parseDateTime(input['created_at'])
        ..updatedAt = parseDateTime(input['updated_at']);
  }
}

class GistComment {
  final GitHub github;

  int id;
  User user;

  @ApiName("created_at")
  DateTime createdAt;

  @ApiName("updated_at")
  DateTime updatedAt;

  String body;

  GistComment(this.github);

  static GistComment fromJSON(GitHub github, input) {
    if (input == null) return null;

    return new GistComment(github)
        ..id = input['id']
        ..user = User.fromJSON(github, input['user'])
        ..createdAt = parseDateTime(input['created_at'])
        ..updatedAt = parseDateTime(input['updated_at'])
        ..body = input['body'];
  }
}

class CreateGistComment {
  final String body;
  
  CreateGistComment(this.body);
  
  String toJSON() {
    var map = {};
    map['body'] = body;
    return JSON.encode(map);
  }
}

class GistHistoryEntry {
  final GitHub github;

  String version;

  User user;

  @ApiName("change_status/deletions")
  int deletions;

  @ApiName("change_status/additions")
  int additions;

  @ApiName("change_status/total")
  int totalChanges;

  @ApiName("committed_at")
  DateTime committedAt;

  GistHistoryEntry(this.github);

  static GistHistoryEntry fromJSON(GitHub github, input) {
    if (input == null) return null;
    return new GistHistoryEntry(github)
        ..version = input['version']
        ..user = User.fromJSON(github, input['user'])
        ..deletions = input['change_status']['deletions']
        ..additions = input['change_status']['additions']
        ..totalChanges = input['change_status']['total']
        ..committedAt = parseDateTime(input['committed_at']);
  }
}
