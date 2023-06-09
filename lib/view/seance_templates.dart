import 'package:flutter/material.dart';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:diacritic/diacritic.dart';
import 'package:provider/provider.dart';


import 'package:sporta/models/history.dart';
import 'package:sporta/models/exercice_db.dart';
import 'package:sporta/models/muscle.dart';
import 'package:sporta/models/seance.dart';
import 'package:sporta/models/series.dart';
import 'package:sporta/models/blocs.dart';
import 'package:sporta/models/current_seance.dart';

import 'package:sporta/widgets/dialog.dart';
import 'package:sporta/view/exercices.dart';
import 'package:sporta/widgets/text.dart';





class TemplateSerieTile extends StatefulWidget {
  const TemplateSerieTile({
    super.key,
    // required this.onChanged,
    required this.serieInd,
    required this.seance,
    required this.blocInd,
    this.lastSerie,
    this.predictions,
    this.predMode=false,
    });


  // final Function(Serie) onChanged;
  final ExecSerie? lastSerie;
  final TemplateSerie? predictions;
  final CurrentTemplateSeance seance;
  // final TextEditingController weightC;
  final int blocInd;
  final int serieInd;
  final bool predMode;


  @override
  State<TemplateSerieTile> createState() => _TemplateSerieTileState();
}

class _TemplateSerieTileState extends State<TemplateSerieTile> {
  
  late CurrentTemplateSeance _seance = widget.seance;
  late TemplateBloc _bloc = _seance.blocs[widget.blocInd];
  late TemplateSerie _serie = _bloc.series[widget.serieInd];
  late String? _weight = _serie.weight?.toStringAsFixed(0);
  late int? _reps = initReps();
  Duration _rest = const Duration(seconds: 0);


  //TODO : gérer les séries d'échauffement, les séries ratées.

  @override
  void initState() {
    super.initState();
    _seance = widget.seance;
    _bloc = _seance.blocs[widget.blocInd];
    _serie = _bloc.series[widget.serieInd];
    _reps = initReps();
    _rest = Duration(milliseconds: _serie.restTime?.toInt() ?? 0);
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
    ExerciceDB exDB = context.read<ExerciceDB>();
    Exercice? ex;
    try {
       ex = _bloc.exId!=null ? exDB.allExs[_bloc.exId!]: null;}
       catch (e) {
        print("exId null");}
    _seance = widget.seance;
    _bloc = _seance.blocs[widget.blocInd];
    _serie = _bloc.series[widget.serieInd];
    _weight = _serie.weight?.toStringAsFixed(0);
    _reps = initReps();
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    // selectedColor: Colors.green,
    // selected: _done,
    // selectedTileColor: Colors.lightGreenAccent,
    title : Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
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
        // const Text("kg"),
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

    ],),

    );
  }
}


class ExBlocView extends StatefulWidget {
  const ExBlocView({super.key,
    required this.exercices,
    required this.menu,
    required this.seance,
    required this.blocInd,
    });


  final void Function(CurrentTemplateSeance, TemplateBloc, String) menu;
  final ExerciceDB exercices;
  final CurrentTemplateSeance seance;
  final int blocInd;

  @override
  State<ExBlocView> createState() => _ExBlocViewState();
}

class _ExBlocViewState extends State<ExBlocView> {
  
  // late ExBloc _currentBloc;
  Exercice? _currentExercice;
  late CurrentTemplateSeance seance;
  late int blocInd;
  final _nameC = TextEditingController();
  final _permNotesC = TextEditingController();
  final GlobalKey _ddKey = GlobalKey();
  final List<String> _choices = [
    "Supprimer",
    "Dupliquer",
    "Voir l'exercice",
    "Réorganiser",
     ];

  @override
  void initState() {
    super.initState();
    blocInd=widget.blocInd;
    seance = widget.seance;
    _currentExercice = widget.exercices.getExById(widget.seance[blocInd].exId);
    _nameC.text = _currentExercice?.name ?? "";
    _permNotesC.text = widget.seance[blocInd].permNotes ?? "";
  }


  void menuOnClick(String choice) {
    setState(() => widget.menu(seance, widget.seance[blocInd], choice));
  }


  @override
  Widget build(BuildContext context) {
    blocInd=widget.blocInd;
    return ExpansionTile(
      initiallyExpanded: true,
      controlAffinity: ListTileControlAffinity.leading,
      
      title:Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children : [
        Expanded(child: DropdownSearch<Exercice>(
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
            elevation: 16,
            //backgroundColor: Color.fromARGB(57, 244, 67, 54),
            shape: OutlineInputBorder(),
          )                 
        ),
          selectedItem: _currentExercice,
          )),
          // const Spacer(),
          PopupMenuButton(
            onSelected: menuOnClick,
            icon: const Icon(Icons.more_vert_rounded), 
            itemBuilder: 
              ((context) => _choices.map((e) 
                  => PopupMenuItem(value: e, child: Text(e))).toList())
            )


      ]),
     //TODO passer en vert quand tous le bloc est fait
      children: [
        NotesField(
          hintText: "Notes permanentes de l'exercice",
          notesC: _permNotesC,
          onChanged: (value) => setState(() {
           seance[blocInd].permNotes =  value;
         })),
         Padding(padding: const EdgeInsets.symmetric(vertical: 10),
         child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text("Masse (kg)"), const Text("Reps"),Container()],))
            ]..addAll(
              seance[blocInd].series.map<Row>((e) =>
              Row(children: [
                Expanded(child: 
                  TemplateSerieTile(
                    seance:seance,
                    blocInd : blocInd,
                    // weightC: TextEditingController(text: e.weight?.toStringAsFixed(0) ?? ""),
                    serieInd: seance[blocInd].indexOf(e),
                    )),
                IconButton(
                  onPressed: () {
                    setState(() {
                    seance[blocInd].remove(e);
                    });},
                  icon: const Icon(Icons.delete_rounded))
              ],)))
          ..add(
        ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children : [
        ElevatedButton(
          onPressed: (){ seance.addSerie(seance[blocInd],
           seance[blocInd].last.copy());
           setState(() {});},
                      // Ajout automatique des valeurs de la dernière série ? 
          child: const Icon(Icons.add)),
        ElevatedButton(
          onPressed: () => setState(() {
            if (seance[blocInd].isNotEmpty) {
            seance[blocInd].removeLast();}}), 
          child: const Icon(Icons.remove)),
        ]))
    );
  }
}


class TemplateCreatorPage extends StatefulWidget {
  //Create and modify a template

  const TemplateCreatorPage({
    super.key,
    required this.history, 
    required this.exercices, 
    required this.body,
    this.initial,
    });

  final HistoryModel history;
  final ExerciceDB exercices;
  final BodyModel body;
  final TemplateTrackedSeance? initial;

  @override
  State<TemplateCreatorPage> createState() => _TemplateCreatorPageState();
}

class _TemplateCreatorPageState extends State<TemplateCreatorPage> {
  

  final _nameC = TextEditingController();
  final _permNotesC = TextEditingController();

  final Map<TemplateBloc,GlobalKey> _blocKeys = {};

  SeanceType? _type;
  late TemplateTrackedSeance _currentSeance;
  late TemplateTrackedSeance initialSeance;
  void blocMenu(CurrentTemplateSeance seance, TemplateBloc bloc, String choice) {
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
        var state = _blocKeys[bloc]!.currentState! as _ExBlocViewState;
        var ddstate = state._ddKey.currentState! as DropdownSearchState;
        ddstate.openDropDownSearch();
        });
        
    } else if (choice == "Réorganiser") {
      //TODO
    }
  }

  @override
  initState() {
    super.initState();
    if (widget.initial != null) {//Modification
      _currentSeance = widget.initial!;
    } else { // Creation
      _currentSeance = context.read<CurrentTemplateSeance>().data.copy();
    }
    
    _nameC.text = _currentSeance.name ?? "";
    _permNotesC.text = _currentSeance.permNotes?? "";
    // _notesC.text = _currentSeance.notes ?? "";
    _type = _currentSeance.type;
    // _intensity = _currentSeance.intensity?.toDouble() ?? 1;
    
  }


  @override
  Widget build(BuildContext context) {
    return Consumer2<CurrentTemplateSeance,SeanceDB>(builder: (context, currentSeance,seanceDB, child) =>
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


            // Navigator.pop(context);},
          icon: const Icon(Icons.arrow_back_rounded)),
        title: 
          TextFormField(
            controller: _nameC,
            onChanged: (value) => currentSeance.name = _nameC.text,
            decoration: const InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: "Nom de la séance",
              border: OutlineInputBorder(),
            )),
        actions: [
            IconButton(onPressed: () {
            var saved = currentSeance.data.copy();
            saved.complete = true;
            if (widget.initial !=null) {
              int ind = seanceDB.indexOf(widget.initial!);
              seanceDB.replace(ind,saved);
            }
            else {
              seanceDB.add(saved);
            }
            currentSeance.clear();
            Navigator.pop(context);
          }, icon: const Icon(Icons.save_rounded)),

          PopupMenuButton(icon: const Icon(Icons.more_vert_rounded),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "Effacer",
                child: Text("Tout effacer")),
                const PopupMenuItem(
                value: "New Save",
                child: Text("Sauvegarder un nouveau modèle")),
            ],
            onSelected: (value) => setState(() {
              if (value == "Effacer") {
                currentSeance.clear();
              }
              else if (value == "New Save"){
                var saved = currentSeance.data.copy();
                saved.complete = true;
                seanceDB.add(saved);
                // if (widget.initial !=null) seanceDB.remove(widget.initial!);
                currentSeance.clear();
                Navigator.pop(context);
              }
            }),
          )
          ],
      ),
     
      body:    
      Container(margin: const EdgeInsets.all(20),
        // padding: const EdgeInsets.all(50),
        child:
      ListView(children: [
         Column(children: [
          // Row(children : [
          // Expanded(
          //     flex : 3,
          //     child: 
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
          // ),
          // const Spacer(flex: 1,),
          //TODO en faire un menu qui s'ouvre
          // const Text("Intensité de la séance : "),
          // Expanded(
          //   flex : 5,
          //   child: SizedBox(
          //       height: MediaQuery.of(context).size.height * 0.15,
          //       child:
          //       IntensitySlider(
          //         sliderHeight: 20,
          //     intensity: _intensity,
          //     onChanged: ((value) => setState((){ _intensity = value; 
          //     currentSeance.intensity = value;})),
          //   ))),
          // ]),

          // const Text("Notes permanentes : "), //TODO : modifiable qu'avec un bouton de modif
          NotesField(
          hintText: "Notes permanentes de la séance",
          notesC: _permNotesC,
          onChanged: (value) => setState(() {
           currentSeance.permNotes =  value;
         })),
          
          // const Text("Notes : "), //TODO : modifiable tout le temps ou alors que à la fin ? 
          // TextField(
          //   decoration: const InputDecoration(
          //     hintText: "Notes",
          //     border: OutlineInputBorder(),
          //   ),
          //   controller: _notesC,
          //   onChanged: (value) => currentSeance.notes = _notesC.text,
          // ),
        ]),
          ListView.builder(
            shrinkWrap: true,
            itemCount:  currentSeance.length,
            itemBuilder: (BuildContext context, int index) {
              _blocKeys.putIfAbsent(currentSeance[index], () => GlobalKey());
              return ExBlocView(
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
                 currentSeance.addExBloc(TemplateBloc(series: [TemplateSerie()]));
              });
            },
            child: const Text("Ajouter un exercice"),
          ),
          ElevatedButton(
          onPressed: () => null, //Multiselector
          child: const Text("Ajouter plusieurs exercices"))]),
          //const Icon(Icons.grid_view)),
         SizedBox(height: MediaQuery.of(context).size.height * 0.2,),

        ],),)
    )));
  }
}