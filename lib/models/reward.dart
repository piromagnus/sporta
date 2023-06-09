
import 'package:sporta/models/exercice_db.dart';

class Reward<T> {
  //TODO: y en a vraiment besoin ? On pourrait juste unlocked les exos, 
  // les challenges, gagner des gems.

  // The basic class for rewards
  
  //final T toDo; //What must be done to get the reward ?
  T result; //what you get as a reward

  Reward({required this.result});

  Reward.fromJson(Map<String,dynamic> jsonMap):
    result = jsonMap["result"];

  Map<String,dynamic> toJson() => {
    "result" : result,
  };


}

class ExerciceReward extends Reward<Exercice> {

    ExerciceReward({
      required super.result
      });
    
    void receive(){
      result.locked = false;
    }
}


class GemsReward extends Reward<int> {

    GemsReward({
      required super.result
      });
    
    void receive(){
    }
}

class XpReward extends Reward<int> {

    XpReward({
      required super.result
      });
    
    void receive(){
    }
}



