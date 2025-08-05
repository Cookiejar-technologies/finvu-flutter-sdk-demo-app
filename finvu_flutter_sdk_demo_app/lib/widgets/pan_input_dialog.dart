import 'package:flutter/material.dart';
import '../styles/shared_styles.dart';
import 'finvu_dialog.dart';

class PanInputDialog extends StatefulWidget {
  final bool visible;
  final VoidCallback onClose;
  final Function(String) onSubmit;

  const PanInputDialog({
    super.key,
    required this.visible,
    required this.onClose,
    required this.onSubmit,
  });

  @override
  State<PanInputDialog> createState() => _PanInputDialogState();
}

class _PanInputDialogState extends State<PanInputDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  void _validate() {
    final pan = _controller.text;
    final regex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');

    if (!regex.hasMatch(pan)) {
      setState(() {
        _error = 'Invalid PAN format';
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
      widget.onSubmit(_controller.text);
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FinvuDialog(
      visible: widget.visible,
      title: 'Enter PAN Number',
      onClose: widget.onClose,
      onSubmit: _handleSubmit,
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: SharedStyles.inputDecoration.copyWith(
              hintText: 'ABCDE1234F',
            ),
            textCapitalization: TextCapitalization.characters,
            onChanged: (value) {
              _controller.text = value.toUpperCase();
              _controller.selection = TextSelection.collapsed(
                offset: _controller.text.length,
              );
            },
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
