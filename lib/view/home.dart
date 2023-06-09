

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sporta/models/profil.dart';
import 'package:sporta/models/history.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../models/quest.dart';

// Define a model for Quest

class QuestCard extends StatelessWidget {
  final Quest quest;

  QuestCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Text(quest.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(quest.desc),
            SizedBox(height: 10),
            Text('Reward: ${quest.rewards.map((e) => e.toString()).join(', ')}'),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: quest.progress,
              semanticsLabel: 'Quest Progress',
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            Text('${(quest.progress * 100).round()}% complete'),
          ],
        ),
      ),
    );
  }
}



class EnergyJauge extends StatelessWidget {
  const EnergyJauge({
    super.key,
    required this.energy,
    required this.energyMax,
  });

  final double energy;
  final double energyMax;

  Color getColor(double energy, double energyMax) {
    final double ratio = energy / energyMax;
    if (ratio < 0.1) {
      return Colors.red;
    } else if (ratio < 0.5) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SfLinearGauge(
      minimum: 0,
      maximum: energyMax+0.5,
      showTicks: false,
      showLabels: false,
      // showAxisTrack: false,
      axisTrackStyle: const LinearAxisTrackStyle(
        thickness: 25,
        borderWidth: 3,
        edgeStyle: LinearEdgeStyle.bothCurve,
        borderColor:Colors.blueGrey,
        color: Colors.transparent ),
      barPointers: <LinearBarPointer>[
        LinearBarPointer(
          value: energy+0.5,
          thickness: 26,
          borderWidth: 2,
          borderColor: energy>2.5 ? Colors.yellowAccent :Colors.transparent,
          color: getColor(energy, energyMax),
          edgeStyle: LinearEdgeStyle.bothCurve,
          // position: LinearElementPosition.outside,
        ),
      ],
    );
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

    return Consumer2<Profil,HistoryModel>(
      builder: (context,profil,history,child) =>
        Scaffold(
          appBar: AppBar(
            title: Text('Salut ${profil.pseudo} !'),
          ),
          body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Spacer(flex: 1,),
                  const Expanded(
                    flex : 1,
                    child: Text("Niveau")),
                  Expanded(
                    flex:1,
                    child:
                    SizedBox(height : MediaQuery.of(context).size.height*0.1,
                    child:
                  LevelWidget(level: profil.level!, xp: profil.xp))),
                  const Spacer(flex: 1,),
                  Expanded(
                    flex : 3,
                    child:EnergyJauge(
                  energy: profil.energy,
                   energyMax: profil.energyMax)),
                  const Spacer(flex: 1,)]
                ),
                
                // Spacer(flex: 1,),

                Expanded(child : Row(
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

                Text(
                  'Your level is ${profil.level}',
                ),
                Text(
                  'Your xp is ${profil.xp}',
                ),

                Text(
                  'Your energy is ${profil.energy} / ${profil.energyMax}',
                ),
                Text(
                  'You have ${history.length} seances in your history',
                ),
                const Spacer(flex: 1,)
              ],
            ),
        ),

    );
  }
}