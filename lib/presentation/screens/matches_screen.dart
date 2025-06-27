import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../blocs/matches/matches_bloc.dart';
import '../blocs/matches/matches_event.dart';
import '../blocs/matches/matches_state.dart';
import '../theme/theme.dart';
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
    _matchesBloc = MatchesBloc.withDefaultDependencies()
      ..add(const LoadMatches());
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
        backgroundColor: AppTheme.backgroundColor(context),
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            'Matches',
            style: AppTheme.navTitle.copyWith(
              color: AppTheme.textColor(context),
            ),
          ),
          backgroundColor: AppTheme.isDarkMode(context)
              ? AppTheme.darkCardColor
              : Colors.white,
          border: null,
        ),
        child: SafeArea(
          child: BlocConsumer<MatchesBloc, MatchesState>(
            listener: (context, state) {
              if (state is MessageSent) {
                showCupertinoDialog(
                  context: context,
                  builder: (_) => CupertinoAlertDialog(
                    title: Text(
                      'Message Sent',
                      style: AppTheme.subtitleStyle.copyWith(
                        color: AppTheme.textColor(context),
                      ),
                    ),
                    content: Text(
                      'Your message has been sent!',
                      style: AppTheme.bodyStyle.copyWith(
                        color: AppTheme.textColor(context),
                      ),
                    ),
                    actions: [
                      CupertinoDialogAction(
                        child: Text(
                          'OK',
                          style: AppTheme.buttonStyle.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              } else if (state is InviteSent) {
                showCupertinoDialog(
                  context: context,
                  builder: (_) => CupertinoAlertDialog(
                    title: Text(
                      'Invitation Sent',
                      style: AppTheme.subtitleStyle.copyWith(
                        color: AppTheme.textColor(context),
                      ),
                    ),
                    content: Text(
                      'Invited to ${state.barName}!',
                      style: AppTheme.bodyStyle.copyWith(
                        color: AppTheme.textColor(context),
                      ),
                    ),
                    actions: [
                      CupertinoDialogAction(
                        child: Text(
                          'OK',
                          style: AppTheme.buttonStyle.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              } else if (state is MatchesError) {
                showCupertinoDialog(
                  context: context,
                  builder: (_) => CupertinoAlertDialog(
                    title: Text(
                      'Error',
                      style: AppTheme.subtitleStyle.copyWith(
                        color: AppTheme.textColor(context),
                      ),
                    ),
                    content: Text(
                      state.message,
                      style: AppTheme.bodyStyle.copyWith(
                        color: AppTheme.textColor(context),
                      ),
                    ),
                    actions: [
                      CupertinoDialogAction(
                        child: Text(
                          'OK',
                          style: AppTheme.buttonStyle.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is MatchesLoading) {
                return Center(
                  child: CupertinoActivityIndicator(
                    color: AppTheme.isDarkMode(context)
                        ? AppTheme.primaryColor
                        : AppTheme.primaryDarkColor,
                  ),
                );
              } else if (state is MatchesLoaded) {
                final matches = state.matches;
                if (matches.isEmpty) {
                  return Center(
                    child: Text(
                      'No matches yet.',
                      style: AppTheme.bodyStyle.copyWith(
                        color: AppTheme.secondaryTextColor(context),
                      ),
                    ),
                  );
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
                        color: AppTheme.cardColor(context),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.isDarkMode(context)
                                ? Colors.black.withOpacity(0.2)
                                : Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Builder(
                            builder: (context) {
                              final url = user.photoUrl;
                              final hasPhoto = url.isNotEmpty;
                              final isSvg =
                                  hasPhoto &&
                                  url.toLowerCase().endsWith('.svg');

                              return Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppTheme.isDarkMode(context)
                                      ? AppTheme.systemGray4(context)
                                      : AppTheme.systemGray5(context),
                                  shape: BoxShape.circle,
                                ),
                                child: hasPhoto
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: isSvg
                                            ? SvgPicture.network(
                                                url,
                                                fit: BoxFit.cover,
                                                placeholderBuilder:
                                                    (
                                                      BuildContext context,
                                                    ) => Center(
                                                      child: CupertinoActivityIndicator(
                                                        color:
                                                            AppTheme.iconColor(
                                                              context,
                                                            ),
                                                      ),
                                                    ),
                                              )
                                            : Image.network(
                                                url,
                                                fit: BoxFit.cover,
                                                loadingBuilder:
                                                    (
                                                      context,
                                                      child,
                                                      loadingProgress,
                                                    ) {
                                                      if (loadingProgress ==
                                                          null) {
                                                        return child;
                                                      }
                                                      return Center(
                                                        child: CupertinoActivityIndicator(
                                                          color:
                                                              AppTheme.iconColor(
                                                                context,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Icon(
                                                        CupertinoIcons
                                                            .person_fill,
                                                        size: 24,
                                                        color:
                                                            AppTheme.iconColor(
                                                              context,
                                                            ),
                                                      );
                                                    },
                                              ),
                                      )
                                    : Icon(
                                        CupertinoIcons.person_fill,
                                        size: 24,
                                        color: AppTheme.iconColor(context),
                                      ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${user.name}, ${user.age}',
                                  style: AppTheme.headline.copyWith(
                                    color: AppTheme.textColor(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.favoriteBeer,
                                  style: AppTheme.subhead.copyWith(
                                    color: AppTheme.secondaryTextColor(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Icon(
                              CupertinoIcons.chat_bubble_2_fill,
                              color: AppTheme.primaryColor,
                              size: 26,
                            ),
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
                            child: Icon(
                              CupertinoIcons.location_solid,
                              color: AppTheme.accentColor,
                              size: 26,
                            ),
                            onPressed: () =>
                                _matchesBloc.add(InviteToBar(user.id, '1')),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return Center(
                child: CupertinoActivityIndicator(
                  color: AppTheme.isDarkMode(context)
                      ? AppTheme.primaryColor
                      : AppTheme.primaryDarkColor,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
