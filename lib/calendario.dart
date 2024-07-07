import 'package:flutter/material.dart';
import 'package:pint/models/evento.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:table_calendar/table_calendar.dart';


class Calendario extends StatefulWidget {
  const Calendario({super.key});

  @override
  State<Calendario> createState() => _CalendarioState();
}



class _CalendarioState extends State<Calendario> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  List<Evento> eventos = [];



  void loadEventos() async {
    final fetchedEventos = await fetchEventos(context, 1);
    setState(() {
       eventos = fetchedEventos;

    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_view_day),
            onPressed: () {
              setState(() {
                _calendarFormat = _calendarFormat == CalendarFormat.month
                    ? CalendarFormat.twoWeeks
                    : _calendarFormat == CalendarFormat.twoWeeks
                        ? CalendarFormat.week
                        : CalendarFormat.month;
              });
            },
          ),
        ],
      ),
      body: TableCalendar(
        locale: 'pt_PT', // Define o idioma para Português Europeu
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        headerVisible: true,
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.grey),
          weekendStyle: TextStyle(color: Colors.black),
        ),
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Color.fromARGB(255, 166, 197, 223),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          rangeStartDecoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          rangeEndDecoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          withinRangeDecoration: BoxDecoration(
            color: Colors.lightGreenAccent,
            shape: BoxShape.circle,
          ),
        ),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        rangeStartDay: _rangeStart,
        rangeEndDay: _rangeEnd,
        rangeSelectionMode: _rangeSelectionMode,
        onDaySelected: _onDaySelected,
        onRangeSelected: _onRangeSelected,
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() => _calendarFormat = format);
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Reset range selection
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null; // Reset single day selection
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
      //eventos[0].data
    });
  }
}
