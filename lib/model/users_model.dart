class User {
  String id;
  String displayName;
  String role;
  Map<dynamic, dynamic> nodesOwned;

  User({
    required this.id,
    required this.displayName,
    required this.role,
    required this.nodesOwned
  });

  factory User.fromEntry(String key, Map<dynamic, dynamic> value) {
    Map<dynamic, dynamic> nodesOwned = {};
    if (value['nodes_owned'] != null) {
      nodesOwned = value['nodes_owned'] as Map;
    }
    return User(
      id: key,
      displayName: value['display_name'],
      nodesOwned: nodesOwned,
      role: value['role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "display_name": displayName,
      "nodes_owned": nodesOwned,
      "role": role
    };
  }
}
