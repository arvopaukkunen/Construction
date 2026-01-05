# Pylontech US3000 Temperature Drop Recovery (Victron 3‑Phase System) — Chat Notes

*Generated:* 2026-01-05

## Overview

This document captures a troubleshooting/understanding session about how **Pylontech US3000** batteries behave when internal temperature drops, in a **Victron** installation using:

- **4× Pylontech US3000 (3.55 kWh each)**
- **3× Victron Quattro 48/5000/70-100/100** (configured **3‑phase**)
- **1× Victron Cerbo GX**
- **2× Victron SmartShunt 500A/50mV**

Primary focus: **How the battery bank “recovers” from low temperature** and how that is reflected in **DVCC**, **CCL/DCL/CVL**, and VRM/GX screens.

---

## User question

**Q:** How does Pylontech US3000 recover from an internal temperature drop?

---

## Assistant response (summary)

- In a Victron + CAN‑bus managed battery setup, recovery is **BMS-driven**:
  - When the pack is cold, the Pylontech BMS typically **reduces** or **blocks** charging by lowering the **Charge Current Limit (CCL)** communicated over CAN.
  - As the battery warms, the BMS **raises CCL** again; Victron DVCC then automatically allows more charge current.
- There is typically no special “manual recovery” action required unless the system has latched into an alarm/protection state.

---

## User provides system details

- Battery: **Pylontech Lithium US3000 3.55 kWh**
- Quantity: **4 modules**
- Victron components:
  - **SmartShunt 500A/50mV ×2**
  - **Quattro 48/5000/70-100/100 ×3**
  - **Cerbo GX ×1**
- Quattros configured as **3-phase**

---

## Evidence provided (screenshots referenced)

### Screenshot set 1 — Pylontech battery screen

- **SOC:** 83%
- **SOH:** 93%
- **Battery temperature:** 9°C
- Live values shown: ~50.49 V, ~13.5 A, ~681 W

### Screenshot set 2 — Parameters screen (Pylontech)

- **CVL (Charge Voltage Limit):** 53.20 V  
- **CCL (Charge Current Limit):** 14.8 A  
- **DCL (Discharge Current Limit):** 118 A  
- **Requests charging:** No

---

## Assistant interpretation of the parameter values

- Actual battery current was observed near **CCL**, indicating **BMS-limited charging**.
- Temperature at 9°C is above freezing, but it is still common for the BMS to **derate charging current** based on temperature and SOC.
- “Requests charging: No” does not necessarily prevent charging; the key limiter is often **CCL** (and **CVL** at higher SOC/near target voltage).

---

## User provides VRM dashboard screenshot

Key points visible on the dashboard:

- **Generator running:** 1450 W  
- **AC loads:** 580 W  
- **Quattro:** Charging ~875 W  
- **Battery tile:** “Charging”, ~83% SOC, ~50.51 V, ~14.2 A, ~9°C  
- **Battery room temperature (in):** ~6.2°C (24h min ~-0.2°C)  
- **Battery room outside:** ~-14.4°C  

At the bottom:
- **SmartShunt tile:** shows SOC ~10.6% (mismatch vs Pylontech 83%)

---

## Assistant conclusions from the dashboard

1. **Charging is occurring and is constrained by the battery’s CCL**
   - Battery charge current (~14.2 A) closely tracks BMS **CCL (~14.8 A)**.
   - This is expected in a DVCC-managed setup: DVCC enforces CCL and other limits.

2. **Temperature is a plausible driver of current derating**
   - Battery is at 9°C; battery room has dipped close to 0°C.
   - Approaching low temperatures can lead the BMS to reduce CCL substantially.

3. **SOC source mismatch likely impacts generator automation**
   - Pylontech SOC: 83%
   - SmartShunt SOC: 10.6%
   - If generator autostart is using the SmartShunt SOC, it may start/stop unexpectedly or too early/late.

---

## User provides DVCC / Charge Control screenshots

### DVCC settings observed

- **DVCC:** Forced on  
- **Limit charge current:** Off  
- **Limit managed battery charge voltage:** Off  
- **SVS:** Forced off  
- **STS:** Forced off  
- **SCS:** Off  
- **Controlling BMS:** Automatic selection  
  - Options shown: Automatic selection / No BMS control / Pylontech battery

---

## Assistant conclusions from DVCC settings

- DVCC being **forced on** is appropriate for a managed CAN-bus battery like Pylontech.
- “Limit charge current” being **off** supports the conclusion that observed charge limiting is coming from **BMS CCL**, not from a Cerbo-imposed cap.
- “Controlling BMS = Automatic selection” is acceptable given only one relevant BMS (Pylontech) is present; explicitly selecting “Pylontech battery” can make behavior more deterministic but is not strictly required.

---

## Practical takeaways documented

### How recovery works in this system

- Cold conditions → BMS lowers **CCL** (possibly to 0 A) → Victron charging is reduced/stopped  
- Warmer conditions → BMS increases **CCL** → Victron charging increases automatically  

No manual “recovery” step is typically needed unless alarms latch or the battery output disconnects.

### Recommended checks/actions

1. **Trend Battery temperature vs CCL** in VRM to confirm temperature-driven derating.
2. Resolve **SOC mismatch** if generator/ESS logic depends on SOC:
   - Decide whether the authoritative SOC should be **Pylontech (BMS SOC)** or **SmartShunt SOC**.
   - In Cerbo GX: **Settings → System setup → Battery monitor**:
     - Use Pylontech as battery monitor for BMS SOC, or
     - Configure and synchronize SmartShunt if it is to be authoritative.
   - Ensure only one SmartShunt is used as **Battery monitor**, and treat the other as a DC meter if applicable.

---

## Notes

- Screenshots indicate the battery is charging around the BMS CCL limit at ~9°C.
- Battery room temperature can approach freezing; additional thermal protection may be required if consistent charging is needed in winter.
