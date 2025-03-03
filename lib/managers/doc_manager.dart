import 'dart:convert';
import 'dart:io';
import 'package:sourcemanv1/datatype.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sourcemanv1/managers/env_var_manager.dart';
import 'package:sourcemanv1/managers/profile_manager.dart';


class DocManager {
  Future<Doc> loadDocFromPath (String folder, String key, ProfileManager profileManager, EnvVarManager envVarManager) async {
    // load meta info
    String content = """
{
  "name": "test doc name",
  "description": "some words xxxxx",
  "createdTime": 1705897543000.0,
  "profiles": [
    {
      "key": "default",
      "name": "default",
      "description": "",
      "createdTime": 1711463444625.0,
      "envs": [
        {
          "key": "test101010",
          "value": "default_env_variable"
        }
      ]
    },
    {
      "key": "p1",
      "name": "profile1",
      "description": "profile 1",
      "createdTime": 1711463555625.0,
      "envs": [
        {
          "key": "test101010",
          "value": "profile_1_env_variable"
        }
      ]
    }
  ]
}
""";
    try {
      final directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/$folder/$key.meta.json';
      filePath = '../../test_data/$key.meta.json'; //dev
      File metafile = File(filePath);
      content = await metafile.readAsString();
    } catch (e) {
      print(e);
    }
    final data = json.decode(content);
    profileManager.parseJsonProfiles(data["profiles"], key, envVarManager);
    String name = data["name"];
    String description = data["description"];
    double createdTime = data["createdTime"];
  
    // load file
    content = """template:
  meta:
    alpha: aaaaa
    beta: bbbbb
  data:
    something \$test101010\$ something else.
""";
    List<String> lines = content.split("\n");
    try {
      final directory = await getApplicationDocumentsDirectory();
      var filePath = '${directory.path}/$folder/$key';
      filePath = '../../test_data/$key'; // dev
      File file = File(filePath);
      List<String> lines = await file.readAsLines();
    } catch (e) {
      print(e);
    }
    var doc = Doc(
      key: key,
      name: name,
      lines: lines,
      description: description,
      createdTime: createdTime,
    );
    return doc;
  }
}