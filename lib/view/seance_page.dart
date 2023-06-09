import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';

import 'package:sporta/models/exercice_db.dart';
import 'package:sporta/models/seance.dart';

import 'package:sporta/models/history.dart';

import 'package:sporta/models/muscle.dart';
import 'package:sporta/models/current_seance.dart';
import 'package:sporta/models/profil.dart';



import 'package:sporta/view/seance_templates.dart';
import 'package:sporta/view/seance_execution.dart';
import 'package:sporta/view/basicadd.dart';
import 'package:sporta/view/seance_view.dart';

format(Duration d) => d.toString().split('.').first.padLeft(8, "0");


class BasicSeanceCard extends StatelessWidget {
  const BasicSeanceCard({
    super.key,
    required this.element,
    required this.history,
     required this.onDelete,
     required this.onModify,});

  final BasicSeance element;
  final HistoryModel history;
  final onDelete;
  final onModify;

  

  @override
  Widget build(BuildContext context) {
     return Card(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
            color: element.complete ? Colors.greenAccent: Colors.orangeAccent,
            margin : const EdgeInsets.all(20),
            elevation: 4,
            child: ListTile(
            contentPadding: const EdgeInsets.all(20),
            title: Text(element.name ?? "No name"),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                IconButton(onPressed: onModify, 
                 icon: const Icon(Icons.edit_note)), // Gérer les différents types de séances
                IconButton(onPressed: 
                onDelete,
                 icon: const Icon(Icons.delete))],),
              subtitle: Column(
                children :[
                Text("Date : ${DateFormat('dd/MM/yyyy HH:mm').
                format(DateTime.fromMillisecondsSinceEpoch(element.date))}"),
                  Text("\nType de Séance : ${element.type!.strName}"),
                  Text("\nDurée : ${format(Duration(seconds: element.time ?? 0))}"), 
                  Text("\t Intensité : ${element.intensity}"),
                  element.complete ? Container() : const Text("\nSéance incomplète"),
                  ])
      )
      );
  }
}

class ExecSeanceCard extends StatelessWidget {
  const ExecSeanceCard({
    super.key,
    required this.seance,
    required this.history,
     required this.onDelete,
     required this.onModify,
     required this.onRun,});

  final ExecTrackedSeance seance;
  final HistoryModel history;
  final onDelete;
  final onModify;
  final onRun;

  

  @override
  Widget build(BuildContext context) {
     return Card(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
            color: seance.complete ? Colors.greenAccent: Colors.orangeAccent,
            margin : const EdgeInsets.all(20),
            elevation: 4,
            child: ListTile(
            onTap: seance.complete ? onRun : null,
            contentPadding: const EdgeInsets.all(20),
            title: Text(seance.name ?? "No name"),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                IconButton(onPressed: onModify, 
                 icon: const Icon(Icons.edit_note)), // Gérer les différents types de séances
                IconButton(onPressed: 
                onDelete,
                 icon: const Icon(Icons.delete))],),
              subtitle: Column(
                children :[
                Text("Date : ${DateFormat('dd/MM/yyyy HH:mm').
                format(DateTime.fromMillisecondsSinceEpoch(seance.date))}"),
                Text("Type de Séance : ${seance.type!.strName}\n"),
                 Text( seance.length>1 ? "${seance.length} exercices" 
                        : "${seance.length} exercice"),
                  Text("Volume total : ${seance.volume(
                    context.read<ExerciceDB>(),
                    context.select((Profil value) => value.weight))} kg"),
                  Text("${seance.reps} reps"),
                  
                  Text("\nDurée : ${format(Duration(seconds: seance.time ?? 0))}"), 
                  Text("\t Intensité : ${seance.intensity}"),
                  seance.complete ? Container() : const Text("\nSéance incomplète"),
                  ])
      )
      );
  }
}



class TemplateSeanceCard extends StatelessWidget {
  const TemplateSeanceCard({
    super.key,
    required this.seance,
    // required this.history,
     required this.onDelete,
     required this.onModify,
     required this.onRun,});

  final TemplateTrackedSeance seance;
  // final HistoryModel history;
  final onDelete;
  final onModify;
  final onRun;
  



  @override
  Widget build(BuildContext context) {
    ExerciceDB exDB = context.watch<ExerciceDB>();
    double weight = context.watch<Profil>().mesurements!.weight;

     return Card(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
            color: seance.complete ? Colors.greenAccent: Colors.orangeAccent,
            margin : const EdgeInsets.all(20),
            elevation: 4,
            child: ListTile(
            onTap: seance.complete ? onRun : null,
            contentPadding: const EdgeInsets.all(20),
            title: Text(seance.name ?? "No name"),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                IconButton(onPressed: onModify, 
                 icon: const Icon(Icons.edit_note)), // Gérer les différents types de séances
                IconButton(onPressed: 
                onDelete,
                 icon: const Icon(Icons.delete))],),
              subtitle: Column(
                children :[
                  Text( seance.length>1 ? "${seance.length} exercices" 
                        : "${seance.length} exercice"),
                  Text("Volume total : ${seance.volume(exDB,weight)} kg"),
                  Text("${seance.reps} reps"),

                                    // Text("Date : ${DateFormat('dd/MM/yyyy HH:mm').
                // format(DateTime.fromMillisecondsSinceEpoch(seance.date))}"),
                // Text("\nType de Séance : ${seance.type!.strName}"),
                // Text("\nDurée : ${format(Duration(seconds: seance.time!))}"), 
                // Text("\t Intensité : ${seance.intensity}"),
                  seance.complete
                   ? const Text("\nCliquer pour lancer la séance",
                        style: TextStyle(fontSize: 12),) 
                   : const Text("\n/!\\  Séance incomplète",
                        style: TextStyle(fontSize: 12)),
                  ])
      )
      );
  }


}


class SeancePage extends StatefulWidget {
  const SeancePage({super.key, required this.history, required this.seanceDB});
  final HistoryModel history;
  final SeanceDB seanceDB;
  @override
  State<SeancePage> createState() => _SeancePageState();
}

class _SeancePageState extends State<SeancePage> with SingleTickerProviderStateMixin{

  void modifyDialog(BuildContext context, BasicSeance seance )
  {
    showDialog(context: context, 
    builder: ((context) => Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular((20)))),
      // title: const Text(" ",
      //         textAlign: TextAlign.center,
      //         style: TextStyle(color: Colors.redAccent)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width*0.7,
        child: Container(padding:const EdgeInsets.all(20), 
                  child:BasicForm(history: widget.history,initial: seance,))
      ))));
  }
  
  void launchSeance(BuildContext context, TemplateTrackedSeance seance){
    ExerciceDB exDB = context.read<ExerciceDB>();
    BodyModel body = context.read<BodyModel>();
    context.read<CurrentExecSeance>().load(seance);
    Navigator.push(context, MaterialPageRoute(builder: (context) => ExecSeancePage(
                    history: widget.history,
                    exercices: exDB,
                    body: body,
                    initial: seance.toExec(),
                    // seanceDB: widget.seanceDB,
                    )));

  }
  

   void modifyTemplateDialog(BuildContext context, TemplateTrackedSeance seance ){
    ExerciceDB exercices = context.read<ExerciceDB>();
    BodyModel body = context.read<BodyModel>();

    context.read<CurrentTemplateSeance>().load(seance);
    //TODO demander si l'utilisateur veut reprendre là où il en était si actif = true

    Navigator.push(context, MaterialPageRoute(builder: (context) =>
     TemplateCreatorPage(
        exercices: exercices,
        body: body,
        history: widget.history,
        initial: seance,
        )));
   }


    late TabController _tabController;
    static const List<Tab> tabs = <Tab>[
          Tab(text: 'Modèles de Séances'),
          Tab(text: 'Séances effectuées')];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des Séances"),
        actions: [IconButton(onPressed: widget.history.reset, 
                            icon : const Icon(Icons.delete))],
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
        ),
      ),
      body: 
        TabBarView(
        controller: _tabController,
        children: tabs.map<Widget>((Tab tab) {
          if (tab.text=='Modèles de Séances') {
            return ListView(children: 
            widget.seanceDB.seances.map<Widget>(
              (element) => TemplateSeanceCard(

                seance: element,
                // history: widget.history,
                onRun: () => launchSeance(context, element),
                onDelete: () => setState(()=> widget.seanceDB.remove(element)),
                onModify: () => setState(() {
                      modifyTemplateDialog(context,element);}))
              ).toList());
            } else {
              return ListView(children: 
                widget.history.history.map<Widget>(
                  (element) {
                    if (element is BasicSeance) {
                      return BasicSeanceCard(
                      element: element,
                      history: widget.history,
                      onDelete: () => setState(()=> widget.history.removeItem(element)),
                      onModify: () => setState(() {
                            modifyDialog(context,element);}));
                            }
                    else if (element is ExecTrackedSeance) {
                       return ExecSeanceCard(
                      seance: element,
                      history: widget.history,
                      onRun: () => 
                      Navigator.push(context,
                       MaterialPageRoute(builder: 
                       (context) => SeanceView(
                        seance : element,
                        exDB : context.read<ExerciceDB>(),
                       ))),
                      onDelete: () => setState(()=> widget.history.removeItem(element)),
                      onModify: () => null,
                      // setState(() {
                      //       modifyDialog(context,element);}
                      //       )
                            ); 
                            
                      } else {
                        return ListTile(title :const Text("Error"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: 
                          () => setState(()=> widget.history.removeItem(element)),
                        )
                        );
                      } }
                  ).toList());

            }
          }).toList())

      


    );
  }
}