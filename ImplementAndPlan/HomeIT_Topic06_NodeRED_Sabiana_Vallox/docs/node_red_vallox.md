# Vallox TSK Multi 80 MV — Node-RED Flows

## What you get
- `vallox_modes_setpoints.json` — buttons for Night Mode, Boost (with minutes), and supply airflow %
- A periodic **status read** (holding regs `41200..41203` as example)

## Requirements
- **node-red-contrib-modbus**
- RS485 adapter at `/dev/ttyUSB1` (edit in **Vallox RS485** client)
- Correct **register addresses** from the Vallox Modbus manual

## Placeholder registers — fill from your manual
- Night Mode toggle: `41001`
- Boost toggle: `41010`
- Boost minutes: `41011`
- Supply airflow %: `41100`
- Status block: `41200..` (read-only example)

> If your address space starts at 0 or uses 3xxxx/4xxxx naming, adapt accordingly.

## Import & test
1. Import the JSON flow in Node-RED.
2. Set the serial port and unit id in **Vallox RS485**.
3. Open the inject nodes (buttons) and click to send ON/OFF or set %.

## Home Assistant
You can expose these as HA entities using MQTT Discovery or HA's Modbus integration directly. If desired, I can add HA YAMLs.