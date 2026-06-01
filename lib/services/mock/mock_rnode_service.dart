import 'dart:async';
import 'dart:math';

import '../rnode_service.dart';

/// Mock implementation of [RNodeService] for development and testing.
///
/// Simulates RNode connection, signal metrics, and packet stats.
class MockRNodeService implements RNodeService {
  final _connectionController = StreamController<bool>.broadcast();
  final _signalController = StreamController<RNodeSignalMetrics>.broadcast();
  final _packetController = StreamController<RNodePacketStats>.broadcast();

  final _rng = Random();
  Timer? _metricsTimer;
  bool _connected = false;

  double? _frequency;
  double? _bandwidth;
  int? _spreadingFactor;
  int? _txPower;

  @override
  bool get isConnected => _connected;

  @override
  double? get frequency => _frequency;

  @override
  double? get bandwidth => _bandwidth;

  @override
  int? get spreadingFactor => _spreadingFactor;

  @override
  int? get txPower => _txPower;

  @override
  Stream<bool> get connectionChanged => _connectionController.stream;

  @override
  Stream<RNodeSignalMetrics> get signalMetrics => _signalController.stream;

  @override
  Stream<RNodePacketStats> get packetStats => _packetController.stream;

  @override
  Future<List<RNodeDevice>> scanDevices() async {
    await Future.delayed(const Duration(seconds: 2));
    return [
      RNodeDevice(
        id: 'usb_RNode_001',
        name: 'RNode USB-C 915MHz',
        type: RNodeConnectionType.usb,
      ),
      RNodeDevice(
        id: 'ble_RNode_002',
        name: 'RNode BLE 868MHz',
        type: RNodeConnectionType.bluetooth,
      ),
      RNodeDevice(
        id: 'usb_RNode_003',
        name: 'RNode USB-C 433MHz',
        type: RNodeConnectionType.usb,
      ),
    ];
  }

  @override
  Future<void> connect(String deviceId) async {
    // Simulate connection handshake
    await Future.delayed(const Duration(seconds: 1));
    _connected = true;

    // Set default params based on device
    if (deviceId.contains('915')) {
      _frequency = 915.0;
    } else if (deviceId.contains('868')) {
      _frequency = 868.0;
    } else if (deviceId.contains('433')) {
      _frequency = 433.0;
    }
    _bandwidth = 125.0;
    _spreadingFactor = 9;
    _txPower = 14;

    _connectionController.add(true);

    // Start metrics simulation
    _startMetricsSimulation();
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    _metricsTimer?.cancel();
    _connectionController.add(false);
  }

  @override
  Future<void> configure({
    double? frequency,
    double? bandwidth,
    int? spreadingFactor,
    int? txPower,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (frequency != null) _frequency = frequency;
    if (bandwidth != null) _bandwidth = bandwidth;
    if (spreadingFactor != null) _spreadingFactor = spreadingFactor;
    if (txPower != null) _txPower = txPower;
  }

  @override
  Future<void> flashFirmware(String firmwarePath) async {
    // Simulate flash process
    await Future.delayed(const Duration(seconds: 10));
  }

  void _startMetricsSimulation() {
    _metricsTimer?.cancel();

    var sent = 0;
    var received = 0;

    _metricsTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_connected) return;

      // Simulate signal metrics
      final snr = 4.0 + _rng.nextDouble() * 8.0;
      final rssi = -120 + _rng.nextDouble() * 40.0;
      _signalController.add(RNodeSignalMetrics(
        snr: snr,
        rssi: rssi,
        timestamp: DateTime.now(),
      ));

      // Simulate packet stats
      sent += _rng.nextInt(3);
      received += _rng.nextInt(3);
      _packetController.add(RNodePacketStats(
        sent: sent,
        received: received,
        lost: (sent - received).clamp(0, 999),
        airtime: _rng.nextDouble() * 0.5,
        timestamp: DateTime.now(),
      ));
    });
  }

  @override
  void dispose() {
    disconnect();
    _connectionController.close();
    _signalController.close();
    _packetController.close();
  }
}
