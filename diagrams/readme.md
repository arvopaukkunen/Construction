# Diagrams

## Logical Data & Control Flow (High Level)
```mermaid
flowchart LR
    %% Edge / Device Layer
    subgraph "Edge Device Layer"
      S1["Critical Sensors (100)"]
      S2["HVAC Sensors"]
      S3["Appliance Sensors"]
      S4["Lighting Sensors"]
      TG["Telegram Bots & Integrations"]
    end

    %% Brokers
    subgraph "Brokers (HA)"
      MQ1["MQTT/NATS A"]
      MQ2["MQTT/NATS B"]
    end

    %% Processing & Orchestration
    subgraph "Processing & Orchestration"
      NR1["Node-RED – Ingest & Validate"]
      NR2["Node-RED – Enrich & Route"]
      NR3["Node-RED – DB Loader"]
      TF["Telegraf (optional)"]
    end

    %% On-Prem Data Stores
    subgraph "On-Prem Data Stores"
      RS["Redis Streams – short buffer"]
      TS["InfluxDB – 1–7d retention"]
      SQL["Relational DB – MySQL/Postgres"]
      FS["SSD Staging – CSV/Parquet"]
    end

    %% Cloud (Optional)
    subgraph "Cloud (Optional, Batch Only)"
      OB["Object Storage"]
      DW["Analytics / Data Warehouse"]
    end

    %% Connections
    S1 -->|QoS1/2, wired| MQ1
    S1 -->|QoS1/2, wired| MQ2
    S2 --> MQ1
    S2 --> MQ2
    S3 --> MQ1
    S3 --> MQ2
    S4 --> MQ1
    S4 --> MQ2
    TG --> MQ1
    TG --> MQ2

    MQ1 --> NR1
    MQ2 --> NR1
    NR1 --> NR2

    NR2 -->|Batched Line Protocol| TS
    NR2 -->|Stream| RS
    NR2 -->|Batch Files| FS
    FS -->|Bulk Load| SQL

    TS -->|Daily/Weekly Export| OB
    SQL -->|Daily/Weekly Export| OB
    OB --> DW

```
## 2) On-Prem Infrastructure (Per Building + Core)
```mermaid
flowchart TB
  %% Core Room
  subgraph "Core Room"
    FW["Industrial Firewall"]
    RT["Router"]
    SWC["Core Switch Stack – L3"]
    VMs["Mini-Server / NUC – Proxmox or VMware"]
    MQA["Broker A"]
    MQB["Broker B"]
    VRRP["VRRP / Keepalived VIP"]
    NFS["NAS / NFS – Snapshots"]
  end

  %% Building 1
  subgraph "Building 1"
    SW1["Edge Switch – PoE"]
    P1a["Node-RED Pi 5 – Ingest"]
    P1b["Node-RED Pi 5 – Processor"]
    P1c["Node-RED Pi 5 – DB Loader"]
    G1["Gateway – RS485, Zigbee, BLE"]
  end

  %% Building 2
  subgraph "Building 2"
    SW2["Edge Switch – PoE"]
    P2a["Node-RED Pi 5"]
    P2b["Node-RED Pi 5"]
    G2["Protocol Gateway"]
  end

  %% Building 3
  subgraph "Building 3"
    SW3["Edge Switch – PoE"]
    P3a["Node-RED Pi 5"]
    G3["Protocol Gateway"]
  end

  %% Building 4
  subgraph "Building 4"
    SW4["Edge Switch – PoE"]
    P4a["Node-RED Pi 5"]
    G4["Protocol Gateway"]
  end

  %% Sensor Connections
  SENSORS1["Critical Sensors"] --> SW1
  SENSORS2["HVAC / Appliances / Lights"] --> SW1

  %% Switch Links
  SW1 --- SWC
  SW2 --- SWC
  SW3 --- SWC
  SW4 --- SWC

  %% Node-RED Pi Connections
  P1a --> SW1
  P1b --> SW1
  P1c --> SW1
  P2a --> SW2
  P2b --> SW2
  P3a --> SW3
  P4a --> SW4

  %% Core Interconnects
  MQA --- SWC
  MQB --- SWC
  VRRP --- MQA
  VRRP --- MQB
  NFS --- SWC
  VMs --- SWC
  FW --> RT --> SWC

```
## 3) Network & Reliability Design
```mermaid
flowchart LR
  %% Network Segmentation
  subgraph "Network Segmentation"
    V1["VLAN 10 – Sensors"]
    V2["VLAN 20 – Control (Node-RED Workers)"]
    V3["VLAN 30 – Data Stores"]
    V4["VLAN 40 – Mgmt / Out-of-Band"]
  end

  %% Nodes on VLANs
  SENS["Sensor NICs – VLAN 10"]
  NR["Node-RED Workers – VLAN 20"]
  BROKERS["Brokers + VIP – VLAN 20"]
  STORES["Redis / Influx / SQL / NAS – VLAN 30"]
  MGMT["Admin – VLAN 40"]

  %% Connections
  SENS --> BROKERS
  NR --> BROKERS
  NR --> STORES
  MGMT --> SENS
  MGMT --> NR
  MGMT --> STORES
```
## 4) Runtime Topology (Scalable by Role)
```mermaid
flowchart TB
  %% Ingest Runtimes
  subgraph "Ingest Runtimes"
    I1["NR-Ingest-B1"]
    I2["NR-Ingest-B2"]
    I3["NR-Ingest-B3"]
    I4["NR-Ingest-B4"]
    T1["Telegraf Collectors"]
  end

  %% Transform / Enrich
  subgraph "Transform & Enrich"
    P1["NR-Processor A"]
    P2["NR-Processor B"]
  end

  %% DB Loaders
  subgraph "DB Loaders"
    L1["NR-Load-SQL A"]
    L2["NR-Load-SQL B"]
  end

  %% Broker & DB
  BROKERS["MQTT / NATS VIP"]
  SQL["Relational Database"]

  %% Connections
  BROKERS --> I1
  BROKERS --> I2
  BROKERS --> I3
  BROKERS --> I4

  I1 --> BROKERS
  I2 --> BROKERS
  I3 --> BROKERS
  I4 --> BROKERS

  BROKERS --> P1
  BROKERS --> P2

  P1 --> L1
  P1 --> L2
  P2 --> L1
  P2 --> L2

  L1 --> SQL
  L2 --> SQL
```
## 5) Topics, Queues & Batching Conventions
```mermaid
flowchart TB
  %% Producers
  subgraph "Producers"
    SENSCRIT["Critical Sensors"]
    SENSORHVAC["HVAC Sensors"]
    APPL["Appliances"]
    LIGHT["Lighting"]
    AGENTS["Worker Agents"]
    OPS["Operator Commands"]
  end

  %% MQTT Topic Schema
  subgraph "MQTT Topic Schema"
    C1["plant/critical/&lt;system&gt;/&lt;sensorId&gt;"]
    B1["building/&lt;id&gt;/hvac/&lt;sensorId&gt;"]
    B2["building/&lt;id&gt;/appliance/&lt;device&gt;/&lt;metric&gt;"]
    B3["building/&lt;id&gt;/lighting/&lt;zone&gt;/&lt;metric&gt;"]
    A1["telemetry/agents/&lt;agentId&gt;"]
    CMD["control/commands/&lt;target&gt;"]
  end

  %% Broker
  subgraph "Broker"
    VIP["Broker VIP"]
  end

  %% Node-RED Ingest
  subgraph "Node-RED Ingest"
    ING["Form Batches"]
  end

  %% Batch Policies
  subgraph "Batch Policies"
    CRITB["Critical  
250–750ms or 100–500 msgs  
QoS2"]
    NONB["Non-Critical  
2–10s or 1–2k msgs  
QoS1"]
    META["Batch Metadata  
batchId, ts_first, ts_last  
count, schemaVer, crc32"]
  end

  %% Downstream
  subgraph "Processed Topics & Loaders"
    PROCQ["processed/&lt;group&gt;/batch"]
    FS["stage/sql/&lt;table&gt;/file"]
    LOAD["NR-Load-SQL"]
  end

  %% Connections
  SENSCRIT --> C1
  SENSORHVAC --> B1
  APPL --> B2
  LIGHT --> B3
  AGENTS --> A1
  OPS --> CMD

  C1 --> VIP
  B1 --> VIP
  B2 --> VIP
  B3 --> VIP
  A1 --> VIP
  CMD --> VIP

  VIP --> ING

  ING --> CRITB
  ING --> NONB

  CRITB --> META
  NONB --> META

  META --> PROCQ
  PROCQ --> FS
  FS --> LOAD

```
## 6) Node-RED Flow Roles (What each does)
```mermaid
flowchart LR
  %% Broker VIP
  subgraph "Broker VIP"
    BRO["MQTT / NATS VIP"]
  end

  %% Ingest Layer
  subgraph "NR-Ingest"
    ING["NR-Ingest  
Subscribe, Validate, Units  
Form Batches  
SSD Queue"]
  end

  %% Processing Layer
  subgraph "NR-Proc"
    PROC["NR-Proc  
Enrich, Normalize  
Write to Influx (Short Retention)  
Fan-out to Redis  
Stage Files"]
  end

  %% On-Prem Stores
  subgraph "On-Prem Stores"
    TS["InfluxDB – Short Retention"]
    RS["Redis Streams"]
    FS["Staged Files"]
    SQL["Relational Database"]
    ARCH["Archive"]
    RETRY["Retry Queue"]
  end

  %% SQL Loader
  subgraph "NR-Load-SQL"
    LOAD["NR-Load-SQL  
Bulk Load  
Upsert / Merge  
Retry + Archive"]
  end

  %% Data Flow
  BRO --> ING
  ING --> BRO
  BRO --> PROC

  PROC --> TS
  PROC --> RS
  PROC --> FS

  FS --> LOAD
  LOAD --> SQL
  LOAD --> ARCH
  LOAD --> RETRY

```
## 7) Sizing & Targets (Raspberry Pi 5 + SSD)
```mermaid
flowchart TB
  %% Edge / Building Tier
  subgraph "Edge / Building"
    PIING["Pi 5 – Ingest & Process  
8GB RAM + USB3 SSD (250–500GB)  
10–50k rows/min – light transform"]
  end

  %% DB Loader Tier
  subgraph "DB Loader Tier"
    PILOAD["Pi 5 – DB Loader  
Fast SSD  
Bulk: 100k–1M rows/job"]
  end

  %% Core Room Tier
  subgraph "Core Room"
    BROKN["2× Brokers – NUC / IPC  
TLS + Persistent Storage"]
    INFL["InfluxDB – Short Retention (1–7d)"]
    REDS["Redis Streams"]
    SQLN["MySQL / Postgres  
Bulk Load Enabled"]
  end

  %% Data Flow
  PIING --> BROKN
  BROKN --> PIING
  BROKN --> PILOAD
  PILOAD --> SQLN
  PIING --> INFL
  PIING --> REDS
```
## 8) Security & Operations

```mermaid
flowchart LR
  %% Security Section
  subgraph "Security"
    TLS["TLS Everywhere"]
    CERTS["Client Certificates per Building"]
    LEAST["Least-Privilege Accounts"]
  end

  %% Observability Section
  subgraph "Observability"
    NRM["Node-RED Metrics"]
    BRM["Broker Metrics"]
    DBM["DB Loader Metrics"]
    PROM["Prometheus"]
    GRAF["Grafana"]
    ALERT["Alertmanager"]
  end

  %% Resilience Section
  subgraph "Resilience"
    UPS["UPS Power"]
    VIP["VRRP / Keepalived VIP"]
    AUTOSTART["Autostart – systemd / pm2"]
    BACKP["Backpressure & Rate Limits"]
    DRILLS["Failure Drills"]
  end

  %% Observability Flow
  NRM --> PROM
  BRM --> PROM
  DBM --> PROM
  PROM --> GRAF
  PROM --> ALERT

  %% Security Links
  TLS --- CERTS
  TLS --- LEAST

```
## 9) Cloud Offload (Optional, Scheduled)
```mermaid
flowchart LR
  %% On-Prem Segment
  subgraph "On-Prem"
    STAGE["Staged Files – CSV / Parquet"]
    TS["InfluxDB – Short Retention"]
    SQL["Relational Database"]
    OFF["Node-RED Offload"]
  end

  %% Cloud Segment
  subgraph "Cloud"
    OBJ["Object Storage"]
    DWH["Analytics / Data Warehouse"]
  end

  %% Data Flow
  STAGE --> OFF
  TS --> OFF
  SQL --> OFF
  OFF --> OBJ --> DWH

```