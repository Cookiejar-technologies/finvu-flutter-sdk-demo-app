import 'package:flutter/material.dart';
import '../styles/shared_styles.dart';
import 'finvu_dialog.dart';

class DobInputDialog extends StatefulWidget {
  final bool visible;
  final VoidCallback onClose;
  final Function(String) onSubmit;

  const DobInputDialog({
    super.key,
    required this.visible,
    required this.onClose,
    required this.onSubmit,
  });

  @override
  State<DobInputDialog> createState() => _DobInputDialogState();
}

class _DobInputDialogState extends State<DobInputDialog> {
  DateTime _selectedDate = DateTime.now();
  String? _error;

  void _validate() {
    final today = DateTime.now();
    final age = today.year - _selectedDate.year;
    final is18 = age > 18 ||
        (age == 18 &&
            (today.month > _selectedDate.month ||
                (today.month == _selectedDate.month &&
                    today.day >= _selectedDate.day)));

    if (!is18) {
      setState(() {
        _error = 'You must be at least 18 years old';
      });
      return;
    }

    setState(() {
      _error = null;
    });
  }

  void _handleSubmit() {
    _validate();
    if (_error == null) {
      final formatted = '${_selectedDate.year}-'
          '${_selectedDate.month.toString().padLeft(2, '0')}-'
          '${_selectedDate.day.toString().padLeft(2, '0')}';
      widget.onSubmit(formatted);
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FinvuDialog(
      visible: widget.visible,
      title: 'Select Date of Birth',
      onClose: widget.onClose,
      onSubmit: _handleSubmit,
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
            child: const Text('Pick Date'),
          ),
          const SizedBox(height: 10),
          Text(
            'Selected: ${_selectedDate.toString().split(' ')[0]}',
            style: SharedStyles.infoTextStyle,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}