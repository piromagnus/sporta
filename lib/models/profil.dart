



import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/services.dart';

import 'series.dart';
import 'seance.dart';
import 'history.dart';
import 'muscle.dart';


enum Objectif {
  habit("Habitude", 
    description: "Créer une habitude durable de musculation"), // Création d'habitude
  condition("Condition",
     description: "Améliorer ma condition physique générale pour être en meilleur santé"), // Condition physique
  //Premium
  force("Force"), // Force
  weight("Masse"), // Prise de Masse
  cut("Sèche"); // Perte de poids


  const  Objectif(this.strName, {this.description});
  final String strName;
  final String? description;

  static Objectif? fromString(String? str) {
    if (str == null) {
      return null;
    }
    else if (str == "Habitude") {
      return Objectif.habit;
    } else if (str == "Condition") {
      return Objectif.condition;
    } else if (str == "Force") {
      return Objectif.force;
    } else if (str == "Masse") {
      return Objectif.weight;
    } else if (str == "Sèche") {
      return Objectif.cut;
    } else {
      return null;
    }
  }
}




int levelToXp(int level) => 5*pow(level,2).toInt();
int xpToLevel(int xp) => sqrt(xp/5).toInt()+1;


const double defaultMaxEnergy = 3;

class Profil extends ChangeNotifier {

  String? _pseudo;
  bool male = true;

  int age =18;
  Mesurements mesurements = Mesurements(size: 175, weight: 75);
  
  double _energy = defaultMaxEnergy ;
  double energyMax = defaultMaxEnergy;

  int level = 1; //
  int _xp = 0 ; // linked

  Map<String,int>? xpMuscleMap;

  int attXp = 0; // Explosivité avec une icon d'épée
  int defXp = 0; // Endurance avec une icon de bouclier
  int powerXp =0; // Hypertrophie avec une icon de muscle
  int skillXp = 0; // Connaissance avec une icon de livre

  Objectif objectif = Objectif.habit;

  int coins = 0;
  int gems = 0;


  ExercicePersonalDataBase? exPersoDataBase;

 

  Profil();

  Profil.fromJson(dynamic jsonMap):
    //load the profil from the jsonMap
    _pseudo = jsonMap["pseudo"],
    _energy = jsonMap["energy"],
    energyMax = jsonMap["energyMax"],
    age = jsonMap["age"],
    male = jsonMap["male"],
    mesurements = Mesurements.fromJson(jsonMap["mesurements"]),
    level = jsonMap["level"],
    attXp = jsonMap["attXp"],
    defXp = jsonMap["defXp"],
    powerXp = jsonMap["powerXp"],
    skillXp = jsonMap["skillXp"],
    _xp = jsonMap["xp"];

    //history = HistoryModel.fromJson(jsonMap["history"]);

  Map<String,dynamic> toJson() => {
    "pseudo" : _pseudo,
    "energy" : _energy,
    "energyMax" : energyMax,
    "age" : age,
    "male" : male,
    "mesurements" : json.encode(mesurements),
    "level" : level,
    "xp" : xp,
    "attXp" : attXp,
    "defXp" : defXp,
    "powerXp" : powerXp,
    "skillXp" : skillXp,
    "xpMuscleMap" : xpMuscleMap,
    "objectif" : objectif.strName,
    "coins" : coins,
    "gems" : gems,
    //"history" : history.toJson(),
  };
   

    int get xp => _xp;
    String? get pseudo => _pseudo;
    double get weight => mesurements.weight;
    double get energy => _energy;
    double get size => mesurements.size;
    Map<String,int>? get musclesLevel => xpMuscleMap;

  set pseudo(String? value) {
    _pseudo = value;
    notifyListeners();
    setPreferences();
  }


  set xp(int? value) {
    if (value != null) {
      _xp = value;
      if (_xp >= levelToXp(level)) {
        level = level + 1;
        notifyListeners();
      }
      setPreferences();
    }
  }
  set energy(double value) {
    if (value <= energyMax) {
      _energy = value;
      notifyListeners();
      setPreferences();
    }
  }

  void resetLevel(){
    level = 1;
    _xp = 0;
    notifyListeners();
    setPreferences();
  }


  

  loadMusclesLevel() async {
    // load the shared preferences "musclesLevel"
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString("musclesLevel");
    if (jsonString != null) {
      xpMuscleMap = json.decode(jsonString);
    }
    else {
      xpMuscleMap = Map<String,int>.fromIterable(MuscleGroup.values, key: (e) => e.strName, value: (e) => 0);

    // String data = await rootBundle.loadString("assets/muscles.json");
    // List<dynamic> jsonList = json.decode(data);
    // //List<Map<String,dynamic>> jsonMap = jsonList.map((e) => Map<String,dynamic>.from(e)).toList();
    // //print(jsonMap.runtimeType);
    // List<Muscle> musclesList= jsonList.map((e) => Muscle.fromJson(e)).toList();
    
    // List simpleMusclesList = [];
    // for (var muscle in musclesList) {
    //   if (simpleMusclesList.contains(muscle.muscle) == false) { 
    //     simpleMusclesList.add(muscle.muscle);
    //   }
    // }
    // List groupMuscle =[];
    // for (var muscle in musclesList){
    //   if (groupMuscle.contains(muscle.group) == false) {
    //     groupMuscle.add(muscle.group);
    //   }
    // }
    // xpMuscleMap = Map<String,int>.fromIterable(groupMuscle, key: (e) => e, value: (e) => 0);
    // // xpMuscleMap = Map<String,int>.fromIterable(simpleMusclesList, key: (e) => e, value: (e) => 0);
    }
    // print(xpMuscleMap);
  }

  Future getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var profilJson = prefs.getString("profil");
    
    if (profilJson != null) {
      Map<String,dynamic> profilMap = json.decode(profilJson);
      _pseudo = profilMap["pseudo"];
      male = profilMap["male"];
      _energy = profilMap["energy"];
      energyMax = profilMap["energyMax"];
      age = profilMap["age"];
      mesurements = Mesurements.fromJson(json.decode(profilMap["mesurements"]));
      level = profilMap["level"];
      attXp = profilMap["attXp"];
      defXp = profilMap["defXp"];
      powerXp = profilMap["powerXp"];
      skillXp = profilMap["skillXp"];
      _xp = profilMap["xp"];
      coins = profilMap["coins"];
      gems = profilMap["gems"];
      objectif = Objectif.fromString(profilMap["objectif"]) ?? Objectif.habit;
        
    }
    else {
      _pseudo = "Id${Random().nextInt(1000000).toString()}";
    }
    loadMusclesLevel();
    notifyListeners();
  }

  setPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("profil", json.encode(this));
  }


}



class Mesurements {

//basic

  double size ; // cm
  double weight; // kg

// Advanced eventuellement à interpoler

  double? shoulders; //cm
  double? waist; //cm
  double? bust; //cm
  double? rightBiceps; //cm
  double? leftBiceps; //cm
  double? rightThigh; //cm
  double? leftThigh; //cm

// Expert / longueur des membres etc.



  Mesurements(
  {
    this.size = 175,
    this.weight = 70,
    this.waist,
    this.bust,
    this.shoulders,
    this.rightBiceps,
    this.leftBiceps,
    this.rightThigh,
    this.leftThigh
  }
  );




  Mesurements.fromJson(Map<String,dynamic> jsonMap)
  : size = jsonMap["size"],
    weight = jsonMap["weight"],
    waist = jsonMap["waist"],
    bust = jsonMap["bust"],
    shoulders = jsonMap["shoulders"],
    rightBiceps = jsonMap["rightBiceps"],
    leftBiceps = jsonMap["leftBiceps"],
    rightThigh = jsonMap["rightThigh"],
    leftThigh = jsonMap["leftThigh"];

  Map<String,dynamic> toJson() => {
    "size" : size,
    "weight" : weight,
    "waist" : waist,
    "bust" : bust,
    "shoulders" : shoulders,
    "rightBiceps" : rightBiceps,
    "leftBiceps" : leftBiceps,
    "rightThigh" : rightThigh,
    "leftThigh" : leftThigh,
  };
}



class ExercicePersonalDataBase extends ChangeNotifier {

  

}


class ExercicePersonalData {
  
  ExercicePersonalData(
    {
      required this.id,
      required this.predictions,
      required this.maxReps,
    }
  );


  int id;
  List<int>? seancesDates; //List of Seance that contains this exercice
  

      
  List<Serie>? predictions; // List of predicted series for the next session .
   //                       Each serie contains the number of reps and the weight(or null if body weight)
  List<Serie>? maxReps; // List of maxReps series. Each Serie must contains a different number of reps.
                         // The weight is null if body weight
}