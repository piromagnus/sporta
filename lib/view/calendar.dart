import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return const CalendarWidget();
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


