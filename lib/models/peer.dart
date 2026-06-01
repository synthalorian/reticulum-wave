import 'package:freezed_annotation/freezed_annotation.dart';

part 'peer.freezed.dart';
part 'peer.g.dart';

/// A discovered Reticulum peer on the mesh network.
@freezed
class Peer with _$Peer {
  const factory Peer({
    /// Reticulum address hash
    required String hash,

    /// Human-readable name (if announced)
    String? name,

    /// When this peer was last seen on the network
    @_DateTimeConverter() required DateTime lastSeen,

    /// Link quality indicator (0.0 - 1.0, higher is better)
    @Default(0.0) double linkQuality,

    /// Number of hops to reach this peer
    @Default(0) int hops,

    /// Services announced by this peer
    @Default([]) List<String> services,

    /// Whether this peer is currently reachable
    @Default(false) bool isOnline,

    /// Whether this peer is favorited
    @Default(false) bool isFavorite,

    /// Optional GPS coordinates (lat, lon)
    double? latitude,
    double? longitude,
  }) = _Peer;

  factory Peer.fromJson(Map<String, dynamic> json) =>
      _$PeerFromJson(json);
}

class _DateTimeConverter implements JsonConverter<DateTime, String> {
  const _DateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toIso8601String();
}
