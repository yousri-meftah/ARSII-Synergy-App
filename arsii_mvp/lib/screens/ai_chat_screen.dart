import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsii_mvp/models/ai.dart';
import 'package:arsii_mvp/state/providers.dart';

class AIChatScreen extends ConsumerStatefulWidget {
  const AIChatScreen({super.key});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<AIChatMessage> _messages = [
    AIChatMessage(
      role: 'assistant',
      content: 'Ask ARSII Bot about blockers, overloaded teammates, risky projects, or who should own the next task.',
    ),
  ];
  bool _sending = false;

  static const _prompts = [
    'Who is overloaded right now?',
    'Which project is most at risk?',
    'Summarize blockers from comments',
    'Who should I assign this project to?',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _messages.add(AIChatMessage(role: 'user', content: text));
      _controller.clear();
    });

    try {
      final reply = await ref.read(aiServiceProvider).chat(
            message: text,
            history: _messages,
          );
      if (!mounted) return;
      setState(() {
        _messages.add(AIChatMessage(role: 'assistant', content: reply.reply));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          AIChatMessage(
            role: 'assistant',
            content: 'I could not answer right now. Check backend status or Gemini configuration.',
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ARSII Bot')),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              itemCount: _prompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ActionChip(
                  label: Text(_prompts[index]),
                  onPressed: _sending ? null : () => _send(_prompts[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.role == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    constraints: const BoxConstraints(maxWidth: 330),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF1F2A44) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BubbleLabel(isUser: isUser),
                        const SizedBox(height: 8),
                        Text(
                          message.content,
                          style: TextStyle(
                            color: isUser ? Colors.white : const Color(0xFF1F2A44),
                            height: 1.42,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Ask ARSII Bot...',
                        prefixIcon: Icon(Icons.chat_bubble_outline),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _sending ? null : _send,
                      child: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.arrow_upward),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleLabel extends StatelessWidget {
  final bool isUser;

  const _BubbleLabel({required this.isUser});

  @override
  Widget build(BuildContext context) {
    final color = isUser ? Colors.white24 : const Color(0xFFEEF2FF);
    final textColor = isUser ? Colors.white : const Color(0xFF1F2A44);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isUser ? 'You' : 'ARSII Bot',
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
