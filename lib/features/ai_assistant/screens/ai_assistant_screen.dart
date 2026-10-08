import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../core/theme/app_colors.dart';

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> chatHistory = [];
  bool isAiLoading = false;

  Future<void> _sendMessage() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        chatHistory.add({"role": "ai", "text": "ERR: API Key missing inside environment payload config."});
      });
      return;
    }

    setState(() {
      chatHistory.add({"role": "user", "text": prompt});
      isAiLoading = true;
      _promptController.clear();
    });
    _scrollToBottom();

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash', 
        apiKey: apiKey
      );
      
      final response = await model.generateContent([Content.text(prompt)]);
      
      setState(() {
        chatHistory.add({"role": "ai", "text": response.text ?? "No encrypted trace returned from node."});
        isAiLoading = false;
      });
    } catch (e) {
      setState(() {
        chatHistory.add({"role": "ai", "text": "ERR: Generation packet crash -> ${e.toString()}"});
        isAiLoading = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header Badge Line
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              children: [
                const Text("AI Assistant", style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primaryLightTint, borderRadius: BorderRadius.circular(8)),
                  child: const Text("BETA", style: TextStyle(color: AppColors.primaryBlue, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
              ],
            ),
          ),
          
          // Chat Streams Display Window
          Expanded(
            child: chatHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.auto_awesome, size: 48, color: AppColors.primaryBlue),
                        SizedBox(height: 16),
                        Text("// SYSTEM ENGINE ONLINE", style: TextStyle(fontFamily: 'monospace', color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                        Text("Ask questions regarding data nodes or coding scripts.", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(24),
                    itemCount: chatHistory.length,
                    itemBuilder: (context, index) {
                      final chat = chatHistory[index];
                      bool isUser = chat['role'] == 'user';
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isUser ? AppColors.primaryBlue : AppColors.surface,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isUser ? 16 : 0),
                                bottomRight: Radius.circular(isUser ? 0 : 16),
                              ),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
                            ),
                            child: Text(
                              chat['text']!, 
                              style: TextStyle(color: isUser ? Colors.white : AppColors.textPrimary, fontSize: 15, height: 1.4),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Technical Floating Input Box
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 4))],
              ),
              child: TextField(
                controller: _promptController,
                textInputAction: TextInputAction.send, // Keyboard "Send" button mapping
                onSubmitted: (_) => _sendMessage(), // Auto transmits configuration query
                decoration: InputDecoration(
                  hintText: "Transmit query to neural core...",
                  hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: isAiLoading 
                        ? const SizedBox(width: 20, height: 20, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue))) 
                        : IconButton(
                            icon: const Icon(Icons.arrow_upward_rounded, color: AppColors.primaryBlue),
                            onPressed: _sendMessage,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}