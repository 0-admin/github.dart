import "../helper.dart";

main() async {
  var org = "DirectMyFile";
  
  var hooks = await github.organizations.listHooks(org).toList();
  
  for (var hook in hooks) {
    print(hook.config);
  }
  
  github.dispose();
}