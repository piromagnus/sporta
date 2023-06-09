import 'package:flutter/material.dart';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:diacritic/diacritic.dart';
import 'package:provider/provider.dart';



import 'package:sporta/widgets/slider.dart';
import 'package:sporta/widgets/dialog.dart';
import 'package:sporta/widgets/text.dart';

import 'package:sporta/models/exercice_db.dart';
import 'package:sporta/models/muscle.dart';
import 'package:sporta/models/seance.dart';
import 'package:sporta/models/series.dart';
import 'package:sporta/models/blocs.dart';
import 'package:sporta/models/current_seance.dart';
import 'package:sporta/models/history.dart';
import 'package:sporta/models/profil.dart';


import 'package:sporta/view/exercices.dart';
import 'mutliselector.dart';













class EndPage extends StatefulWidget {
  const EndPage({super.key,
  required this.onValidate});

  final Function onValidate;

  @override
  State<EndPage> createState() => _EndPageState();
}

class _EndPageState extends State<EndPage> {

  double _intensity = 1;
  SeanceType? _type;
  final _notesC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = SeanceType.values[0];
    _notesC.text = context.select((CurrentExecSeance value) => value.notes ?? "");
  }


  @override
  Widget build(BuildContext context) {
    ExerciceDB exDB = context.watch<ExerciceDB>();
    Profil profil = context.watch<Profil>();
    //Gérer les validations ou pas.

    return Consumer2<CurrentExecSeance,SeanceDB>(
      builder: (context, currentSeance, seanceDB, child) => Scaffold(
      appBar: AppBar(
        title: const Text("Fin de la séance"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              widget.onValidate();
              Navigator.pop(context);
            },
          ),],
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
          const Expanded(
            child: 
              Text("Bravo vous avez fini votre séance",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),),), 
              //TODO : Différentes messages en fonction de la séance
              Expanded(
                flex : 2,
              child: Text("Vous avez fait ${currentSeance.length} exercices différents"
               " avec un total de ${currentSeance.data.reps} reps"
               "\nVous avez soulevé ${currentSeance.data.volume(exDB,profil.mesurements!.weight)} kilos !!"
            " \n\nVous pouvez maintenant modifier le type de séance"
              " \net notez l'intensité ressenti lors de la séance",
              textAlign : TextAlign.center, ),
             ),
             const Spacer(flex: 1,),
             NotesField(
              labelText: "Notes de séance",
              hintText: "Commentaires sur la séance",
              notesC: _notesC,
              onChanged:(value) =>  currentSeance.notes = _notesC.text,
              ),
              //TODO Text("Vous avez brûlé ${currentSeance.data.calories} calories !!"),
          Expanded(
                  // flex : 3,
                  child: 
                  DropdownButton<SeanceType>(
                  
                value: _type,
                isExpanded: true,
                isDense: false,
                hint: const Text("Type de séance"),
                onChanged: (SeanceType? newValue) {
                  setState(() {
                    _type = newValue!;
                    currentSeance.type = newValue;
                  });
                },
                items: SeanceType.values.map((SeanceType value) {
                  return DropdownMenuItem<SeanceType>(
                    value: value,
                    child: Text(value.strName),
                  );
                }).toList(),
              ),
              ),
          const Spacer(flex: 1,),
          Expanded(
            //Si l'intensité par exercice ou par bloc est activé pas la peine.
                  flex : 2,
            child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
                child:
                IntensitySlider(
                  sliderHeight: 35,
                  intensity: _intensity,
                  onChanged: ((value) => setState((){ _intensity = value; 
                  currentSeance.intensity = value;})),
            ))
          ),
                const Spacer(flex: 1,),
                
        ]),
      ),
    ));
  }
}




class ExerciceSimpleTile extends StatelessWidget {
  const ExerciceSimpleTile({
    super.key,
    required this.exercice
    });

  final Exercice exercice;


  @override
  Widget build(BuildContext context) {
    return ListTile(
      title : Text(exercice.name));
  }
}


class ReorderPage extends StatefulWidget {
  const ReorderPage({
    super.key,
    required this.seance,
    required this.exDB
  });

  final ExecTrackedSeance seance;
  final ExerciceDB exDB;

  @override
  State<ReorderPage> createState() => _ReorderPageState();
}

class _ReorderPageState extends State<ReorderPage> {
  @override
  Widget build(BuildContext context) {
    int index=0;
    return Scaffold(
      appBar : AppBar(title : const Text("Reorder")),
      
      body : ReorderableListView(
      
      onReorder: (int oldIndex, int newIndex) {
            setState(() {
               if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
              final ExecBloc item = widget.seance.removeAt(oldIndex);
              widget.seance.insert(newIndex, item);
            });
            print(widget.seance.map((e) => e.exId).toList());
            },
            
      children: List<Widget>.from(widget.seance.map((ExecBloc bloc) {
        
        return ExerciceSimpleTile(
          key: Key("${index++}"),
          exercice: widget.exDB[bloc.exId],
        );
      })),             
    ));
  }
}


class ExecSerieTile extends StatefulWidget {
  const ExecSerieTile({
    super.key,
    // required this.onChanged,
    required this.serieInd,
    required this.seance,
    required this.blocInd,
    required this.onChanged,
    this.lastSerie,
    this.predictions,
    // this.done=false,
    this.predMode=false,
    this.showIntensity=false,
    });


  // final Function(Serie) onChanged;
  final Serie? lastSerie;
  final Serie? predictions;
  final CurrentExecSeance seance;
  // final TextEditingController weightC;
  final int blocInd;
  final int serieInd;
  final bool predMode;
  // final bool done;
  final bool showIntensity;
  final Function(bool) onChanged;


  @override
  State<ExecSerieTile> createState() => _ExecSerieTileState();
}

class _ExecSerieTileState extends State<ExecSerieTile> {
  
  late CurrentExecSeance _seance = widget.seance;
  late ExecBloc _bloc = _seance.blocs[widget.blocInd];
  late ExecSerie _serie = _bloc.series[widget.serieInd];
  late String? _weight = _serie.weight?.toStringAsFixed(0);
  late int? _reps = initReps();
  double? _intensity;
  Duration _rest = const Duration(seconds: 0);
  // late bool _done;


  //TODO : gérer les séries d'échauffement, les séries ratées.

  @override
  void initState() {
    super.initState();
    // _seance = widget.seance;
    // _bloc = _seance.blocs[widget.blocInd];
    // _serie = _bloc.series[widget.serieInd];
    // _reps = initReps();
    // _weightC.text = _serie.weight?.toStringAsFixed(0) ?? "";
    _intensity =_serie.intensity;
    _rest = Duration(milliseconds: _serie.restTime?.toInt() ?? 0);

    // _done = widget.done;
  }

  int? initReps() {
    if (_serie.reps !=null)
    {
      return _serie.reps;
    }
    else if (widget.predMode && widget.predictions != null && widget.predictions!.reps != null) 
    {        
      return widget.predictions!.reps;
    }
    else {
       return widget.lastSerie?.reps;
      }
  }
  String showWeight(Serie? serie) => serie?.weight?.toString() ?? "-";

  @override
  Widget build(BuildContext context) {
    
    Exercice? ex;
    try {
    _bloc.exId!=null 
        ? context.watch<ExerciceDB>().allExs[_bloc.exId!] 
        : null;}
     catch (e) {print(e);}
    _seance = widget.seance;
    _bloc = _seance.blocs[widget.blocInd];
    _serie = _bloc.series[widget.serieInd];
    _weight = _serie.weight?.toStringAsFixed(0);
    _reps = initReps();

    return CheckboxListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    selected: _serie.done,
    selectedTileColor: Colors.lightGreenAccent,
    title : Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // TODO : series Type ? 

        //Weight textField
        SizedBox(
          width: 50, 
          child: TextFormField( 
            //Modify the state just when the user tap outside the textfield 
            //to avoid rebuilding during the user is typing
            enabled: ex!=null && ex.type == ExerciceType.body ? false : true,
            onTapOutside: (event) => setState(() { 
              if (_weight!=null && _weight!.isNotEmpty){
              _seance.updateWeight(_bloc, _serie, double.parse(_weight!));
              }
              FocusScope.of(context).unfocus();
            }),
            // initialValue: _weight,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: widget.predMode 
                        ? showWeight(widget.predictions) 
                        : showWeight(widget.lastSerie), 
              border: const OutlineInputBorder(),
            ),
            controller: TextEditingController(text : _weight)
                ..selection=TextSelection.fromPosition(TextPosition(offset: _weight?.length ?? 0)), 
                //Put the cursor at the end
            onChanged: (value) { 
              _weight = value;
              },
          )
        ),
       // Reps dropwdown
      SizedBox(width: 75,
      child: DropdownButtonFormField(
        alignment: Alignment.center,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          ),
        isExpanded: true,
        value : _reps,
        items: [for (int i = 1; i < 100; i++) DropdownMenuItem( value: i, child: Text(i.toString()),)],
        onChanged: (value) => setState(() {
          _reps = value;
          _seance.updateReps(_bloc, _serie, _reps!);
        }),
        )
      ,),
      // Intensity button
      widget.showIntensity ? ElevatedButton(
        onPressed: () => 
          showModalBottomSheet(
            backgroundColor: Colors.transparent,
            anchorPoint: const Offset(-400, -400),
            context : context, 
            builder: ((context) => 
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child:
                IntensitySlider(
              intensity: _intensity,
              onChanged: ((value) => setState((){ _intensity = value;
                                _seance.updateIntensity(_bloc, _serie, _intensity!); })),
            )))),
        child :Text("${_intensity ?? 'Int'}") //Todo mettre un mode intensity par Série ou par Bloc
      ): Container(),

    ],),
     value: _serie.done,
      onChanged: (bool? value) => setState(() {
        _serie.done = value!;
        widget.onChanged(value);
      }),
    );
  }
}



class ExecExBlocView extends StatefulWidget {
  const ExecExBlocView({super.key,
    required this.exercices,
    required this.menu,
    required this.seance,
    required this.blocInd,
    this.showIntensity = true
    });


  final void Function(CurrentExecSeance, ExecBloc, String) menu;
  final ExerciceDB exercices;
  final CurrentExecSeance seance;
  final int blocInd;
  final bool showIntensity;
  

  @override
  State<ExecExBlocView> createState() => _ExecExBlocViewState();
}

class _ExecExBlocViewState extends State<ExecExBlocView> {
  
  // late ExBloc _currentBloc;
  Exercice? _currentExercice;
  late CurrentExecSeance seance;
  late int blocInd;
  
    //TODO mettre un radio button pour activité l'intensity par série.
    // TODO : gérer les prédictions et les séances précédantes.
    //TODO : affichage de l'historique des séances précédantes :
    // - soit .tous l'historique dans une dialog
    // - la dernière itération de l'exercice (ou de variantes) dans l'extension tile 
    // avec la date et les éventuelles équivalences entre exercices.
  final _nameC = TextEditingController();
  final _notesC = TextEditingController();
  final _permNotesC = TextEditingController();

  final GlobalKey _ddKey = GlobalKey();
  final List<String> _choices = [
    "Supprimer",
    "Dupliquer",
    "Voir l'exercice",
    "Réorganiser",
     ];

  bool _allDone= false;
  @override
  void initState() {
    super.initState();
    blocInd=widget.blocInd;
    seance = widget.seance;
    _currentExercice = widget.exercices.getExById(widget.seance[blocInd].exId);
    _nameC.text = _currentExercice?.name ?? "";
    _notesC.text = seance[blocInd].notes ?? "";
    _permNotesC.text = seance[blocInd].permNotes ?? "";
  }


  void menuOnClick(String choice) {
    setState(() => widget.menu(seance, widget.seance[blocInd], choice));
  }


  @override
  Widget build(BuildContext context) {
    blocInd=widget.blocInd;
    
    return ExpansionTile(
      backgroundColor: _allDone ?
         Colors.greenAccent[100] : null,
      initiallyExpanded: true,
      controlAffinity: ListTileControlAffinity.leading,
      //Exercice + menu button
      title:Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children : [
        Expanded(
          // Exercice Selection dropdown search
          child: DropdownSearch<Exercice>(

          key: _ddKey,
          onBeforePopupOpening: (ex) {
            _nameC.text="";
            return Future<bool>.value(true);},

          itemAsString: (item) => item.name,
          // clearButtonProps: const ClearButtonProps(
          //   color: Colors.red,
          // ),
          filterFn: (item, filter) => removeDiacritics(item.name.toLowerCase())
                          .startsWith(removeDiacritics(filter.toLowerCase())),
          items: widget.exercices.allExs,
            dropdownDecoratorProps: const  DropDownDecoratorProps(
              textAlignVertical: TextAlignVertical.center,
              textAlign: TextAlign.center,
            dropdownSearchDecoration: InputDecoration(
              // labelText: "Exercice",
              hintText: "Choisir un exercice",
              isCollapsed: true,
              ),
            ),
          onChanged: (value) => setState(() {
            _currentExercice = value;
            widget.seance.setExId(seance[blocInd], value!.id);
            _nameC.text = "";
          }),
          popupProps: PopupProps.menu(
            searchFieldProps: TextFieldProps(
              keyboardType: TextInputType.text,
              autofocus : true,
              controller: _nameC),
            isFilterOnline: true,
            showSearchBox: true,
            menuProps: const MenuProps(
              elevation: 0,
              backgroundColor: null,
              //backgroundColor: Color.fromARGB(57, 244, 67, 54),
              shape: null
            // OutlineInputBorder(),
          )                 
        ),
        dropdownButtonProps: const DropdownButtonProps(
          icon :  Icon(Icons.arrow_drop_down_rounded),
        ),
          selectedItem: _currentExercice,
          )),
          
          
          // Menu button
          PopupMenuButton(
            onSelected: menuOnClick,
            icon: const Icon(Icons.more_vert_rounded), 
            itemBuilder: 
              ((context) => _choices.map((e) 
                  => PopupMenuItem(value: e, child: Text(e))).toList())
            )


      ]),
      
      children: 
        [
          SizedBox(
            width: MediaQuery.of(context).size.width*.9,
            child: 
              PermNoteField(
                currentSeance: seance,
                //  seanceDB: seanceDB,
                  permNotesC: _permNotesC)),
          //Notes
          SizedBox(
            width: MediaQuery.of(context).size.width*.9,
            child:

          NotesField(
              hintText: "Notes",
              notesC: _notesC, 
              onChanged: (value) => seance[blocInd].notes = _notesC.text),
            ),
            Padding(padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:  [
                  const Text("Masse (kg)"),
                    const Text("Reps"),
                    const Text("Intensité"),
                      Container()],))
        ]..addAll(
              seance[blocInd].series.map<Row>((e) {
              return Row(children: [
                Expanded(child: 
                  //SerieTile for execution
                  ExecSerieTile(
                    onChanged: (checked) => setState(() {
                      seance.updateDone(seance[blocInd], e, checked);
                      _allDone = seance[blocInd].allDone;
                    }),
                    seance:seance,
                    blocInd : blocInd,
                    serieInd: seance[blocInd].indexOf(e),
                    showIntensity: widget.showIntensity,)),
                //Delete button
                IconButton(
                  onPressed: () {
                    setState(() {
                    seance[blocInd].remove(e);
                    });},
                  icon: const Icon(Icons.delete_rounded))
              ],
              );}
            )
          )..add(
        ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children : [
            ElevatedButton(
               // TODO :  Ajout automatique des valeurs de la dernière série ? 
              onPressed: (){ seance.addSerie(seance[blocInd],
              seance[blocInd].last.copy());
              setState(() {});},
              child: const Icon(Icons.add)),
            ElevatedButton(
              onPressed: () => setState(() {
                if (seance[blocInd].isNotEmpty) {
                seance[blocInd].removeLast();}}), 
              child: const Icon(Icons.remove)),
            ])
            )
    );
  }
}


// -------------------------------------------------- //
// ----------------- ExecSeancePage ----------------- //
// -------------------------------------------------- //



class ExecSeancePage extends StatefulWidget {
  //Create and modify a template

  const ExecSeancePage({
    super.key,
    required this.history, 
    required this.exercices, 
    required this.body,
    this.initial,
    });

  final HistoryModel history;
  final ExerciceDB exercices;
  final BodyModel body;
  final ExecTrackedSeance? initial;

  @override
  State<ExecSeancePage> createState() => _ExecSeancePageState();
}

class _ExecSeancePageState extends State<ExecSeancePage> {
  

  final _nameC = TextEditingController();
  final _permNotesC = TextEditingController();
  final _notesC = TextEditingController();

  final Map<ExecBloc,GlobalKey> _blocKeys = {};

  // SeanceType? _type;
  // double? _intensity;
  late ExecTrackedSeance _currentSeance;

  void blocMenu(CurrentExecSeance seance, ExecBloc bloc, String choice) {
    // remove bloc, duplicate it, move it, show exercice.
    if (choice == "Supprimer") {
      setState(() {
       seance.removeExBloc(bloc);
      });
    } else if (choice == "Dupliquer") {
      setState(() {
        var ind = seance.indexOf(bloc)+1;
         seance.insert(ind,bloc.copy());
      });
    } else if (choice == "Voir l'exercice") {
      showExercice(bloc.exId,context,
      () { //Open the dropdown
        var state = _blocKeys[bloc]!.currentState! as _ExecExBlocViewState;
        var ddstate = state._ddKey.currentState! as DropdownSearchState;
        ddstate.openDropDownSearch();
        });
        
    } else if (choice == "Réorganiser") {
      //show in a dialog the ReorderPage
      ExecTrackedSeance temp = seance.data.copy();
      showDialog(context: context, builder: (context) => 
      AlertDialog(
        content :
        ReorderPage(
          seance: temp,
          exDB: widget.exercices,
        ),
        actions: [
          TextButton(
            onPressed: () => 
              Navigator.pop(context),
            child: const Text("Annuler")),
          TextButton(onPressed: () {
            setState(() {
              seance.load(temp);
            });
            Navigator.pop(context);
          }, child: const Text("Valider")),
        ],
        )
      );
    }
  }


  void endSeance(CurrentExecSeance currentSeance){


    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Terminer la séance ?"),
        content: const Text("La séance sera ajoutée à l'historique."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler")),
          TextButton(
            onPressed: () {
              
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: 
              (context) => EndPage(
                onValidate : () {
                currentSeance.data.complete = true;
              widget.history.add(currentSeance.data.copy());
              if (widget.initial != null) widget.history.removeItem(widget.initial!);
              currentSeance.clear();
              })));
              },
            child: const Text("Valider")),
        ],
      )
    );

    
    // Navigator.pop(context);



  }




  @override
  initState() {
    super.initState();
    if (widget.initial != null) {//Modification
      _currentSeance = widget.initial!;
    } else { // Creation
       _currentSeance = context.read<CurrentExecSeance>().data;
    }
    _nameC.text = _currentSeance.name ?? "";
    _permNotesC.text = _currentSeance.permNotes ?? "";
    _notesC.text = _currentSeance.notes ?? "";
    // _type = _currentSeance.type;
    // _intensity = _currentSeance.intensity?.toDouble() ?? 1;
    
  }


  @override
  Widget build(BuildContext context) {
    return Consumer2<CurrentExecSeance,SeanceDB>(builder: (context, currentSeance,seanceDB, child) =>
      
      
      Form(child:
      Scaffold(
      
      appBar: AppBar(
       leading: IconButton(
          onPressed: (){ 
            showDialog(context: context, builder: (context) =>QuitDialog(
              message : "Voulez-vous quitter sans sauvegarder ?",
              onValidate: () {
                currentSeance.clear(); 
                // TODO : vérifier que c'est bien ce que je veux faire
                Navigator.pop(context);},
              )
            );},
          icon: const Icon(Icons.arrow_back)),
        title: TextFormField(
            controller: _nameC,
            onChanged: (value) => currentSeance.name = _nameC.text,
            decoration: const InputDecoration(
              fillColor: null,
              filled: true,
              hintText: "Nom de la séance",
              border: OutlineInputBorder(),
            )),
        actions: [
            ElevatedButton(onPressed: () {
              //TODO : dialog de fin, 
              //TODO : faire une validation de form pour être sur que tout est bien rempli.
            endSeance(currentSeance);
          }, child: const Text("Terminer")),

          // PopupMenuButton(icon: const Icon(Icons.more_vert_rounded),
          //   itemBuilder: (context) => [
          //     const PopupMenuItem(
          //       value: "Effacer",
          //       child: const Text("Tout effacer")),
          //   ],
          //   onSelected: (value) => setState(() {
          //     if (value == "Effacer") {
          //       currentSeance.clear();
          //     }
          //   }),
          // )
          ],
      ),      
      body: Container(margin: const EdgeInsets.all(20),
        // padding: const EdgeInsets.all(50),
        child:
          ListView(children: 
          [
            Column(children: 
            [

              //Notes permanentes
              PermNoteField(
                currentSeance: currentSeance,
                permNotesC: _permNotesC),  
  
              NotesField(
                labelText: "Notes de séance",
                hintText: "Comment se passe la séance ? ",
                notesC: _notesC, 
                onChanged: (value) => currentSeance.notes = _notesC.text)
    
            ]),
              ListView.builder(
                shrinkWrap: true,
                itemCount:  currentSeance.length,
                itemBuilder: (BuildContext context, int index) {
                  _blocKeys.putIfAbsent(currentSeance[index],
                    () => GlobalKey());
                  return ExecExBlocView(
                                    key: _blocKeys[currentSeance[index]],
                                    exercices: widget.exercices,
                                    menu: blocMenu,
                                    seance : currentSeance,
                                    blocInd : index);
                },
              ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentSeance.addExBloc(ExecBloc(series: [ExecSerie()]));
                  });
                },
                child: const Text("Ajouter un exercice"),
              ),
              ElevatedButton(
              onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => 
                FBSelector())
              ), //Multiselector
              child: const Text("Ajouter plusieurs exercices"))])//const Icon(Icons.grid_view)),

            ],),)
        )));
  }
}