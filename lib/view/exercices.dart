
import 'package:flutter/material.dart';
import 'package:sporta/models/exercice_db.dart';
import 'package:sporta/models/muscle.dart';
import 'package:provider/provider.dart';
import 'package:sporta/view/muscles.dart';
import 'package:sporta/models/requirement.dart';
import 'package:awesome_rating/awesome_rating.dart';



void showExercice(int? id, BuildContext context, onClick) {
  // Function that shows a dialog with the details of an exercice
  final ExerciceDB exDB = context.read<ExerciceDB>();

  if (id==null) {
    showDialog(
      context: context,
      builder: ((context) => AlertDialog(
        content: Text("Sélectionner un exercice pour voir les détails."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onClick();
            },
            child: const Text("OK"),
          )
        ],
      ))
    );

  } else {
  final Exercice ex = exDB.getExById(id)!;
  showDialog(
    context: context,
    builder: ((context) => 
      Dialog(
        child: ExerciceView(exercice: ex),
        )
    )  
  );
  }

}

class ExercicePage extends StatelessWidget {
  // Page with all the exercices from the Database
  const ExercicePage({super.key,required this.body, required this.exDB});

  final BodyModel body;
  final ExerciceDB exDB;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exercices"),
      ),
      body: Center(child: 
      Column(children: [
        // listView of widget.muscles whih contains name and desc
        SizedBox(
          height: MediaQuery.of(context).size.height*.7,
          width: MediaQuery.of(context).size.width*.9,
          child:
          GroupExView(exDB: exDB)
          ),
          ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: ((context) => Dialog(
                    child: CreateBodyExerciceForm(body: body),
                  )
                  )
                  );
              },
              child: const Text('Ajouter un exercice'),
            ),
      ]
      ),
    ));
  }
}


class GroupExView extends StatelessWidget {
  // The Grid view of the exercices by group
  const GroupExView({super.key, required this.exDB});

  final ExerciceDB exDB;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      child: GridView.count(
      // maxCrossAxisExtent: MediaQuery.of(context).size.width*.4,
      crossAxisCount: 3,
      padding: const EdgeInsets.all(4),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: exDB.
          allExsByGroup.keys.map((e) => GroupExCard(exDB: exDB, group: e)).toList()),
    );
  }
}


// class GroupExCard extends StatelessWidget {
//   const GroupExCard({super.key,required this.exDB, required this.group});

//   final ExerciceDB exDB;
//   final String group;


//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Card(
//         child: Column(children: [
//           Expanded(child : Text(group,style:const TextStyle(fontSize: 20))),
//           Expanded(
//             flex : 2,
//             child: 
//             ListView.builder(
//               itemCount: exDB.allExsByGroup[group]!.length,
//               itemBuilder: (context, index) {
//                 return ExerciceTile(exercice: exDB.allExsByGroup[group]![index]);
//                }
//              )
//            )
//         ],)
//       ),
//     );
//   }
// }

class GroupExCard extends StatelessWidget {
  // the card of the group of exercices
  const GroupExCard({super.key,required this.exDB, required this.group});
  final ExerciceDB exDB;
  final String group;

  @override
  Widget build(BuildContext context) {
    double avDiff = (exDB.
              allExsByGroup[group]
              !.fold(0, (previousValue, element) => previousValue + element.difficulty)*10 /
               exDB.allExsByGroup[group]!.length).roundToDouble()/10;
    return Container(
      padding: const EdgeInsets.all(2),
      child: ElevatedButton(
        onPressed : (() => Navigator.push(context, 
            MaterialPageRoute(builder: (context) => GroupExPage(exDB: exDB, group: group)))),
        child:  Column(children : [
                Expanded(child: Text("$group \n(${exDB.allExsByGroup[group]!.length} exs)")),
                Expanded(child : AwesomeStarRating(rating: avDiff,
                            color: Colors.black,
                            borderColor: Colors.black,
                            size: 20 )),
        ])// \n\nDiff : \n$avDiff / 5 "),
       
      )
    );
  }
}
class GroupExPage extends StatelessWidget {
  const GroupExPage({super.key, required this.exDB, required this.group});
  final ExerciceDB exDB;
  final String group;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(group),
      ),
      body: Center(child:
      Column(children: [
        // listView of widget.muscles whih contains name and desc
        SizedBox(
          height: MediaQuery.of(context).size.height*.7,
          width: MediaQuery.of(context).size.width*.9,
          child:
          ListView.builder(
            itemCount: exDB.allExsByGroup[group]!.length,
            itemBuilder: (context, index) {
              return ExerciceTile(exercice: exDB.allExsByGroup[group]![index]);
             }
           )
          ),
          // ElevatedButton(
          //     onPressed: () {
          //       showDialog(
          //         context: context,
          //         builder: ((context) => Dialog(
          //           child: CreateBodyExerciceForm(body: body),
          //         )
          //         )
          //         );
          //     },
          //     child: Text('Ajouter un exercice'),
          //   ),
      ]
      ),
    ));
  }
}



class ExerciceTile extends StatelessWidget {
  // The simple exercice tile
  const ExerciceTile({super.key, required this.exercice});
  final Exercice exercice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      child: ListTile(
        title: Text(exercice.name),
        subtitle: AwesomeStarRating(rating: exercice.difficulty.toDouble(),),
        //Text("Difficulté : ${exercice.difficulty} / 5"),
        onTap: () => showDialog(context: context, builder: ((context) => 
          Dialog(
            child: ExerciceView(exercice: exercice)
            )
        ) 
      )
      ),
    );
  }
}

class ExerciceView extends StatelessWidget {
  //The view of the exercice details
  const ExerciceView({super.key,required this.exercice});
  final Exercice exercice;

  @override
  Widget build(BuildContext context) {
    Map<String, Muscle> muscles = context.select((BodyModel body) => body.muscles);
    return 
    Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child : Text(exercice.name,style:
          const TextStyle(fontSize: 25))),
          // const Spacer(),
          Expanded(
            
            child : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: [
            AwesomeStarRating(rating: exercice.difficulty.toDouble(),),
            Text("Type :  ${exercice.type.strName}",)])), // Difficulté :  ${exercice.difficulty} / 5\n
          // Expanded(child: Text("Type :  ${exercice.type.strName}")),
          // const Spacer(),
          const Expanded(child: Text("Description :",style: TextStyle(fontSize: 20),),),
          Expanded(flex : 2, child : SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child:Text(exercice.desc))),
          // const Spacer(),
          const Expanded(child: Padding(padding:EdgeInsets.all(10) ,
          child :Text("Muscles primaires: ", style: TextStyle(fontSize: 20,overflow: TextOverflow.ellipsis),))),
          Expanded(
            flex : 2, 
            // height: MediaQuery.of(context).size.height*.2,
            child: ListView(
              children: 
              exercice.primaryMusclesId
                ?.map((e) => MuscleTile(muscle: muscles[e])).toList()??[]
            ,)),
          const Expanded(child : Padding(padding: EdgeInsets.all(10) ,
          child :Text("Muscles secondaires : ", style: TextStyle(fontSize: 20)))),
          Expanded(
            flex : 2,
            // height: MediaQuery.of(context).size.height*.2,
            child: ListView(
              // clipBehavior: Clip.antiAlias,
              children: 
              exercice.secondaryMusclesId
                ?.map((e) => MuscleTile(muscle: muscles[e])).toList()??[]
            ,)),  


          // Expanded(child : Text("Equipements : " + exercice.equipements.toString())),
          // Expanded(child : Text("Type : " + exercice.type.toString())),
          
        ],)
    );
  }
}


class CreateBodyExerciceForm extends StatefulWidget {
  const CreateBodyExerciceForm({super.key, required this.body, this.initial});

  final Exercice? initial;
  final BodyModel body;

  @override
  State<CreateBodyExerciceForm> createState() => _CreateBodyExerciceFormState();
}

class _CreateBodyExerciceFormState extends State<CreateBodyExerciceForm> {
  


  
  //BodyExercice? result;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _iconPathController = TextEditingController();
  final _imgPathController = TextEditingController();
  final _groupController = TextEditingController();
  bool _locked = false;
  late List<String> _primaryMuscles;
  late List<String> _secondaryMuscles;
  late List<Muscle> _primaryMusclesList;
  late List<Muscle> _secondaryMusclesList;
  //late List<Muscle> _musclesList;
  late String _selectedGroup;

  @override
  void initState() {
      super.initState();
    _nameController.text=widget.initial?.name ?? '';
    _descController.text=widget.initial?.desc ?? '';
    _iconPathController.text=widget.initial?.iconPath ?? '';
    _imgPathController.text=widget.initial?.imgPath ?? '';
    _primaryMuscles=widget.initial?.primaryMusclesId ?? <String>[];
    _primaryMusclesList= _primaryMuscles.map((e) => widget.body.muscles[e]!).toList();
    //(_primaryMuscles.keys.isEmpty) ? [null] : _primaryMuscles.keys.toList();
    _secondaryMuscles=widget.initial?.secondaryMusclesId ?? [];
    _secondaryMusclesList= _secondaryMuscles.map((e) => widget.body.muscles[e]!).toList();
    _locked=widget.initial?.locked ?? false;
    _selectedGroup=widget.initial?.group ?? "";
   
  }
  @override
  Widget build(BuildContext context) {
     //build a form for creating the object result
      //with a text field for the name, desc, iconPath, imgPath,
      //and a submit button
   return Form(
      key: _formKey,
      child: 
     
     ListView(children: [
        //Name
        TextFormField(
        controller: _nameController,
         decoration: const InputDecoration(labelText: 'Name'),
         validator: (value) {
           if (value == null || value.isEmpty) {
             return 'Please enter some text';
           }
           return null;
         },
       ),
        //Description
        TextFormField(
          maxLines:3,
          controller: _descController,
         decoration: const InputDecoration(labelText: 'Description'),
         validator: (value) {
           if (value == null || value.isEmpty) {
             return 'Please enter some text';
           }
           return null;
         },
       ),
        //Icon Path
        TextFormField(
          controller: _iconPathController,
         decoration: const InputDecoration(labelText: 'Icon Path'),
      //    validator: (value) {
      //      if (value == null || value.isEmpty) {
      //        return 'Please enter some text';
      //      }
      //      return null;
      //    },
       ),
       //Img Path
       TextFormField(
        controller: _imgPathController,
         decoration: const InputDecoration(labelText: 'Image Path'),
        //  validator: (value) {
        //    if (value == null || value.isEmpty) {
        //      return 'Please enter some text';
        //    }
        //    return null;
        //  },
       ),
       
      //Dropdown for group  //TODO create the BodyExerciceDB which contains all the exercice list BodyModel
      // DropdownButtonFormField(
      //   decoration: const InputDecoration(labelText: 'Group'),
      //   onChanged: (value){if (value!=null) setState(() => _selectedGroup=value);},
      //   value: (_selectedGroup.isEmpty) ? null : _selectedGroup,
      //   items: [
      //     for (var group in context.read<BodyExerciceDB>().groups)
      //       DropdownMenuItem(
      //         value: group,
      //         child: Text(group),
      //       )
      //   ],
      // ),

      const Text('Primary Muscles'),
      ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          shrinkWrap: true,
          itemCount: _primaryMusclesList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_primaryMusclesList[index].name ),
              //subtitle: Text(_primaryMusclesList[index].desc ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _primaryMusclesList.removeAt(index);
                  });
                },
              ),
            ) ;
          },
      ),

       DropdownButtonFormField(

      isExpanded: true,
       decoration: const InputDecoration(labelText: 'Primary Muscles'),
       onChanged: (value){if (value!=null) setState(() => _primaryMusclesList.add(value));},
       value: (_primaryMusclesList.isEmpty) ? null : _primaryMusclesList.last,
       items: [
          for (var muscle in context.read<BodyModel>().muscles.values)
            DropdownMenuItem(
              value: muscle,
              child: Text(muscle.name),
            ),
        ],
        ),
       
        //Secondary Muscles
        const Text("Secondary Muscles"),
        ListView.separated(
          
          separatorBuilder: (context, index) => const Divider(),
          shrinkWrap: true,
          itemCount: _secondaryMusclesList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_secondaryMusclesList[index].name ),
              //subtitle: Text(_secondaryMusclesList[index].desc),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _secondaryMusclesList.removeAt(index);
                  });
                },
              ),
            ) ;
          },
        ),
        DropdownButtonFormField(
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Secondary Muscles'),
        onChanged: (value){if (value!=null) setState(() => _secondaryMusclesList.add(value));},
        value: (_secondaryMusclesList.isEmpty) ? null : _secondaryMusclesList.last,
        items: [
          for (var muscle in context.read<BodyModel>().muscles.values)
            DropdownMenuItem(
              value: muscle,
              child: Text(muscle.name),
            ),
        ],
        ),

        ElevatedButton(
         onPressed: () {
           // Validate returns true if the form is valid, or false otherwise.
           if (_formKey.currentState!.validate()) {

              var ex = Exercice(
                id: 0,
                name: _nameController.text,
                difficulty: 1, //TODO modify difficulty with a slider
                desc: _descController.text,
                type: ExerciceType.body,
                iconPath: _iconPathController.text,
                imgPath: _imgPathController.text,
                primaryMusclesId: _primaryMusclesList.map((e) => e.id).toList(), 
                secondaryMusclesId: _secondaryMusclesList.map((e) => e.id).toList(),
                group: _groupController.text,
                variantes: <int>[],
                history: <int>[],
                locked: _locked,
                requirements: <Requirement>[],
                );


             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Processing Data')),
             );
           }
         },
        child : const Text('Submit'),
       )
     ],)  
  );
  }
}