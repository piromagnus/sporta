

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sporta/models/profil.dart';
import 'package:sporta/models/history.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../models/quest.dart';
import 'graph_view.dart';

// Define a model for Quest


class QuestJauge extends StatelessWidget {
  const QuestJauge({
    super.key,
    required this.quests,
    this.height});

    final List<Quest> quests;
    final double? height;

  @override
  Widget build(BuildContext context) {
    

    int completeInd = 0;
    int unlockedInd =0;
    for (var i in quests) {
      if (i.generalState == QuestState.complete) {
        completeInd++;
      }
      if (i.generalState == QuestState.unlocked) {
        unlockedInd++;
      }
    }

    var reversedList = quests.reversed.toList();
    completeInd = reversedList.length - completeInd;
    unlockedInd = reversedList.length - unlockedInd;
    print(unlockedInd);
    print(completeInd);
    return Container(
      height : height ?? reversedList.length.toDouble()*75,
      width: 200,
      child : 
      // Expanded(child: 
    SfLinearGauge(
      orientation: LinearGaugeOrientation.vertical,
      minimum: 0,
      maximum: reversedList.length.toDouble()-1,
      showTicks: true,
      axisTrackStyle: LinearAxisTrackStyle(
            thickness: 8,
            color: Colors.grey[200],
          ),
      markerPointers: quests.map((e) => 
      LinearWidgetPointer(value: reversedList.indexOf(e).toDouble(),
      child: (e.generalState == QuestState.complete) 
      ? Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.greenAccent,
          shape: BoxShape.circle,
        ),
      ) 
      
      : (e.generalState == QuestState.unlocked)
      ? Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.yellowAccent,
          shape: BoxShape.circle,
        ),
      )

      : Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
      ) 
      ) 
      ).toList(),
      minorTicksPerInterval: 0,
      interval: 1,
     ranges: [
    //   LinearGaugeRange(
    //     startValue: 0,
    //     endValue: unlockedInd.toDouble(),
    //     color: Colors.transparent,
    //     startWidth: 10,
    //     endWidth: 10,
    //     position: LinearElementPosition.cross,
    //   ),
      LinearGaugeRange(
        startValue: unlockedInd.toDouble()-1,
        endValue: completeInd.toDouble(),
        color: Colors.yellowAccent,
        startWidth: 10,
        endWidth: 10,
        position : LinearElementPosition.cross
      ),
       LinearGaugeRange(
        startValue: completeInd.toDouble()-1,
        endValue: reversedList.length.toDouble()-1,
        color: Colors.greenAccent,
        startWidth: 10,
        endWidth: 10,
        position : LinearElementPosition.cross
      ),
     ],
      showLabels: false,
    )
    );
  }
}



class QuestCard extends StatefulWidget {
  const QuestCard({
    super.key,
  required this.quest
  });

  final Quest quest;
  @override
  State<QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard> {
  

    bool _isExpanded = false;

  Color getColor(Quest quest){
    Color donjonColor = Colors.red;
    Color donjonlockedColor = const Color.fromARGB(120, 244, 67, 54);
    Color queteColor = Colors.yellow;
    Color completeColor = Colors.green;
    Color lockedColor = const Color.fromARGB(120, 158, 158, 158);
    if (quest.type == QuestType.donjon){
      if (quest.generalState==QuestState.unlocked)
      {
        return donjonColor;
      }
      else {
        return donjonlockedColor;
      }
    }
    else {
      if (quest.generalState==QuestState.unlocked)
      {
        return queteColor;
      }
      else if (quest.generalState==QuestState.complete)
      {
        return completeColor;
      }
      else {
        return lockedColor;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Quest quest = widget.quest;
    return 
     Card(
      margin: EdgeInsets.symmetric(vertical:2, horizontal: 10),
      elevation: quest.generalState == QuestState.unlocked ?  10 : 0,
      color :getColor(quest),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: 
    ExpansionTile(
        title : (!_isExpanded) 
          ? Column( children : [
           Text(quest.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5,),
                LinearProgressIndicator(
                    value: quest.progress,
                    semanticsLabel: 'Quest Progress',
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green)),
                ])
            : Text(quest.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                color : Colors.black)),
          onExpansionChanged: (value) => setState(() => _isExpanded = value),

          children: <Widget>[
            Text(quest.description),
            SizedBox(height: 5),
            Text(
                'Récompenses: ${quest.rewards.map((e) => e.toString()).join(', ')}'),
            SizedBox(height: 5),
            LinearProgressIndicator(
              value: quest.progress,
              semanticsLabel: 'Quest Progress',
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            Text('${(quest.progress * 100).round()}% complete'),
            // Text ("Récompenses : ${quest.rewards.map((e) => e.toString()).join(', ')}"),
          ],
        ),
      ),
    );
  }
}

class QuestView extends StatelessWidget {
  const QuestView({
    super.key,
    required this.questDB});

  final QuestDB questDB;

  @override
  Widget build(BuildContext context) {
    
    List<GlobalKey> _keys = [];
    List<Quest> tutorialList=[];
    for (var i in questDB){
      if (i.type == QuestType.tutorial || i.type == QuestType.donjon){
        tutorialList.add(i);
      }
    }
    List<Widget> queteVis= [];
    for (var i in tutorialList) { 
      final _key = GlobalKey();
      queteVis.add(QuestCard(quest:i,
        key : _key,
        ));
      
     if (tutorialList.indexOf(i) != tutorialList.length-1) {
      _keys.add(_key);
      queteVis.add(const Divider( height: 5,color: Colors.transparent,));
     }
    }

    return  Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        image: DecorationImage(image : AssetImage("assets/bookBackground.jpg",
        ),
        fit : BoxFit.fill,
        ),
      ),
      height: MediaQuery.of(context).size.height*0.6,
      width: MediaQuery.of(context).size.width*0.9,
      child : 
      
      SingleChildScrollView(child :
      
      Row(children : [

        
        Expanded(
          flex : 1,
          child:
          QuestJauge(
            quests: tutorialList,
            height :  (_keys.isNotEmpty) ? _keys.map((e) => (e.currentContext !=null) ? 
            (e.currentContext?.findRenderObject() as RenderBox).size.height : 80.0)
            .reduce((a, b) => a + b + 5) : 0.0,
          ),
        ),

        Expanded(
          flex : 4,
          child : Column(
            children : queteVis)),
      
      ])));
  }
}



class EnergyJauge extends StatelessWidget {
  const EnergyJauge({
    super.key,
    this.energy = 3,
    this.energyMax = 3,
  });

  final double energy;
  final double energyMax;

  Color getColor(double energy, double energyMax) {
    final double ratio = energy / energyMax;
    if (ratio < 0.1) {
      return Colors.redAccent;
    } else if (ratio < 0.5) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      return SfLinearGauge(
      minimum: 0,
      maximum: energyMax,
      showTicks: false,
      showLabels: false,
      // showAxisTrack: false,
      axisTrackStyle: LinearAxisTrackStyle(
        thickness: 25,
        borderWidth: 3,
        edgeStyle: LinearEdgeStyle.bothCurve,
        borderColor:energy<0.3 ? Colors.red: Colors.blueGrey,
        color:   Colors.transparent ),
      barPointers: <LinearBarPointer>[
        LinearBarPointer(
          enableAnimation: false,
          // animationDuration: 10, //TODO : corriger le bug d'animation
          value: energy,
          thickness: 26,
          borderWidth: 2,
          borderColor: energy>2.5 ? Colors.yellowAccent :  Colors.transparent,
          color: getColor(energy, energyMax),
          edgeStyle: LinearEdgeStyle.bothCurve,
          // position: LinearElementPosition.outside,
        ),
      ],
    );} catch (e) {
      return Container();
    }
  }
}


class LevelWidget extends StatelessWidget {

  const LevelWidget({
    super.key,
    required this.level,
    required this.xp,
  });

  final int level;
  final int xp;
  

  double getAngle(int xp, int level) {
    final int xpLevel = xp - levelToXp(level-1);
    final int xpNextLevel = levelToXp(level)-levelToXp(level-1);
    final double angle = xpLevel / xpNextLevel * 350 + 100;
    print("$xp $level $xpLevel $xpNextLevel  $angle");
    return angle;
  }

  @override
  Widget build(BuildContext context) {
    return 
    SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          showTicks: false,
          showLabels: false,
          startAngle: 180,
          endAngle: 180,
          radiusFactor: 1,
          axisLineStyle: const AxisLineStyle(
              // Dash array not supported in web
              thickness: 10,
              // dashArray: <double>[8, 10]),
          )
        ),
        RadialAxis(
            showTicks: false,
            showLabels: false,
            startAngle: 90,
            endAngle: getAngle(xp, level),
            radiusFactor: 1,
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                  // angle: 90,
                  horizontalAlignment: GaugeAlignment.near,
                  verticalAlignment: GaugeAlignment.center,
                  widget: Text('$level',
                      style: const TextStyle(
                          // fontStyle: FontStyle.italic,
                          fontFamily: 'Times',
                          fontWeight: FontWeight.bold,
                          fontSize: 15)))
            ],
            axisLineStyle: const AxisLineStyle(
                color: Color(0xFF00A8B5),
                gradient: SweepGradient(
                    colors: <Color>[Color(0xFF06974A), Color(0xFFF2E41F)],
                    stops: <double>[0, 0.95]),
                thickness: 10,
            ))
      ],
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {

    return Consumer3<Profil,HistoryModel,QuestDB>(
      builder: (context,profil,history,questDB,child) =>
        Scaffold(
          appBar: AppBar(
            title: Row( children : [ 
              // const Expanded(
              //       flex : 1,
              //       child: Text("Niveau")),
                  Expanded(
                    flex:1,
                    child:
                    SizedBox(height : MediaQuery.of(context).size.height*0.07,
                    child:
                  Tooltip(message : "${profil.xp} XP \nProchain Niveau : ${levelToXp(xpToLevel(profil.xp))} XP",
                  child : LevelWidget(level: profil.level, xp: profil.xp)))),
                  const Spacer(flex: 1,),
                Expanded(
                    flex : 3,
                    child:
                      Tooltip(
                        message : "Energie  : ${profil.energy} / ${profil.energyMax}",
                        child : EnergyJauge(
                      energy: profil.energy,
                      energyMax: profil.energyMax))),

            //   Expanded(flex : 3,child : Text('${profil.pseudo}',
            // textAlign: TextAlign.center,)),
            const Spacer(flex: 1,),
            Padding(padding : EdgeInsets.all(7),
              child :  Text("${profil.coins}",)),
            Image.asset('assets/icons/coin.png',
              height: 30,width: 30,),
            const Spacer(flex: 1,),
             Padding(padding : EdgeInsets.all(5),
              child :  Text("${profil.gems}")),
            Image.asset('assets/icons/gem.png',
              height: 30,width: 30,),

              ],
          )),
          body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
              
                Expanded(child : 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [ElevatedButton(
                  onPressed: () => setState(() {
                    profil.xp+=1;
                  }),
                 child: Text("+1 XP")),
                 ElevatedButton(
                  onPressed: () => setState(() {
                    profil.resetLevel();
                  }),
                 child: Text("Reset XP")),
                 ElevatedButton(
                  onPressed: () => setState(() {
                    profil.energy++;
                  }),
                 child: Text("Energy +1")),
                 ElevatedButton(
                  onPressed: () => setState(() {
                    profil.energy--;
                  }),
                 child: Text("Energy -1")),])),
                
                ElevatedButton(
                  onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: 
                  (context) => TreeViewPage(
                    quests: context.read<QuestDB>(),
                  ))),
                 child: Text("Graph")),

                // Text(
                //   'Your level is ${profil.level}',
                // ),
                // Text(
                //   'Your xp is ${profil.xp}',
                // ),

                // Text(
                //   'Your energy is ${profil.energy} / ${profil.energyMax}',
                // ),
                // Text(
                //   'You have ${history.length} seances in your history',
                // ),
                // const Spacer(flex: 1,),
                QuestView(questDB: questDB)

              ],
            ),
        ),

    );
  }
}