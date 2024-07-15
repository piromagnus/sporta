

import 'package:flutter/material.dart'hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

import 'dart:math';
import "package:provider/provider.dart";


import '../models/exercice_db.dart';
import '../models/blocs.dart';
import '../models/series.dart';
import '../models/muscle.dart';
import '../models/history.dart';
import 'package:sporta/models/current_seance.dart';

import 'package:sporta/view/seance_templates.dart';


class EmptyButton extends StatefulWidget {
  const EmptyButton({super.key,
      required this.muscle,
      required this.onTap});


  final List<MuscleGroup>? muscle;
  final VoidCallback onTap;

  @override
  State<EmptyButton> createState() => _EmptyButtonState();
}

class _EmptyButtonState extends State<EmptyButton> {

  bool isPressed =true;

  @override
  Widget build(BuildContext context) {

    double medWidth = MediaQuery.of(context).size.width*0.25;
    double medHeight = MediaQuery.of(context).size.height*0.3;
    medWidth = min(medWidth, medHeight);
    medHeight = min(medWidth, medHeight);

    double width = isPressed ? medWidth-10 : medWidth-15;
    double height = isPressed ? medHeight-10 : medHeight-15;

    Offset distance = isPressed ? Offset(10, 10) : Offset(15, 15);
    double blur = isPressed ? 5 : 5;

    return GestureDetector(
      onTapDown :(e) => setState(() {isPressed = !isPressed;}),
      onTapUp: (e) => setState(() => isPressed = !isPressed),
      onTap : () => widget.onTap(),
    
    child : 
    SizedBox(
      height: medHeight,
      width: medWidth,
      child:
          Stack(
            alignment: Alignment.center,
            fit : StackFit.loose,
            
            children : [
            Container(
              width: width,
              height : height,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,),
                // borderRadius: BorderRadius.circular(50)),
              // color : Colors.blue,  
              child : (widget.muscle !=null ) ? Row(children :  widget.muscle!.map((e) =>
                Expanded(child : Image(image : AssetImage("assets/icons/${e.strName}_color.png")))).toList())
                : Container()),
            Container(
            width: medWidth,
            height: medHeight,
            // foregroundDecoration: BoxDecoration(
            //   image : DecorationImage(
            //     image: AssetImage("assets/icons/${widget.muscle.strName}.png"),
            //     fit: BoxFit.fill,
            // )),
            // duration : const Duration(milliseconds: 500),
            // curve: Curves.easeIn,
            decoration: BoxDecoration(
              // backgroundBlendMode: BlendMode.darken,
              borderRadius: BorderRadius.circular(50),
              color : Colors.transparent,
              // color: Colors.blueAccent,//.of(context).colorScheme.background,
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
            child : Icon(Icons.add, size: 100,
            color: Colors.black54) //Theme.of(context).colorScheme.secondary,)
            ),
              

          ],
          )));
  }
}




class SelectExerciceDialog extends StatelessWidget {
  const SelectExerciceDialog({
    super.key,
    required this.exerciceDB,
    required this.muscleGroup,
    required this.onTap,
    this.initialExercice });

  final ExerciceDB exerciceDB;
  final Exercice? initialExercice;
  final List<MuscleGroup>? muscleGroup;
  final Function(Exercice?) onTap;
  @override
  Widget build(BuildContext context) {

    var body =context.watch<BodyModel>();
    List<Exercice> liste =[];
    if (muscleGroup != null) {
    for (var i in muscleGroup!) {
     liste.addAll(exerciceDB.getExercicesByMuscleGroup(body,i));
    }} 
    else {
      liste = exerciceDB.allExs;
    }
    //TODO sort by favorite + last used
    // List<Exercice> liste = exerciceDB.getExercicesByMuscleGroup(body,muscleGroup);
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
         (initialExercice != null) ?  
         ListTile(
          trailing: IconButton(icon: Icon(Icons.delete),
              onPressed: () { onTap(null);
                Navigator.pop(context);
              }),
          title: Text(initialExercice!.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,))
          : Container(),

          Divider(),
          SizedBox(height: MediaQuery.of(context).size.height*0.6,
          child : 
                  (liste.isNotEmpty) ? ListView.builder(
        itemCount: liste.length,
        itemBuilder: (context,index) =>
        ListTile(
          title: Text(liste[index].name,
          textAlign: TextAlign.center,),
          onTap: () {
            onTap(liste[index]);
            Navigator.pop(context);}),
        ) 
      : Text("No exercice found"),),

        ]));
  }
}

class ExerciceButton extends StatelessWidget {
  const ExerciceButton({
    super.key,
    required this.onPressed,
    required this.exercice,
  });

  final VoidCallback onPressed;
  final Exercice exercice;
  @override
  Widget build(BuildContext context) {
    double medWidth = MediaQuery.of(context).size.width*0.25;
    double medHeight = MediaQuery.of(context).size.height*0.3;
    medWidth = min(medWidth, medHeight);
    medHeight = min(medWidth, medHeight);
    return Container(
      height: medHeight,
      width: medWidth,
      color : Colors.transparent,
      child : 
    ElevatedButton(onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      shape: CircleBorder(),
      foregroundColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,

      elevation: 0,
      padding: EdgeInsets.all(0),
      ),
     child: Expanded(child : Card(
      margin: EdgeInsets.all(5),
      elevation: 20,
      shape : CircleBorder(),
      child: 
     Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      //TODO Icon
      Text(exercice.name,textAlign: TextAlign.center,)
      //TODO Icon du group musculaire en petit avec la difficulté
      ]),))));
  }
}



class FBSelector extends StatefulWidget {
  const FBSelector({super.key,
  this.exerciceDB,
  required this.type});

  final ExerciceDB? exerciceDB;
  final String type;

  @override
  State<FBSelector> createState() => _FBSelectorState();
}

class _FBSelectorState extends State<FBSelector> {


  List<List<MuscleGroup>> _leftMuscle= [
    [MuscleGroup.Shoulders,MuscleGroup.Chest],
    [MuscleGroup.Back,MuscleGroup.Arm]];

  List<List<MuscleGroup>> _rightMuscle= [
    [MuscleGroup.Legs,MuscleGroup.Hip],
    [MuscleGroup.Abs,MuscleGroup.Hip]];

  List<List<int>?> _bottomMuscle = [[0],[1],[2]];

  List<Exercice?> _leftExercice = [null,null];
  List<Exercice?> _rightExercice = [null,null];
  List<Exercice?> _bottomExercice = [null,null,null];



  @override
  Widget build(BuildContext context) {
    //the avatar in the middle 
    //and buttons on the sides for adding exercices for each group

    return Scaffold(
      appBar: AppBar(
        title: Text('Select your exercices'),
        actions: [
          IconButton(icon: Icon(Icons.check),
          onPressed: () {
            if (_leftExercice[0] != null && _leftExercice[1] != null 
            && _rightExercice[0] != null && _rightExercice[1] != null) {
              
              var currentSeance = context.read<CurrentExecSeance>();
              currentSeance
              ..addExBloc(
                ExecBloc(
                  exId: _leftExercice[0]!.id,
                  series: [ExecSerie()]
                  ))
                ..addExBloc(
                ExecBloc(
                  exId: _leftExercice[1]!.id,
                  series: [ExecSerie()]
                  ))
                ..addExBloc(
                ExecBloc(
                  exId: _rightExercice[0]!.id,
                  series: [ExecSerie()]
                  ))
                ..addExBloc(
                ExecBloc(
                  exId: _rightExercice[1]!.id,
                  series: [ExecSerie()]
                  ));
                  if (_bottomExercice[0] != null) {
                    currentSeance.addExBloc(
                      ExecBloc(
                        exId: _bottomExercice[0]!.id,
                        series: [ExecSerie()]
                        ));
                  }
                  if (_bottomExercice[1] != null) {
                    currentSeance.addExBloc(
                      ExecBloc(
                        exId: _bottomExercice[1]!.id,
                        series: [ExecSerie()]
                        ));
                  }
                  if (_bottomExercice[2] != null) {
                    currentSeance.addExBloc(
                      ExecBloc(
                        exId: _bottomExercice[2]!.id,
                        series: [ExecSerie()]
                        ));
                  }
              Navigator.pop(context);
            }
            else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: 
                Text(" Tu dois selectionner 4 exercices pour valider")));
            }
            // Navigator.pop(context);
          })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: 
        Column(children : [
        Expanded(
          flex : 4,
          child : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
          
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children : 
            _leftMuscle.map((e) {
              int index = _leftMuscle.indexOf(e);
                return (_leftExercice[index]== null)
                ? EmptyButton(
                muscle : e,
                onTap: ()=> showDialog(context: context, builder: (context) =>
                SelectExerciceDialog(
                  exerciceDB: widget.exerciceDB!,
                  muscleGroup: e,
                  onTap: (exercice) => setState(() => _leftExercice[index] = exercice),
                )),
              )
               :   ExerciceButton(
                exercice: _leftExercice[index]!,
                onPressed: () => showDialog(context: context, builder: (context) =>
                SelectExerciceDialog(
                  exerciceDB: widget.exerciceDB!,
                  muscleGroup: e,
                  initialExercice: _leftExercice[index],
                  onTap: (exercice) => setState(() => _rightExercice[index] = exercice),
                )),
              );}).toList()
              // _leftInd++;
          ),
          

          Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.width * 0.45,
                child: 
              Image(image : AssetImage('assets/body.png'))),
              
              // Text('Shoulder'),
              // Text('Exercices'),
              // Text('here'),
            ],
          ),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children : 
            _rightMuscle.map(
              (e) {
                int index = _rightMuscle.indexOf(e);
                // _rightInd++;
                 return (_rightExercice[index] == null)  
              ? EmptyButton(
                muscle : e,
                onTap: ()=> showDialog(context: context, builder: (context) =>
                SelectExerciceDialog(
                  exerciceDB: widget.exerciceDB!,
                  muscleGroup: e,
                  onTap: (exercice) => setState(() => _rightExercice[index] = exercice),
                )),
              ) 
              : ExerciceButton(
                exercice: _rightExercice[index]!,
                onPressed: ()=> showDialog(context: context, builder: (context) =>
                SelectExerciceDialog(
                  exerciceDB: widget.exerciceDB!,
                  muscleGroup: e,
                  initialExercice: _rightExercice[index]!,
                  onTap: (exercice) => setState(() => _rightExercice[index] = exercice),
                )),
              );}).toList()
          ),
          
          ]
        )),
        
        Expanded(
          flex : 1,
          child : Row (
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: 
        _bottomMuscle.map((e){

          int index = _bottomMuscle.indexOf(e);

          return (_bottomExercice[index] == null)  
              ? EmptyButton(
                muscle : null,
                onTap: ()=> showDialog(context: context, builder: (context) =>
                SelectExerciceDialog(
                  exerciceDB: widget.exerciceDB!,
                  muscleGroup: null,
                  onTap: (exercice) => setState(() => _bottomExercice[index] = exercice),
                )),
              ) 
              : ExerciceButton(
                exercice: _bottomExercice[index]!,
                onPressed: ()=> showDialog(context: context, builder: (context) =>
                SelectExerciceDialog(
                  exerciceDB: widget.exerciceDB!,
                  muscleGroup: null,
                  initialExercice: _bottomExercice[index]!,
                  onTap: (exercice) => setState(() => _bottomExercice[index] = exercice),
                )),
              );}).toList()
              )
        )

      ])),

    );
  }
}

class TemplateFBSelector extends StatefulWidget {
  const TemplateFBSelector({super.key,
  this.exerciceDB,
  required this.type});

  final ExerciceDB? exerciceDB;
  final String type;

  @override
  State<TemplateFBSelector> createState() => _TemplateFBSelectorState();
}

class _TemplateFBSelectorState extends State<TemplateFBSelector> {


  List<List<MuscleGroup>> _leftMuscle= [
    [MuscleGroup.Shoulders,MuscleGroup.Chest],
    [MuscleGroup.Back,MuscleGroup.Arm]];

  List<List<MuscleGroup>> _rightMuscle= [
    [MuscleGroup.Legs,MuscleGroup.Hip],
    [MuscleGroup.Abs,MuscleGroup.Hip]];

  List<List<int>?> _bottomMuscle = [[0],[1],[2]];

  List<Exercice?> _leftExercice = [null,null];
  List<Exercice?> _rightExercice = [null,null];
  List<Exercice?> _bottomExercice = [null,null,null];



  @override
  Widget build(BuildContext context) {
    //the avatar in the middle 
    //and buttons on the sides for adding exercices for each group

    return Scaffold(
      appBar: AppBar(
        title: Text('Select your exercices'),
        actions: [
          IconButton(icon: Icon(Icons.check),
          onPressed: () {
            if (_leftExercice[0] != null && _leftExercice[1] != null 
            && _rightExercice[0] != null && _rightExercice[1] != null) {
              
              var currentSeance = context.read<CurrentTemplateSeance>();
              currentSeance
              ..addExBloc(
                TemplateBloc(
                  exId: _leftExercice[0]!.id,
                  series: [TemplateSerie()]
                  ))
                ..addExBloc(
                TemplateBloc(
                  exId: _leftExercice[1]!.id,
                  series: [TemplateSerie()]
                  ))
                ..addExBloc(
                TemplateBloc(
                  exId: _rightExercice[0]!.id,
                  series: [TemplateSerie()]
                  ))
                ..addExBloc(
                TemplateBloc(
                  exId: _rightExercice[1]!.id,
                  series: [TemplateSerie()]
                  ));
                  if (_bottomExercice[0] != null) {
                    currentSeance.addExBloc(
                      TemplateBloc(
                        exId: _bottomExercice[0]!.id,
                        series: [TemplateSerie()]
                        ));
                  }
                  if (_bottomExercice[1] != null) {
                    currentSeance.addExBloc(
                      TemplateBloc(
                        exId: _bottomExercice[1]!.id,
                        series: [TemplateSerie()]
                        ));
                  }
                  if (_bottomExercice[2] != null) {
                    currentSeance.addExBloc(
                      TemplateBloc(
                        exId: _bottomExercice[2]!.id,
                        series: [TemplateSerie()]
                        ));
                  }
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                                builder: ((context) => 
                                Consumer3<HistoryModel,
                                        BodyModel, ExerciceDB>(
                                    builder: (context, history, body, exercices,
                                            child) =>
                                        TemplateCreatorPage(
                                            history: history,
                                            body: body,
                                            exercices: exercices)

                                            )))
                                            );
            }
            else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: 
                Text(" Tu dois selectionner 4 exercices pour valider")));
            }
            // Navigator.pop(context);
          })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: 
        Column(children : [
        Expanded(
          flex : 4,
          child : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
          
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children : 
            _leftMuscle.map((e) {
              int index = _leftMuscle.indexOf(e);
                return (_leftExercice[index]== null)
                ? EmptyButton(
                muscle : e,
                onTap: ()=> showDialog(context: context, builder: (context) =>
                SelectExerciceDialog(
                  exerciceDB: widget.exerciceDB!,
                  muscleGroup: e,
                  onTap: (exercice) => setState(() => _leftExercice[index] = exercice),
                )),
              )
               :   ExerciceButton(
                exercice: _leftExercice[index]!,
                onPressed: () => showDialog(context: context, builder: (context) =>
                SelectExerciceDialog(
                  exerciceDB: widget.exerciceDB!,
                  muscleGroup: e,
                  initialExercice: _leftExercice[index],
                  onTap: (exercice) => setState(() => _rightExercice[index] = exercice),
                )),
              );}).toList()
              // _leftInd++;
          ),
          

          Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.width * 0.45,
                child: 
              Image(image : AssetImage('assets/body.png'))),
              
              // Text('Shoulder'),
              // Text('Exercices'),
              // Text('here'),
            ],
          ),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children : 
            _rightMuscle.map(
              (e) {
                int index = _rightMuscle.indexOf(e);
                // _rightInd++;
                 return (_rightExercice[index] == null)  
              ? EmptyButton(
                muscle : e,
                onTap: ()=> showDialog(context: context, builder: (context) =>
                SelectExerciceDialog(
                  exerciceDB: widget.exerciceDB!,
                  muscleGroup: e,
                  onTap: (exercice) => setState(() => _rightExercice[index] = exercice),
                )),
              ) 
              : ExerciceButton(
                exercice: _rightExercice[index]!,
                onPressed: ()=> showDialog(context: context, builder: (context) =>
                SelectExerciceDialog(
                  exerciceDB: widget.exerciceDB!,
                  muscleGroup: e,
                  initialExercice: _rightExercice[index]!,
                  onTap: (exercice) => setState(() => _rightExercice[index] = exercice),
                )),
              );}).toList()
          ),
          
          ]
        )),
        
        Expanded(
          flex : 1,
          child : Row (
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: 
        _bottomMuscle.map((e){

          int index = _bottomMuscle.indexOf(e);

          return (_bottomExercice[index] == null)  
              ? EmptyButton(
                muscle : null,
                onTap: ()=> showDialog(context: context, builder: (context) =>
                SelectExerciceDialog(
                  exerciceDB: widget.exerciceDB!,
                  muscleGroup: null,
                  onTap: (exercice) => setState(() => _bottomExercice[index] = exercice),
                )),
              ) 
              : ExerciceButton(
                exercice: _bottomExercice[index]!,
                onPressed: ()=> showDialog(context: context, builder: (context) =>
                SelectExerciceDialog(
                  exerciceDB: widget.exerciceDB!,
                  muscleGroup: null,
                  initialExercice: _bottomExercice[index]!,
                  onTap: (exercice) => setState(() => _bottomExercice[index] = exercice),
                )),
              );}).toList()
              )
        )

      ])),

    );
  }
}