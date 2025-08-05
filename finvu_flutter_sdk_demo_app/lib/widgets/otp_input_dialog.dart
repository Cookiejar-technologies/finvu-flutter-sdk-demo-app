import 'package:flutter/material.dart';
import '../styles/shared_styles.dart';
import 'finvu_dialog.dart';

class OtpInputDialog extends StatefulWidget {
  final bool visible;
  final VoidCallback onClose;
  final Function(String) onSubmit;

  const OtpInputDialog({
    super.key,
    required this.visible,
    required this.onClose,
    required this.onSubmit,
  });

  @override
  State<OtpInputDialog> createState() => _OtpInputDialogState();
}

class _OtpInputDialogState extends State<OtpInputDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  void _validate() {
    final otp = _controller.text;
    if (!RegExp(r'^\d{6,8}$').hasMatch(otp)) {
      setState(() {
        _error = 'OTP must be 6 or 8 digits';
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
      title: 'Enter OTP',
      onClose: () {
        widget.onClose();
        _controller.clear();
      },
      onSubmit: () {
        _handleSubmit();
        _controller.clear();
      },
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: SharedStyles.inputDecoration.copyWith(
              hintText: '123456',
            ),
            keyboardType: TextInputType.number,
            maxLength: 8,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}
