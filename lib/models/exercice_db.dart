import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';


import 'requirement.dart';

import 'package:flutter/services.dart' show rootBundle;

import 'muscle.dart';



// L'idée est de stocker une partie des exercices en Asset avec un json. Ceux-ci seront assez clean associé à des quêtes, 
//avec des variantes, avec des coefs par muscles pour de la data analyse etc.
// Une autre partie sera stocker soit avec shared_preferences soit avec AppData en fichier explicit (à voir en fonction) 
//et ça sera les exerices crée par les utilisateurs qui ne seront pas dans l'histoire / le lore.

// Process de Loading : 
//    Tout avec des ids et on fait les liens après 
//    ou alors on sauvegarde les listes d'objects entièrement ?

//TODO créer la classe associé à une exécution d'un exercice
//TODO définir la proportion des muscules primaire et secondaire
 //TODO Maxreps :  List pour RM1, RM3, RM5, RM10 ou dict {nb reps : charge}
 //TODO Link Exercice variantes with the name saved

enum ExerciceType{
  body("Corps"),
  barbell("Barre"),
  dumbbell("Haltères"),
  kettlebell("Kettlebell"),
  machine("Machine"),
  cable("Cable"),
  band("Elastique"),
  ball("Ballon"),
  other("Autre");

  const ExerciceType(this.strName);
  final String strName;
}

Map<ExerciceType,String> exerciceTypeToStringFr ={
  ExerciceType.body : "Corps",
  ExerciceType.barbell : "Barre",
  ExerciceType.dumbbell : "Haltères",
  ExerciceType.kettlebell : "Kettlebell",
  ExerciceType.machine : "Machine",
  ExerciceType.cable : "Cable",
  ExerciceType.band : "Elastique",
  ExerciceType.ball : "Ballon",
  ExerciceType.other : "Autre",
};

Map<String,ExerciceType> stringFrToExerciceType ={
  "Corps" : ExerciceType.body,
  "Barre" : ExerciceType.barbell,
  "Haltères" : ExerciceType.dumbbell,
  "Kettlebell" : ExerciceType.kettlebell,
  "Machine" : ExerciceType.machine,
  "Cable" : ExerciceType.cable,
  "Elastique" : ExerciceType.band,
  "Ballon" : ExerciceType.ball,
  "Autre" : ExerciceType.other,
};




class ExerciceDB extends ChangeNotifier {

  ExerciceDB(){
    loadExs();
  }
  
  Map<int,Exercice> bodyExs={};
  Map<int,Exercice> weightExs={};
  Map<String,List<Exercice>> allExsByGroup ={};
  Map<int,Exercice> allExsById ={};

  Map<MuscleGroup,Exercice> allExsByMucleGroup = {};

  List<Exercice> get allExs => allExsById.values.toList();

  operator [](int? id) => getExById(id);


  Exercice? getExById(int? id){
    if (id == null) return null;
    return allExsById[id];
  }

  Future<void> loadExs() async {
    //load function from the assets file bodyEx.json
    var jsonBodyString= await rootBundle.loadString("assets/bodyEx.json");
    List<dynamic> jsonBodyList =json.decode(jsonBodyString) as List;

    jsonBodyList = jsonBodyList.map((e) => 
      Exercice.fromJson(e)).toList();
    bodyExs = Map<int,Exercice>.fromIterables(jsonBodyList.map((e) => e.id),
      jsonBodyList as List<Exercice>); 
    
    //TODO : add a try catch
    var jsonWeightString= await rootBundle.loadString("assets/weightEx.json");
    List<dynamic> jsonWeightList =json.decode(jsonWeightString) as List;
    jsonWeightList = jsonWeightList.map((e) => 
      Exercice.fromJson(e)).toList();
    for (Exercice i in jsonWeightList){
      i.id = i.id + bodyExs.length;
    }
    weightExs = Map<int,Exercice>.fromIterables(jsonWeightList.map(
      (e) => e.id),
      jsonWeightList as List<Exercice>);

    // group all exercices by group
    for (var ex in [...bodyExs.values,...weightExs.values]){
      if (allExsByGroup.containsKey(ex.group)){
        allExsByGroup[ex.group]!.add(ex);
      } else {
        allExsByGroup[ex.group] = [ex];
      }
    }
    for (var key in allExsByGroup.keys){
      allExsByGroup[key]!.sort((a,b) => a.difficulty.compareTo(b.difficulty));
    }
    //  = <int,Exercice>{}..addAll(bodyExs)..addAll(weightExs);
    
   allExsById =  Map<int,Exercice>.fromIterables(
      [...bodyExs.values].map((e) => e.id).toList()..addAll([...weightExs.values].map((e) => e.id)),
      [...bodyExs.values,...weightExs.values]);

    notifyListeners();

  }

  List<Exercice> getExercicesByMuscleGroup(BodyModel body, MuscleGroup group){
    List<Exercice> exs = [];
    for (var ex in allExs){
      var primMuscle = ex.primaryMusclesId!.map((e) => body.muscles[e]?.group).toList();
      var secMuscle = ex.secondaryMusclesId!.map((e) => body.muscles[e]?.group).toList();
      if (primMuscle.contains(group) ){//|| secMuscle.contains(group)){
        exs.add(ex);
      }
    }
    return exs;
  }



}



class Exercice extends Object {
    // Hierarchie :
    // Exercice :
    // -> Poids du corps avec assistance ou avec leste
    // -> Chargé (Haltères, barres, poids)
    // -> Elastique 

    // Questions : Quid des tractions avec élastique etc.? //TODO : Mixin ?
    
    
    // Chargé depuis les assets -> Immutable ? 
    //Si les user veulent modifier? Quid des customs ?

    final String name;
    final String desc; 
    final int id;
    final int difficulty; // 1 to 5
    final String group;
    final ExerciceType type;
    final String? iconPath; //nullable for custom exercice
    final String? imgPath; // Png or gif works & nullable for custom exercice
    final List<int>? variantes; //ids of muscle
     //only the id because with full Exercice we will have a looping recursion i guess
    // final Map<int,double>? primaryMuscles; // Muscle and coef default equals 
    // final Map<int,double>? secondaryMuscles; // Muscle and coef default equals
    final List<String>? primaryMusclesId; // Muscles
    final List<String>? secondaryMusclesId; // Muscles
    final List<Requirement>? requirements; 
    List<int> history ;// historique des ids des séances ou des itérations de l'exercice 
  //bool locked; // default : false, true for locked exercice that are not usable (eg : waiting some requirements to be unlocked )
    bool locked; // default : false, true for locked exercice that are not usable (eg : waiting some requirements to be unlocked )
  

    Exercice({
      required this.id,
      required this.name,
      required this.desc,
      required this.group,
      required this.difficulty,
      required this.type,
      this.iconPath, 
      this.imgPath, 
      this.variantes,
      this.primaryMusclesId,
      this.secondaryMusclesId,
      this.requirements,
      this.locked = false, 
      this.history= const [],
      });

    //load from file
    // async therefore we will need to deal with it.
    Future loadFromFile(String path) async { 
      // in the case we have only one Exercice per file
      var jsonString= await rootBundle.loadString(path);
      Map<String,dynamic> jsonMap =json.decode(jsonString) as Map<String,dynamic>;
      return Exercice.fromJson(jsonMap);
    }
    //loading from a JsonMap
    Exercice.fromJson(Map<String,dynamic> jsonMap):
      name =  jsonMap["name"],
      desc = jsonMap["description"],
      id = jsonMap["id"],
      difficulty = jsonMap["difficulty"],
      iconPath = jsonMap["iconPath"], // Quid du nullable ?
      imgPath = jsonMap["imgPath"],
      group = jsonMap["group"],
      type = stringFrToExerciceType[jsonMap["type"] ?? "Autre" ]!,
      locked = json.decode(jsonMap["locked"]??json.encode(false)),
      // A tester
      history = List<int>.from(jsonMap["history"]?? []),
      variantes = List<int>.from(jsonMap["variantes"] ?? []),
      requirements = List<Requirement>.from(json.decode(jsonMap["requirements"] ?? json.encode([]) )
            .map((e) => SimpleRequirement.fromJson(e)).toList()),
      primaryMusclesId = List.from(jsonMap["primaryMuscles"] ?? []),
      secondaryMusclesId = List.from(jsonMap["secondaryMuscles"] ?? []);   
      
    set id (int id) => id = id;


    Map<String,dynamic> toJson()=> {
      "name" : name,
      "description" : desc,
      "id": id,
      "group" : group,
      "type" : type.strName,
      "difficulty" : difficulty,
      "iconPath" : iconPath,
      "imgPath" : imgPath,
      "variantes" : json.encode(variantes),
      "requirements" : json.encode(requirements),
      "primaryMuscles" : json.encode(primaryMusclesId),
      "secondaryMuscles" : json.encode(secondaryMusclesId)
    };
}


// class BodyExercice extends Exercice{
//   // Chargé depuis les shared parameters car il y a des variables mutables
//   BodyExercice({
//     required super.name,
//     required super.desc,
//     required super.id,
//     required super.group,
//     required super.difficulty,
//     super.iconPath,
//     super.imgPath,
//     super.primaryMusclesId,
//     super.requirements,
//     super.secondaryMusclesId,
//     super.variantes,
//     super.history,
//     super.locked,
 
//     });

//   //nullable if the user never execute the exercices
//   Map<int,int>? predictions; // nb séries , nb reps
//   int? maxReps;
  
//   // @override
//   // // TODO: implement name
//   // String get name => super.name;

//   BodyExercice.fromJson(Map<String,dynamic> jsonMap):
//     predictions= Map<int,int>.from(json.decode(jsonMap["predictions"]?? "{}")),
//     maxReps = jsonMap["maxReps"] ?? 0,
//     super.fromJson(jsonMap);

//   @override
//   Map<String,dynamic> toJson() => super.toJson()
//       ..addAll({
//         "predictions" : json.encode(predictions),
//         "maxReps" : maxReps,
//       });

// }


// class WeightExercice extends Exercice {
//   WeightExercice({
//     required super.name,
//     required super.desc,
//     required super.id,
//     required super.group,
//     required super.difficulty,
//     super.iconPath,
//     super.imgPath,
//     super.primaryMusclesId,
//     super.requirements,
//     super.secondaryMusclesId,
//     super.variantes,
//     super.history,
//     super.locked,
//     this.type,
//   });

//   WeightExercice.fromJson(Map<String, dynamic> jsonMap)
//       : predictions = Map<int, Map<int, double>>.from(
//             json.decode(jsonMap["predictions"] ?? "{}")),
//         maxReps = Map<double, int>.from(json.decode(jsonMap["maxReps"] ?? "{}")),
//         super.fromJson(jsonMap);

//   @override
//   Map<String, dynamic> toJson() => super.toJson()
//     ..addAll({
//       "predictions": json.encode(predictions),
//       "maxReps": json.encode(maxReps),
//     });
// }


