import 'package:flutter/material.dart';
import 'package:sporta/models/exercice_db.dart';
import 'package:sporta/models/muscle.dart';
import 'package:sporta/view/muscles.dart';
import 'package:sporta/view/exercices.dart';








class LibraryView extends StatefulWidget {
  const LibraryView({super.key,required this.body, required this.exDB});

  final BodyModel body;
  final ExerciceDB exDB;

  @override
  State<LibraryView> createState() => _LibraryViewState();

}

class _LibraryViewState extends State<LibraryView> {
  //class widget that is a basic scaffold for with a button 
  

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
        title: Text("Bibliothèque ${widget.exDB.allExs.length}"),
      ),
      body: 

        ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MusclePage(body: widget.body)),
                  );
              },
              child: const Text('Muscles Page'),
            ),
            ElevatedButton(
              onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExercicePage(body: widget.body, exDB: widget.exDB)),
                  );
              },
              child: const Text('Exercices Pages'),
            ),
          ],
        ),

    );

  }
}




