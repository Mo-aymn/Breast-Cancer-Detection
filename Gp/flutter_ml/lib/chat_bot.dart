import 'package:flutter/material.dart';
import 'package:flutter_ml/app_colors.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class BotScreen extends StatefulWidget {
  const BotScreen({super.key});

  @override
  State<BotScreen> createState() => _BotScreenState();
}

class _BotScreenState extends State<BotScreen> {
  final TextEditingController _userMessage = TextEditingController();
  static const String apiKey = "AIzaSyChmAWjvAUeakivmVdpFgQqHGcDC-sI8O0";

  final model = GenerativeModel(
    model: 'gemini-2.0-flash',
    apiKey: apiKey,
  );

  final List<Map<String, String>> _messages = [];

  Future<void> sendMessage() async {
    final message = _userMessage.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': message});
    });
    _userMessage.clear();

    try {
      final response = await model.generateContent([Content.text(message)]);
      setState(() {
        _messages
            .add({'role': 'gemini', 'text': response.text ?? 'No response'});
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'error', 'text': 'حدث خطأ: ${e.toString()}'});
      });
    }
  }

  Widget buildMessage(Map<String, String> message) {
    final isUser = message['role'] == 'user';
    final isError = message['role'] == 'error';

    final bgColor = isError
        ? Colors.red.shade100
        : isUser
            ? Colors.green.shade100
            : Colors.white;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          );

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Text(
            message['text'] ?? '',
            style: TextStyle(fontSize: 16),
            textAlign: isUser ? TextAlign.right : TextAlign.left,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppColors.third,
      appBar: AppBar(
        title: const Text(
          'Chat with AI',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: isDark ? Colors.grey[900] : AppColors.primary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) => buildMessage(_messages[index]),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: isDark ? Colors.black12 : AppColors.third,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _userMessage,
                    decoration: const InputDecoration(
                      hintStyle: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      hintText: "Ask anything...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
