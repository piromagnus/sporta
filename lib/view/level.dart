

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  required this.child});

  final int xp;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      // color: Colors.blue,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children : [
            Expanded(flex : 2,child : child),
            Expanded(child : Text(':')),
            Text('${xpToLevel(xp)} '),
            Expanded(flex: 3, child : XpJauge(xp:xp)),
            Text(
              ' ${xpToLevel(xp)+1}',
              textAlign: TextAlign.center,),
              
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
            
                for (var muscle in profil.musclesLevel!.keys)

                CaraTile(xp: profil.musclesLevel![muscle]!, 
                  child: Text('$muscle : ',
                        textAlign: TextAlign.center) //TODO : icons
                      ),
                    
              
                  CaraTile(xp: profil.attXp, child: const Icon(Icons.add)),
                  CaraTile(xp: profil.powerXp, child: const Icon(Icons.sports_mma)),
                  CaraTile(xp: profil.defXp, child: Icon(Icons.shield),),
               
                CaraTile(xp: profil.skillXp, child:       Icon(Icons.menu_book)),
               
                  
          ],
        ),
      ),

    ));
  }
}