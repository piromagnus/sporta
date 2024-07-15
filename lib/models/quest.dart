import 'requirement.dart';
import 'reward.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

// mixin QuestDBIterable {
//   Iterator<Quest> get iterator => _quests.iterator;
// }

enum QuestState {
  locked("locked"),
  unlocked("unlocked"),
  inProgress("inProgress"),
  complete("complete");

  const QuestState(this.strName);
  final String strName;

  static QuestState strToQuestState(String str) {
    switch (str) {
      case "locked":
        return QuestState.locked;
      case "unlocked":
        return QuestState.unlocked;
      case "inProgress":
        return QuestState.inProgress;
      case "complete":
        return QuestState.complete;
      default:
        return QuestState.locked;
    }

  }
}

enum QuestType {
  main("principal"),
  tutorial("tutorial"),
  donjon("donjon"),
  secondary("secondaire"),
  daily("quotidienne");

  final String strName;
  const QuestType(this.strName);

  static QuestType strToQuestType(String str) {
    switch (str) {
      case "principal":
        return QuestType.main;
      case "tutorial":
        return QuestType.tutorial;
      case "donjon":
        return QuestType.donjon;
      case "secondaire":
        return QuestType.secondary;
      case "quotidienne":
        return QuestType.daily;
      default:
        return QuestType.main;
    }
  }

}


class QuestDB extends ChangeNotifier with Iterable<Quest> {
  List<Quest> _quests = [];

  List<Quest> get quests => _quests;

  Quest? getByName(String name) =>
      _quests.firstWhere((element) => element.name == name);

  Quest operator [](int index) => _quests[index];
  operator []=(int index, Quest value) => _quests[index] = value;

  List<Quest> get unlockedQuests =>
    _quests.where(
      (element) => element.generalState == QuestState.unlocked)
      .toList();

  @override
  Iterator<Quest> get iterator => _quests.iterator;

  @override
  Iterable<Object> map<Object>(Object Function(Quest) f) => _quests.map(f);

  int get length => _quests.length;
  int indexOf(Quest quest) => _quests.indexOf(quest);

  void addQuest(Quest quest) {
    _quests.add(quest);
    notifyListeners();
  }

  void resetCache() async {
    var pref = await SharedPreferences.getInstance();
    await pref.remove("quests");
    notifyListeners();
  }

  void removeQuest(Quest quest) {
    _quests.remove(quest);
    notifyListeners();
  }

  void removeByName(String name) {
    _quests.removeWhere((element) => element.name == name);
    notifyListeners();
  }

  void loadQuests(List<Quest> quests) {
    _quests = quests;
    notifyListeners();
  }

  void loadQuestsFromJson(List<dynamic> jsonList) {
    _quests = jsonList.map((e) => Quest.fromJson(e)).toList();
    notifyListeners();
  }

  void firstLoad() async {
    var jsonBodyString = await rootBundle.loadString("assets/quest.json");
    List<dynamic> jsonList = json.decode(jsonBodyString) as List;
    _quests = jsonList.map((e) => Quest.fromJson(e)).toList();
  }

  Future<void> getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> questsJson = prefs.getStringList("quests") ?? [];
    if (questsJson.isEmpty) {
      firstLoad();
    } else {
      _quests = questsJson.map((e) => Quest.fromJson(json.decode(e))).toList();
    }
    notifyListeners();
  }

  void setPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> questsJson =
        _quests.map((e) => json.encode(e.toJson())).toList();
    prefs.setStringList("quests", questsJson);
  }
}

class Quest {
  final String name;
  final String description;
  final List<Reward> rewards;
  final QuestType type;
  // List<QuestRequirement> requirements; // Can be empty
  QuestState generalState;
  Progression? generalProgression;
  List<String>? nextQuest; //name of the next quest

  //Quest.fromJson(String jsonMap);
  Quest(
      {required this.name,
      required this.description,
      required this.generalProgression,

      // this.requirements =const [],
      this.type = QuestType.main,
      this.rewards = const [],
      this.generalState = QuestState.locked,
      this.nextQuest});

  double get progress =>
      (generalProgression?.value ?? 0) / (generalProgression?.maximum ?? 1);

  Quest.fromJson(Map<String, dynamic> jsonMap)
      : name = jsonMap["name"],
        description = jsonMap["description"],
        nextQuest = List<String>.from(jsonMap["nextQuest"] ?? []),
        type = QuestType.strToQuestType(jsonMap["type"] ?? "principal"),
        // requirements = jsonMap["requirements"]
        //   .map<QuestRequirement>(
        //     (e) => QuestRequirement.fromJson(e)).toList(),
        generalProgression = Progression.fromJson(
            Map<String,int>.from(jsonMap["generalProgression"] ?? {"value": 0, "maximum": 1})),
        generalState =
            QuestState.strToQuestState(jsonMap["generalState"] ?? "locked"),
        rewards =
            jsonMap["reward"].map<Reward>((e) => Reward.fromJson(e)).toList();

  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "nextQuest": nextQuest,
        "type" : type.strName,
        // "requirements" : requirements.map((e) => e.toJson()).toList(),
        "generalProgression":
            generalProgression?.toJson() ?? Progression.empty().toJson(),
        "generalState": generalState.strName,
        "rewards": rewards.map((e) => e.toJson()).toList(),
      };
}
