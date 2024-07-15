import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:provider/provider.dart';

import '../models/quest.dart';
import 'graph_view.dart';



class QuestPage extends StatelessWidget {
  const QuestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quêtes"),
        actions: [
          GraphButton(),],
      ),
      body: QuestView(questDB: context.read<QuestDB>()),
    );
  }
}




class GraphButton extends StatelessWidget {
  const GraphButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
                  onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: 
                  (context) => TreeViewPage(
                    quests: context.read<QuestDB>(),
                  ))),
                 child: Text("Graph"));
  }
}



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
      padding: EdgeInsets.all(20),
      // margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        image: DecorationImage(image : AssetImage("assets/bookBackground.jpg",
        ),
        fit : BoxFit.fill,
        ),
      ),
      height: MediaQuery.of(context).size.height*0.95,
      // width: MediaQuery.of(context).size.width*0.9,
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


