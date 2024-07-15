import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:sporta/models/seance.dart';
import 'package:sporta/models/blocs.dart';


class HistoryModel extends ChangeNotifier {
  //Interface with _fullHistory but save with basic et tracked.


  // int _size = 20;
  List<BasicSeance> _basicHistory = [];
  List<ExecTrackedSeance> _trackedHistory = [];
  //In the future take care of the type, maybe a Seance Class that is the ancester of everyone else
  //TODO  plutôt faire un dictionaire avec la date et l'heure de la séance en key ? Pas sûr en fait

  List<Seance> _fullHistory = [];

  HistoryModel() {
    getBasicPreferences();
    getTrackedPreferences().then((value) => getFullHistory());
  }


  operator [](int index) {
    return _fullHistory[index];
  }
  operator []=(int index, Seance value) {
    _fullHistory[index] = value;
    notifyListeners();
    setPreferences();
  }

  int get length => _fullHistory.length;

  List<Seance> get history => _fullHistory;


  void getFullHistory(){
    _fullHistory.clear();
    _fullHistory.addAll(_basicHistory);
    _fullHistory.addAll(_trackedHistory);
    // _fullHistory.toList();
    _fullHistory.sort((a,b) => b.date.compareTo(a.date));
    notifyListeners();
  }


  void add(Seance val) {
    if (val is BasicSeance) {
      _basicHistory.add(val);
      notifyListeners();
      setBasicPreferences();
    } else if (val is ExecTrackedSeance) {
      _trackedHistory.add(val);
      notifyListeners();
      setTrackedPreferences();
    }
    else {
      print("Error, unknown type of seance");
    }
    notifyListeners();
    getFullHistory();
  }

  void removeItem(Seance item) {
    if (item is BasicSeance) {
      _basicHistory.removeWhere((element) => element == item);
      notifyListeners();
      setBasicPreferences();
    } else if (item is ExecTrackedSeance) {
      _trackedHistory.removeWhere((element) => element == item);
      notifyListeners();
      setTrackedPreferences();
    }
    else {
      print("Error, unknown type of seance");
    }
    getFullHistory();
  }

  void modifyBasicSeance(BasicSeance item, String name, SeanceType type, String? notes,
      int date, int time, double intensity) {
    item.name = name;
    item.type = type;
    item.notes = notes;
    item.date = date;
    item.time = time;
    item.intensity = intensity;
    notifyListeners();
    getFullHistory();
  }

  void modifyTrackedSeance(
    ExecTrackedSeance item, String name,
    SeanceType type, String? notes, String? permNotes,
    int date, int time, double intensity, 
    List<ExecBloc> blocs) {

      item.name = name;
      item.type = type;
      item.notes = notes;
      item.permNotes = permNotes;
      item.date = date;
      item.time = time;
      item.intensity = intensity;
      item.exerciceBlocs = blocs;
      notifyListeners();
      getFullHistory();
  }

  void resetBasic() {
    _basicHistory.clear();
    notifyListeners();
    setBasicPreferences();
    getFullHistory();
  }

  void resetTracked(){
    _trackedHistory.clear();
    notifyListeners();
    setTrackedPreferences();
    getFullHistory();
  }

  void reset(){
    resetBasic();
    resetTracked();
    getFullHistory();
  }

  setPreferences() async {
    setBasicPreferences();
    setTrackedPreferences();
  }

  setBasicPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("basicHistory", json.encode(_basicHistory.toList()));
    print("saved Basic History");
  }

  setTrackedPreferences() async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("trackedHistory", json.encode(_trackedHistory.toList()));
    print("saved Tracked History");
  }

  getBasicPreferences() async {
    print("Getting history...");
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? historyString = sharedPreferences.getString("basicHistory");
      var historyList = json.decode(historyString!) as List;
      if (historyList != []) {
        _basicHistory = List<BasicSeance>.from(
            historyList.map((e) => BasicSeance.fromJson(e)).toList());
      }
      notifyListeners();
    } catch (e) {
      print("No Basic history ");
    }
  }
  getTrackedPreferences() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? historyString = sharedPreferences.getString("trackedHistory");
      var historyList = json.decode(historyString!) as List;
      if (historyList != []) {
        _trackedHistory = List<ExecTrackedSeance>.from(
            historyList.map((e) => ExecTrackedSeance.fromJson(e)).toList());
      }
      notifyListeners();
    } catch (e) {
      print("No Tracked history");
    }

  }

}