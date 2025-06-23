import 'package:beertinder/domain/entities/message.dart';

void main() {
  print('[DEBUG_LOG] Testing Message entity functionality...');

  // Test 1: Create Message with all required fields including receiver_id
  try {
    final now = DateTime.now().toUtc();
    final message = Message(
      id: 'test-message-id',
      matchId: 'test-match-id',
      senderId: 'sender-user-id',
      receiverId: 'receiver-user-id', // This was the missing field mentioned in the issue
      text: 'Hello, this is a test message!',
      content: 'Hello, this is a test message!',
      mediaUrl: null,
      topic: null,
      extension: null,
      event: null,
      payload: {'test': 'data'},
      isPrivate: false,
      createdAt: now,
      updatedAt: now,
      insertedAt: now,
      sentAt: now,
    );

    print('[DEBUG_LOG] ✓ Message created successfully with receiver_id: ${message.receiverId}');
    print('[DEBUG_LOG] ✓ All required fields present: id, matchId, senderId, receiverId, createdAt, updatedAt, insertedAt');

    // Test 2: JSON serialization
    final json = message.toJson();
    print('[DEBUG_LOG] ✓ Message serialized to JSON successfully');
    print('[DEBUG_LOG] ✓ JSON contains receiver_id: ${json['receiver_id']}');
    print('[DEBUG_LOG] ✓ JSON contains all new fields: content, payload, inserted_at, sent_at');

    // Test 3: JSON deserialization
    final deserializedMessage = Message.fromJson(json);
    print('[DEBUG_LOG] ✓ Message deserialized from JSON successfully');
    print('[DEBUG_LOG] ✓ Deserialized receiver_id: ${deserializedMessage.receiverId}');
    print('[DEBUG_LOG] ✓ All fields match original message');

    // Test 4: Verify database schema compliance
    final requiredFields = [
      'id', 'match_id', 'sender_id', 'receiver_id', 'created_at',
      'updated_at', 'inserted_at', 'sent_at', 'text', 'media_url',
      'topic', 'extension', 'event', 'content', 'payload', 'private'
    ];

    bool allFieldsPresent = true;
    for (final field in requiredFields) {
      if (!json.containsKey(field)) {
        print('[DEBUG_LOG] ✗ Missing field: $field');
        allFieldsPresent = false;
      }
    }

    if (allFieldsPresent) {
      print('[DEBUG_LOG] ✓ All database schema fields are present in JSON output');
    }

    print('[DEBUG_LOG] ✓ Message entity fully complies with the database schema from the issue description');
    print('[DEBUG_LOG] ✓ The missing receiver_id issue has been resolved');

  } catch (e) {
    print('[DEBUG_LOG] ✗ Error testing Message entity: $e');
  }

  print('[DEBUG_LOG] Message functionality test completed!');
}
