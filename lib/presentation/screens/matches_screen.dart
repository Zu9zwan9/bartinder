import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/matches/matches_bloc.dart';
import '../blocs/matches/matches_event.dart';
import '../blocs/matches/matches_state.dart';
import '../../domain/entities/user.dart';
import 'chat_screen.dart';

/// Screen showing user's matches
class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  late final MatchesBloc _matchesBloc;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _matchesBloc = MatchesBloc.withDefaultDependencies()..add(const LoadMatches());
  }

  @override
  void dispose() {
    _matchesBloc.close();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _matchesBloc,
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Matches'),
        ),
        child: SafeArea(
          child: BlocConsumer<MatchesBloc, MatchesState>(
            listener: (context, state) {
              if (state is MessageSent) {
                showCupertinoDialog(
                  context: context,
                  builder: (_) => CupertinoAlertDialog(
                    title: const Text('Message Sent'),
                    content: const Text('Your message has been sent!'),
                    actions: [CupertinoDialogAction(
                      child: const Text('OK'),
                      onPressed: () => Navigator.of(context).pop(),
                    )],
                  ),
                );
              } else if (state is InviteSent) {
                showCupertinoDialog(
                  context: context,
                  builder: (_) => CupertinoAlertDialog(
                    title: const Text('Invitation Sent'),
                    content: Text('Invited to ${state.barName}!'),
                    actions: [CupertinoDialogAction(
                      child: const Text('OK'),
                      onPressed: () => Navigator.of(context).pop(),
                    )],
                  ),
                );
              } else if (state is MatchesError) {
                showCupertinoDialog(
                  context: context,
                  builder: (_) => CupertinoAlertDialog(
                    title: const Text('Error'),
                    content: Text(state.message),
                    actions: [CupertinoDialogAction(
                      child: const Text('OK'),
                      onPressed: () => Navigator.of(context).pop(),
                    )],
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is MatchesLoading) {
                return const Center(child: CupertinoActivityIndicator());
              } else if (state is MatchesLoaded) {
                final matches = state.matches;
                if (matches.isEmpty) {
                  return const Center(child: Text('No matches yet.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final user = matches[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(user.photoUrl),
                            radius: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${user.name}, ${user.age}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: CupertinoColors.black)),
                                const SizedBox(height: 4),
                                Text(user.favoriteBeer,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: CupertinoColors.systemGrey)),
                              ],
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: const Icon(CupertinoIcons.chat_bubble_2_fill),
                            onPressed: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (_) => ChatScreen(matchedUser: user),
                                ),
                              );
                            },
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: const Icon(CupertinoIcons.location_solid),
                            onPressed: () => _matchesBloc.add(InviteToBar(user.id, '1')),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return const Center(child: CupertinoActivityIndicator());
            },
          ),
        ),
      ),
    );
  }

  void _showMessageDialog(User user) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Message ${user.name}'),
        content: CupertinoTextField(
          controller: _messageController,
          placeholder: 'Type your message',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Send'),
            onPressed: () {
              final message = _messageController.text.trim();
              if (message.isNotEmpty) {
                _matchesBloc.add(SendMessage(user.id, message));
              }
              _messageController.clear();
              Navigator.of(ctx).pop();
            },
          ),
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}
