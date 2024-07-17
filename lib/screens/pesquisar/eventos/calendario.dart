import 'package:flutter/material.dart';
import 'package:pint/screens/pesquisar/eventos/paginaEvento.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/widgets/verifica_conexao.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:pint/models/evento.dart';
import 'package:pint/utils/fetch_functions.dart';


class Calendario extends StatefulWidget {
  final postoID;

  Calendario({required this.postoID});

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
  List<Evento> eventosDoDia = [];
  bool isLoading = true;
  bool isServerOff = false;

  @override
  void initState() {
    super.initState();
    loadEventos();
  }

  void loadEventos() async {
    try {
      final fetchedEventos = await fetchEventos(context, widget.postoID);
      setState(() {
        eventos = fetchedEventos;
        isLoading = false;
        if (_selectedDay != null) {
          eventosDoDia = _getEventsForDay(_selectedDay!);
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isServerOff = true;
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        eventosDoDia = _getEventsForDay(selectedDay);
        _rangeStart = null;
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
    }
  }

  List<Evento> _getEventsForDay(DateTime day) {
    return eventos.where((event) => isSameDay(DateTime.parse(event.data), day)).toList();
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
      body: VerificaConexao(isLoading: isLoading, isServerOff: isServerOff, child: 
       Column(
              children: [
                TableCalendar(
                  locale: 'pt_PT',
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  headerVisible: true,
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                    weekendStyle: const TextStyle(color: Colors.black, fontSize: 12),
                    dowTextFormatter: (date, locale) => DateFormat.E(locale).format(date).substring(0, 1).toUpperCase(), // Primeiro caractere do nome do dia
                  ),
                  calendarStyle: const CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: secondaryColor,
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
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() => _calendarFormat = format);
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  eventLoader: _getEventsForDay,
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: _buildEventList(),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildEventList() {
    if (eventosDoDia.isEmpty) {
      return const Center(
        child: Text('Nenhum evento para o dia selecionado.', style: TextStyle(fontSize: 12),),
      );
    }
    return ListView.builder(
      itemCount: eventosDoDia.length,
      itemBuilder: (context, index) {
        final evento = eventosDoDia[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListTile(
            title: Text(evento.titulo),
            subtitle: Text(evento.hora),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventoPage(
                                  eventoID: evento.id,
                                ),
                              ),
                            );
            }
          ),
        );
      },
    );
  }
}