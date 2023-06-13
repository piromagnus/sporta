

enum RewardType {
  exercice("exercises"),
  gems("gems"),
  xp("xp"),
  coin("coins"),
  template("template"),
  premium("premium"),
  templateStyle("templateStyle"),
  other("other");

  final String strName;
  const RewardType(this.strName);

  static RewardType strToRewardType (String? str) {
    if (str == "exercises") {
      return RewardType.exercice;
    } else if (str == "gems") {
      return RewardType.gems;
    } else if (str == "xp") {
      return RewardType.xp;
    } else if (str == "coins") {
      return RewardType.coin;
    } else if (str == "template") {
      return RewardType.template;
    } else if (str == "premium") {
      return RewardType.premium;
    } else if (str == "templateStyle") {
      return RewardType.templateStyle;
    } else if (str == "other") {
      return RewardType.other;
    }
    else{
      throw Exception("Unknown reward type : $str");
    }
  }
}


class Reward<T> {
  //TODO: y en a vraiment besoin ? On pourrait juste unlocked les exos, 
  // les challenges, gagner des gems.

  // The basic class for rewards
  
  //final T toDo; //What must be done to get the reward ?
  T value; //what you get as a reward
  RewardType? type;

  Reward({
    required this.value,
    this.type});

  Reward.fromJson(Map<String,dynamic> jsonMap):
    type = RewardType.strToRewardType(jsonMap["type"]),
    value = jsonMap["value"];
    


  Map<String,dynamic> toJson() => {
    "value" : value,
    "type" : type?.strName ?? "Other",
  };

  Reward toRewardClass () {
    if (type == RewardType.exercice) {
      return ExerciceReward(value: value as int);
    } else if (type == RewardType.gems) {
      return GemsReward(value: value as int);
    } else if (type == RewardType.xp) {
      return XpReward(value: value as int);
    } else if (type == RewardType.coin) {
      return CoinReward(value: value as int);
    } else if (type == RewardType.template) {
      return TemplateReward(value: value as int);
    } else if (type == RewardType.premium) {
      return PremiumReward(value: value as int);
    } else if (type == RewardType.templateStyle) {
      return TemplateStyleReward(value: value as String);
    } else if (type == RewardType.other) {
      return OtherReward(value: value as String);
    }
    else{
      throw Exception("Unknown reward type : $type");
    }
  }
  @override
  String toString() => "$value ${type?.strName}";

}

class ExerciceReward extends Reward<int> {

    ExerciceReward({
      required super.value, //nombre d'exercice aléatoire à débloquer
      });


    @override
    String toString() => "$value ${value> 1 ? "nouveaux exercices" 
    : "nouvel exercice"}";
    

}


class GemsReward extends Reward<int> {

    GemsReward({ 
      required super.value //gems gagné
      }); 
    
    void receive(){
    }

    String toString() => "$value gemmes";
}

class XpReward extends Reward<int> {

    XpReward({
      required super.value //xp gagné
      });
    
    void receive(){
    }
    @override
    String toString() => "$value points d'expérience";
}


class CoinReward extends Reward<int> {

    CoinReward({
      required super.value //pièces
      });
    
    void receive(){
    }
    @override
    String toString() => "$value pièces";
}

class TemplateReward extends Reward<int> {

    TemplateReward({
      required super.value //nb template en plus
      });
    
    void receive(){
    }
    @override
    String toString() => "$value ${value > 1 ? "pages de Séance " : "page de Séance"}}";
}

class PremiumReward extends Reward<int> {

    PremiumReward({
      required super.value //nb de jour de premium
      });
    
    void receive(){
    }
    @override
    String toString() => "$value ${value > 1 ? "jours d'abonnement offerts" : "jour d'abonnement offert"}}";
}



class TemplateStyleReward extends Reward<String> {

    TemplateStyleReward({
      required super.value //le type de template
      });
    
    void receive(){
    }
    @override
    String toString() => "Le nouveau modèle de séance : $value";
}

class OtherReward extends Reward<String> {

    OtherReward({
      required super.value //Divers pour l'instant
      });
    
    void receive(){
    }
}
