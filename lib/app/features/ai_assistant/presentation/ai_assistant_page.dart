import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:nawy_ai_app/app/core/injection/injection.dart';
import 'package:nawy_ai_app/app/features/ai_assistant/domain/ai_service.dart';
import 'package:nawy_ai_app/app/features/ai_assistant/presentation/bloc/ai_assistant_bloc.dart';
import 'package:nawy_ai_app/app/features/ai_assistant/presentation/models/assistant_message.dart';

class AiAssistantPage extends StatelessWidget {
  const AiAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AiAssistantBloc(getIt<AiService>())..add(const StartNewChatEvent()),
      child: const _AiAssistantView(),
    );
  }
}

class _AiAssistantView extends StatefulWidget {
  const _AiAssistantView();

  @override
  State<_AiAssistantView> createState() => _AiAssistantViewState();
}

class _AiAssistantViewState extends State<_AiAssistantView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  int _previousMessageCount = 0;

  static const List<String> _prompts = [
    'Find 3 bedroom homes under 10M EGP',
    'Which filters should I use for a family home?',
    'Compare apartments vs villas',
    'Help me shortlist by location',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _sendMessage([String? quickPrompt]) {
    final message = (quickPrompt ?? _messageController.text).trim();
    if (message.isEmpty) return;

    context.read<AiAssistantBloc>().add(SendMessageEvent(message));
    _messageController.clear();
    _messageFocusNode.requestFocus();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nawy AI Assistant'),
        actions: [
          IconButton(
            tooltip: 'Start new chat',
            padding: const EdgeInsets.only(right: 12),
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () => context.read<AiAssistantBloc>().add(const StartNewChatEvent()),
          ),
        ],
      ),
      body: BlocConsumer<AiAssistantBloc, AiAssistantState>(
        listener: (context, state) {
          if (state.messages.length > _previousMessageCount) {
            _previousMessageCount = state.messages.length;
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          if (state.status.isInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              const _AssistantHero(),
              Expanded(
                child: state.messages.isEmpty
                    ? _EmptyAssistantState(prompts: _prompts, onPromptTap: _sendMessage)
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: state.messages.length + (state.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (state.isLoading && index == 0) {
                            return const Align(alignment: Alignment.centerLeft, child: _TypingIndicator());
                          }
                          final messageIndex = state.isLoading ? index - 1 : index;
                          return _MessageBubble(message: state.messages[messageIndex]);
                        },
                      ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 12 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _messageFocusNode,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Ask about budget, areas, or property types...',
                          prefixIcon: const Icon(Icons.auto_awesome_outlined),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed: state.isLoading ? null : () => _sendMessage(),
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AssistantHero extends StatelessWidget {
  const _AssistantHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text('Smart property advisor', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ask for a shortlist strategy, budget guidance, area comparison, or filter recommendations.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
}

class _EmptyAssistantState extends StatelessWidget {
  final List<String> prompts;
  final ValueChanged<String> onPromptTap;

  const _EmptyAssistantState({required this.prompts, required this.onPromptTap});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.chat_bubble_outline_rounded, size: 72),
        const SizedBox(height: 12),
        Text('Start with a goal', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(
          'The assistant can translate your needs into concrete search filters and explain tradeoffs.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        ...prompts.map(
          (prompt) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton.icon(
              onPressed: () => onPromptTap(prompt),
              icon: const Icon(Icons.north_east_rounded, size: 18),
              label: Text(prompt),
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final AssistantMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 20),
          ),
        ),
        child: isUser
            ? Text(message.text, style: const TextStyle(color: Colors.white, height: 1.35))
            : MarkdownBody(
                data: message.text,
                selectable: true,
                styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                  p: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
              ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)..repeat();
    _dotAnimations = List.generate(
      3,
      (index) => Tween<double>(begin: 0.35, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.2, 0.6 + index * 0.2, curve: Curves.easeInOut),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (index) => FadeTransition(
            opacity: _dotAnimations[index],
            child: Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
