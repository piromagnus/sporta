
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sporta/models/profil.dart';
import 'package:sporta/models/blocs.dart';
import 'package:sporta/models/exercice_db.dart';
import 'package:sporta/models/seance.dart';

import 'package:sporta/view/exercices.dart';
import 'package:sporta/widgets/text.dart';




class SimpleExBlocView extends StatelessWidget {
  const SimpleExBlocView({
    super.key,
    required this.bloc,
    required this.exDB,
    });

  final ExecBloc bloc;
  final ExerciceDB exDB;

  @override
  Widget build(BuildContext context) {
    final Exercice exercice = exDB[bloc.exId];
    final bool showIntensity = bloc.series.every((element) => element.intensity!=null);
    
    return ListTile(
      // isThreeLine: true,
      leading: IconButton(
        onPressed: () => showDialog(
            context: context,
            builder: ((context) => 
              Dialog(
                child: ExerciceView(exercice: exercice),
                )
            )
          ),
        icon : const Icon(Icons.fitness_center)), //
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children : [
          Text(exercice.name,
              style: const TextStyle(fontWeight: FontWeight.bold,
              color: Colors.black),
              textAlign: TextAlign.center,),
              Text("Int : ${bloc.intensity ?? "N/A"}"),
            
              ]),
      subtitle: 
      Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: 
        [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              

            const Text ("Reps",style: TextStyle(fontWeight: FontWeight.bold,
            color: Colors.black)),
            const Text("Masse (kg)",style: TextStyle(fontWeight: FontWeight.bold,
            color: Colors.black)),
            showIntensity ? const Text("Intensité",style: TextStyle(fontWeight: FontWeight.bold,
            color: Colors.black)) :Container()],),
            const SizedBox(height: 7),
          ...bloc.series.map((e) => 
            e.done ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [Text("${e.reps}",
                style: const TextStyle(color: Colors.black)),
            Text("${e.weight ?? "Poids du corps" }",
            style: const TextStyle(color: Colors.black )),
            //?? context.select((Profil profil) => profil.weight)}"
            e.intensity!=null ? Text("${e.intensity} ",
            style: const TextStyle(color: Colors.black)) : Container(),
            ])
            : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [Text("${e.reps}",
                style: const TextStyle(color: Colors.grey)),
            Text("${e.weight ?? "Poids du corps" }",
            style: const TextStyle(color: Colors.grey)),
            //?? context.select((Profil profil) => profil.weight)}"
            e.intensity!=null ? Text("${e.intensity} ",
            style: const TextStyle(color: Colors.grey)) : Container(),
            
            ])
            // Container()
            ),
        const SizedBox(height: 20),]
        ),
    );
  }
}


class SimpleTemplateBlocView extends StatelessWidget {
  const SimpleTemplateBlocView({
    super.key,
    required this.bloc,
    required this.exDB,
    });

  final TemplateBloc bloc;
  final ExerciceDB exDB;

  @override
  Widget build(BuildContext context) {
    final Exercice exercice = exDB[bloc.exId];
    // final bool showIntensity = bloc.series.every((element) => element.intensity!=null);
    
    return ListTile(
      // isThreeLine: true,
      leading: IconButton(
        onPressed: () => showDialog(
            context: context,
            builder: ((context) => 
              Dialog(
                child: ExerciceView(exercice: exercice),
                )
            )
          ),
        icon : const Icon(Icons.fitness_center)), //
      title: 
          Text(exercice.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold,
              color: Colors.black),
              textAlign: TextAlign.center,),
              // Text("Int : ${bloc.intensity ?? "N/A"}"),
      subtitle: 
      Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: 
        [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              

            const Text ("Reps",style: TextStyle(fontWeight: FontWeight.bold,
            color: Colors.black)),
            const Text("Masse (kg)",style: TextStyle(fontWeight: FontWeight.bold,
            color: Colors.black)),
            // showIntensity ? const Text("Intensité",style: TextStyle(fontWeight: FontWeight.bold,
            // color: Colors.black)) :Container()
            ],),
            const SizedBox(height: 7),
          ...bloc.series.map((e) => 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [Text("${e.reps}",
                style: const TextStyle(color: Colors.black)),
            Text("${e.weight ?? "Poids du corps" }",
            style: const TextStyle(color: Colors.black )),
            //?? context.select((Profil profil) => profil.weight)}"
            // e.intensity!=null ? Text("${e.intensity} ",
            // style: const TextStyle(color: Colors.black)) : Container(),
            ])
    
            ),
            // Container()
            
        const SizedBox(height: 20),]
        ),
    );
  }
}

class SeanceView extends StatefulWidget {
  const SeanceView({
    super.key,
    required this.seance,
    required this.exDB,
  });

  final ExecTrackedSeance seance;
  final ExerciceDB exDB;

  @override
  State<SeanceView> createState() => _SeanceViewState();
}

class _SeanceViewState extends State<SeanceView> {
  @override
  Widget build(BuildContext context) {
    List<ExecBloc> blocs = widget.seance.exerciceBlocs;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.seance.name ?? "Séance",textAlign: TextAlign.center,),
      ),
      body: ListView(
        children: [
          // Expanded(
          //   flex : 1,
            // child: 
            NotesView(
            labelText: "Notes permanentes",
            hintText: "Notes permanentes",
            notes: widget.seance.permNotes),
            // ),
          // Expanded(
          //   flex : 1,
          //   child: 
            NotesView(
              labelText: "Notes de séance",
              hintText: "Notes de séance",
              notes: widget.seance.notes),
            // ),
          //Stats : durée, volume, reps
          // SizedBox(
          //   height: MediaQuery.of(context).size.height * 0.25,
          //   child: ListView.builder(
          //     itemCount: blocs.length,
          //     itemBuilder: (context, index) {
          //       return 
          ...blocs.map((e) => e.anyDone ? SimpleExBlocView(
                  exDB: widget.exDB,
                  bloc: e)
                  : Container()
                  )])
        //       },
        //     ),
        //   ),
        // ])
    );
  }
}

class TemplateSeanceView extends StatefulWidget {
  const TemplateSeanceView({
    super.key,
    required this.seance,
    required this.exDB,
  });

  final TemplateTrackedSeance seance;
  final ExerciceDB exDB;

  @override
  State<TemplateSeanceView> createState() => _TemplateSeanceViewState();
}

class _TemplateSeanceViewState extends State<TemplateSeanceView> {
  @override
  Widget build(BuildContext context) {
    List<TemplateBloc> blocs = widget.seance.exerciceBlocs;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.seance.name ?? "Séance",textAlign: TextAlign.center,),
      ),
      body: ListView(
        children: [
          // Expanded(
          //   flex : 1,
            // child: 
            NotesView(
            labelText: "Notes permanentes",
            hintText: "Notes permanentes",
            notes: widget.seance.permNotes),
            // ),
          // Expanded(
          //   flex : 1,
          //   child: 
        
            // ),
          //Stats : durée, volume, reps
          // SizedBox(
          //   height: MediaQuery.of(context).size.height * 0.25,
          //   child: ListView.builder(
          //     itemCount: blocs.length,
          //     itemBuilder: (context, index) {
          //       return 
          ...blocs.map((e) => SimpleTemplateBlocView(
                  exDB: widget.exDB,
                  bloc: e)
                  )])
        //       },
        //     ),
        //   ),
        // ])
    );
  }
}