class Rune {
  bool isVar;
  String? ch;
  String? varKey;

  Rune({required this.isVar, this.ch, this.varKey});
}

class EnvVar {
  String key;
  String value;
  String documentKey;
  String profileKey;

  EnvVar({required this.key, required this.value, required this.documentKey, required this.profileKey});
}

class Profile {
  String key;
  String name;
  String description;
  double createdTime;
  Profile({required this.key, required this.name, this.description="", required this.createdTime});
}

class Doc {
  String key;
  String name;
  List<String> lines;
  String description;
  double createdTime;
  Doc({required this.key, required this.name, required this.lines, this.description="", this.createdTime=0});
}