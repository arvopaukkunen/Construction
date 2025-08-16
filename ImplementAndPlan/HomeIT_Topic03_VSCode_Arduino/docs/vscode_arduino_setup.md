# VS Code Setup for Arduino Uno & Arduino Opta (macOS + Windows)

This guide packages **two paths**. Choose **one** to avoid conflicts:
1) **Arduino CLI + VS Code Arduino extension** (simple & official)
2) **PlatformIO** (richer project model, libs, unit test)

---

## 0) Prerequisites
- **VS Code** (latest)
- **Git** (optional but recommended)
- **USB cable** for boards
- **Drivers** (Windows only, see below)

---

## 1) Install Key Extensions (pick ONE stack)

### Stack A — Arduino CLI + VS Code Arduino
- **Arduino** by Microsoft: `vsciot-vscode.vscode-arduino`
- **C/C++** by Microsoft: `ms-vscode.cpptools`
- **Wokwi Simulator** (Uno only, optional): `wokwi.wokwi-vscode`

**Arduino CLI**:
- macOS: `brew install arduino-cli`
- Windows: `winget install Arduino.ArduinoCLI` (or `choco install arduino-cli`)

### Stack B — PlatformIO
- **PlatformIO IDE**: `platformio.platformio-ide`

> ⚠️ Don’t enable both stacks in the same workspace. If you must, use **VS Code Profiles** (included in `templates/profiles`).

---

## 2) Board Cores (via Arduino CLI)
```bash
arduino-cli core update-index

# UNO:
arduino-cli core install arduino:avr

# Opta (find the exact core first):
arduino-cli core search opta
# Example result might be: arduino:mbed_opta
arduino-cli core install arduino:mbed_opta
```

**Find the FQBNs** (board identifiers):
```bash
arduino-cli board listall | grep -i "uno\|opta"
```
- Uno: typically `arduino:avr:uno`
- Opta: run the command above to confirm the exact FQBN on your system.

---

## 3) Create the VS Code settings files

### macOS — how to create `.vscode/settings.json`
```bash
# from your project root
mkdir -p .vscode
cp ./templates/.vscode/settings.example.json .vscode/settings.json
cp ./templates/.vscode/arduino.example.json .vscode/arduino.json
cp ./templates/.vscode/tasks.example.json .vscode/tasks.json
```

### Windows (PowerShell)
```powershell
# from your project root
New-Item -ItemType Directory -Force .vscode | Out-Null
Copy-Item .\templates\.vscode\settings.example.json .\.vscode\settings.json
Copy-Item .\templates\.vscode\arduino.example.json .\.vscode\arduino.json
Copy-Item .\templates\.vscode\tasks.example.json .\.vscode\tasks.json
```

Then open **Command Palette → Arduino: Board Config** and set:
- **FQBN** for Uno: `arduino:avr:uno`
- **FQBN** for Opta: the one you found via `board listall`
- **Port** (check with `arduino-cli board list` while board is connected)

---

## 4) Drivers (Windows)
- **Uno (ATmega16U2 official)**: usually no extra driver required.
- **Clones (CH340/CH341)**: install CH340 driver if the port doesn’t appear.
- **Opta (STM32 USB)**: Windows 10/11 typically OK; install ST drivers if needed.

---

## 5) Build & Upload (Arduino CLI)
Common commands:
```bash
# List ports
arduino-cli board list

# Compile (Uno)
arduino-cli compile -b arduino:avr:uno ./samples/uno-blink

# Upload (Uno) - set your COM port or /dev/tty*
arduino-cli upload -b arduino:avr:uno -p COM3 ./samples/uno-blink

# Compile/Upload (Opta) - replace FQBN and port
FQBN=<your-opta-fqbn>   # e.g., arduino:mbed_opta:opta (verify!)
PORT=<your-port>
arduino-cli compile -b %FQBN% ./samples/opta-blink
arduino-cli upload -b %FQBN% -p %PORT% ./samples/opta-blink
```

You can also use **VS Code Tasks**: *Terminal → Run Task → Build (Arduino CLI)* or *Upload (Arduino CLI)*.

---

## 6) Simulation / Testing
- **Wokwi**: Excellent for Uno. Use `wokwi.toml` in the sample; extension `wokwi.wokwi-vscode`.
- **SimulIDE / Proteus**: Desktop simulators (Uno support varies; Opta not officially supported).
- **FakeSerial**: For host-side testing, write a small script that mimics sensor data over serial to your app.

> **Opta:** No official full simulation. Test on hardware, or mock logic with host-side unit tests and FakeSerial.

---

## 7) Optional: PlatformIO
- Open `samples/uno-blink-pio` folder → PlatformIO will auto-install platform/toolchain.
- For Opta, search for the board/platform in PlatformIO; if missing, stay with Arduino CLI.

---

## 8) Troubleshooting
- **Board not found**: check cable, driver, and `arduino-cli board list`.
- **Permission (macOS)**: `ls /dev/tty.*`, grant access if prompted.
- **Upload fails**: press board reset, try again; close Serial Monitor.
- **Conflicting extensions**: disable PlatformIO when using Arduino extension and vice versa.

---

## 9) What’s in this package
```
docs/
  vscode_arduino_setup.md          # this file
images/
  setup_overview.svg               # visual overview
templates/
  .vscode/
    settings.example.json
    arduino.example.json
    tasks.example.json
  profiles/
    profile-arduino-cli.json       # VS Code profile export (Arduino stack)
    profile-platformio.json        # VS Code profile export (PlatformIO)
samples/
  uno-blink/                        # Arduino CLI sample for Uno
    uno-blink.ino
    wokwi.toml
  opta-blink/
    opta-blink.ino
  uno-blink-pio/                   # PlatformIO sample project
    platformio.ini
    src/main.cpp
```

Happy building!