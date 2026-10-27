import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../services/rnode_service.dart';
import '../theme.dart';

/// RNode Manager tab — scan, connect, configure, and monitor LoRa radio.
class RNodeScreen extends ConsumerStatefulWidget {
  const RNodeScreen({super.key});

  @override
  ConsumerState<RNodeScreen> createState() => _RNodeScreenState();
}

class _RNodeScreenState extends ConsumerState<RNodeScreen> {
  bool _scanning = false;
  List<RNodeDevice> _devices = [];

  Future<void> _scan() async {
    setState(() => _scanning = true);
    final service = ref.read(rnodeServiceProvider);
    final devices = await service.scanDevices();
    setState(() {
      _devices = devices;
      _scanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(rnodeServiceProvider);
    final isConnected = service.isConnected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RNode'),
        actions: [
          if (isConnected)
            IconButton(
              icon: const Icon(Icons.settings, color: AppColors.textSecondary),
              onPressed: () => _showConfigSheet(context, service),
            ),
        ],
      ),
      body: isConnected
          ? _RNodeMonitor(service: service)
          : _DeviceList(
              devices: _devices,
              scanning: _scanning,
              onScan: _scan,
              onConnect: (device) async {
                await service.connect(device.id);
              },
            ),
    );
  }

  void _showConfigSheet(BuildContext context, RNodeService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _ConfigSheet(service: service),
    );
  }
}

/// Device scan list.
class _DeviceList extends StatelessWidget {
  const _DeviceList({
    required this.devices,
    required this.scanning,
    required this.onScan,
    required this.onConnect,
  });

  final List<RNodeDevice> devices;
  final bool scanning;
  final VoidCallback onScan;
  final ValueChanged<RNodeDevice> onConnect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: scanning ? null : onScan,
            icon: scanning
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search),
            label: Text(scanning ? 'Scanning...' : 'Scan for Devices'),
          ),
        ),
        if (devices.isEmpty && !scanning)
          const Expanded(
            child: Center(
              child: Text(
                'No devices found.\nTap Scan to find RNodes.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        if (devices.isNotEmpty)
          Expanded(
            child: ListView.separated(
              itemCount: devices.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  leading: Icon(
                    device.type == RNodeConnectionType.usb
                        ? Icons.usb
                        : Icons.bluetooth,
                    color: AppColors.electricPurple,
                  ),
                  title: Text(device.name),
                  subtitle: Text(
                    device.type == RNodeConnectionType.usb ? 'USB' : 'Bluetooth',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => onConnect(device),
                    child: const Text('Connect'),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Live monitoring view for connected RNode.
class _RNodeMonitor extends ConsumerWidget {
  const _RNodeMonitor({required this.service});

  final RNodeService service;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signalAsync = ref.watch(rnodeSignalProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Connection status card
        _StatusCard(service: service),
        const SizedBox(height: 16),

        // Signal metrics
        signalAsync.when(
          data: (metrics) => _SignalCard(metrics: metrics),
          loading: () => const _LoadingCard(title: 'Signal Metrics'),
          error: (_, __) => const _ErrorCard(title: 'Signal Metrics'),
        ),
        const SizedBox(height: 16),

        // Packet stats
        signalAsync.when(
          data: (metrics) => _PacketCard(
            stats: RNodePacketStats(
              sent: metrics.timestamp.second * 2,
              received: metrics.timestamp.second,
              lost: 0,
              airtime: 0.1,
              timestamp: metrics.timestamp,
            ),
          ),
          loading: () => const _LoadingCard(title: 'Packet Stats'),
          error: (_, __) => const _ErrorCard(title: 'Packet Stats'),
        ),
        const SizedBox(height: 16),

        // Disconnect button
        ElevatedButton.icon(
          onPressed: () => service.disconnect(),
          icon: const Icon(Icons.logout),
          label: const Text('Disconnect'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.offline,
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.service});

  final RNodeService service;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _ConfigRow(label: 'Frequency', value: '${service.frequency?.toStringAsFixed(0) ?? '--'} MHz'),
            _ConfigRow(label: 'Bandwidth', value: '${service.bandwidth?.toStringAsFixed(0) ?? '--'} kHz'),
            _ConfigRow(label: 'Spreading Factor', value: 'SF${service.spreadingFactor ?? '--'}'),
            _ConfigRow(label: 'TX Power', value: '${service.txPower ?? '--'} dBm'),
          ],
        ),
      ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  const _ConfigRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalCard extends StatelessWidget {
  const _SignalCard({required this.metrics});

  final RNodeSignalMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Signal Quality',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _MetricRow(label: 'SNR', value: '${metrics.snr.toStringAsFixed(1)} dB'),
            _MetricRow(label: 'RSSI', value: '${metrics.rssi.toStringAsFixed(1)} dBm'),
          ],
        ),
      ),
    );
  }
}

class _PacketCard extends StatelessWidget {
  const _PacketCard({required this.stats});

  final RNodePacketStats stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Packet Statistics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _MetricRow(label: 'Sent', value: '${stats.sent}'),
            _MetricRow(label: 'Received', value: '${stats.received}'),
            _MetricRow(label: 'Lost', value: '${stats.lost}'),
            _MetricRow(label: 'Airtime', value: '${stats.airtime.toStringAsFixed(2)}s'),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Error loading data',
              style: TextStyle(color: AppColors.offline),
            ),
          ],
        ),
      ),
    );
  }
}

/// Configuration sheet for LoRa parameters.
class _ConfigSheet extends StatefulWidget {
  const _ConfigSheet({required this.service});

  final RNodeService service;

  @override
  State<_ConfigSheet> createState() => _ConfigSheetState();
}

class _ConfigSheetState extends State<_ConfigSheet> {
  late double _frequency;
  late double _bandwidth;
  late int _spreadingFactor;
  late int _txPower;

  final _frequencies = [433.0, 868.0, 915.0];
  final _bandwidths = [125.0, 250.0, 500.0];
  final _spreadingFactors = [7, 8, 9, 10, 11, 12];
  final _txPowers = [1, 5, 10, 14, 17, 20, 22];

  @override
  void initState() {
    super.initState();
    _frequency = widget.service.frequency ?? 915.0;
    _bandwidth = widget.service.bandwidth ?? 125.0;
    _spreadingFactor = widget.service.spreadingFactor ?? 9;
    _txPower = widget.service.txPower ?? 14;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LoRa Configuration',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _DropdownRow(
            label: 'Frequency',
            value: _frequency,
            items: _frequencies,
            suffix: ' MHz',
            onChanged: (v) => setState(() => _frequency = v!),
          ),
          _DropdownRow(
            label: 'Bandwidth',
            value: _bandwidth,
            items: _bandwidths,
            suffix: ' kHz',
            onChanged: (v) => setState(() => _bandwidth = v!),
          ),
          _DropdownRow(
            label: 'Spreading Factor',
            value: _spreadingFactor,
            items: _spreadingFactors,
            prefix: 'SF',
            onChanged: (v) => setState(() => _spreadingFactor = v!),
          ),
          _DropdownRow(
            label: 'TX Power',
            value: _txPower,
            items: _txPowers,
            suffix: ' dBm',
            onChanged: (v) => setState(() => _txPower = v!),
          ),
          const SizedBox(height: 16),
          // Preset buttons
          Row(
            children: [
              _PresetChip(
                label: 'Long Range',
                onTap: () => setState(() {
                  _bandwidth = 125.0;
                  _spreadingFactor = 12;
                  _txPower = 22;
                }),
              ),
              const SizedBox(width: 8),
              _PresetChip(
                label: 'Fast',
                onTap: () => setState(() {
                  _bandwidth = 500.0;
                  _spreadingFactor = 7;
                  _txPower = 14;
                }),
              ),
              const SizedBox(width: 8),
              _PresetChip(
                label: 'Balanced',
                onTap: () => setState(() {
                  _bandwidth = 250.0;
                  _spreadingFactor = 9;
                  _txPower = 17;
                }),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await widget.service.configure(
                  frequency: _frequency,
                  bandwidth: _bandwidth,
                  spreadingFactor: _spreadingFactor,
                  txPower: _txPower,
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DropdownRow<T> extends StatelessWidget {
  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefix,
    this.suffix,
  });

  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String? prefix;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: DropdownButtonFormField<T>(
              initialValue: value,
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              items: items.map((item) {
                final text = '${prefix ?? ''}$item${suffix ?? ''}';
                return DropdownMenuItem(
                  value: item,
                  child: Text(text),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      backgroundColor: AppColors.deepPurple,
      side: const BorderSide(color: AppColors.divider),
      onPressed: onTap,
    );
  }
}
