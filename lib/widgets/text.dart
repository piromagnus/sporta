
import 'package:flutter/material.dart';
import 'package:sporta/models/current_seance.dart';
import 'package:sporta/models/seance.dart';
import 'package:provider/provider.dart';



class NotesView extends StatelessWidget {
  const NotesView({
    super.key,
    this.notes,
    this.hintText = "Notes",
    this.labelText,
  });

  final String? notes;
  final String? labelText;
  final String hintText;
  

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.07,
      child : InputDecorator(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: (notes !=null) ? labelText : null,
          labelStyle: const TextStyle(fontSize: 16, color: Colors.black),
          // hintText: hintText,
          // hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        child :(notes !=null) 
      ? Text( 
        "$notes", 
        style: const TextStyle(fontSize: 16, color: Colors.black),
        textAlign: TextAlign.center,)
      : 
      Text (hintText,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
        textAlign: TextAlign.center) )
        
        );
  }
}


class NotesField extends StatelessWidget {
  const NotesField({super.key,
  required this.notesC,
  required this.onChanged,
  this.hintText = "Notes",
  this.labelText ,
  });

  final TextEditingController notesC ;
  final Function(String) onChanged;
  final String? hintText;
  final   String? labelText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: (notesC.text== "") ? null : labelText,
        labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
        hintText: hintText, //Notes de la séance précédante
        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey), 
        border: const OutlineInputBorder(),
      ),
      maxLines: 2,
      controller: notesC,
      onChanged: onChanged,
    );
  }
}

class PermNoteField extends StatefulWidget {
  const PermNoteField({super.key,
    required this.currentSeance,
    required this.permNotesC});

  final CurrentExecSeance currentSeance;
  final TextEditingController permNotesC;

  @override
  State<PermNoteField> createState() => _PermNoteFieldState();
}

class _PermNoteFieldState extends State<PermNoteField> {
  late CurrentExecSeance currentSeance;
 
  late TextEditingController _permNotesC;


  @override
  void initState() {
    super.initState();
    currentSeance = widget.currentSeance;

    _permNotesC = widget.permNotesC;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      // padding: const EdgeInsets.all(10),
      margin : const EdgeInsets.symmetric(vertical: 15),
      child : 
      InputDecorator(
        
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: ( _permNotesC.text !="") ? "Notes permanentes":null,
          labelStyle: const TextStyle(fontSize: 16, color: Colors.black),
          // hintText: hintText,
          // hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        ),

        child:
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children :[
      _permNotesC.text != "" ? Text( _permNotesC.text,
          style: const TextStyle(color: Colors.black,
          fontSize: 18),
          textAlign: TextAlign.center,
          ) :
          const Text("Notes permanentes",
          style: TextStyle(color: Colors.grey,
          fontSize: 16,
          fontStyle: FontStyle.italic,
          )),
      ElevatedButton(
        onPressed: () { 
          var _tempPermNotesC = TextEditingController(text : _permNotesC.text);
          showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Modifier les notes permanentes",
            textAlign: TextAlign.center,),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children : [
            
            const Text("ATTENTION : \nLes notes permanentes seront aussi modifiées sur le modèle de séance",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red, fontSize: 15)),

            TextField(
              controller: _tempPermNotesC,
              maxLines: 2,
              // onChanged: (value) => currentSeance.permNotes = _permNotesC.text,
            )]),
            actions: [
              TextButton(
                onPressed: () { Navigator.pop(context);
                },
                child: const Text("Annuler")),
              TextButton(
                onPressed: () => setState((){ 
                SeanceDB seanceDB = context.read<SeanceDB>();
                  Navigator.pop(context);
                  _permNotesC.text = _tempPermNotesC.text;
                  currentSeance.data.template?.permNotes = _tempPermNotesC.text;
                  seanceDB.save();
                }),
                child: const Text("Ok")),
            ],
          ),
        );},
        child: const Icon(Icons.edit_rounded)
        )
    ])));
  }
}