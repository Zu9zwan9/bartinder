import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/auth_service.dart';
import '../../domain/entities/user.dart' as domain;
import '../blocs/chat/chat_bloc.dart';
import '../blocs/chat/chat_event.dart';
import '../blocs/chat/chat_state.dart';
import '../theme/theme.dart';

class ChatScreen extends StatelessWidget {
  final domain.User matchedUser;
  const ChatScreen({super.key, required this.matchedUser});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChatBloc.withDefaultDependencies(matchedUser.id)
            ..add(const LoadMessages()),
      child: _ChatScreenContent(matchedUser: matchedUser),
    );
  }
}

class _ChatScreenContent extends StatefulWidget {
  final domain.User matchedUser;
  const _ChatScreenContent({required this.matchedUser});

  @override
  _ChatScreenContentState createState() => _ChatScreenContentState();
}

class _ChatScreenContentState extends State<_ChatScreenContent> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _editingMessageId;
  String? _editingInitialText;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatBloc>().add(SendTextMessage(text));
    _controller.clear();
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

  void _showMessageActions(BuildContext context, String messageId, String initialText) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showEditDialog(context, messageId, initialText);
            },
            child: const Text('Edit'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<ChatBloc>().add(DeleteMessage(messageId));
            },
            child: const Text('Delete'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, String messageId, String initialText) {
    final editController = TextEditingController(text: initialText);
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Edit Message'),
        content: CupertinoTextField(
          controller: editController,
          autofocus: true,
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              final newText = editController.text.trim();
              if (newText.isNotEmpty && newText != initialText) {
                context.read<ChatBloc>().add(EditMessage(messageId: messageId, newText: newText));
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(messageDay).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService.currentUserId;
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          widget.matchedUser.name,
          style: AppTheme.navTitle.copyWith(color: AppTheme.textColor(context)),
        ),
        previousPageTitle: 'Back',
        backgroundColor: AppTheme.isDarkMode(context)
            ? AppTheme.darkCardColor
            : Colors.white,
        border: null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state is ChatLoaded) _scrollToBottom();
                },
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return Center(
                      child: CupertinoActivityIndicator(
                        color: AppTheme.isDarkMode(context)
                            ? AppTheme.primaryColor
                            : AppTheme.primaryDarkColor,
                      ),
                    );
                  } else if (state is ChatError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.errorColor(context),
                        ),
                      ),
                    );
                  } else if (state is ChatLoaded) {
                    final messages = state.messages;
                    if (messages.isEmpty) {
                      return Center(
                        child: Text(
                          'Start a conversation!',
                          style: AppTheme.bodyStyle.copyWith(
                            color: AppTheme.secondaryTextColor(context),
                          ),
                        ),
                      );
                    }
                    List<Widget> messageWidgets = [];
                    DateTime? lastDate;
                    for (int i = 0; i < messages.length; i++) {
                      final message = messages[i];
                      final isMe = message.senderId == currentUserId;
                      final showDateSeparator = lastDate == null ||
                        lastDate.year != message.createdAt.year ||
                        lastDate.month != message.createdAt.month ||
                        lastDate.day != message.createdAt.day;
                      if (showDateSeparator) {
                        messageWidgets.add(
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Center(
                              child: Text(
                                _formatDateSeparator(message.createdAt),
                                style: AppTheme.bodyStyle.copyWith(
                                  color: AppTheme.secondaryTextColor(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                        lastDate = message.createdAt;
                      }
                      messageWidgets.add(
                        GestureDetector(
                          onLongPress: isMe
                              ? () => _showMessageActions(context, message.id, message.text ?? message.content ?? '')
                              : null,
                          child: Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? AppTheme.systemBlue(context)
                                    : AppTheme.isDarkMode(context)
                                        ? AppTheme.systemGray4(context)
                                        : AppTheme.systemGray5(context),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: Text(
                                      message.text ?? message.content ?? '',
                                      style: AppTheme.bodyStyle.copyWith(
                                        color: isMe ? Colors.white : AppTheme.textColor(context),
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatTime(message.createdAt),
                                    style: AppTheme.bodyStyle.copyWith(
                                      color: isMe ? Colors.white70 : AppTheme.secondaryTextColor(context),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      children: messageWidgets,
                    );
                  }
                  return Center(
                    child: Text(
                      'Start a conversation!',
                      style: AppTheme.bodyStyle.copyWith(
                        color: AppTheme.secondaryTextColor(context),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 12,
                right: 8,
                top: 8,
                bottom: 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _controller,
                      placeholder: 'Type a message',
                      placeholderStyle: AppTheme.bodyStyle.copyWith(
                        color: AppTheme.isDarkMode(context)
                            ? AppTheme.darkSecondaryTextColor
                            : AppTheme.lightSecondaryTextColor,
                      ),
                      style: AppTheme.bodyStyle.copyWith(
                        color: AppTheme.textColor(context),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.isDarkMode(context)
                            ? AppTheme.darkSurfaceColor
                            : AppTheme.systemGray6(context),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: _sendMessage,
                    child: Icon(
                      CupertinoIcons.arrow_up_circle_fill,
                      color: AppTheme.primaryColor,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
