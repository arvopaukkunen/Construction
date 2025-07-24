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

## Solar water heater

![alt text](/media/Domestic%20water%20system%202.png) { width=50% }

### System Overview

Sure! Here's a complete English translation and summary of everything discussed above regarding your hybrid heating system:

---

## System Overview**

You are building a hybrid **solar + wood-fired heating** system for a small detached house, using the following components:

* **Hot water tank:** Jäspi GTW 500 (500-liter buffer with solar coil)
* **Fan coil units:** 2x **Sabiana CVP-ECM-MB 3**
* **Solar thermal collector:** To be dimensioned
* **Controller:** **Sorel XHCC** – already managing three **Wita circulation pumps**
* **Heat recovery sources:**

  * **Tulikivi fireplace**
  * **Wood-fired sauna stove**

---

## Recommended Solar Collector Sizing

You want to use solar thermal energy to cover **domestic hot water (DHW)** and support **space heating via fan convectors**, especially in winter.

### Sizing approach (updated with wood heat sources in mind)

| Purpose               | Area Needed                               |
| --------------------- | ----------------------------------------- |
| DHW for 4 people      | 6–8 m²                                    |
| Space heating support | 5–10 m²                                   |
| **Total recommended** | **12–18 m² of evacuated tube collectors** |

> If you want full summer DHW coverage without using wood heating: **16–20 m²** would be optimal.

---

## System Schematic Updates

You requested updated **system diagrams** showing:

1. Solar collectors
2. Fireplace + sauna heater heat recovery
3. XHCC controller
4. Fan convectors
5. Jäspi GTW 500 buffer tank

The updated schematics show:

* Red and blue lines for hot and cold loops
* Pumps controlled by XHCC
* Proper heat flow direction from collectors and wood-fired loops into the tank

---

## Sorel XHCC Logic (Pump Control & Priority)

**Sorel XHCC** controls:

* Solar circuit pump
* Fireplace circuit pump
* Sauna heater pump
* Distribution pumps to fan convectors

### Logic (suggested configuration):

1. **Priority 1:**
   Solar → lower coil in tank (heat stored if available)

2. **Priority 2:**
   Wood stove or fireplace → charges tank during burn (thermal sensors on return pipe trigger pump when hot)

3. **Priority 3:**
   Fan convector pumps triggered by:

   * Tank top temperature
   * Or thermostats / heating demand

4. **Failover (optional):**
   Electric resistance heater in top of tank (to maintain DHW if others unavailable)

5. **Sensors used:**

   * Collector sensor (T1)
   * Tank top and bottom sensors (T2/T3)
   * Return water (T4)
   * Outdoor sensor (optional)

---

## Seasonal Energy Flow Diagram

Here's how energy sources are used throughout the year:

| Month       | Solar Heating     | Fireplace / Sauna Heat      | Fan Coil Use | Electric Backup  |
| ----------- | ----------------- | --------------------------- | ------------ | ---------------- |
| **Jan–Feb** | Minimal (low sun) | Main source (daily burning) | High         | Possibly needed  |
| **Mar–Apr** | Moderate          | Occasional use              | Moderate     | Rare             |
| **May–Aug** | High (long days)  | Rarely used (warm weather)  | Low / Off    | Not needed       |
| **Sep–Oct** | Moderate          | Frequent (cold evenings)    | Moderate     | Backup if needed |
| **Nov–Dec** | Low               | Main source again           | High         | Sometimes needed |

---

## Summary of Benefits

* **High efficiency year-round** with solar + wood combo
* **Low electric consumption** even in winter
* **Comfortable heat distribution** via fan convectors
* **Smart control** through Sorel XHCC maximizes available energy and minimizes waste

---

Next... maybe a programmable configuration for XHCC based on this logic?

Older and to be updated ?

# IT Architecture (draft)

![alt text](EA1.png){ width=25% }

# Homeassistant addons in use

# Nodered addons in use

Victron OS Large & Nodered build in installed on Cerbo CX linux box

# Construction

Powerplant, House plans and more

## House IoT

- About 106 sensors for humidity & temperature Data
- Flow and temp sensors for all water points to track water consuming events.
- Warm water reserve sensors
- Climate in/out sensors including the ppm for air quality
- Electricity sensors are included and activated/consumed by Victron energy as <https://vrm.victronenergy.com/login>
- I will share the actual realtime information as soon as all components are in place and issues has been solved.

