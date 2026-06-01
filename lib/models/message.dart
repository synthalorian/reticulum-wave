import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

/// Status of an LXMF message in its lifecycle.
enum MessageStatus {
  draft,
  sending,
  sent,
  delivered,
  read,
  failed,
}

/// A single LXMF message in a conversation.
@freezed
class LxmfMessage with _$LxmfMessage {
  const factory LxmfMessage({
    /// Unique message ID (UUID v4)
    required String id,

    /// Reticulum hash of the sender
    required String senderHash,

    /// Reticulum hash of the recipient
    required String recipientHash,

    /// Message content (plaintext or markdown)
    required String content,

    /// When the message was created / sent
    @_DateTimeConverter() required DateTime timestamp,

    /// Current delivery status
    @Default(MessageStatus.draft) MessageStatus status,

    /// Optional file attachment paths (local or remote)
    @Default([]) List<String> attachments,

    /// Optional voice message audio path
    String? voicePath,

    /// Whether this message was sent by the local user
    @Default(false) bool isOutgoing,

    /// Reply-to message ID (if this is a reply)
    String? replyToId,
  }) = _LxmfMessage;

  factory LxmfMessage.fromJson(Map<String, dynamic> json) =>
      _$LxmfMessageFromJson(json);
}

class _DateTimeConverter implements JsonConverter<DateTime, String> {
  const _DateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toIso8601String();
}
