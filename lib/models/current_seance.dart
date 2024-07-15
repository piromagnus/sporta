
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


import 'seance.dart';
import 'series.dart';
import 'blocs.dart';



class CurrentTemplateSeance extends ChangeNotifier {
  CurrentTemplateSeance() {
    // getPreferences();
  }

  TemplateTrackedSeance _currentSeance = TemplateTrackedSeance(
    date: DateTime.now().millisecondsSinceEpoch,
    exerciceBlocs: [],
  );
  bool actif = false;

  getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String? json = prefs.getString("currentTemplateSeance");
      actif = prefs.getBool("actifTemplateSeance") ?? false;
      if (json != null) {
        _currentSeance = TemplateTrackedSeance.fromJson(jsonDecode(json));
      }
    } catch (e) {
      print("No current Seance");
    }
    notifyListeners();
  }

  setPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("currentTemplateSeance", jsonEncode(_currentSeance));
    prefs.setBool("actifTemplateSeance", actif);
  }


  operator [](int index) => _currentSeance.exerciceBlocs[index];
  operator []=(int index, TemplateBloc bloc) =>
      _currentSeance.exerciceBlocs[index] = bloc;

  void clear() {
    _currentSeance = TemplateTrackedSeance(
      date: DateTime.now().millisecondsSinceEpoch,
      exerciceBlocs: [],
    );
    actif = false;
    notifyListeners();
    setPreferences();
  }

  void load(TemplateTrackedSeance seance) {
    _currentSeance = seance.copy();
    actif = true;
    notifyListeners();
    setPreferences();
  }

  int indexOf(TemplateBloc bloc) => _currentSeance.exerciceBlocs.indexOf(bloc);
  void insert(int index, TemplateBloc bloc) =>
      _currentSeance.exerciceBlocs.insert(index, bloc);

  TemplateTrackedSeance get data => _currentSeance;

  set data(TemplateTrackedSeance seance) {
    _currentSeance = seance;
    notifyListeners();
    setPreferences();
  }

  String get name => _currentSeance.name ?? "Nouvelle séance";
  SeanceType get type => _currentSeance.type ?? SeanceType.other;
  String? get permNotes => _currentSeance.permNotes;

  // int get date => _currentSeance.date;
  // int? get time => _currentSeance.time;
  // double? get intensity => _currentSeance.intensity;
  // String? get notes => _currentSeance.notes;

  List<TemplateBloc> get blocs => _currentSeance.exerciceBlocs;
  List<TemplateSerie> getSeries(TemplateBloc bloc) => _currentSeance
      .exerciceBlocs[_currentSeance.exerciceBlocs.indexOf(bloc)].series;

  bool get isEmpty => _currentSeance.exerciceBlocs.isEmpty;
  bool get isNotEmpty => _currentSeance.exerciceBlocs.isNotEmpty;

  int get length => _currentSeance.exerciceBlocs.length;

  bool containsExBloc(TemplateBloc bloc) =>
      _currentSeance.exerciceBlocs.contains(bloc);
  bool containsSerie(TemplateBloc bloc, Serie serie) => _currentSeance
      .exerciceBlocs[_currentSeance.exerciceBlocs.indexOf(bloc)].series
      .contains(serie);

  set name(String name) {
    _currentSeance.name = name;
    // print("name set to $name");
    notifyListeners();
    setPreferences();
  }

  set type(SeanceType type) {
    _currentSeance.type = type;
    notifyListeners();
    setPreferences();
  }

  set permNotes(String? permNotes) {
    _currentSeance.permNotes = permNotes;
    notifyListeners();
    setPreferences();
  }

  set seance(TemplateTrackedSeance seance) {
    _currentSeance = seance;
    notifyListeners();
    setPreferences();
  }

  void setExId(TemplateBloc bloc, int id) {
    if (containsExBloc(bloc)) {
      _currentSeance
          .exerciceBlocs[_currentSeance.exerciceBlocs.indexOf(bloc)].exId = id;
      notifyListeners();
      setPreferences();
    }
  }

  void addExBloc(TemplateBloc exBloc) {
    _currentSeance.exerciceBlocs.add(exBloc);
    notifyListeners();
    setPreferences();
  }

  void addSerie(TemplateBloc bloc, TemplateSerie serie) {
    if (!containsExBloc(bloc)) addExBloc(bloc);
    _currentSeance
        .exerciceBlocs[_currentSeance.exerciceBlocs.indexOf(bloc)].series
        .add(serie);
    notifyListeners();
    setPreferences();
  }

  void removeExBloc(TemplateBloc bloc) {
    if (containsExBloc(bloc)) {
      _currentSeance.exerciceBlocs.remove(bloc);
      notifyListeners();
      setPreferences();
    }
  }

  void removeSerie(TemplateBloc bloc, TemplateSerie serie) {
    if (containsExBloc(bloc) && containsSerie(bloc, serie)) {
      _currentSeance
          .exerciceBlocs[_currentSeance.exerciceBlocs.indexOf(bloc)].series
          .remove(serie);
      notifyListeners();
      setPreferences();
    }
  }

  void updateExBloc(TemplateBloc bloc, TemplateBloc newBloc) {
    if (containsExBloc(bloc)) {
      _currentSeance.exerciceBlocs[_currentSeance.exerciceBlocs.indexOf(bloc)] =
          newBloc;
      notifyListeners();
      setPreferences();
    }
  }

  void updateSerie(
      TemplateBloc bloc, TemplateSerie serie, TemplateSerie newSerie) {
    if (containsExBloc(bloc) && containsSerie(bloc, serie)) {
      var blocInd = _currentSeance.exerciceBlocs.indexOf(bloc);
      var serieInd =
          _currentSeance.exerciceBlocs[blocInd].series.indexOf(serie);
      _currentSeance.exerciceBlocs[blocInd].series[serieInd] = newSerie;
      notifyListeners();
      setPreferences();
    }
  }

  void updateReps(TemplateBloc bloc, TemplateSerie serie, int reps) {
    if (containsExBloc(bloc) && containsSerie(bloc, serie)) {
      var blocInd = _currentSeance.exerciceBlocs.indexOf(bloc);
      var serieInd =
          _currentSeance.exerciceBlocs[blocInd].series.indexOf(serie);
      _currentSeance.exerciceBlocs[blocInd].series[serieInd].reps = reps;
      notifyListeners();
      setPreferences();
    }
  }

  void updateWeight(TemplateBloc bloc, TemplateSerie serie, double? weight) {
    if (containsExBloc(bloc) && containsSerie(bloc, serie)) {
      var blocInd = _currentSeance.exerciceBlocs.indexOf(bloc);
      var serieInd =
          _currentSeance.exerciceBlocs[blocInd].series.indexOf(serie);
      _currentSeance.exerciceBlocs[blocInd].series[serieInd].weight = weight;
      notifyListeners();
      setPreferences();
    }
  }

  void updateRest(TemplateBloc bloc, TemplateSerie serie, double rest) {
    if (containsExBloc(bloc) && containsSerie(bloc, serie)) {
      var blocInd = _currentSeance.exerciceBlocs.indexOf(bloc);
      var serieInd =
          _currentSeance.exerciceBlocs[blocInd].series.indexOf(serie);
      _currentSeance.exerciceBlocs[blocInd].series[serieInd].restTime = rest;
      notifyListeners();
      setPreferences();
    }
  }
}

class CurrentExecSeance extends ChangeNotifier {
  CurrentExecSeance() {
    // getPreferences();
  }

  ExecTrackedSeance _currentSeance = ExecTrackedSeance(
    date: DateTime.now().millisecondsSinceEpoch,
    complete: false,
    exerciceBlocs: [],
  );
  bool actif = false;

  Future getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String? json = prefs.getString("currentExecSeance");
      actif = prefs.getBool("actifExecSeance") ?? false;
      if (json != null) {
        _currentSeance = ExecTrackedSeance.fromJson(jsonDecode(json));
      }
    } catch (e) {
      print("No current Exec Seance");
    }
    notifyListeners();
  }

  setPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("currentExecSeance", jsonEncode(_currentSeance.toJson()));
    prefs.setBool("actifExecSeance", actif);
  }

  operator [](int index) => _currentSeance.exerciceBlocs[index];
  operator []=(int index, ExecBloc bloc) =>
      _currentSeance.exerciceBlocs[index] = bloc;

  void clear() {
    _currentSeance.exerciceBlocs.clear();
    _currentSeance.name = null;
    _currentSeance.type = null;
    _currentSeance.date = DateTime.now().millisecondsSinceEpoch;
    _currentSeance.time = null;
    _currentSeance.intensity = null;
    _currentSeance.permNotes = null;
    _currentSeance.notes = null;
    actif = false;
    notifyListeners();
    setPreferences();
  }

  void load(TrackedSeance seance) {
    if (seance is ExecTrackedSeance) {
      _currentSeance = seance;
      actif = true;
    } else if (seance is TemplateTrackedSeance) {
      _currentSeance = seance.toExec();
      actif = true;
    }
    notifyListeners();
    setPreferences();
  }

  void insert(int index, ExecBloc bloc) =>
      _currentSeance.exerciceBlocs.insert(index, bloc);

  int indexOf(ExecBloc bloc) => _currentSeance.exerciceBlocs.indexOf(bloc);
  ExecTrackedSeance get data => _currentSeance;
  String get name => _currentSeance.name ?? "Nouvelle séance";
  SeanceType get type => _currentSeance.type ?? SeanceType.other;
  int get date => _currentSeance.date;
  int? get time => _currentSeance.time;
  double? get intensity => _currentSeance.intensity;
  String? get permNotes => _currentSeance.permNotes;
  String? get notes => _currentSeance.notes;

  List<ExecBloc> get blocs => _currentSeance.exerciceBlocs;
  List<Serie> getSeries(ExecBloc bloc) => _currentSeance
      .exerciceBlocs[_currentSeance.exerciceBlocs.indexOf(bloc)].series;
  int get length => _currentSeance.exerciceBlocs.length;

  bool get isEmpty => _currentSeance.exerciceBlocs.isEmpty;
  bool get isNotEmpty => _currentSeance.exerciceBlocs.isNotEmpty;
  bool containsExBloc(ExecBloc bloc) =>
      _currentSeance.exerciceBlocs.contains(bloc);
  bool containsSerie(ExecBloc bloc, ExecSerie serie) => _currentSeance
      .exerciceBlocs[_currentSeance.exerciceBlocs.indexOf(bloc)].series
      .contains(serie);

  set data(ExecTrackedSeance seance) {
    _currentSeance = seance;
    notifyListeners();
    setPreferences();
  }

  set name(String name) {
    _currentSeance.name = name;
    // print("name set to $name");
    notifyListeners();
    setPreferences();
  }

  set type(SeanceType type) {
    _currentSeance.type = type;
    notifyListeners();
    setPreferences();
  }

  set date(int date) {
    _currentSeance.date = date;
    notifyListeners();
    setPreferences();
  }

  set time(int? time) {
    _currentSeance.time = time;
    notifyListeners();
    setPreferences();
  }

  set intensity(double? intensity) {
    _currentSeance.intensity = intensity;
    notifyListeners();
    setPreferences();
  }

  set permNotes(String? permNotes) {
    _currentSeance.permNotes = permNotes;
    notifyListeners();
    setPreferences();
  }

  set notes(String? notes) {
    _currentSeance.notes = notes;
    notifyListeners();
    setPreferences();
  }

  set seance(ExecTrackedSeance seance) {
    _currentSeance = seance;
    notifyListeners();
    setPreferences();
  }

  void setExId(ExecBloc bloc, int id) {
    if (containsExBloc(bloc)) {
      _currentSeance
          .exerciceBlocs[_currentSeance.exerciceBlocs.indexOf(bloc)].exId = id;
      notifyListeners();
      setPreferences();
    }
  }

  void addExBloc(ExecBloc exBloc) {
    _currentSeance.exerciceBlocs.add(exBloc);
    notifyListeners();
    setPreferences();
  }

  void addSerie(ExecBloc bloc, ExecSerie serie) {
    if (!containsExBloc(bloc)) addExBloc(bloc);
    _currentSeance
        .exerciceBlocs[_currentSeance.exerciceBlocs.indexOf(bloc)].series
        .add(serie);
    notifyListeners();
    setPreferences();
  }

  void removeExBloc(ExecBloc bloc) {
    if (containsExBloc(bloc)) {
      _currentSeance.exerciceBlocs.remove(bloc);
      notifyListeners();
      setPreferences();
    }
  }

  void removeSerie(ExecBloc bloc, ExecSerie serie) {
    if (containsExBloc(bloc) && containsSerie(bloc, serie)) {
      _currentSeance
          .exerciceBlocs[_currentSeance.exerciceBlocs.indexOf(bloc)].series
          .remove(serie);
      notifyListeners();
      setPreferences();
    }
  }

  void updateExBloc(ExecBloc bloc, ExecBloc newBloc) {
    if (containsExBloc(bloc)) {
      _currentSeance.exerciceBlocs[_currentSeance.exerciceBlocs.indexOf(bloc)] =
          newBloc;
      notifyListeners();
      setPreferences();
    }
  }

  void updateSerie(ExecBloc bloc, ExecSerie serie, ExecSerie newSerie) {
    if (containsExBloc(bloc) && containsSerie(bloc, serie)) {
      var blocInd = _currentSeance.exerciceBlocs.indexOf(bloc);
      var serieInd =
          _currentSeance.exerciceBlocs[blocInd].series.indexOf(serie);
      _currentSeance.exerciceBlocs[blocInd].series[serieInd] = newSerie;
      notifyListeners();
      setPreferences();
    }
  }

  void updateReps(ExecBloc bloc, ExecSerie serie, int reps) {
    if (containsExBloc(bloc) && containsSerie(bloc, serie)) {
      var blocInd = _currentSeance.exerciceBlocs.indexOf(bloc);
      var serieInd =
          _currentSeance.exerciceBlocs[blocInd].series.indexOf(serie);
      _currentSeance.exerciceBlocs[blocInd].series[serieInd].reps = reps;
      notifyListeners();
      setPreferences();
    }
  }

  void updateWeight(ExecBloc bloc, ExecSerie serie, double? weight) {
    if (containsExBloc(bloc) && containsSerie(bloc, serie)) {
      var blocInd = _currentSeance.exerciceBlocs.indexOf(bloc);
      var serieInd =
          _currentSeance.exerciceBlocs[blocInd].series.indexOf(serie);
      _currentSeance.exerciceBlocs[blocInd].series[serieInd].weight = weight;
      notifyListeners();
      setPreferences();
    }
  }

  void updateDone(ExecBloc bloc, ExecSerie serie, bool done) {
    if (containsExBloc(bloc) && containsSerie(bloc, serie)) {
      var blocInd = _currentSeance.exerciceBlocs.indexOf(bloc);
      var serieInd =
          _currentSeance.exerciceBlocs[blocInd].series.indexOf(serie);
      (_currentSeance.exerciceBlocs[blocInd].series[serieInd] as ExecSerie)
          .done = done;
      notifyListeners();
      setPreferences();
    }
  }

  void updateTime(ExecBloc bloc, ExecSerie serie, int time) {
    if (containsExBloc(bloc) && containsSerie(bloc, serie)) {
      var blocInd = _currentSeance.exerciceBlocs.indexOf(bloc);
      var serieInd =
          _currentSeance.exerciceBlocs[blocInd].series.indexOf(serie);
      _currentSeance.exerciceBlocs[blocInd].series[serieInd].time = time;
      notifyListeners();
      setPreferences();
    }
  }

  void updateRest(ExecBloc bloc, ExecSerie serie, double rest) {
    if (containsExBloc(bloc) && containsSerie(bloc, serie)) {
      var blocInd = _currentSeance.exerciceBlocs.indexOf(bloc);
      var serieInd =
          _currentSeance.exerciceBlocs[blocInd].series.indexOf(serie);
      _currentSeance.exerciceBlocs[blocInd].series[serieInd].restTime = rest;
      notifyListeners();
      setPreferences();
    }
  }

  void updateIntensity(ExecBloc bloc, ExecSerie serie, double intensity) {
    if (containsExBloc(bloc) && containsSerie(bloc, serie)) {
      var blocInd = _currentSeance.exerciceBlocs.indexOf(bloc);
      var serieInd =
          _currentSeance.exerciceBlocs[blocInd].series.indexOf(serie);
      _currentSeance.exerciceBlocs[blocInd].series[serieInd].intensity =
          intensity;
      notifyListeners();
      setPreferences();
    }
  }
}