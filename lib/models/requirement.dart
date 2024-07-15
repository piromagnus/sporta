


import 'dart:convert';
// import 'dart:collection';

import 'quest.dart';







class Progression {
  // Class used to follow the Progression of a Requirements or Quest
  num value;
  num maximum;

  Progression(this.value,this.maximum);

  Progression.fromJson(Map<String,num> jsonMap):
    value = jsonMap["value"] ?? 0,
    maximum = jsonMap["maximum"] ?? 0;

  Map<String,dynamic> toJson() => {
    "value" :value,
    "maximum" : maximum
  };
  Progression.empty() : this(0, 0);

  void progress(num val){
    // change the progression regarding the "val" value
    num res= value + val;
    value= (res<maximum) ? res : maximum;
    }
}

class Requirement {
    // Basic requirements -> Sometimes mission, question, exercice will have a list of requirements
    //TODO : ça va pas marcher de faire une liste de requirements, 
    // il faut faire une liste de questRequirement 
    // et une liste de ExerciceRequirement
    // car sinon le load du fichier va rater.  

  final String name;
  final int id;
  final String desc;
  QuestState fullfilled;
  Progression progression; //

  Requirement({
    required this.name,
    required this.id,
    required this.desc,
    required this.progression, 
    this.fullfilled = QuestState.locked,
    
    });

  Requirement.fromJson(Map<String,dynamic> jsonMap):
  name = jsonMap["name"],
  id = jsonMap["id"],
  desc = jsonMap["desc"],
  progression = Progression.fromJson(json.decode(jsonMap["progression"])),
  fullfilled = QuestState.strToQuestState(jsonMap["fullfilled"] ?? "locked");

  Map<String,dynamic> toJson() => {
    "name" : name,
    "id" : id,
    "desc" : desc,
    "fullfilled" : fullfilled.strName,
    "progression" : json.encode(progression)
  };

}


class SimpleRequirement extends Requirement{ 
  // Requirement for just "Do X reps of an Exercice"
  
  
  final double repsToDo; //Number of reps for completing the Requiremements
  final int exerciceToDoId; // id to avoid load 
  
 
  

  SimpleRequirement({
    required super.name,
    required super.desc,
    required super.id,
    required this.repsToDo,
    required this.exerciceToDoId,
    required super.progression,
    super.fullfilled = QuestState.locked
    });
    // Initial class for requirements
    // Differents class inherited from that will be create (eg : Complete a quête, unlock exercice, do X reps for Y exos etc.)
  SimpleRequirement.fromJson(Map<String,dynamic> jsonMap):
    repsToDo = jsonMap["repsToDo"],
    exerciceToDoId = jsonMap["exerciceToDoId"],
    super.fromJson(jsonMap);
    // super(name : jsonMap["name"],
    //       id : jsonMap["id"],
    //       desc : jsonMap["desc"],
    //       fullfilled : jsonMap["fullfilled"]);
  
  @override
  Map<String,dynamic> toJson() => super.toJson()
      ..addAll({
        "repsToDo":repsToDo,
        "exerciceToDoId": exerciceToDoId,
        });
   
}



class QuestRequirement extends Requirement{
  // Requirement for a quest
  // A quest can have multiple requirements
  // A q
  final List<Requirement> requirements;

  QuestRequirement({
    required super.name,
    required super.desc,
    required super.id,
    required this.requirements,
    required super.progression,
    super.fullfilled = QuestState.locked
    });

  QuestRequirement.fromJson(Map<String,dynamic> jsonMap):
    requirements = List<Requirement>.from(
      jsonMap["requirements"]
      .map((x) => Requirement.fromJson(x))),
    super.fromJson(jsonMap);

  @override
  Map<String,dynamic> toJson() => super.toJson()
      ..addAll({
        "requirements": json.encode(requirements),
        });

}