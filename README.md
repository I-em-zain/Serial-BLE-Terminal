# Serial-BLE-Terminal

A Flutter-based Serial BLE Terminal for Nordic UART service, with customizable UUIDs for other services. This ongoing project is designed to enable serial communication between Flutter applications and Nordic nRF52840 chips using UART communication. It supports both iOS and Android platforms.

## Features

- **Nordic UART Service**: Connect to Nordic nRF52840 chips using the default Nordic UART service.
- **Customizable UUIDs**: Update UUIDs to support different services as needed.
- **Cross-Platform Support**: Compatible with both iOS and Android devices.
- **BLE Communication**: Use Bluetooth Low Energy (BLE) for efficient serial communication.

## Getting Started

### Prerequisites

- Flutter SDK
- Dart
- A device with Bluetooth capabilities (iOS or Android)

### Installation

1. **Clone the Repository**

    ```bash
    git clone https://github.com/I-em-zain/Serial-BLE-Terminal.git
    ```

2. **Navigate to the Project Directory**

    ```bash
    cd Serial-BLE-Terminal
    ```

3. **Install Dependencies**

    ```bash
    flutter pub get
    ```

4. **Set Up Permissions**

    - **Android**: Add permissions to `AndroidManifest.xml`

      ```xml
      <uses-permission android:name="android.permission.BLUETOOTH"/>
      <uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
      <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
      ```

    - **iOS**: Update `Info.plist`

      ```xml
      <key>NSBluetoothAlwaysUsageDescription</key>
      <string>We need access to Bluetooth to communicate with BLE devices.</string>
      <key>NSBluetoothPeripheralUsageDescription</key>
      <string>We need access to Bluetooth to communicate with BLE devices.</string>
      <key>NSLocationWhenInUseUsageDescription</key>
      <string>We need location permissions to scan for BLE devices.</string>
      ```

### Configuration

1. **UUIDs and Service Configuration**

   By default, the app uses the Nordic UART service UUID. If you need to use a different service, update the UUIDs in the code where applicable.

   ```dart
   // Example UUID for Nordic UART Service
   final uartServiceUUID = Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
