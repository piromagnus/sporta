import 'series.dart';


// ------------------------------------------ //
// Exercice bloc//
// ------------------------------------------ //

abstract class ExerciceBloc<T extends Serie> {
  // can't instanciate this class
  // Basic implementation of an exercice bloc

  int? exId; //we only save the id
  // List<T> series = []; // Un exercice avec chaque bloc de série
  String? permNotes; //Permanent notes that will be showed every iterations of the seance

  ExerciceBloc({
    // required this.series,
    this.exId, 
    this.permNotes});

  

  ExerciceBloc copy();


  ExerciceBloc.fromJson(dynamic jsonMap) {
    exId = jsonMap["exId"];
    permNotes = jsonMap["permNotes"];
  }

  Map<String, dynamic> toJson() => {
        "exId": exId,
        // "series": series.map((e) => e.toJson()).toList(),
        "permNotes": permNotes,
      };
  @override
  String toString() {
    String res = "exId: $exId\n";
    res += "permNotes: $permNotes\n";
    return res;
  }
}

class TemplateBloc extends ExerciceBloc<TemplateSerie> {
  TemplateBloc({
    super.exId,
    super.permNotes,
    this.restTime,
    required this.series,
  });

  int? restTime; // Rest time at the end of the bloc
  List<TemplateSerie> series = [];

  TemplateSerie get last => (series.isNotEmpty) ? series.last : TemplateSerie();
  TemplateSerie get first =>
      (series.isNotEmpty) ? series.first : TemplateSerie();

  @override
  TemplateBloc copy() {
    return TemplateBloc(
      series: series.map((e) => e.copy()).toList(),
      exId: exId,
      permNotes: permNotes,
      restTime: restTime,
    );
  }

  ExecBloc toExec() => ExecBloc(
        exId: exId,
        series: series.map((e) => e.toExec()).toList(),
        restTime: restTime,
        permNotes: permNotes,
      );

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      "restTime": restTime,
      "series": series.map((e) => e.toJson()).toList(),
    });

  TemplateBloc.fromJson(dynamic jsonMap)
      : restTime = jsonMap["restTime"],
        series = List<TemplateSerie>.from(
            jsonMap["series"]?.map((serie) => TemplateSerie.fromJson(serie))?? []),
        super.fromJson(jsonMap);

  @override
  String toString() {
    var res = "${super.toString()} \nrestTime: $restTime";
    for (var serie in series) {
      res += "$serie\n";
    }
    return res;
  }

  operator [](int index) => series[index];
  operator []=(int index, TemplateSerie value) => series[index] = value;

  List<int?> get repsList => series.map((e) => e.reps).toList();
  List<double?> get weightList => series.map((e) => e.weight).toList();
  List<double?> get restTimeList => series.map((e) => e.restTime).toList();
  int indexOf(TemplateSerie serie) => series.indexOf(serie);

  get isEmpty => series.isEmpty;
  get isNotEmpty => series.isNotEmpty;
  int get length => series.length;

  void add(TemplateSerie serie) => series.add(serie);
  void remove(TemplateSerie serie) => series.remove(serie);

  void removeLast() => series.removeLast();

  void removeAt(int index) => series.removeAt(index);
  void insert(int index, TemplateSerie serie) => series.insert(index, serie);

  void clear() => series.clear();
  void sort() => series.sort((a, b) => a.reps!.compareTo(b.reps!));
  void shuffle() => series.shuffle();

  void swap(int index1, int index2) {
    TemplateSerie tmp = series[index1];
    series[index1] = series[index2];
    series[index2] = tmp;
  }


}

class ExecBloc extends ExerciceBloc<ExecSerie> {
  ExecBloc({
    super.exId,
    super.permNotes,
    this.restTime,
    this.blocIntensity,
    this.notes,
    required this.series,
  });

  // bool done;
  String?
      notes; // temporary notes that will be showed from one seance to the other
  int? restTime; // Rest time at the end of the bloc
  double? blocIntensity; // Intensity of the bloc
  List<ExecSerie> series = [];
  // @override
  // operator [](int index) => series[index];

  // @override
  // operator []=(int index, ExecSerie value) => execSeries[index] = value;

  ExecSerie get last => (series.isNotEmpty) ? series.last : ExecSerie();
  ExecSerie get first => (series.isNotEmpty) ? series.first : ExecSerie();

  List<int?> get timeList => series.map((e) => e.time).toList();
  List<double?> get intensityList => series.map((e) => e.intensity).toList();

  bool get allDone => series.every((element) => element.done);

  bool get anyDone => series.any((element) => element.done);

  get intensity {
    double res = 0;
    int count = 0;
    if (blocIntensity != null) 
    {
      return blocIntensity;
      } else {
    for (var serie in series) 
    {
      if (serie.intensity != null){
        res += serie.intensity!;
        count++;
      }
    }
    return (count != 0) ? res / count : null;
    }
  }


  @override
  ExecBloc copy() => ExecBloc(
        series: series.map((e) => (e.copy())).toList(),
        exId: exId,
        restTime: restTime,
        blocIntensity: blocIntensity,
        permNotes: permNotes,
        notes: notes,
      );

  ExecBloc.fromJson(dynamic jsonMap)
      : restTime = jsonMap["restTime"],
        blocIntensity = jsonMap["blocIntensity"],
        notes = jsonMap["notes"],
        series = List<ExecSerie>.from(jsonMap["series"]?.map((e) => ExecSerie.fromJson(e)) ?? [])
           ,
        super.fromJson(jsonMap);

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      "restTime": restTime,
      "blocIntensity": blocIntensity,
      "notes": notes,
      "series": series.map((e) => e.toJson()).toList(),
    });

  @override
  String toString() {
    String res = "";
    if (exId != null) res += "exId: $exId ";
    if (series.isNotEmpty) res += "series: $series ";
    if (restTime != null) res += "restTime: $restTime ";
    if (blocIntensity != null) res += "blocIntensity: $blocIntensity ";
    if (permNotes != null) res += "permNotes: $permNotes ";
    if (notes != null) res += "notes: $notes ";
    if (allDone) res += "done";
    return res;
  }

  operator [](int index) => series[index];
  operator []=(int index, ExecSerie value) => series[index] = value;

  List<int?> get repsList => series.map((e) => e.reps).toList();
  List<double?> get weightList => series.map((e) => e.weight).toList();
  List<double?> get restTimeList => series.map((e) => e.restTime).toList();
  int indexOf(ExecSerie serie) => series.indexOf(serie);

  get isEmpty => series.isEmpty;
  get isNotEmpty => series.isNotEmpty;
  int get length => series.length;

  void add(ExecSerie serie) => series.add(serie);
  void remove(ExecSerie serie) => series.remove(serie);

  void removeLast() => series.removeLast();

  void removeAt(int index) => series.removeAt(index);
  void insert(int index, ExecSerie serie) => series.insert(index, serie);

  void clear() => series.clear();
  void sort() => series.sort((a, b) => a.reps!.compareTo(b.reps!));
  void shuffle() => series.shuffle();

  void swap(int index1, int index2) {
    ExecSerie tmp = series[index1];
    series[index1] = series[index2];
    series[index2] = tmp;
  }

}