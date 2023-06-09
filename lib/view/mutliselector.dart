

import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

import '../models/exercice_db.dart';


// Types d'exercices
enum MuscleGroup {
  Shoulder,
  Chest,
  Back,
  Biceps,
  Triceps,
  Legs,
  Abs,
  Cardio,
  Stretching,
}

Map<MuscleGroup,String> muscleGroupToStringFr ={
  MuscleGroup.Shoulder : "Epaules",
  MuscleGroup.Chest : "Pectoraux",
  MuscleGroup.Back : "Dos",
  MuscleGroup.Biceps : "Biceps",
  MuscleGroup.Triceps : "Triceps",
  MuscleGroup.Legs : "Jambes",
  MuscleGroup.Abs : "Abdominaux",
  MuscleGroup.Cardio : "Cardio",
  MuscleGroup.Stretching : "Etirements",
};

class EmptyButton extends StatefulWidget {
  const EmptyButton({super.key,
      this.exercice,});


  final Exercice? exercice;

  @override
  State<EmptyButton> createState() => _EmptyButtonState();
}

class _EmptyButtonState extends State<EmptyButton> {

  bool isPressed =true;

  @override
  Widget build(BuildContext context) {


    Offset distance = isPressed ? Offset(10, 10) : Offset(12, 12);
    double blur = isPressed ? 5 : 5;

    return GestureDetector(
      onTap :() => setState(() => isPressed = !isPressed),
    
    child : Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.blueAccent,//.of(context).colorScheme.background,
              boxShadow: [
                BoxShadow(
                  offset: -distance,
                  blurRadius: blur,
                  color : Color.fromARGB(180, 255, 255, 255),
                  inset: true,
                ),
                BoxShadow(
                  offset: distance,
                  blurRadius: blur,
                  color: Color.fromARGB(220, 103, 105, 109),
                  inset: true,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Text("${widget.exercice?.group ?? " "}"),
              Icon(Icons.add)]),
          ));
  }
}





class FBSelector extends StatefulWidget {
  const FBSelector({super.key});

  @override
  State<FBSelector> createState() => _FBSelectorState();
}

class _FBSelectorState extends State<FBSelector> {
  @override
  Widget build(BuildContext context) {
    //the avatar in the middle 
    //and buttons on the sides for adding exercices for each group

    return Scaffold(
      appBar: AppBar(
        title: Text('Select your exercices'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
          
          Column(
            children : [
              EmptyButton()

            ]

          ),
          

          Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.width * 0.5,
                child: 
              Image(image : AssetImage('assets/body.png'))),
              
              // Text('Shoulder'),
              // Text('Exercices'),
              // Text('here'),
            ],
          ),
          
          Column(),
          
          ]
        ),
      ),

    );
  }
}