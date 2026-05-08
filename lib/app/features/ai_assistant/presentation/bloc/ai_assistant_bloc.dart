import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nawy_ai_app/app/core/models/status.dart';
import 'package:nawy_ai_app/app/features/ai_assistant/domain/ai_service.dart';
import 'package:nawy_ai_app/app/features/ai_assistant/presentation/models/assistant_message.dart';

part 'ai_assistant_event.dart';
part 'ai_assistant_state.dart';

class AiAssistantBloc extends Bloc<AiAssistantEvent, AiAssistantState> {
  final AiService _aiService;

  AiAssistantBloc(this._aiService) : super(AiAssistantState.initial()) {
    on<StartNewChatEvent>(_onStartNewChat);
    on<SendMessageEvent>(_onSendMessage);
  }

  Future<void> _onStartNewChat(StartNewChatEvent event, Emitter<AiAssistantState> emit) async {
    emit(state.copyWith(status: const Success<void>(null), messages: []));
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<AiAssistantState> emit) async {
    try {
      // Add user message to chat UI immediately
      final userMessage = AssistantMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: event.message,
        isUser: true,
        timestamp: DateTime.now(),
      );

      final updatedMessages = [userMessage, ...state.messages];
      emit(state.copyWith(status: const Loading<void>(), messages: updatedMessages));

      // Prepare history for AI
      // Using 'text' as the key to match the expected format
      final history = state.messages.reversed.map((msg) => {
        'role': msg.isUser ? 'user' : 'model',
        'text': msg.text,
      }).toList();

      // Send message to AI via Supabase Function
      final responseText = await _aiService.sendMessage(event.message, history);

      // Create AI response message
      final aiMessage = AssistantMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      final finalMessages = [aiMessage, ...updatedMessages];
      emit(state.copyWith(status: const Success<void>(null), messages: finalMessages));
    } catch (error) {
      // Handle error by showing a message in the chat
      final errorMessage = AssistantMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Sorry, I encountered an error: $error',
        isUser: false,
        timestamp: DateTime.now(),
      );

      final finalMessages = [errorMessage, ...state.messages];
      emit(
        state.copyWith(status: Failure<void>('Failed to send message: $error'), messages: finalMessages),
      );
    }
  }
}
