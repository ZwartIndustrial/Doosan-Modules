# Doosan Modules

A growing collection of Doosan Robotics DART modules published by **Zwart Industrial Innovations (ZII)**.

This repository is organised as a multi-module library. Every module has its own folder containing the installable module file, documentation, screenshots, changelog, and release notes.

## Available modules

| Module | Version | Description | Download | Documentation |
|---|---:|---|---|---|
| [PlcData](PlcData/README.md) | 0.0.1 | Adds BIT, INT, and FLOAT input-register wait commands to the Task Editor. | [Download `.dm`](PlcData/release/com.zii.plcdata_0.0.1.dm) | [Manual](PlcData/MANUAL.md) · [PDF](PlcData/PlcData_User_Manual_v0.0.1.pdf) |

## Installing a module

1. Download the required `.dm` file.
2. Open DART-Platform and select **Install Module** from the Home screen.
3. Select the downloaded `.dm` file.
4. Open the Task Editor and find the commands under **User Commands**.

See Doosan Robotics' official [Build and Install a Module guide](https://developers.drdart.io/guide/ver/pub/build-a-module) for the platform workflow.

## Repository layout

```text
Doosan-Modules/
├── README.md
├── LICENSE
├── assets/
│   └── donation assets
└── PlcData/
    ├── README.md
    ├── MANUAL.md
    ├── PlcData_User_Manual_v0.0.1.pdf
    ├── RELEASE_NOTES_0.0.1.md
    ├── CHANGELOG.md
    ├── assets/
    └── release/
```

## Publisher

Copyright (c) 2026 Zwart Industrial Innovations.

Doosan Robotics, DART, Dr.DART, and related product names are trademarks of their respective owners. Review each module's manual and validate its behaviour in a safe test environment before production use.

## Support further development

Donations support the further development, testing, documentation, and maintenance of these modules. They are also greatly appreciated as a thank-you for making the modules available.

Scan the PayPal QR code:

<img src="assets/paypal-donation-qr.png" alt="PayPal donation QR code" width="300">
