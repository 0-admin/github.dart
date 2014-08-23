part of github.client;

/**
 * GitHub Pages Information
 */
class RepositoryPages {
  final GitHub github;
  
  /**
   * Pages CNAME
   */
  String cname;
  
  /**
   * Pages Status
   */
  String status;
  
  /**
   * If the repo has a custom 404
   */
  @ApiName("custom_404")
  bool custom404;
  
  RepositoryPages(this.github);
  
  static RepositoryPages fromJSON(GitHub github, input) {
    var pages = new RepositoryPages(github);
    pages.cname = input['cname'];
    pages.status = input['status'];
    pages.custom404 = input['custom_404'];
    return pages;
  }
}