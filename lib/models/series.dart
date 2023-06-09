// ---- //
// SERIE //
// ---- //

abstract class Serie {
  //basic class that contains the basic information et methods of a serie
  // can't be instanciated

  int? reps;
  double? weight;
  double? restTime;

  Serie({this.reps, this.weight, this.restTime});

  Serie copy();

  @override
  String toString() {
    String res = "";
    if (reps != null) res += "$reps reps ";
    if (weight != null) res += "$weight kg ";
    if (restTime != null) res += "$restTime s ";
    return res;
  }

  Serie.fromJson(dynamic jsonMap) {
    reps = jsonMap["reps"];
    weight = jsonMap["weight"];
    restTime = jsonMap["restTime"];
  }

  Map<String, dynamic> toJson() => {
        "reps": reps,
        "weight": weight,
        "restTime": restTime,
      };
}

class TemplateSerie extends Serie {
  TemplateSerie({
    super.reps,
    super.weight,
    super.restTime,
  });

  ExecSerie toExec() => ExecSerie(
        reps: reps,
        weight: weight,
        restTime: restTime,
        done: false,
      );

  @override
  TemplateSerie copy() => TemplateSerie(
        reps: reps,
        weight: weight,
        restTime: restTime,
      );

  TemplateSerie.fromJson(dynamic jsonMap) : super.fromJson(jsonMap);

  // Map<String,dynamic> toJson() => super.toJson();

  // @override
  // String toString() {
  //   String res = "";
  //   if (reps != null) res += "$reps reps ";
  //   if (weight != null) res += "$weight kg ";
  //   if (restTime != null) res += "$restTime s ";
  //   return res;
  // }
}

class ExecSerie extends Serie {
  ExecSerie({
    super.reps,
    super.weight,
    super.restTime,
    this.time,
    this.intensity,
    this.done = false,
  });

  double? intensity;
  int? time;
  bool done;

  TemplateSerie toTemplate() => TemplateSerie(
        reps: reps,
        weight: weight,
        restTime: restTime,
      );

  @override
  ExecSerie copy() => ExecSerie(
        reps: reps,
        weight: weight,
        time: time,
        restTime: restTime,
        intensity: intensity,
        done: done,
      );

  ExecSerie.fromJson(dynamic jsonMap)
      : done = jsonMap["done"] ?? false,
        time = jsonMap["time"],
        intensity = jsonMap["intensity"],
        super.fromJson(jsonMap);

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      "done": done,
      "time": time,
      "intensity": intensity,
    });

  @override
  String toString() {
    String res = "";
    if (reps != null) res += "$reps reps ";
    if (weight != null) res += "$weight kg ";
    if (time != null) res += "$time s ";
    if (restTime != null) res += "$restTime s ";
    if (intensity != null) res += "$intensity ";
    if (done) res += "done";
    return res;
  }
}
