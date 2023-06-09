import 'requirement.dart';
import 'reward.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class QuestDB extends ChangeNotifier{
  List<Quest> _quests = [];

  List<Quest> get quests => _quests;

  Quest? getByName(String name) => 
      _quests.firstWhere((element) => element.name == name);

  operator [](int index) => _quests[index];

  void addQuest(Quest quest){
    _quests.add(quest);
    notifyListeners();
  }

  void removeQuest(Quest quest){
    _quests.remove(quest);
    notifyListeners();
  }

  void removeByName(String name){
    _quests.removeWhere((element) => element.name == name);
    notifyListeners();
  }

  void loadQuests(List<Quest> quests){
    _quests = quests;
    notifyListeners();
  }

  void loadQuestsFromJson(List<dynamic> jsonList){
    _quests = jsonList.map((e) => Quest.fromJson(e)).toList();
    notifyListeners();
  }

  void getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> questsJson = prefs.getStringList("quests") ?? [];
    _quests = List<Quest>.from(questsJson.map((e) => Quest.fromJson(json.decode(e))));
  }




}



class Quest {

  final String name;
  final String desc;
  final List<Reward> rewards;
  List<QuestRequirement> requirements; // Can be empty  
  QuestState generalState;
  Progression? generalProgression;

  //Quest.fromJson(String jsonMap);
  Quest({
    required this.name,
    required this.desc,
    required this.generalProgression,
    this.requirements =const [],
    this.rewards = const [],
    this.generalState = QuestState.locked,
  });



  double get progress => (generalProgression?.value ?? 0 )/ (generalProgression?.maximum ?? 1);

  Quest.fromJson(Map<String,dynamic> jsonMap):
  name = jsonMap["name"],
  desc = jsonMap["desc"],
  requirements = jsonMap["requirements"]
    .map<QuestRequirement>((e) => QuestRequirement.fromJson(e)).toList(),
  generalProgression = Progression.fromJson(jsonMap["generalProgression"]),
  generalState = strToQuestState[jsonMap["generalState"]] ?? QuestState.locked,
  rewards = jsonMap["rewards"]
    .map<Reward>((e) => Reward.fromJson(e)).toList();


    Map<String,dynamic> toJson() => {
      "name" : name,
      "desc" : desc,
      "requirements" : requirements.map((e) => e.toJson()).toList(),
      "generalProgression" : generalProgression?.toJson() 
          ?? Progression.empty().toJson(),
      "generalState" : generalState.strName,
      "rewards" : rewards.map((e) => e.toJson()).toList(),
  };
}