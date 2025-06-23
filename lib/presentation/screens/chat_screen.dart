import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:beertinder/data/services/auth_service.dart';
import '../../core/data/models/message_model.dart';
import '../../domain/entities/user.dart';

class ChatScreen extends StatefulWidget {
  final User matchedUser;
  const ChatScreen({super.key, required this.matchedUser});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;
  String? _matchId;
  List<MessageModel> messages = [];

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final currentId = AuthService.currentUserId;
    if (currentId == null) return;
    // get match record id
    final data = await _supabase.from('likes')
        .select('id')
        .eq('from_user', currentId)
        .eq('to_user', widget.matchedUser.id)
        .limit(1);
    String? matchId;
    if ((data as List).isNotEmpty) {
      matchId = (data[0])['id'] as String;
    }
    if (matchId != null) {
      setState(() => _matchId = matchId);
      await _loadMessages();
      _listenForMessages();
    }
  }

  Future<void> _loadMessages() async {
    if (_matchId == null) return;
    final data = await _supabase.from('messages').select().eq('match_id', _matchId!).order('sent_at', ascending: true);
    final list = (data as List)
        .map((m) => MessageModel.fromMap(m as Map<String, dynamic>))
        .toList();
    setState(() => messages = list);
  }

  void _listenForMessages() {
    if (_matchId == null) return;
    _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('match_id', _matchId!)
        .listen((List<Map<String, dynamic>> newRecords) {
          final newMessages = newRecords
              .map((m) => MessageModel.fromMap(m))
              .toList();
          setState(() => messages = newMessages);
        });
  }

  Future<void> _sendMessage() async {
    if (_matchId == null) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final currentId = AuthService.currentUserId!;
    await _supabase.from('messages').insert({
      'match_id': _matchId!,
      'sender_id': currentId,
      'text': text,
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.matchedUser.name),
        previousPageTitle: 'Back',
        backgroundColor: CupertinoColors.systemBackground,
        border: null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: messages.length,
                reverse: false,
                itemBuilder: (context, index) {
                  final m = messages[index];
                  final isMe = m.senderId == AuthService.currentUserId;
                  return Align(
                    alignment: isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isMe
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGrey4,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        m.text ?? '',
                        style: TextStyle(
                          color: isMe
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          fontSize: 16,
                        ),
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
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
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
                      color: CupertinoColors.activeBlue,
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
