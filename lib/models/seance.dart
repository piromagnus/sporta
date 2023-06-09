import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


import 'package:sporta/models/series.dart';
import 'package:sporta/models/blocs.dart';
import 'package:sporta/models/exercice_db.dart';



enum SeanceType {
  musculation("Musculation"),
  cardio("Cardio"),
  running("Course à pied"),
  cycling("Cyclisme"),
  swimming("Natation"),
  climbing("Escalade"),
  skiing("Ski"),
  nordicSkiing("Ski de fond"),
  boxing("Boxe"),
  judo("Judo"),
  jujitsu("Jujitsu"),
  other("Autre");

  const SeanceType(this.strName);
  final String strName;
}

Map<String, SeanceType> stringFrToSeanceType = {
  "Musculation": SeanceType.musculation,
  "Cardio": SeanceType.cardio,
  "Course à pied": SeanceType.running,
  "Cyclisme": SeanceType.cycling,
  "Natation": SeanceType.swimming,
  "Escalade": SeanceType.climbing,
  "Ski": SeanceType.skiing,
  "Ski de fond": SeanceType.nordicSkiing,
  "Boxe": SeanceType.boxing,
  "Judo": SeanceType.judo,
  "Jujitsu": SeanceType.jujitsu,
  "Autre": SeanceType.other,
};

// Structure de série :
// 1. Géneral avec méthodes générales et deux sous-classes
//pour templates et exécution
// 2. Serie<T> avec T = Execution ou Template

// Structure de ExBloc
// 1. ExBloc<T> avec T = ExecSerie ou TemplateSerie
//-> Y a le done et l'intensité à ajouter et probablement le temps
// 2. ExBloc général et deux sous classes pour templates et exécution

class SeanceDB extends ChangeNotifier {
  SeanceDB() {
    getPreferences();
  }

  List<TemplateTrackedSeance> _seances = [];

  List<TemplateTrackedSeance> get seances => _seances;

  void add(TemplateTrackedSeance seance) {
    _seances.add(seance.copy());
    notifyListeners();
    setPreferences();
  }

  void remove(TemplateTrackedSeance seance) {
    _seances.remove(seance);
    notifyListeners();
    setPreferences();
  }

  int indexOf(TemplateTrackedSeance seance) {
    return _seances.indexOf(seance);
  }

  void replace(int index,TemplateTrackedSeance newSeance) {
    _seances[index] = newSeance;
    notifyListeners();
    setPreferences();
  }

  operator [](int index) => _seances[index];
  operator []=(int index, TemplateTrackedSeance newSeance) {
    _seances[index] = newSeance;
    notifyListeners();
    setPreferences();
  }



  getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      List<String>? json = prefs.getStringList("templateSeances");
      // print("JSON : $json");
      if (json != null) {
        _seances = json
            .map((e) => TemplateTrackedSeance.fromJson(jsonDecode(e)))
            .toList();
      }
      // print("Get Seance ${_seances.map((e) => e.exerciceBlocs).toList()}");
    } catch (e) {
      print("No seances");
    }
    notifyListeners();
  }

  setPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        "templateSeances", _seances.map((e) => json.encode(e)).toList());
    // print("Set Seance : ${_seances.map((e) => json.encode(e)).toList()}");
  }

  void save() {
    setPreferences();
  }

}



class Seance {
  
  int date;

  Seance({required this.date});  

  Seance.fromJson(dynamic jsonMap):
  date = jsonMap["date"];

  Map<String, dynamic> toJson() => {};
}

// The type is within the parameter of the seance but in the futur their can be multiple seance type inherited from this class
class BasicSeance extends Seance {
  BasicSeance(
      {required super.date,
      this.complete = false,
      this.name,
      this.type,
      this.time,
      this.intensity,
      this.permNotes,
      this.notes});

  // int date; // milliseconds since epoch

  bool complete;

  String? name;
  SeanceType? type;
  // for the moment it is a string but in the futur it could be a Object
  int? time; //times
  double? intensity; //between 1 and 10
  // Notes of the seance, basically can be anything
  String?
      permNotes; //permanent notes that will be showed every iterations of the seance
  String? notes;

  @override
  Map<String, dynamic> toJson() => {
        "date": date,
        "name": name,
        "type": type?.strName ?? "Autre",
        "complete": complete,
        "time": time,
        "permNotes": permNotes ?? "",
        "intensity": intensity,
        "notes": notes ?? "",
      };

  BasicSeance.fromJson(dynamic jsonMap) //Map<String,dynamic>jsonMap)
      : name = jsonMap["name"],
        complete = jsonMap["complete"] ?? false,
        type = stringFrToSeanceType[jsonMap["type"] ?? "Autre"]!,
        notes = jsonMap["notes"],
        time = jsonMap["time"],
        intensity = jsonMap["intensity"],
        super.fromJson(jsonMap);
}

abstract class TrackedSeance extends Seance {
  TrackedSeance(
      {required super.date,
      this.name,
      this.type,
      this.permNotes,
      this.complete = false,
      // required this.exerciceBlocs // empty list by default
      });

  // int date; // milliseconds since epoch
  String? name;
  SeanceType?
      type; // for the moment it is a string but in the futur it could be a Object
  String?
      permNotes; //permanent notes that will be showed every iterations of the seance
  bool complete;
  // List<T> exerciceBlocs = []; // Un exercice avec chaque bloc de série

  TrackedSeance.fromJson(dynamic jsonMap)
      : name = jsonMap["name"],
        complete = jsonMap["complete"] ?? false,
        type = stringFrToSeanceType[jsonMap["type"] ?? "Autre"]!,
        permNotes = jsonMap["permNotes"],
        super.fromJson(jsonMap)
        ;
        // exerciceBlocs = (T is TemplateBloc)
        //     ? List<T>.from(jsonMap["exerciceBlocs"]
        //         .map((Map bloc) => TemplateBloc.fromJson(bloc)))
        //     : List<T>.from(jsonMap["exerciceBlocs"]
        //             .map((bloc) => ExecBloc.fromJson(bloc)));
  @override
  Map<String, dynamic> toJson() => {
        "date": date,
        "name": name,
        "type": type?.strName ?? "Autre",
        "permNotes": permNotes ?? "",
        "complete": complete,
        // "exerciceBlocs": exerciceBlocs.map((e) => e.toJson()).toList()
      };

  
}

class TemplateTrackedSeance extends TrackedSeance {
  TemplateTrackedSeance(
      {required super.date,
      super.name,
      super.type,
      super.permNotes,
      super.complete = false,
      required this.exerciceBlocs // empty list by default
      });

  

  List<TemplateBloc> exerciceBlocs = []; // Un exercice avec chaque bloc de série
  
  @override
  Map<String,dynamic> toJson() => super.toJson()..addAll({
    "exerciceBlocs": exerciceBlocs.map((e) => e.toJson()).toList()
  }); 


  TemplateTrackedSeance.fromJson(dynamic jsonMap) : 
    exerciceBlocs = List<TemplateBloc>.from(jsonMap["exerciceBlocs"]?.map(
      (bloc) => TemplateBloc.fromJson(bloc))??[]),
    super.fromJson(jsonMap);

  TemplateTrackedSeance copy() => TemplateTrackedSeance(
      date: date,
      name: name,
      type: type,
      permNotes: permNotes,
      complete: complete,
      exerciceBlocs: exerciceBlocs.map((e) => e.copy()).toList());

  ExecTrackedSeance toExec() => ExecTrackedSeance(
        name: name,
        type: type,
        permNotes: permNotes,
        date: DateTime.now().millisecondsSinceEpoch,
        template: this,
        exerciceBlocs: exerciceBlocs.map((e) => e.toExec()).toList(),
      );

  get length => exerciceBlocs.length;

  double volume(ExerciceDB exDB, double? bodyWeight  ) {
    // on gère pas le poids du corps

    double res = 0;
    for (var bloc in exerciceBlocs) {
      ExerciceType type = exDB[bloc.exId]!.type;
      if (type == ExerciceType.body) {
        if (bodyWeight == null) {
          throw Exception("bodyWeight is null");
        }
        for (var serie in bloc.series) {
          if (serie.reps != null) {
            res += serie.reps! * bodyWeight;
          }
        }
      }
      else {
        for (var serie in bloc.series) {
          if (serie.reps != null ) {
            res += serie.reps! * (serie.weight ?? 0);
          }
        }
      }
    }
    return res;
  }

  get reps {
    int res = 0;
    for (var bloc in exerciceBlocs) {
      for (var serie in bloc.series) {
        if (serie.reps != null) {
          res += serie.reps!;
        }
      }
    }
    return res;
  }

  void remove(TemplateBloc bloc) => exerciceBlocs.remove(bloc);
  int indexOf(TemplateBloc bloc) => exerciceBlocs.indexOf(bloc);

  void removeAt(int index) => exerciceBlocs.removeAt(index);



  void add(TemplateBloc bloc) => exerciceBlocs.add(bloc);

  void insert(int index, TemplateBloc bloc) {
    exerciceBlocs.insert(index, bloc);
  }


}

class ExecTrackedSeance extends TrackedSeance {
  ExecTrackedSeance({
    required super.date,
    super.name,
    super.type,
    super.permNotes,
    super.complete = false,
    required this.exerciceBlocs,
    // required super.exerciceBlocs,
    this.template,
    this.time,
    this.intensity,
    this.notes, // empty list by default
  });

  int? time; //times
  double? intensity; //between 1 and 10
  String? notes;

  TemplateTrackedSeance? template;
  List<ExecBloc> exerciceBlocs = [];

  ExecTrackedSeance.fromJson(dynamic jsonMap)
      : time = jsonMap["time"],
        intensity = jsonMap["intensity"],
        notes = jsonMap["notes"],
        template = jsonMap["template"] != null
            ? TemplateTrackedSeance.fromJson(jsonMap["template"])
            : null,
        exerciceBlocs = List<ExecBloc>.from(
            jsonMap["exerciceBlocs"]?.map((bloc) => ExecBloc.fromJson(bloc))?? []) ,
        super.fromJson(jsonMap);

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      "time": time,
      "intensity": intensity,
      "notes": notes ?? "",
      "template": template?.toJson(),
      "exerciceBlocs": exerciceBlocs.map((e) => e.toJson()).toList()
    });

  ExecTrackedSeance copy() => ExecTrackedSeance(
      date: date,
      name: name,
      type: type,
      time: time,
      intensity: intensity,
      notes: notes,
      permNotes: permNotes,
      complete: complete,
      template: template?.copy(),
      exerciceBlocs: exerciceBlocs.map((e) => e.copy()).toList());


get length => exerciceBlocs.length;

  double volume(ExerciceDB exDB, double? bodyWeight  ) {
    double res = 0;
    for (var bloc in exerciceBlocs) {
      ExerciceType type = exDB[bloc.exId]!.type;
      if (type == ExerciceType.body) {
        if (bodyWeight == null) {
          throw Exception("bodyWeight is null");
        }
        for (var serie in bloc.series) {
          if (serie.reps != null && serie.done) {
            res += serie.reps! * bodyWeight;
          }
        }
      }
      else {
        for (var serie in bloc.series) {
          if (serie.reps != null && serie.done) {
            res += serie.reps! * (serie.weight ?? 0);
          }
        }
      }
    }
    return res;
  }

  get reps {
    int res = 0;
    for (var bloc in exerciceBlocs) {
      for (var serie in bloc.series) {
        if (serie.reps != null  && serie.done) {
          res += serie.reps!;
        }
      }
    }
    return res;
  }

  Iterable map( Function(ExecBloc) f) {
    return exerciceBlocs.map(f);
  }

  void remove(ExecBloc bloc) => exerciceBlocs.remove(bloc);
  int indexOf(ExecBloc bloc) => exerciceBlocs.indexOf(bloc);
  ExecBloc removeAt(int index) => exerciceBlocs.removeAt(index);

  void add(ExecBloc bloc) => exerciceBlocs.add(bloc);

  void insert(int index, ExecBloc bloc) {
    exerciceBlocs.insert(index, bloc);
  }
}

class CardioSeance extends BasicSeance {
  CardioSeance({
    required super.date,
    required super.name,
    required super.type,
    required super.time,
    required super.intensity,
    super.notes,
  });
}



