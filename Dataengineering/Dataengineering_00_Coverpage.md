# Data Engineering Documentation (Home IT)

_Generated: 2026-01-01_

## Summary

This folder consolidates the operational runbooks and implementation notes for the Home IT data platform, covering:

- **Ingestion & telemetry**: Home Assistant and other sources writing to **InfluxDB 2.x** (including strategies to exclude specific noisy sources such as RuuviTag).
- **Integration & automation**: **Node-RED** flows and troubleshooting notes, with Git-based version control for repeatable deployments.
- **Warehouse-style governance on MariaDB**: a practical **dbt** pattern for lifecycle/lineage concepts (RAW/WORK/CURATED and downstream layers), plus a governance gate for GDPR special-category data.

Use the index below as the starting point for the documentation set.

## Document Index

| Document | What it covers |
|---|---|
| [Home Assistant: Stop RuuviTag Writes to InfluxDB v2 (Keep Other Sensors) + Set Up Git Remote (GitHub)](ha_influx_ruuvi_git_setup.md) | This document captures the exact, repeatable steps used to: 1. Keep the Home Assistant → InfluxDB v2 integration enabled for other entities, but exclude only RuuviTag sensors. |
| [InfluxDB 2.x archiving with CLI (Arvosoft / sensors → sensor_YYYY)](influxdb2_archiving_cli.md) | Archiving/retention approach for InfluxDB 2.x buckets using the CLI, with year-based buckets. |
| [Node-RED Projects + GitHub Version Control (Troubleshooting & Fix)](nodered-projects-git-troubleshooting.md) | Last updated: 20251228 |
| [A complete, warehouse-native dbt pattern that delivers:](readme.md) | Below is a complete, warehousenative dbt pattern that delivers: |
| [MariaDB (`smarthome`) Governance with dbt (`dw_mariadb`) — Practical Runbook](smarthome_dbt_governance_runbook.md) | This document captures the working governance pattern for detecting and controlling GDPR special‑category personal data signals in a single MariaDB database using dbt. It is writte |
| [MariaDB (smarthome) + dbt Governance Gate for GDPR Special-Category Personal Data](smarthome_mariadb_dbt_governance.md) | This document describes the practical, enforceable governance pattern implemented for the smarthome MariaDB database using dbt project MariaDbDevContainers. |

## Recommended Reading Order

1. **Governance overview**: start with the dbt pattern overview, then the runbook and governance gate.
2. **Operational ingestion controls**: configure HA/Influx write filtering and Influx archiving as needed.
3. **Automation reliability**: apply Node-RED + Git troubleshooting guidance to keep flows reproducible.

## Notes

- All links are **relative** so the index works in GitHub, Azure DevOps Wiki (repo-backed), and local browsing.
- If you move or rename files, update this index to keep it authoritative.
