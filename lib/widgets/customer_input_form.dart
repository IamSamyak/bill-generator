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
  String _activeLabel = '';

  final Map<String, String> _spokenToDigit = {
    "zero": "0",
    "one": "1",
    "two": "2",
    "three": "3",
    "four": "4",
    "five": "5",
    "six": "6",
    "seven": "7",
    "eight": "8",
    "nine": "9",
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening(TextEditingController controller, String label) async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _activeController = controller;
        _activeLabel = label;
        _lastRecognized = '';
      });

      _speech.listen(
        onResult: (result) {
          String recognized = result.recognizedWords;

          if (_activeLabel.toLowerCase().contains("mobile")) {
            recognized = _processMobileInput(recognized);
          }

          setState(() {
            _lastRecognized = recognized;
            _activeController!.text = recognized;
            _activeController!.selection = TextSelection.fromPosition(
              TextPosition(offset: recognized.length),
            );
          });
        },
        listenMode: stt.ListenMode.dictation,
      );

      _showListeningModal(label);
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
    Navigator.of(context).maybePop(); // Close modal if open
  }

  String _processMobileInput(String input) {
    input = input.toLowerCase();
    for (var entry in _spokenToDigit.entries) {
      input = input.replaceAll(entry.key, entry.value);
    }

    // Remove non-digit characters and limit to 10 digits
    final digitsOnly = input.replaceAll(RegExp(r'\D'), '');
    return digitsOnly.length > 10 ? digitsOnly.substring(0, 10) : digitsOnly;
  }

void _showListeningModal(String label) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) {
        // We'll listen to changes in _lastRecognized using a timer or by passing setState
        // So to update the dialog UI, we call setState from the onResult callback
        // Let's do this by passing a callback when starting listening.

        // But since _showListeningModal is called after _speech.listen(), and onResult calls setState,
        // the dialog will update because _lastRecognized is in the State.

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mic, size: 48, color: Colors.blue.shade700),
                const SizedBox(height: 16),
                Text(
                  "Listening for $label",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                // Show this text only if no speech recognized yet:
                if (_lastRecognized.isEmpty) ...[
                  Text(
                    "Please speak the $label now.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    _lastRecognized.isNotEmpty ? _lastRecognized : "Listening...",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _stopListening,
                  icon: const Icon(Icons.stop, size: 24),
                  label: const Text(
                    "Stop Listening",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
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
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: isActive ? Colors.blue : Colors.grey,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isActive ? Colors.blue : Colors.grey,
                width: 2,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isActive ? Icons.mic : Icons.mic_none,
                color: isActive ? Colors.blue.shade700 : Colors.grey,
              ),
              onPressed: () {
                if (isActive) {
                  _stopListening();
                } else {
                  _startListening(controller, label);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
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
        _buildVoiceInputField(
          label: "Mobile Number",
          controller: widget.mobileController,
          keyboardType: TextInputType.phone,
        ),
        const Text(
          "Payment Status",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 5),
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
