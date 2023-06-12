

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sporta/models/muscle.dart';
import 'package:sporta/models/profil.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class XpJauge extends StatelessWidget {
  const XpJauge({super.key,
  required this.xp});

  final int xp;



  @override
  Widget build(BuildContext context) {
    final int level = xpToLevel(xp);
    final xpMax = levelToXp(level);
    return SfLinearGauge(

      minimum: 0,
      maximum: xpMax+0.5,
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
          value: xp+0.5,
          thickness: 26,
          borderWidth: 2,
          borderColor: xp/xpMax>0.8 ? Colors.yellowAccent :Colors.transparent,
          color: Colors.greenAccent,
          // shaderCallback: (value) => GradientShader(
          //           colors: <Color>[Colors.green,Colors.greenAccent],
          //           stops: <double>[0, 0.9]),
          edgeStyle: LinearEdgeStyle.bothCurve,
          // position: LinearElementPosition.outside,
        ),
      ],
    );
  }
}


class CaraTile extends StatelessWidget {
  const CaraTile({super.key,
  required this.xp,
  required this.child,
  required this.message});

  final int xp;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      // color: Colors.blue,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children : [
            Expanded(flex : 3,child : Tooltip(message : message ,child : child)),
            const Expanded(flex : 1, child : Text(':')),
            Expanded(
              flex : 3,
              child : Container(
              margin : const EdgeInsets.all(4),
              padding: const EdgeInsets.all(5),
              decoration : BoxDecoration(
                shape : BoxShape.circle,
                color : Theme.of(context).primaryColor
                // border: Border.all(
                //   color: Theme.of(context).primaryColor,
                //   width: 5,
                // ),
                // borderRadius: BorderRadius.circular(10),
              ),
              child : Text('${xpToLevel(xp)} ',
              style : TextStyle(fontSize: 20, color : Colors.white),
              textAlign: TextAlign.center,))),
            Expanded(flex: 5, child : XpJauge(xp:xp)),
            Expanded(child: Text(
              ' ${xpToLevel(xp)+1}',
              textAlign: TextAlign.center,)),
              
          ]
          // style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class LevelPage extends StatefulWidget {
  const LevelPage({super.key});

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Profil>(builder : (context,profil,child ) =>Scaffold(
      appBar: AppBar(
        title: const Text('Niveau'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            
              
                  CaraTile(xp: profil.attXp, 
                    message : "Attaque (Force)",
                    child: Image.asset("assets/icons/sword.png",
                      width: 30, height: 30,)),
                  CaraTile(xp: profil.powerXp, 
                    message : "Pouvoir (Masse Musculaire)",
                    child: Image.asset("assets/icons/strong.png",
                      width: 30, height: 30,)),
                  CaraTile(xp: profil.defXp,
                    message : "Défense (Endurance)",
                    child:Image.asset("assets/icons/shield.png",
                      width: 30, height: 30,),),
               
                CaraTile(xp: profil.skillXp, 
                  message : "Compétence (Connaissance)",
                  child:  Image.asset("assets/icons/book.png",
                    width: 30, height: 30,)),
               
                for (var muscle in MuscleGroup.values)

                CaraTile(xp: profil.musclesLevel![muscle.strName]!, 
                message : muscle.strName,
                  child: Image.asset("assets/icons/${muscle.strName}_color.png",
                      width: 30, height: 30,)
                      ),
                    
                  
          ],
        ),
      ),

    ));
  }
}