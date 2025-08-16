# Sabiana CVP–ECM–MB — Node-RED Flows

## What you get
- `sabiana_summer_flow.json` — temperature-based summer rules
- `sabiana_winter_flow.json` — winter rules for heating season

## Requirements
- Install **node-red-contrib-modbus**
- Have MQTT broker configured (flows use `home/sensors/T1` for temperature)
- RS485 adapter at `/dev/ttyUSB0` (edit in the **Sabiana RS485** client config node)

## Register addresses
Set the **fan speed holding register** address in both flows:
- Default placeholder: `40010` (change to your Sabiana register)
- Speed codes used: `0=OFF, 1=MIN, 2=MED, 3=MAX`

## Import
1. Node-RED menu → *Import* → select JSON → pick the flow file.
2. Double-click **Sabiana RS485** client node:
   - Serial port: `/dev/ttyUSB0`
   - Baud: `9600`, Data:`8`, Stop:`1`, Parity:`none`, UnitId:`1`
3. Double-click **Write Fan Speed** node and set **Address** if needed.

## Topics & logic
- Temperature comes from MQTT topic `home/sensors/T1` as a number (°C).
- **Summer rules**:
  - `t > 28` → MAX(3)
  - `24 < t < 28` → MED(2)
  - `t <= 24` → OFF(0)
- **Winter rules**:
  - `t < 18` → MAX(3)
  - `17 < t < 25` → MED(2)
  - `24 < t < 30` → MIN(1)
  - `t >= 30` → OFF(0)

Adjust thresholds to taste.