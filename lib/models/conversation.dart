import 'package:freezed_annotation/freezed_annotation.dart';
import 'message.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

/// A conversation thread with a specific peer or group.
@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    /// Unique conversation ID (peer hash for 1:1, UUID for groups)
    required String id,

    /// Display name for this conversation
    required String name,

    /// Reticulum hash of the primary peer (null for group chats)
    String? peerHash,

    /// Messages in this conversation, ordered oldest → newest
    @Default([]) List<LxmfMessage> messages,

    /// Number of unread messages
    @Default(0) int unreadCount,

    /// Whether this conversation is pinned to the top
    @Default(false) bool isPinned,

    /// Whether this is a group conversation
    @Default(false) bool isGroup,

    /// For groups: list of member hashes
    @Default([]) List<String> memberHashes,

    /// When the conversation was created
    @_DateTimeConverter() required DateTime createdAt,

    /// When the last message was received/sent
    @_DateTimeConverter() DateTime? lastActivityAt,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}

class _DateTimeConverter implements JsonConverter<DateTime, String> {
  const _DateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toIso8601String();
}
