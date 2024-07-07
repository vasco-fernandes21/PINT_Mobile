  import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeInput extends StatefulWidget {
  final Function(DateTime?) onDateChanged;
  final Function(TimeOfDay?) onTimeChanged;
  final String? Function(DateTime?, TimeOfDay?) validator;
  final bool showValidation;

  const DateTimeInput({
    Key? key,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.validator,
    this.showValidation = false,
  }) : super(key: key);

  @override
  _DateTimeInputState createState() => _DateTimeInputState();
}

class _DateTimeInputState extends State<DateTimeInput> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.onDateChanged(_selectedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        widget.onTimeChanged(_selectedTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 380,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: const Text('Data'),
            subtitle: Text(_selectedDate != null
                ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                : 'Selecionar Data'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectDate(context),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 380,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: const Text('Hora'),
            subtitle: Text(_selectedTime != null
                ? _selectedTime!.format(context)
                : 'Selecionar Hora'),
            trailing: const Icon(Icons.access_time),
            onTap: () => _selectTime(context),
          ),
        ),
        // Adding validation message
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Builder(
            builder: (context) {
              if(!widget.showValidation){
                return SizedBox.shrink();
              }
              final validationMessage = widget.validator(_selectedDate, _selectedTime);
              return validationMessage != null
                  ? Text(
                      validationMessage,
                      style: TextStyle(color: Colors.red),
                    )
                  : SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
