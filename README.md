# 📡 Reticulum Wave

> Cross-platform encrypted mesh messaging client for Reticulum/LXMF

```
    ╔═════════════════════════════════════════════════════════════════════╗
    ║                    R E T I C U L U M   W A V E                     ║
    ║                                                                     ║
    ║   ┌─────────────────────────────────────────────────────────────┐  ║
    ║   │                    Flutter UI Layer                         │  ║
    ║   │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐  │  ║
    ║   │  │ Messages │ │ Network  │ │  Map     │ │ RNode        │  │  ║
    ║   │  │ Screen   │ │ Explorer │ │  View    │ │ Manager      │  │  ║
    ║   │  └────┬─────┘ └────┬─────┘ └────┬─────┘ └──────┬───────┘  │  ║
    ║   │       │            │            │               │           │  ║
    ║   │  ┌────┴────────────┴────────────┴───────────────┴────────┐  │  ║
    ║   │  │              Riverpod State Layer                     │  │  ║
    ║   │  │  ┌───────────┐ ┌───────────┐ ┌─────────────────────┐ │  │  ║
    ║   │  │  │ Providers │ │  Models   │ │  Repositories       │ │  │  ║
    ║   │  │  └─────┬─────┘ └─────┬─────┘ └──────────┬──────────┘ │  │  ║
    ║   │  └────────┼─────────────┼───────────────────┼────────────┘  │  ║
    ║   └───────────┼─────────────┼───────────────────┼───────────────┘  ║
    ║              │             │                   │                   ║
    ║   ┌──────────┴─────────────┴───────────────────┴───────────────┐  ║
    ║   │                  Service Layer (Dart)                      │  ║
    ║   │  ┌──────────┐ ┌──────────┐ ┌──────────┐                  │  ║
    ║   │  │ LXMF     │ │ Reticulum│ │ RNode    │                  │  ║
    ║   │  │ Service  │ │ Service  │ │ Service  │                  │  ║
    ║   │  └────┬─────┘ └────┬─────┘ └────┬─────┘                  │  ║
    ║   └───────┼─────────────┼─────────────┼────────────────────────┘  ║
    ║           │             │             │                           ║
    ║   ┌───────┴─────────────┴─────────────┴────────────────────────┐  ║
    ║   │              FFI Bridge (Dart ↔ Rust/C)                    │  ║
    ║   │         or Python subprocess bridge                        │  ║
    ║   └───────────────────────────┬───────────────────────────────┘  ║
    ║                               │                                   ║
    ║                   ┌───────────┴───────────┐                      ║
    ║                   │    Reticulum Network   │                      ║
    ║              ┌────┴─────┐           ┌─────┴──────┐               ║
    ║              │  LoRa    │           │  Bluetooth  │               ║
    ║              │  RNode   │           │  / USB      │               ║
    ║              └──────────┘           └────────────┘               ║
    ╚═════════════════════════════════════════════════════════════════════╝
```

## Overview

Reticulum Wave is a cross-platform encrypted mesh messaging client built in **Flutter**. It provides LXMF messaging, file transfer, network discovery, and RNode hardware management — running on **Android, iOS, Linux, macOS, and Windows**.

Designed for use with LoRa radio hardware connected via USB or Bluetooth. Works completely offline — no internet required.

## Features

### ✉️ LXMF Messaging
- **Encrypted conversations** — end-to-end encrypted via Reticulum's identity system
- **Group channels** — multi-recipient encrypted group messaging
- **File attachments** — send files, images, documents over the mesh
- **Voice messages** — record and send via LXST protocol
- **Message status** — sent, delivered, read receipts
- **Offline queue** — messages wait for peer to come back online

### 🌐 Network Discovery
- **Browse nodes** — discover nearby and reachable Reticulum nodes
- **Service registry** — find LXMF delivery nodes, propagation nodes, Nomad Network sites
- **Peer details** — identity, services offered, link quality, hop count
- **Favorites** — bookmark frequently-contacted nodes

### 📻 RNode Management
- **Flash firmware** — update RNode firmware from the app
- **Configure LoRa** — set frequency, bandwidth, TX power, spreading factor
- **Signal monitoring** — real-time SNR, RSSI, packet stats
- **USB & Bluetooth** — connect RNodes via USB-C or BLE

### 🗺️ Map View
- **Network topology** — visualize mesh network layout
- **GPS nodes** — show locations of GPS-enabled nodes on a map
- **Signal heatmap** — link quality color-coded connections
- **Offline maps** — downloaded map tiles for disconnected use

### 🔋 Offline-First
- **No internet required** — all messaging works over local mesh
- **Propagation sync** — fetch messages from propagation nodes when available
- **Low bandwidth** — optimized for LoRa data rates (250 bps – 50 kbps)
- **Battery efficient** — background messaging with minimal wake-ups

## Tech Stack

| Component       | Technology                          |
|-----------------|-------------------------------------|
| Framework       | Flutter 3.24+ / Dart 3.5+          |
| State Mgmt      | Riverpod 2.x                        |
| Reticulum       | FFI (Rust) or Python subprocess     |
| Serial/USB      | flutter_usb_serial, web_serial      |
| Bluetooth       | flutter_blue_plus                   |
| Maps            | flutter_map + offline tiles         |
| Storage         | Hive / Isar (local DB)              |
| Platforms       | Android, iOS, Linux, macOS, Windows |

## Quick Start

### Prerequisites

- Flutter 3.24+
- Dart 3.5+
- Android Studio / Xcode (for mobile builds)
- CMake / LLVM (for FFI/Rust bridge)

### Setup

```bash
git clone https://github.com/synthalorian/reticulum-wave.git
cd reticulum-wave
flutter pub get

# Run on connected device / emulator
flutter run

# Build APK
flutter build apk --release

# Build Linux
flutter build linux --release
```

### Connecting Hardware

**USB RNode:**
1. Connect RNode via USB-C to your phone/computer
2. Grant USB permissions when prompted
3. Wave auto-detects and connects

**Bluetooth RNode:**
1. Pair your BLE RNode in system Bluetooth settings
2. Open Wave → Settings → RNode → Connect
3. Select your device from the scan list

## Project Structure

```
reticulum-wave/
├── lib/
│   ├── main.dart              # App entry point
│   ├── models/                # Data models
│   ├── providers/             # Riverpod providers
│   ├── screens/               # Page widgets
│   ├── widgets/               # Reusable UI components
│   ├── services/              # Reticulum, LXMF, RNode services
│   └── ffi/                   # Native bridge bindings
├── android/                   # Android-specific config
├── ios/                       # iOS-specific config
├── linux/                     # Linux-specific config
├── assets/                    # Images, fonts, map tiles
├── pubspec.yaml               # Flutter dependencies
└── README.md
```

## License

Apache License 2.0 — see [LICENSE](LICENSE).

## Credits

Built by **synthalorian 🎹🤺** (synthalorian) with **synthclaw**.

---

## ☕ Support the Developer

If this project saved you time, solved a problem, or just made your day a little more neon, you can fuel the next one:

[![Buy Me A Coffee](https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png)](https://buymeacoffee.com/synthalorian)
