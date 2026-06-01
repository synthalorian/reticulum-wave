import 'package:freezed_annotation/freezed_annotation.dart';

part 'identity.freezed.dart';
part 'identity.g.dart';

/// A Reticulum identity — the cryptographic identity used for
/// LXMF addressing and end-to-end encryption.
@freezed
class ReticulumIdentity with _$ReticulumIdentity {
  const factory ReticulumIdentity({
    /// Human-readable name chosen by the user
    required String name,

    /// Reticulum address hash (hex string, 32 bytes)
    required String hash,

    /// Ed25519 public key (hex string, 32 bytes)
    required String publicKey,

    /// Optional display name / callsign
    String? displayName,

    /// When this identity was created
    @_DateTimeConverter() required DateTime createdAt,

    /// Whether this is the active identity for sending
    @Default(false) bool isActive,
  }) = _ReticulumIdentity;

  factory ReticulumIdentity.fromJson(Map<String, dynamic> json) =>
      _$ReticulumIdentityFromJson(json);
}

class _DateTimeConverter implements JsonConverter<DateTime, String> {
  const _DateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toIso8601String();
}
