# PlcData User Manual

**Version 0.0.1**  
Doosan DART User Command V2 module  
Published by Zwart Industrial Innovations  
20 July 2026

## Document information

| Item | Value |
|---|---|
| Module | PlcData |
| Package | `com.zii.plcdata` |
| Version | 0.0.1 |
| Target SDK | 6 |
| Interface | Task Editor User Command V2 |
| Included commands | BIT, INT, FLOAT input-register waits |
| Polling interval | 0.1 seconds |
| Publisher | Zwart Industrial Innovations |

## Contents

1. [Overview](#1-overview)
2. [Installation](#2-installation)
3. [Adding a PlcData command](#3-adding-a-plcdata-command)
4. [Wait for Input Register Bit](#4-wait-for-input-register-bit)
5. [Wait for Input Register Int](#5-wait-for-input-register-int)
6. [Wait for Input Register Float](#6-wait-for-input-register-float)
7. [Understanding the Task Editor summary](#7-understanding-the-task-editor-summary)
8. [Wait-function reference](#8-wait-function-reference)
9. [Timeout and popup behaviour](#9-timeout-and-popup-behaviour)
10. [PLC integration and safe use](#10-plc-integration-and-safe-use)
11. [Troubleshooting](#11-troubleshooting)
12. [Support and donations](#12-support-and-donations)

## 1. Overview

PlcData adds three waiting commands to the Doosan Task Editor:

- **Wait IR[B]** waits for an input-register bit to become `ON` or `OFF`.
- **Wait IR[I]** waits for an input-register INT to equal a signed 32-bit value.
- **Wait IR[F]** waits for an input-register FLOAT to exactly equal a decimal value.

Every command polls its input register once every 0.1 seconds. It returns successfully as soon as the selected PLC value matches the configured target.

> **Safety notice:** PlcData is not a safety component. Do not use it instead of safety-rated I/O, a safety PLC, protective stops, or emergency-stop circuitry.

## 2. Installation

1. Download [`com.zii.plcdata_0.0.1.dm`](release/com.zii.plcdata_0.0.1.dm).
2. If an older module with package name `com.zwart.wri` is installed, remove it first. Otherwise two `PlcData` groups can appear.
3. Open DART-Platform and switch to the authority level required for module installation.
4. Select **Install Module** on the Home screen.
5. Choose the downloaded `.dm` file and complete the installation.
6. Open the Task Editor and find **PlcData** under **User Commands**.

For the platform workflow, refer to Doosan Robotics' official [Build and Install a Module guide](https://developers.drdart.io/guide/ver/pub/build-a-module).

## 3. Adding a PlcData command

1. Open or create a task in Task Editor.
2. Add a command.
3. Scroll to **User Commands**.
4. Select the required PlcData command:
   - `Wait IR[B]`
   - `Wait IR[I]`
   - `Wait IR[F]`
5. Configure its property screen.
6. Save the task.

<img src="assets/task-list-summary.png" alt="PlcData commands in Task Editor" width="420">

The green hourglass is supplied by the Task Editor. The tested Task Editor version uses the same colour for all three User Commands.

## 4. Wait for Input Register Bit

<img src="assets/property-bit.png" alt="Wait for Input Register Bit property screen" width="570">

### Fields

| Field | Meaning |
|---|---|
| Register | Input-register bit number from `0` through `63`. |
| ON / OFF | Desired bit state. The command completes when the current bit equals this state. |
| No timeout (None) | Wait indefinitely until the desired state is reached. |
| Number of seconds | Enable a positive timeout. Decimal values are accepted. |
| Show timeout popup | Show an alarm-style popup if the timeout expires. |

### Generated function call

```python
wait_input_register_bit(register, value, timeout, timeout_message)
```

Example:

```python
wait_input_register_bit(0, ON, 1, "Input register bit 0 is not ON after 1 seconds from starting the function.")
```

## 5. Wait for Input Register Int

<img src="assets/property-int.png" alt="Wait for Input Register Int property screen" width="570">

### Fields

| Field | Meaning |
|---|---|
| Address | Input-register INT address from `0` through `23`. |
| Desired integer value | Signed 32-bit integer from `-2147483648` through `2147483647`. |
| No timeout / Number of seconds | Wait indefinitely or use a positive timeout. |
| Show timeout popup | Show an alarm-style popup if the timeout expires. |

### Generated function call

```python
wait_input_register_int(address, value, timeout, timeout_message)
```

Example:

```python
wait_input_register_int(0, 42, 5, "Input register int 0 is not equal to 42 after 5 seconds from starting the function.")
```

## 6. Wait for Input Register Float

<img src="assets/property-float.png" alt="Wait for Input Register Float property screen" width="570">

### Fields

| Field | Meaning |
|---|---|
| Address | Input-register FLOAT address from `0` through `23`. |
| Desired float value | Decimal target value. |
| No timeout / Number of seconds | Wait indefinitely or use a positive timeout. |
| Show timeout popup | Show an alarm-style popup if the timeout expires. |

### Generated function call

```python
wait_input_register_float(address, value, timeout, timeout_message)
```

Example:

```python
wait_input_register_float(0, 12.5, 5, "Input register float 0 is not equal to 12.5 after 5 seconds from starting the function.")
```

> FLOAT uses exact equality. A displayed PLC value that appears identical can still differ internally due to floating-point representation. Use values that both systems represent identically.

## 7. Understanding the Task Editor summary

The Task Editor places the module name before the summary supplied by PlcData.

### BIT example

```text
PlcData, 0, ON, 1 s, STP
```

| Position | Example | Meaning |
|---:|---|---|
| 1 | `PlcData` | Installed module name. This text is not a PLC parameter. |
| 2 | `0` | BIT register number. |
| 3 | `ON` | Desired bit state. |
| 4 | `1 s` | Timeout in seconds. `None` means no timeout. |
| 5 | `STP` | **Show Timeout Popup** is enabled. It does not mean “stop task”. |

### INT and FLOAT examples

```text
PlcData, 0, 42, 5 s, STP
PlcData, 0, 12.5, None
```

For INT and FLOAT, the second value is the address and the third value is the desired numeric value.

## 8. Wait-function reference

### Signatures

```python
wait_input_register_bit(register, value, timeout=None, timeout_message=None)
wait_input_register_int(address, value, timeout=None, timeout_message=None)
wait_input_register_float(address, value, timeout=None, timeout_message=None)
```

### Common behaviour

1. Read the configured input register.
2. Compare it with the configured target.
3. When it matches, return `True` immediately.
4. When it does not match, wait `0.1` seconds and check again.
5. If a positive timeout expires, optionally show the configured popup and return `False`.

The generated Task Editor command calls the function as a statement. Its boolean return value is therefore not stored by the standard PlcData command block. The timeout popup provides the normal operator feedback. Developers calling the functions from custom DRL can use the return value for their own branching logic.

### No-timeout behaviour

When `timeout=None`, the function continues waiting until the target value is reached or the task is stopped externally.

## 9. Timeout and popup behaviour

- Timeout values must be greater than zero.
- Decimal timeout values are supported.
- The final polling delay is shortened when less than 0.1 seconds remains.
- The popup is generated only when **Show timeout popup** is enabled.
- The popup uses the DART language selected for the property screen.
- After timeout handling, the function returns `False`.
- `STP` in the summary means **Show Timeout Popup**; it is not a stop instruction.

## 10. PLC integration and safe use

- Confirm that the PLC and robot use the same register mapping.
- Confirm the INT byte order and signed-value interpretation in the surrounding PLC integration.
- Use FLOAT only when exact equality is appropriate.
- Select a timeout that accounts for the PLC scan time, network update time, and process delay.
- Do not use an indefinite wait where a missing PLC update could leave the process blocked indefinitely.
- Test every command in a safe environment before using it in production.
- Never use PlcData as a replacement for safety-rated control functions.

## 11. Troubleshooting

### Two PlcData groups are visible

The former `com.zwart.wri` package and the current `com.zii.plcdata` package are both installed. Remove the former package.

### All hourglasses have the same colour

The Task Editor supplies the generic User Command icon and ignores the individual screen icons offered by the tested module build. This does not affect functionality.

### The command name is shortened

The Task Editor shortens long User Command names. Version 0.0.1 uses labels of ten characters: `Wait IR[B]`, `Wait IR[I]`, and `Wait IR[F]`.

### The wait never completes

Check the selected register/address, PLC mapping, desired value, and live PLC data. For FLOAT, also check the exact binary value.

### No popup appears after timeout

Verify that a timeout in seconds is selected and **Show timeout popup** is enabled. `STP` should then appear in the task summary.

## 12. Support and donations

PlcData is published by Zwart Industrial Innovations.

Donations support further development, testing, documentation, and maintenance and are appreciated as a thank-you for the modules.

<a href="../assets/paypal-donation-qr.png"><img src="../assets/donate-button.svg" alt="Donate via PayPal" width="230"></a>

<img src="../assets/paypal-donation-qr.png" alt="PayPal donation QR code" width="280">
