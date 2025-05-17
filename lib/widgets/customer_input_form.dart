import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class CustomerInputForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController mobileController;
  final String payStatus;
  final ValueChanged<String?> onPayStatusChanged;

  const CustomerInputForm({
    super.key,
    required this.nameController,
    required this.mobileController,
    required this.payStatus,
    required this.onPayStatusChanged,
  });

  @override
  State<CustomerInputForm> createState() => _CustomerInputFormState();
}

class _CustomerInputFormState extends State<CustomerInputForm> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastRecognized = '';

  TextEditingController? _activeController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening(TextEditingController controller) async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _activeController = controller;
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            _lastRecognized = result.recognizedWords;
            // Update the text field with recognized speech
            _activeController!.text = _lastRecognized;
            _activeController!.selection = TextSelection.fromPosition(
              TextPosition(offset: _activeController!.text.length),
            );
          });
        },
        listenMode: stt.ListenMode.dictation,
      );
    } else {
      setState(() => _isListening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition unavailable')),
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Widget _buildVoiceInputField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
  }) {
    bool isActive = _isListening && _activeController == controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                isActive ? Icons.mic : Icons.mic_none,
                color: isActive ? Colors.blue.shade700 : Colors.grey,
              ),
              onPressed: () {
                if (isActive) {
                  _stopListening();
                } else {
                  _startListening(controller);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVoiceInputField(
          label: "Customer Name",
          controller: widget.nameController,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 10),
        _buildVoiceInputField(
          label: "Mobile Number",
          controller: widget.mobileController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 10),
        const Text(
          "Payment Status",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        DropdownButtonFormField<String>(
          value: widget.payStatus,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          dropdownColor: Colors.white,
          items: ['Paid', 'Unpaid'].map((status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Text(status),
            );
          }).toList(),
          onChanged: widget.onPayStatusChanged,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
