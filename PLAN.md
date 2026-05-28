# Reticulum Wave — Implementation Plan

## Overview

Phased implementation of a cross-platform Flutter app for Reticulum/LXMF mesh messaging, targeting Android, iOS, Linux, macOS, and Windows.

## Phase 1: Foundation & Architecture (Weeks 1–2)

**Goal:** Bootable Flutter app with Riverpod state management, navigation, and service layer interfaces.

### Tasks
- [ ] Flutter project initialization with Riverpod, GoRouter, Freezed
- [ ] App theme — Material 3 with dark/light mode, mesh-inspired design
- [ ] Navigation shell — bottom nav: Messages, Network, Map, Settings
- [ ] Core models (Freezed):
  - `ReticulumIdentity` — name, hash, public key
  - `Peer` — identity + last_seen, link_quality, services, hops
  - `LxmfMessage` — sender, recipient, content, timestamp, status, attachments
  - `Conversation` — peer + message list + unread count
- [ ] Riverpod providers for state management
- [ ] Local storage setup with Hive (identities, messages, settings)
- [ ] Logging infrastructure (logger package)

### File Touchpoints
```
lib/main.dart
lib/app.dart
lib/router.dart
lib/theme.dart
lib/models/identity.dart
lib/models/peer.dart
lib/models/message.dart
lib/models/conversation.dart
lib/providers/peers_provider.dart
lib/providers/messages_provider.dart
```

## Phase 2: Reticulum Service Bridge (Weeks 3–5)

**Goal:** Dart ↔ Reticulum communication layer via FFI or Python subprocess.

### Tasks
- [ ] `ReticulumService` abstract interface — start/stop, send/receive, discover
- [ ] **Strategy A: Python subprocess bridge**
  - Bundle Python RNS library with the app
  - Communicate via JSON-RPC over stdin/stdout
  - Platform channels for Android/iOS
- [ ] **Strategy B: Rust FFI** (preferred for performance)
  - Rust crate wrapping Reticulum protocol (partial reimplementation)
  - `ffigen` bindings for Dart
  - Compile Rust lib per platform (cargo-ndk for Android, etc.)
- [ ] `LxmfService` — send messages, receive messages, track delivery status
- [ ] `RnodeService` — serial communication with RNode hardware
  - USB serial via `flutter_usb_serial`
  - BLE via `flutter_blue_plus`
- [ ] Event streams — `Stream<LxmfMessage>` for incoming messages, `Stream<Peer>` for discovery
- [ ] Background service — keep Reticulum running when app is backgrounded (Android WorkManager)

### File Touchpoints
```
lib/services/reticulum_service.dart
lib/services/lxmf_service.dart
lib/services/rnode_service.dart
lib/ffi/reticulum_ffi.dart
lib/ffi/bindings.dart
native/src/lib.rs        # Rust bridge
native/Cargo.toml
```

## Phase 3: Messaging UI (Weeks 6–8)

**Goal:** Full messaging experience — conversations, compose, attachments.

### Tasks
- [ ] Conversations list screen — avatar, name, last message, timestamp, unread badge
- [ ] Chat screen — message bubbles (sent/received), timestamps, delivery status icons
- [ ] Compose — text field with send button, character count for LoRa mode
- [ ] New message — peer selector (from discovered peers + manual entry)
- [ ] File attachments — pick file → compress if needed → send over LXMF
- [ ] Voice messages — record audio → encode → send via LXST
- [ ] Message search — full-text search across conversations
- [ ] Swipe actions — reply, delete, forward
- [ ] Pull-to-refresh — sync from propagation node
- [ ] Drafts — auto-save unsent messages

### File Touchpoints
```
lib/screens/conversations_screen.dart
lib/screens/chat_screen.dart
lib/screens/compose_screen.dart
lib/screens/peer_selector_screen.dart
lib/widgets/message_bubble.dart
lib/widgets/conversation_tile.dart
lib/widgets/attachment_picker.dart
lib/widgets/voice_recorder.dart
```

## Phase 4: Network Explorer (Weeks 9–10)

**Goal:** Discover and browse the Reticulum network.

### Tasks
- [ ] Peer list screen — sortable, filterable peer table
- [ ] Peer detail screen — identity, services, link quality, path, last seen
- [ ] Service discovery — browse announced services per peer
- [ ] Signal quality visualization — bars/graph for link quality
- [ ] Favorites — star frequently-contacted peers
- [ ] Peer actions — send message, ping, trace path, block

### File Touchpoints
```
lib/screens/network_screen.dart
lib/screens/peer_detail_screen.dart
lib/widgets/peer_tile.dart
lib/widgets/signal_indicator.dart
lib/providers/discovery_provider.dart
```

## Phase 5: Map View (Weeks 11–12)

**Goal:** Visualize network topology and GPS-enabled nodes on a map.

### Tasks
- [ ] `flutter_map` integration with offline tile caching
- [ ] Node markers — color-coded by status (online/offline/degraded)
- [ ] Link lines — connections between nodes colored by link quality
- [ ] GPS node support — nodes that announce location
- [ ] Cluster markers — group nearby nodes at low zoom
- [ ] Tap node → detail sheet with peer info + quick message
- [ ] Download region — pre-cache map tiles for offline use

### File Touchpoints
```
lib/screens/map_screen.dart
lib/widgets/node_marker.dart
lib/widgets/link_line.dart
lib/providers/map_provider.dart
lib/services/location_service.dart
```

## Phase 6: RNode Manager (Weeks 13–14)

**Goal:** Configure and monitor LoRa radio hardware.

### Tasks
- [ ] RNode connection screen — USB/BLE scan and connect
- [ ] Configuration editor:
  - Frequency (433 MHz, 868 MHz, 915 MHz)
  - Bandwidth (125 kHz, 250 kHz, 500 kHz)
  - Spreading factor (SF7 – SF12)
  - TX power (1 – 22 dBm)
  - Coding rate
- [ ] Firmware flash — update RNode firmware from the app
- [ ] Live monitoring — SNR, RSSI, packets sent/received, airtime
- [ ] Preset profiles — "Long Range", "Fast", "Balanced"
- [ ] Hardware detection — auto-identify RNode variant and capabilities

### File Touchpoints
```
lib/screens/rnode_screen.dart
lib/screens/rnode_config_screen.dart
lib/screens/rnode_monitor_screen.dart
lib/widgets/lora_params_editor.dart
lib/providers/rnode_provider.dart
```

## Phase 7: Settings & Identity (Week 15)

**Goal:** Identity management, app settings, and configuration.

### Tasks
- [ ] Identity management — create, import, export identities
- [ ] Propagation settings — preferred propagation nodes, sync interval
- [ ] Interface config — configure which interfaces to use
- [ ] Appearance — theme, font size, language
- [ ] Notifications — message notifications, peer alerts
- [ ] Data management — export/import messages, clear cache
- [ ] About screen — version, licenses, links

### File Touchpoints
```
lib/screens/settings_screen.dart
lib/screens/identity_screen.dart
lib/providers/settings_provider.dart
```

## Phase 8: Polish & Release (Weeks 16–18)

**Goal:** Production-quality release on all platforms.

### Tasks
- [ ] Comprehensive widget and integration tests
- [ ] Performance optimization — lazy loading, message pagination, image caching
- [ ] Accessibility audit — screen readers, contrast, touch targets
- [ ] Localization setup (intl)
- [ ] Android: Play Store assets, screenshots, description
- [ ] iOS: App Store submission, TestFlight beta
- [ ] Linux: Flatpak / Snap package
- [ ] CI: GitHub Actions for build + test on all platforms
- [ ] Release v1.0.0

## Success Metrics

| Metric | Target |
|--------|--------|
| App startup | < 2s cold, < 500ms warm |
| Message send (local) | < 1s |
| Message send (LoRa) | < 30s (typical) |
| Peer discovery | < 5s (local) |
| Memory usage | < 150 MB |
| Battery drain (background) | < 3% / hour |
| Cold start messages load | < 500ms for 1000 messages |
