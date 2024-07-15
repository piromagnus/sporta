import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'bloc/calendar_bloc.dart'; // Le bloc que vous allez créer pour gérer l'état du calendrier
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';

import 'package:sporta/models/seance.dart';
import 'package:sporta/models/calendar.dart';
import 'package:sporta/models/exercice_db.dart';
import 'seance_view.dart';

class CalendarSeanceTile extends StatelessWidget {
  const CalendarSeanceTile({super.key,
    required this.seance,
    required this.date,
    this.color,

  });

  final TemplateTrackedSeance seance;
  final Color? color;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(' ${seance.name}'),
        subtitle: Text(' ${seance.type!.strName}',),
        onTap: () => showDialog(context: context,
          builder : (context) => 
          Dialog(
            child: TemplateSeanceView(seance: seance,
            exDB: context.read<ExerciceDB>(),
            ),
            )
        ),
        trailing: 
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // On utilise Provider pour accéder à SeanceDB
                final seanceDB = context.read<CalendarDB>();
                // Provider.of<CalendarDB>(context, listen: true);
                // On supprime la séance
                seanceDB.removeSeance(date,seance);
              },
            ),
    );
  }
}

class DayTile extends StatelessWidget {
  const DayTile({super.key,
    required this.day,
    required this.seances,
    this.color,
  });

  final DateTime day;
  final List<TemplateTrackedSeance> seances;
  final Color? color;


  @override
  Widget build(BuildContext context) {
    return Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: color ?? Colors.blueAccent[100],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child:Column( 
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children : [
              const Spacer(),
              Expanded(child : Text(
              day.day.toString(),
              style: TextStyle(color: Colors.white,
              fontSize: 15,
              ),
              )),
              // const Spacer(),
              ]..addAll(seances.map((e) => Text(e.name!,
              style: TextStyle(color: Colors.white,
              fontSize: 10),
              )
              )
              )..add(Spacer())
            ),
          );
  }
}

class FocusedDayTile extends StatelessWidget {
  const FocusedDayTile({super.key,
    required this.day,
    required this.dbSeances,
    this.color,
  });

  final DateTime day;
  final List<TemplateTrackedSeance> dbSeances;
  // /!\ dbSeances est la liste des séances types complètes 
  //  et non pas celle de la journée comme dans DayTile
  final Color? color;


  @override
  Widget build(BuildContext context) {
    return Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: color ?? Colors.blueAccent[100],
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            child:
            
              InkWell(
                focusColor: Colors.blueAccent[100] ,
                onTap: () => 
              showDialog(context: context,
              builder : (context) =>
              AddSeanceDialog(seances: dbSeances, date: day,),
              ),
                child : 
                Column( 
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children : [
                  
                  Text(
                  day.day.toString(),
                  style: TextStyle(color: Colors.white,
                  ),
                  ),
                  Text("+",
                  style: TextStyle(color: Colors.white,
                  fontSize: 20),
                  ) 
                
                  ]
                )),
          );
  }
}

class AddSeanceDialog extends StatefulWidget {
  const AddSeanceDialog({
    super.key,
    required this.seances,
    required this.date
  });

  final List<TemplateTrackedSeance> seances;
  final DateTime date;

  @override
  State<AddSeanceDialog> createState() => _AddSeanceDialogState();
}

class _AddSeanceDialogState extends State<AddSeanceDialog> {

  late List<bool> _selected;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selected = [for (var i in widget.seances) false];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter une séance'),
      scrollable: true,
      content: 
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width * 0.8,
        child : ListView.builder(
        itemBuilder: (context, index) {
        return CheckboxListTile(
          tileColor: _selected[index] ? Colors.greenAccent : null,
          title: Text(widget.seances[index].name!),
          subtitle: Text("${widget.seances[index].type!.strName}"),
          value : _selected[index],
          onChanged: (e) {
            setState(() {
              _selected[index] = e!;
            });
          },
        );
      },
        itemCount: widget.seances.length,
      )),
        actions: <Widget>[
        TextButton(
          child: Text('Ajouter les séances'),
          onPressed: () {
            // On utilise Provider pour accéder à SeanceDB
            final calendarDB = context.read<CalendarDB>();
            // Provider.of<CalendarDB>(context, listen: true);
            // On ajoute la séance à la date sélectionnée
            calendarDB.addSeances(widget.date, 
              widget.seances.where(
              (element) => _selected[widget.seances.indexOf(element)])
              .toList()
            );
            // On ferme la boîte de dialogue
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    // final seanceDB = Provider.of<CalendarDB>(context);

    return 
    Center(child : CalenderWidgetV2());
  }
}

class CalenderWidgetV2 extends StatefulWidget {
  const CalenderWidgetV2({super.key});

  @override
  State<CalenderWidgetV2> createState() => _CalenderWidgetV2State();
}

class _CalenderWidgetV2State extends State<CalenderWidgetV2> {
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // On utilise Provider pour accéder à SeanceDB
    // final seanceDB = Provider.of<CalendarDB>(context);
    // final Map<DateTime,List<TemplateTrackedSeance>> seances = seanceDB.seances;

    return Consumer<CalendarDB>(builder: (context, seances, child) => 
    
    Column(children : [
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child :
       TableCalendar(
        calendarStyle: CalendarStyle(
          // Use `CalendarStyle` to customize the UI
         markersMaxCount: 0,
        ),
        rowHeight: _calendarFormat == CalendarFormat.month 
        ? MediaQuery.of(context).size.height * 0.09
        : MediaQuery.of(context).size.height * 0.2,
        // shouldFillViewport: true,
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        // Use `selectedDayPredicate` to determine which day is currently selected.
        // If this returns true, then `day` will be marked as selected.
        return isSameDay(_selectedDay, day);
      },
      eventLoader: (day) {
        // Use `eventLoader` to decide which events to show on each day.
        return seances[day];
      },
      onDaySelected: (selectedDay, focusedDay) {
        // Update `_focusedDay` here because we only have the `focusedDay` 
        // parameter outside of `onDaySelected`.
        if (!isSameDay(_selectedDay, selectedDay)) {
          // Call `setState()` when updating the selected day
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay; // update `_focusedDay` here as well
          });
        }
      },
      onPageChanged: (focusedDay) {
        // No need to call `setState()` here
        _focusedDay = focusedDay;
      },
      onFormatChanged: (format) {
        // Call `setState()` if format changes
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarBuilders: CalendarBuilders(
      //   dowBuilder: (context, day) {
      //   if (day.weekday == DateTime.sunday) {
      //     final text = DateFormat.E().format(day);

      //   return Center(
      //     child: Text(
      //       text,
      //       style: TextStyle(color: Colors.red),
      //     ),
      //   );
      //   }

      // },
        selectedBuilder: (context, day, focusedDay) {
          return FocusedDayTile(day: day,
           dbSeances: context.read<SeanceDB>().completeSeances,
          color: Colors.deepOrange[400] ,);
        },
        todayBuilder: (context, day, focusedDay) {
          return DayTile(day: day,
           seances: seances[day],
           color: Colors.amber[400]);
        },
      defaultBuilder: (context, day, focusedDay) => 
      DayTile(day: day, seances: seances[day],
      color : seances[day].isNotEmpty ? Colors.greenAccent : null)
      ),

      // calendarStyle: CalendarStyle(
      //   // Use `CalendarStyle` to customize the UI
      //   selectedDecoration: BoxDecoration(
      //     color: Colors.blue,
      //     shape: BoxShape.circle,
      //   ),
      //   todayDecoration: BoxDecoration(
      //     color: Colors.purpleAccent,
      //     shape: BoxShape.circle,
      //   ),
      // ),
      headerStyle: HeaderStyle(
        // Style the header
        formatButtonVisible: true,
      ),
      )),
    
    Expanded(child : 
    (seances[_focusedDay].isNotEmpty) ? 
    ListView.builder(
    itemCount: seances[_focusedDay].length, shrinkWrap: true, physics: NeverScrollableScrollPhysics(),
    itemBuilder: (context, index) {
      return  CalendarSeanceTile(seance: seances[_focusedDay][index],
       date: _focusedDay); 
    
    },
    ): Container()),

        // IconButton(
        //   icon: Icon(Icons.add),
        //   onPressed: () {
        //     setState(() {
        //      showDialog(context: context, 
        //      builder: (context) => AddSeanceDialog(
        //       date: _focusedDay,
        //       seances: context.read<SeanceDB>().completeSeances,
        //       ));
        //     });
        //   },
        // ),
  

    ]
    )
    
    );
  }
}






class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});
  
  @override
  createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late Map<DateTime, List> _events;
  late List _selectedEvents;
  late DateTime _selectedDate;
  late DateTime _focusedDate;
  // String _draggedEvent ="";


  @override
  void initState() {
    super.initState();
    _events = {};
    _selectedEvents = [];
    _selectedDate = DateTime.now();
    _focusedDate = DateTime.now();
  }

  @override
Widget build(BuildContext context) {
  return Column(
    children: [
      TableCalendar(
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: _focusedDate,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDate, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDate = selectedDay;
            _focusedDate = focusedDay;
            _selectedEvents = _getEventsForDay(selectedDay);
          });
        },
        eventLoader: _getEventsForDay,
        onFormatChanged: (format) {},
        onPageChanged: (focusedDay) {
          _focusedDate = focusedDay;
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return DragTarget<Map<DateTime,String>>(
              onAccept: (map) {
                DateTime fromDate =map.keys.toList()[0];
                String title = map[fromDate]!;
                setState(() {
                  _events[fromDate]?.removeWhere((event) => event == title);
                  _events[day] = _events[day] ?? [];
                  _events[day]!.add(title);
                });
              },
              builder: (context, candidateData, rejectedData) {
                bool isDraggedDay = candidateData.isNotEmpty && isSameDay(candidateData.first!.keys.toList()[0], day);
                //print(isDraggedDay);
                return Container(
                  color: isDraggedDay ? Colors.red[300] : Colors.green[300] ,
                  child: Center(
                    child: Text(day.day.toString()),
                  ),
                );
              },
            );
          },
        ),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: _selectedEvents.length,
          itemBuilder: (context, index) => _buildDraggable(
            _selectedEvents[index],
            _selectedDate,
          ),
        ),
      ),
      FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Add Musculation Session'),
              content: TextFormField(
                onFieldSubmitted: (value) {
                  setState(() {
                    _events[_selectedDate] = _events[_selectedDate] ?? [];
                    _events[_selectedDate]?.add(value);
                    _selectedEvents.add(value);
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
      ),
    ],
  );
}


  List _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  Widget _buildDraggable(String title, DateTime fromDate) {
  return Draggable<Map<DateTime,String>>(
    data: {fromDate:title},

    feedback: Material(
      elevation: 6.0,
      color: const Color.fromARGB(61, 0, 0, 0),
      child: SizedBox(
        width: 200, // You can adjust the width as needed
        child: ListTile(title: Text(title)),
      ),
    ),
    childWhenDragging: Container(),
    child: ListTile(title: Text(title)),
  );
}
}
