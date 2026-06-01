import 'dart:async';

/// Abstract interface for RNode hardware management.
///
/// Handles USB/Bluetooth connection, LoRa configuration,
/// firmware flashing, and signal monitoring.
abstract class RNodeService {
  /// Whether an RNode is currently connected.
  bool get isConnected;

  /// Current LoRa frequency in MHz.
  double? get frequency;

  /// Current bandwidth in kHz.
  double? get bandwidth;

  /// Current spreading factor (7-12).
  int? get spreadingFactor;

  /// Current TX power in dBm.
  int? get txPower;

  /// Stream of connection state changes.
  Stream<bool> get connectionChanged;

  /// Stream of signal metrics (SNR, RSSI).
  Stream<RNodeSignalMetrics> get signalMetrics;

  /// Stream of packet statistics.
  Stream<RNodePacketStats> get packetStats;

  /// Scan for available RNode devices (USB + Bluetooth).
  Future<List<RNodeDevice>> scanDevices();

  /// Connect to an RNode by device ID.
  Future<void> connect(String deviceId);

  /// Disconnect from the current RNode.
  Future<void> disconnect();

  /// Configure LoRa parameters.
  Future<void> configure({
    double? frequency,
    double? bandwidth,
    int? spreadingFactor,
    int? txPower,
  });

  /// Flash firmware to the connected RNode.
  Future<void> flashFirmware(String firmwarePath);

  /// Dispose of resources.
  void dispose();
}

/// RNode device descriptor.
class RNodeDevice {
  final String id;
  final String name;
  final RNodeConnectionType type;

  RNodeDevice({
    required this.id,
    required this.name,
    required this.type,
  });
}

enum RNodeConnectionType { usb, bluetooth }

/// Signal metrics from RNode.
class RNodeSignalMetrics {
  final double snr;
  final double rssi;
  final DateTime timestamp;

  RNodeSignalMetrics({
    required this.snr,
    required this.rssi,
    required this.timestamp,
  });
}

/// Packet statistics from RNode.
class RNodePacketStats {
  final int sent;
  final int received;
  final int lost;
  final double airtime; // seconds
  final DateTime timestamp;

  RNodePacketStats({
    required this.sent,
    required this.received,
    required this.lost,
    required this.airtime,
    required this.timestamp,
  });
}
