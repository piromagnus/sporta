
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sporta/models/seance.dart';
import 'package:sporta/widgets/slider.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:sporta/models/history.dart';

format(Duration d) => d.toString().split('.').first.padLeft(8, "0");

List<String> types = ["Musculation", "Cardio", "Course à Pied", "Cyclisme", "Natation", "Escalade", "Ski", "Ski de fond", "Boxe", "Judo", "Jujitsu"];





class BasicForm extends StatefulWidget {
  const BasicForm({super.key, required this.history, this.initial});
  final HistoryModel history;
  final BasicSeance? initial;

  @override
  State<BasicForm> createState() => _BasicFormState();
} 

class _BasicFormState extends State<BasicForm> {

  final _basicFormKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _notesC = TextEditingController();
  final _timeC = TextEditingController();
  final _dateC = TextEditingController();
  DateTime _date = DateTime.now() ;
  SeanceType? _ddtype;
  double _intensity=1;
  Duration _duration = const Duration();
  
  
  Future displayTimePicker(BuildContext context) async { // show a time picker that put the time in the controller
    var time = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.parse("20000101"),
        lastDate: DateTime.parse("25000101")
        );

    if (time != null) {
      setState(() {
        _date=time;
        _dateC.text = DateFormat('dd/MM/yyyy HH:mm').format(_date);
      });
    }
  }

void durationDialog(BuildContext context)
{
  Picker(
    adapter: NumberPickerAdapter(data: <NumberPickerColumn>[
      const NumberPickerColumn(begin: 0, end: 100, suffix: Text(' hours')),
      const NumberPickerColumn(begin: 0, end: 60, suffix: Text(' minutes'),),
      const NumberPickerColumn(begin: 0, end: 60, suffix: Text(' secondes'),),
    ]),
    delimiter: <PickerDelimiter>[
      PickerDelimiter(
        child: Container(
          width: 30.0,
          alignment: Alignment.center,
          child: const Icon(Icons.more_vert),
        ),
      )
    ],
    hideHeader: true,
    confirmText: 'OK',
    confirmTextStyle: const TextStyle(inherit: false, color: Colors.red, fontSize: 22),
    title: const Text('Select duration'),
    selectedTextStyle: const TextStyle(color: Colors.blue),
    onConfirm: (Picker picker, List<int> value) {
      // You get your duration here
    //if (time != null) {
      setState(() {
        _timeC.text = "${picker.getSelectedValues()[0]}h ${picker.getSelectedValues()[1]} min ${picker.getSelectedValues()[2]} sec";
        _duration = Duration(hours: picker.getSelectedValues()[0], minutes: picker.getSelectedValues()[1],seconds: picker.getSelectedValues()[2]);
      });
     
    },
  ).showDialog(context);
}

   @override
  void initState() {
    if (widget.initial !=null){
      _nameC.text = widget.initial!.name ?? "";
      _notesC.text = widget.initial!.notes ?? "";
      _date=DateTime.fromMillisecondsSinceEpoch(widget.initial!.date);
      _dateC.text = DateFormat('dd/MM/yyyy HH:mm').format(_date);
      _duration=Duration(seconds: widget.initial!.time ?? 0);
      _timeC.text = format(_duration);
      _intensity=widget.initial!.intensity?.toDouble() ?? 1;
      _ddtype=widget.initial!.type;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
  
    return Form(
      key : _basicFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Nom de la séance",
            ),
            controller: _nameC,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer le nom de la séance';
              }
              return null;
            },
          ), // Nom de la séance
          DropdownButtonFormField(
            value: _ddtype,
            items: SeanceType.values.map((e) => DropdownMenuItem(value: e,child: Text(e.strName))).toList(), 
            onChanged: (value) {
              setState(() {
                _ddtype=value!;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Veuillez sélectionner le type de séance';
              }
              return null;
            },
            ), // type (probably will disapear in futur with a grid icon selection)

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [ 
            const Spacer(),
            SizedBox(width :MediaQuery.of(context).size.width*.2,
                     child: TextFormField(
                     //enabled: false,
                     readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez noter la date de la séance';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          labelText: 'Date', border: OutlineInputBorder()),
                          controller: _dateC,)
                      ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => setState(() {
                _date=DateTime.now();
                _dateC.text = DateFormat('dd/MM/yyyy HH:mm').format(_date);
              }),
              child: const Text("Maintenant")),
            const Spacer(),
            ElevatedButton(onPressed: () => displayTimePicker(context), child: const Text("Sélectionner")),
            const Spacer(),
            ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [ 
            const Spacer(),
            SizedBox(width :MediaQuery.of(context).size.width*.2,
                     child: TextFormField(
                     //enabled: false,
                     readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez noter la durée de la séance';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          labelText: 'Durée de la séance', border: OutlineInputBorder()),
                          controller: _timeC,)
                      ),
            const Spacer(),
            ElevatedButton(onPressed: () => durationDialog(context), child: const Text("Sélectionner")),
            const Spacer(),
            ]),//,  // time
          
          
          IntensitySlider(
            intensity: _intensity,
            onChanged: (value) => _intensity=value,
            ), // Intensity
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Notes de la séance",
            ),
            controller: _notesC,
            
            ), // Notes
          ElevatedButton(onPressed: (() {
            if (_basicFormKey.currentState!.validate()) {
               ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content:  Text('Processing Data...' )),
                  );
               if (widget.initial !=null)
               {
                widget.history.modifyBasicSeance(
                  widget.initial!,
                  _nameC.text, _ddtype!,
                  _notesC.text,
                  _date.millisecondsSinceEpoch,
                  _duration.inSeconds,
                  _intensity);
               }
               else {
               
               widget.history.add(
                          BasicSeance(
                          date :_date.millisecondsSinceEpoch,
                          name : _nameC.text,
                          complete: true,
                          type : _ddtype!,
                          time : _duration.inSeconds,
                          intensity :_intensity,
                          notes: _notesC.text));
               }
              
                  Navigator.of(context).pop();
            } 
          }) ,
           child: const Text("Sauvegarder"))


        ],

      ),
      
      );
  }
}


class BasicAddition extends StatefulWidget {
  const BasicAddition({super.key, required this.history});

  final HistoryModel history;
  @override
  State<BasicAddition> createState() => _BasicAdditionState();
}

class _BasicAdditionState extends State<BasicAddition> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title : const Text("Ajouter une séance basique")),
    body: 
    
     Center(child: SizedBox(
      width: MediaQuery.of(context).size.width*.8,
      child: BasicForm(history:widget.history))),
      // Column(
      //   children: [
      //     Text

      //   ],  

      // )

    // Nom de la séance
    // Type de séance : Muscu, Cardio, CAP, Vélo, Natation, Escalade, Ski, Ski de fond, Boxe, Judo, Jujitsu,  
    // Temps de la séance
    // Intensité 
    // Notes

    // BasicSeance model, pour sauvegarder l'état et l'afficher dans l'onglet historique

      
    );
  }
}

