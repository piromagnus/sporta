import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'package:sporta/models/profil.dart';
import 'package:sporta/models/muscle.dart';




class MuscleLevelWidget extends StatelessWidget {

 const MuscleLevelWidget({
    super.key,
    required this.xp,
  });

  final int xp;

  


  double getAngle(int xp) {
    final int level = xpToLevel(xp);
    final int xpLevel = xp - xpToLevel(level-1);
    final int xpNextLevel = xpToLevel(level)-xpToLevel(level-1);
    final double angle = xpLevel / xpNextLevel * 360 + 91;
    print("$xp $xpLevel $xpNextLevel  $angle");
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
              thickness: 5,
              // dashArray: <double>[8, 10]),
          )
        ),
        RadialAxis(
            showTicks: false,
            showLabels: false,
            startAngle: 90,
            endAngle: getAngle(xp),
            radiusFactor: 1,
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                  // angle: 90,
                  horizontalAlignment: GaugeAlignment.near,
                  verticalAlignment: GaugeAlignment.center,
                  widget: Text('${xpToLevel(xp)}',
                      style: const TextStyle(
                          // fontStyle: FontStyle.italic,
                          // fontFamily: 'Times',
                          fontWeight: FontWeight.bold,
                          fontSize: 15)))
            ],
            axisLineStyle: AxisLineStyle(
              color : Theme.of(context).colorScheme.primary,
                // color: Color(0xFF00A8B5),
                // gradient: SweepGradient(
                //     colors: <Color>[Color(0xFF06974A), Color(0xFFF2E41F)],
                //     stops: <double>[0, 0.95]),
                thickness: 6,
            ))
      ],
    );
  }
}

class MuscleTile extends StatelessWidget {
  const MuscleTile({super.key, required this.muscle,this.poped=false,this.showGroup=false});
    final Muscle? muscle;
    final bool poped;
    final bool showGroup;
  @override
  Widget build(BuildContext context) {
    // build a tile with the name of the muscle and the description
    if (muscle == null) {return Container();}
    else {
    return 
    SizedBox(
      // width: MediaQuery.of(context).size.width*.25,
      child: 
    ListTile(
      title: Text(muscle!.name, textAlign: TextAlign.center,),
      subtitle: showGroup ? Text("Groupe : ${muscle!.group.strName}") : null,
      onTap: () { if (poped) {Navigator.of(context).pop("muscleView");}
        showDialog(context: context, builder: ((context) => 
        Dialog(
          child: MuscleView(muscle: muscle!)
          )
      ) 
    );}
    ));
  }
  }
}


class MuscleView extends StatelessWidget{
  const MuscleView({super.key, required this.muscle});
  final Muscle muscle;
  @override
  Widget build(BuildContext context) {
    BodyModel body = context.read<BodyModel>();
    return Container(
      margin: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width*.9,
      height: MediaQuery.of(context).size.height*.9,
      child: Column(
        children: [
          Text(muscle.name,
          textAlign: TextAlign.center,
          style:const TextStyle(fontSize: 35)),  
          // const Spacer(),
          Text(muscle.group.strName,style:const TextStyle(fontSize: 20)),
          const Spacer(),
          Row(children: [
            Expanded(flex: 2, child:  Image.asset(muscle.path ?? 'assets/body.png', 
                height: MediaQuery.of(context).size.height*0.4 ,)),
            Expanded(flex: 3, child: Container(margin:const EdgeInsets.all(20),child:Text(muscle.desc,softWrap: true,)))
            ]),
            const Spacer(),
            const Text("Antagoniste : "),
          SizedBox(
            height: MediaQuery.of(context).size.height*0.25,
            child: ListView(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: 
              muscle.antagonistId.map((e) => MuscleTile(muscle : body.muscles[e],showGroup: true,poped: true,)).toList())),
          const Spacer(),
          // Text(e.origin),
          // Text(e.insertion),
          // Text(e.innervation),
          // Text(e.vascularisation),
          // Text(e.image),
          // Text(e.video),
          // Text(e.exercices.toString()),
          // Text("Exercices : "),
          // Expanded(child: 
          //   ListView.builder(
          //     itemCount: widget.muscle.exercices.length,
          //     itemBuilder: (context, index) {
          //       return ListTile(
          //         title: Text(widget.muscle.exercices[index].name),
          //         subtitle: Text(widget.muscle.exercices[index].desc),
          //         onTap: () => showDialog(context: context, builder: ((context) => 
          //           Dialog(
          //             child: ExerciceView(exercice: widget.muscle.exercices[index])
          //             )
          //         ) 
          //       )
          //       );
          //     }
          //   )
          // )
        ],
      ),

    );
  }
}



  
class GroupMuscleCard extends StatelessWidget{
  const GroupMuscleCard({super.key, required this.body, required this.group});
  final BodyModel body;
  final MuscleGroup group;
  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.all(2),
      child: Card(child : 
        Padding(padding: EdgeInsets.all(5),
        child: 
        Column(children: [
          Expanded(child :Row(
            children :[ 
              Expanded(flex: 2, child : Image.asset("assets/icons/${group.strName}_color.png")),
              // Container(
              //   decoration: BoxDecoration(
              //     shape: BoxShape.circle,
              //     color: Theme.of(context).primaryColor),
              //     padding: const EdgeInsets.all(5),
              //   child : 
              //     Text("${context.select((Profil value) => value.musclesLevel![group])}",
              //     style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              //     textAlign: TextAlign.center,))),
              // const Spacer(),
              Expanded(flex : 7,child : Text(group.strName,
              textAlign: TextAlign.center,
              style:const TextStyle(fontSize: 20))),
              // const Spacer(),
               Expanded(
                flex : 2,
                child : 
                MuscleLevelWidget(
                  xp : context.select((Profil value) => value.musclesLevel![group.strName]!)
                  )),
              ])),
          // Text("Muscles : "),
          Expanded(
            flex : 3,
            child: 
            ListView.builder(
              itemCount: body.musclesByGroup[group]!.length,
              itemBuilder: (context, index) {
                return MuscleTile(muscle: body.musclesByGroup[group]![index]);
               }
             )
           )
        ],)
      ),
    ));
  }
}


class GroupMuscleView extends StatelessWidget {
   const GroupMuscleView({super.key, required this.body});
    final BodyModel body;
  @override
  Widget build(BuildContext context) {

    return GridView.count(
      // maxCrossAxisExtent: MediaQuery.of(context).size.width*.4,
      crossAxisCount: 2,
      padding: const EdgeInsets.all(4),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: body.
          musclesByGroup.keys.map((e) => 
            GroupMuscleCard(body: body, group: e)).toList());
  }
}



class MusclePage extends StatelessWidget {
  const MusclePage({super.key, required this.body});
  final BodyModel body;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Muscles"),
      ),
      body: Center(child: 
      Column(children: [
        // listView of widget.muscles whih contains name and desc
        SizedBox(
          height: MediaQuery.of(context).size.height*.7,
          width: MediaQuery.of(context).size.width*.9,
          child:
          GroupMuscleView(body: body)
          ),
          ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: ((context) => const Dialog(
                    child: MuscleFormCreation()
                  )
                  )
                  );
              },
              child: const Text('Ajouter un muscle'),
            ),
      ]
      ),
    ));
  }
}


class MuscleFormCreation extends StatefulWidget {
  const MuscleFormCreation({super.key});

  @override
  State<MuscleFormCreation> createState() => _MuscleFormCreationState();
}

class _MuscleFormCreationState extends State<MuscleFormCreation> {


  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _idController = TextEditingController();
  // final _groupController = TextEditingController();
  MuscleGroup? _group;
  final _antagonistIdList = <String>[];
  Muscle? _currentMucle;



  @override
  Widget build(BuildContext context) {
    //build a form for creating the the Muscle object
    //with a text field for the name, desc,id with TextController
    return Form(
        key: _formKey,
        child: Column(children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            }
          ),
          TextFormField(
            controller: _idController,
            decoration: const InputDecoration(labelText: 'iD'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            }
          ),
          TextFormField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'Description'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            }
          ),
          TextFormField(
            controller: _idController,
            decoration: const InputDecoration(labelText: 'Id'),
            keyboardType: TextInputType.number,
            // validator: (value) {
            //   if (value == null || value.isEmpty) {
            //     return 'Please enter some text';
            //   }
            //   return null;
            // }
          ),
          
          
          // TextFormField(
          //   controller: _groupController,
          //   decoration: const InputDecoration(labelText: 'Group'),
          //   // validator: (value) {
          //   //   if (value == null || value.isEmpty) {
          //   //     return 'Please enter some text';
          //   //   }
          //   //   return null;
          //   // }
          // ),
          
        //DropdownButtonFormField for selecting group
        DropdownButtonFormField(
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Group'),
          onChanged: (value){if (value!=null) setState(() =>_group = value);},
          value: _group,
          validator: (value) => value == null ? 'Please select a group' : null,
          items: [
            for (var group in MuscleGroup.values)//context.read<BodyModel>().musclesByGroup.keys.toSet())
              DropdownMenuItem(
                value: group,
                child: Text(group.strName),
              ),
          ],
        ),

        const Text("Antagonist Muscles"),

        //List view of muscles in antagonistIdList  
        ListView.separated(
          itemBuilder: (context, index) => ListTile(
            title: Text(context.read<BodyModel>().muscles[_antagonistIdList[index]]!.name),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                _antagonistIdList.removeAt(index);
                _currentMucle =(_antagonistIdList.isNotEmpty) ? context.read<BodyModel>().muscles[_antagonistIdList.last] : null;

                });
              },
            ),
          ),
          separatorBuilder: (context, index) => const Divider(),
          shrinkWrap: true,
          itemCount: _antagonistIdList.length,
        ),
         
              
        //Add button for adding a muscle to the antagonistIdList       
         DropdownButtonFormField(
          isExpanded: true,
          value: _currentMucle,
          decoration: const InputDecoration(labelText: 'Add antagonist muscles'),
          items: [
            for (var muscle in context.read<BodyModel>().muscles.values)
              DropdownMenuItem(
                value: muscle,
                child: Text(muscle.name),
              ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _currentMucle = value;
                _antagonistIdList.add(_currentMucle!.id);
              });
            }
          },
        ),

          ElevatedButton(
            onPressed: () {
              BodyModel body = context.read<BodyModel>();
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing Data')),
                );
                Muscle muscle = Muscle(
                  name: _nameController.text,
                  desc: _descController.text,
                  group : _group!,
                  id: _idController.text,
                  muscle: "Autre", //TODO : modifier ça.
                  antagonistId: _antagonistIdList,
                );
                body.addMuscle(muscle);
                _nameController.clear();
                _descController.clear();
                _idController.clear();
                Navigator.pop(context,muscle);
              }
            },
            child: const Text('Submit'),
          )
        ])
    );
  }
}