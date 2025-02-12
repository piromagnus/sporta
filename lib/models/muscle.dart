
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';


enum MuscleGroup {
  Shoulders("Epaules"),
  Chest("Torse"),
  Arm("Bras"),
  Back("Dos"),
  Abs("Abdominaux"),
  Hip("Hanche"),
  Legs("Jambes");
  // Cardio,
  // Stretching,
  final String strName;
  final String? path;
  const MuscleGroup(this.strName, {this.path});


  static MuscleGroup fromString(String str) {
    if (str == "Epaules") {
      return MuscleGroup.Shoulders;
    } else if (str == "Torse") {
      return MuscleGroup.Chest;
    } else if (str == "Dos") {
      return MuscleGroup.Back;
    } else if (str == "Bras") {
      return MuscleGroup.Arm;
    } else if (str == "Jambes") {
      return MuscleGroup.Legs;
    } else if (str == "Abdominaux") {
      return MuscleGroup.Abs;
    } else if (str == "Hanche"){
      return MuscleGroup.Hip;
    }
    else{
      throw Exception("Unknown muscle group : $str");
    }
  }
}




class Muscle {

    final String name;
    final String desc;
    final String? path;
    final List<String> antagonistId;
    final MuscleGroup group;
    final String id;
    final String muscle;
    // each muscle class will inherit from this
  Muscle({
    required this.name,
    required this.desc,
    this.path,
    required this.id,
    this.antagonistId = const [],
    required this.group ,
    required this.muscle,
    });

  Muscle.fromJson(Map<String,dynamic> jsonMap):
    name = jsonMap["name"],
    desc = jsonMap["desc"],
    path = jsonMap["path"],
    id = jsonMap["id"],
    muscle = jsonMap["muscle"] ?? "Autre",
    antagonistId = List<String>.from(jsonMap["antagonistId"] ?? []),
    group = MuscleGroup.fromString(jsonMap["group"] as String);
    //this(name: jsonMap["name"], desc: jsonMap["desc"], id: jsonMap["id"]); 
    // a priori pas de problème d'inférence ici.

  Map<String,dynamic> toJson()=> {
    "name" : name,
    "desc" : desc,
    "id" : id,
    "antagonistId" : antagonistId,
    "group" : group,
    "path" : path,
    "muscle" : muscle,
  };
  @override
  String toString(){
    return "group : $group, name : $name, id : $id";
  }

  Future<File> writetoFile({String path = "muscles.json"}) async {
    // write the muscles to the assets
    // TODO : check if it's the best way to do it
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$path');
    final initialdata = await file.readAsString();
    List<dynamic> jsonList = json.decode(initialdata) ?? [];
    print(jsonList);
    print(toJson());
    jsonList.add(toJson());
    return file.writeAsString(json.encode(jsonList), mode: FileMode.write);
  }

}


class BodyModel extends ChangeNotifier {

  Map<String,Muscle> muscles = {}; // id: muscle
  Map<MuscleGroup,List<Muscle>> musclesByGroup = {}; // group : [muscle]
  BodyModel() {
    // loadMuscles();
  }

  List<Muscle> get musclesList => muscles.values.toList();

  Future<void> loadMuscles() async {
    // load the muscles from the assets
    // TODO : check if it's the best way to do it
    String data = await rootBundle.loadString("assets/muscles.json");
    List<dynamic> jsonList = json.decode(data);
    //List<Map<String,dynamic>> jsonMap = jsonList.map((e) => Map<String,dynamic>.from(e)).toList();
    //print(jsonMap.runtimeType);
    List<Muscle> musclesList= jsonList.map((e) => Muscle.fromJson(e)).toList();
    // for ( var e in musclesList)
    // { print(e.antagonistId);}

    muscles = Map<String,Muscle>.fromIterables(musclesList.map((e) => e.id),
      musclesList.map((e) => e));
   for (var muscle in muscles.values){
      if (musclesByGroup.containsKey(muscle.group)){
        musclesByGroup[muscle.group]!.add(muscle);
      }
      else {
        musclesByGroup[muscle.group] = [muscle];
      }
    }
      //jsonMap.map((e) => {e["id"] as int :Muscle.fromJson(e)}));
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/muscles.json');
    try { final customData = await file.readAsString();
    List<dynamic> customList = json.decode(customData) ?? [];
    muscles.addAll(Map.fromIterable(customList.map((e) => {e["id"]:Muscle.fromJson(e)})));
    }
    catch (e) {
      print("No custom file found");
    }
    notifyListeners();

  }

  Future<void> addMuscle(Muscle muscle) async {
    // addition of a muscle to a custom file
    muscles[muscle.id] =muscle;
    await muscle.writetoFile();
    notifyListeners();
  }
}

