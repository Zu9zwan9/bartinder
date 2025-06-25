import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/auth_service.dart';
import '../../domain/entities/user.dart' as domain;
import '../blocs/chat/chat_bloc.dart';
import '../blocs/chat/chat_event.dart';
import '../blocs/chat/chat_state.dart';
import '../theme/theme.dart';
import '../theme/fonts.dart';

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

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<ChatBloc>().add(SendTextMessage(text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
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
              child: BlocBuilder<ChatBloc, ChatState>(
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
                    return messages.isEmpty
                        ? Center(
                            child: Text(
                              'Start a conversation!',
                              style: AppTheme.bodyStyle.copyWith(
                                color: AppTheme.secondaryTextColor(context),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            itemCount: messages.length,
                            reverse: false,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isMe =
                                  message.senderId == AuthService.currentUserId;
                              return Align(
                                alignment: isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? AppTheme.systemBlue(context)
                                        : AppTheme.isDarkMode(context)
                                        ? AppTheme.systemGray4(context)
                                        : AppTheme.systemGray5(context),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Text(
                                    message.text ?? message.content ?? '',
                                    style: AppTheme.bodyStyle.copyWith(
                                      color: isMe
                                          ? Colors.white
                                          : AppTheme.textColor(context),
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              );
                            },
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
