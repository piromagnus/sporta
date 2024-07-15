


import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'seance.dart';


class CalendarDB extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  Map<DateTime, List<TemplateTrackedSeance>> _seances = {};

  get seances => _seances;

  DateTime get selectedDate => _selectedDate;
  DateTime get focusedDate => _focusedDate;

  List get selectedEvents => _seances[_selectedDate] ?? [];

  List<TemplateTrackedSeance> operator [](DateTime date) => _seances[date]  ?? [];
  operator []=(DateTime date, List<TemplateTrackedSeance> seances) {
    _seances[date] = seances;
    notifyListeners();
    setPreferences();
  }

  Map<DateTime,List<TemplateTrackedSeance>> get nextWeekSeances {
    final DateTime today = DateTime.now().add(Duration(days: -1));
    final DateTime nextWeek = today.add(Duration(days: 7));
    Map<DateTime,List<TemplateTrackedSeance>> nextWeekSeances = {};
    _seances.forEach((date, seances) {
      if (date.isAfter(today) && date.isBefore(nextWeek)) {
        nextWeekSeances[date] = seances;
      }
    });
    return nextWeekSeances;
  }

  void addSeance(DateTime date, TemplateTrackedSeance seance) {
    (_seances[date] !=null) ?_seances[date]!.add(seance)
    : _seances[date]= [seance];
    notifyListeners();
    setPreferences();
  }

  void addSeances(DateTime date, List<TemplateTrackedSeance> seances) {
    (_seances[date] !=null) ?_seances[date]!.addAll(seances) 
    : _seances[date]= seances;
    notifyListeners();
    setPreferences();
  }

  void removeSeance(DateTime date,TemplateTrackedSeance seance) {
    _seances[date]?.remove(seance);
    notifyListeners();
    setPreferences();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setFocusedDate(DateTime date) {
    _focusedDate = date;
    notifyListeners();
  }

  Future getPreferences() async {
    // Load the _seances from sharedPreferences "plannifiedSeances"
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString("plannifiedSeances");
    Map<String, dynamic> seances = json.decode( jsonString ?? "{}");
    seances.forEach((key, value) {
      DateTime date = DateTime.parse(key);
      List<TemplateTrackedSeance> seance = List<TemplateTrackedSeance>.from(json.decode(value).map((x) => TemplateTrackedSeance.fromJson(x)));
      _seances[date] = seance;
    });  
  }

  void setPreferences() async {
    // Save the _seances to sharedPreferences "plannifiedSeances"
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> seances = {};
    _seances.forEach((key, value) {
      seances[key.toString()] = json.encode(value.map((x) => x.toJson()).toList());
    });
    prefs.setString("plannifiedSeances", json.encode(seances));

  }


}