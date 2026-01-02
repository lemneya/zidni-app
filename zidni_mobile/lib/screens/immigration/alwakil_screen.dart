import 'package:flutter/material.dart';
import '../../services/immigration/immigration_alwakil.dart';

/// Screen for the Immigration Alwakil (AI Assistant).
class AlwakilScreen extends StatefulWidget {
  const AlwakilScreen({super.key});

  @override
  State<AlwakilScreen> createState() => _AlwakilScreenState();
}

class _AlwakilScreenState extends State<AlwakilScreen> {
  final _questionController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFAQs();
  }

  Future<void> _loadFAQs() async {
    await ImmigrationAlwakil.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isArabic ? 'الوكيل - مساعد الهجرة' : 'Alwakil - Immigration Assistant'),
        ),
        body: Column(
          children: [
            // Chat messages
            Expanded(
              child: _messages.isEmpty
                  ? _buildWelcomeView(isArabic)
                  : _buildChatView(isArabic),
            ),

            // Input area
            _buildInputArea(isArabic),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeView(bool isArabic) {
    final faqs = ImmigrationAlwakil.instance.getFAQs();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Welcome card
        Card(
          color: Colors.teal.shade50,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.smart_toy,
                  size: 48,
                  color: Colors.teal.shade700,
                ),
                const SizedBox(height: 12),
                Text(
                  isArabic ? 'مرحباً! أنا الوكيل' : 'Hello! I\'m Alwakil',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isArabic
                      ? 'مساعدك الشخصي لأسئلة الهجرة'
                      : 'Your personal immigration assistant',
                  style: TextStyle(color: Colors.teal.shade600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // FAQ section
        Text(
          isArabic ? 'أسئلة شائعة' : 'Frequently Asked Questions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...faqs.map((faq) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  faq.getLocalizedQuestion(isArabic ? 'ar' : 'en'),
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _askQuestion(faq.getLocalizedQuestion(isArabic ? 'ar' : 'en')),
              ),
            )),
      ],
    );
  }

  Widget _buildChatView(bool isArabic) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message, isArabic);
      },
    );
  }

  Widget _buildMessageBubble(_ChatMessage message, bool isArabic) {
    final isUser = message.isUser;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser ? Colors.teal : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : null,
            bottomLeft: !isUser ? const Radius.circular(4) : null,
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _questionController,
              decoration: InputDecoration(
                hintText: isArabic ? 'اسأل سؤالاً...' : 'Ask a question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendQuestion(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _isLoading ? null : _sendQuestion,
            mini: true,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _askQuestion(String question) {
    _questionController.text = question;
    _sendQuestion();
  }

  Future<void> _sendQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: question, isUser: true));
      _isLoading = true;
    });
    _questionController.clear();
    _scrollToBottom();

    final response = await ImmigrationAlwakil.instance.askQuestion(question);
    
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final answer = response.getLocalizedAnswer(isArabic ? 'ar' : 'en') ?? 
        (isArabic ? 'عذراً، لم أتمكن من الإجابة' : 'Sorry, I couldn\'t answer that');

    setState(() {
      _messages.add(_ChatMessage(text: answer, isUser: false));
      _isLoading = false;
    });
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
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}
