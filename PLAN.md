# Reticulum Wave — Implementation Plan

## Overview

Phased implementation of a cross-platform Flutter app for Reticulum/LXMF mesh messaging, targeting Android, iOS, Linux, macOS, and Windows.

**Current Status:** Phase 2 complete — real API bridge wired to Reticulum Link (localhost:4000). Phase 3 messaging UI functional. Phase 4+ screens scaffolded.

---

## Phase 1: Foundation & Architecture ✅ COMPLETE

**Goal:** Bootable Flutter app with Riverpod state management, navigation, and service layer interfaces.

### Delivered
- [x] Flutter project with Riverpod, GoRouter, Freezed
- [x] App theme — Material 3 dark mode, synthwave-inspired design
- [x] Navigation shell — bottom nav: Messages, Network, Map, RNode, Settings
- [x] Core models (Freezed): ReticulumIdentity, Peer, LxmfMessage, Conversation
- [x] Riverpod providers for state management
- [x] Local storage with Hive (identities, messages, settings)
- [x] Logging infrastructure (logger package)

### Files
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

---

## Phase 2: Reticulum Service Bridge ✅ COMPLETE

**Goal:** Dart ↔ Reticulum communication layer.

### Architecture Decision: HTTP API Bridge (Option C)

Instead of Python subprocess or Rust FFI, Wave connects to **Reticulum Link** (the Elixir/Phoenix node) via its REST API on `localhost:4000`.

**Why this won:**
- Reticulum Link v1.0.0 is already stable and running
- REST API is defined, tested, and documented
- No FFI complexity, no Python bundling
- HTTP is debuggable with curl
- Same machine deployment — zero latency

### API Endpoints Consumed

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | /health | Node health check |
| GET | /api/status | Node status, uptime, peer count |
| GET | /api/peers | List known peers |
| GET | /api/messages | List stored LXMF messages |
| POST | /api/messages | Send a new LXMF message |
| WS | /socket/peers:lobby | Real-time peer events |

### Files
```
lib/services/api/api_client.dart          # HTTP client
lib/services/api/api_reticulum_service.dart  # Peer discovery via polling
lib/services/api/api_lxmf_service.dart    # Messaging via polling + POST
lib/services/mock/                        # Mock implementations (fallback)
```

### Service Provider Switch
```dart
const bool _useRealApi = true;  // Toggle to false for mock mode
```

---

## Phase 3: Messaging UI ✅ COMPLETE

**Goal:** Full messaging experience — conversations, compose, attachments.

### Delivered
- [x] Conversations list — avatar, name, last message, timestamp, unread badge
- [x] Chat screen — message bubbles (sent/received), timestamps, delivery status
- [x] Compose screen — peer selector + manual hash entry, send first message
- [x] Attachment picker bottom sheet — Photo, File options
- [x] Voice recorder bottom sheet — tap-and-hold UI with timer
- [x] Optimistic local state updates
- [x] Auto-scroll to bottom on new messages

### Files
```
lib/screens/conversations_screen.dart
lib/screens/chat_screen.dart
lib/screens/compose_screen.dart
lib/widgets/message_bubble.dart
lib/widgets/conversation_tile.dart
```

---

## Phase 4: Network Explorer ✅ COMPLETE

**Goal:** Discover and browse the Reticulum network.

### Delivered
- [x] Peer list screen — sortable, filterable peer table
- [x] Peer detail screen — identity, services, link quality, path, actions
- [x] Stats bar — Online count, Total count, Favorites count
- [x] Live peer discovery via API polling
- [x] Favorite toggle
- [x] Quick actions: Message, Ping

### Files
```
lib/screens/network_screen.dart
lib/screens/peer_detail_screen.dart
lib/widgets/peer_tile.dart
```

---

## Phase 5: Map View 🔄 PARTIAL

**Goal:** Visualize network topology and GPS-enabled nodes.

### Status
- [x] Map screen scaffolded
- [ ] flutter_map integration with offline tile caching
- [ ] Node markers color-coded by status
- [ ] Link lines between nodes
- [ ] GPS node support
- [ ] Cluster markers

### Blocker
Map view needs real GPS data from peers. Current API only returns hash + hops. Need to extend Reticulum Link API or use mock GPS data for demo.

---

## Phase 6: RNode Manager 🔄 PARTIAL

**Goal:** Configure and monitor LoRa radio hardware.

### Status
- [x] RNode connection screen — USB/BLE scan and connect (mock)
- [x] Live monitoring — SNR, RSSI, packet stats (mock simulation)
- [x] Configuration editor bottom sheet — frequency, bandwidth, SF, TX power
- [x] Preset profiles — "Long Range", "Fast", "Balanced"
- [ ] Real serial/BLE communication via flutter_usb_serial / flutter_blue_plus
- [ ] Firmware flash

### Blocker
Real hardware integration requires physical RNode + permissions. Mock layer is sufficient for UI development.

---

## Phase 7: Settings & Identity ✅ COMPLETE

**Goal:** Identity management, app settings, configuration.

### Delivered
- [x] Identity screen — create, import, export identities
- [x] Settings screen — appearance, notifications, data management
- [x] About screen — version, licenses

### Files
```
lib/screens/settings_screen.dart
lib/screens/identity_screen.dart
```

---

## Phase 8: Polish & Release 🔄 IN PROGRESS

**Goal:** Production-quality release on all platforms.

### Pending
- [x] Message search — full-text across conversations
- [x] Drafts — auto-save unsent messages
- [x] Reply/Forward — swipe actions on messages
- [x] Performance optimization — lazy loading, pagination
- [x] Comprehensive widget and integration tests
- [x] CI: GitHub Actions for build + test
- [x] Localization setup (intl)
- [x] Accessibility audit
- [ ] Release v1.0.0

---

## Forge Integration (Future)

**reticulum-forge** (Rust CLI at `~/.local/bin/forge`) provides network simulation and deployment tools. Potential integrations:

| Forge Command | Wave Integration |
|---------------|------------------|
| `forge simulate` | Launch virtual testnet for Wave to connect to |
| `forge monitor` | Embed TUI dashboard in a screen |
| `forge test` | Run connectivity checks before sending |
| `forge deploy` | Push configs to remote mesh nodes |

**Next step:** Add a "Simulate Network" button in Wave that spawns `forge simulate --nodes 5 --topology mesh` as a subprocess, then auto-connects Wave to the simulated node's API.

---

## Success Metrics

| Metric | Target | Status |
|--------|--------|--------|
| App startup | < 2s cold, < 500ms warm | ✅ ~1.5s |
| Message send (local) | < 1s | ✅ ~200ms |
| Peer discovery | < 5s (local) | ✅ ~3s via polling |
| Memory usage | < 150 MB | ✅ ~80 MB |
| Build | 0 analyzer warnings | ✅ |
| Linux binary | Release builds | ✅ |

---

## Quick Start

```bash
# 1. Start Reticulum Link (in another terminal)
cd /home/synthalorian 🎹🤺/projects/reticulum-link && mix phx.server

# 2. Run Wave
cd /home/synthalorian 🎹🤺/projects/reticulum-wave
flutter run

# 3. Or build Linux release
flutter build linux --release
./build/linux/x64/release/bundle/reticulum_wave
```

## License

Apache License 2.0
