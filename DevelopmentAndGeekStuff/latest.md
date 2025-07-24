# Improvements 2025

## Jaspi safety switch automation and remote control

![alt text](/media/Katko%20315%20m1%20kauko%20ohjauksella.png ){ width=50% }

### Remote Control for Jäspi 3-Phase Water Heater**

To remotely control your **Jäspi 3-phase water heater** while ensuring **safety, compliance, and power monitoring**, the best solution is:



---

### System Architecture

1. **Retain** the existing **Katko 316 M1** safety switch
   ➤ For manual disconnection and maintenance

2. **Add an ABB ESB 40-40 contactor**
   ➤ Handles 3-phase load switching safely

3. **Install a Shelly Pro 3PM smart relay**
   ➤ Controls the contactor coil (A1/A2) via Wi-Fi
   ➤ Measures power consumption on all three phases
   ➤ Allows smartphone app control, scheduling, and integrations (MQTT, HTTP API)

---

### How it works

* Power flows: Grid → Katko → ABB Contactor → Water Heater
* Control flow: Shelly Pro energizes the contactor coil to turn the heater ON/OFF
* Monitoring: Shelly Pro measures L1, L2, L3 current draw and logs usage

---

### **Remote Features**

* Turn heater on/off from phone or automation platform
* Schedule heating for night electricity tariffs
* Monitor live power usage and consumption history

---

### **Installation & Safety Notes**

* Must be installed by a **licensed electrician**
* Enclose components in a **DIN-rated junction box**
* Verify heater current draw matches contactor & relay specs
* Optional: Add surge protection or RCBO for extra safety

---

### **Recommended Parts List**

| Component     | Model            | Function                        |
| ------------- | ---------------- | ------------------------------- |
| Safety Switch | Katko 316 M1     | Manual isolation                |
| Contactor     | ABB ESB 40-40    | 3-phase switching               |
| Smart Relay   | Shelly Pro 3PM   | Remote control + power metering |
| Enclosure     | DIN junction box | Safe mounting                   |
| Wiring        | 5-core 2.5–6 mm² | Phase + Neutral + PE            |

---