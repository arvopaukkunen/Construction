# Home Assistant: Stop RuuviTag Writes to InfluxDB v2 (Keep Other Sensors) + Set Up Git Remote (GitHub)

This document captures the exact, repeatable steps used to:
1. Keep the Home Assistant → InfluxDB v2 integration enabled **for other entities**, but **exclude only RuuviTag sensors**.
2. Configure `/config` as a Git repository with a GitHub remote under `https://github.com/arvopaukkunen`.

Environment assumptions (adjust as needed):
- Home Assistant config directory: `/config`
- You edit files via VS Code Server / Terminal on the HA host (or HA add-on container)
- You have an InfluxDB 2.x instance reachable from HA
- Your GitHub account: `arvopaukkunen`

---

## 1) Keep InfluxDB writes, exclude only RuuviTag entities (Option B)

### 1.1 Why RuuviTag is currently being written
If you have **include** configured like this:

```yaml
include:
  domains:
    - sensor
```

Home Assistant will send **all** `sensor.*` entities to InfluxDB unless explicitly excluded. RuuviTag entities are typically `sensor.*`, so they are included by default.

---

### 1.2 Update `configuration.yaml` to exclude RuuviTag

In `/config/configuration.yaml`, add `entity_globs` under your existing `influxdb: -> exclude:` block.

**Example (based on your current config)**

```yaml
# --- InfluxDB v2 output (HA → InfluxDB 2.x) ---
influxdb:
  api_version: 2
  ssl: false
  host: !secret influxdb_host
  port: !secret influxdb_port
  token: !secret influxdb_token
  organization: !secret influxdb_org
  bucket: !secret influxdb_bucket
  tags:
    source: HA
  tags_attributes:
    - friendly_name
  #default_measurement: units

  exclude:
    entities:
      - zone.home
    domains:
      - persistent_notification
      - person
    entity_globs:
      - sensor.ruuvi*
      - sensor.*ruuvi*
      - sensor.*ruuvitag*

  include:
    domains:
      - sensor
      - binary_sensor
      - sun
    entities:
      - weather.home
```

**Notes**
- `entity_globs` is the most scalable approach when you have multiple Ruuvi entities.
- If your Ruuvi entities do not contain `ruuvi` in the entity_id, use the exact IDs instead (see 1.3).

---

### 1.3 Alternative: exclude exact RuuviTag entity IDs
If you prefer a deterministic list:

1. In HA UI: **Developer Tools → States**
2. Search: `ruuvi`
3. Copy the `entity_id` values (e.g., `sensor.ruuvitag_0c90_temperature`, etc.)
4. Add them under `exclude.entities`

Example:

```yaml
exclude:
  entities:
    - zone.home
    - sensor.ruuvitag_0c90_temperature
    - sensor.ruuvitag_0c90_humidity
    - sensor.ruuvitag_0c90_pressure
```

---

### 1.4 Restart Home Assistant
Changes to `configuration.yaml` should be applied via restart:

- **Settings → System → Restart**

---

### 1.5 Validate RuuviTag is no longer written

#### A) Validate in InfluxDB
Check whether any new Ruuvi points arrive after the restart.

Typical checks:
- Search the last 5–10 minutes for measurements/tags you recognize as RuuviTag
- Confirm other sensors (e.g., Miele / Legrand / LIFX) still appear

#### B) Validate via Home Assistant logs
In HA:
- **Settings → System → Logs**
- Filter for `influxdb`

You should see general write activity continuing, but no Ruuvi entity writes.

---

## 2) Set up Git local + GitHub remote for Home Assistant `/config`

You already have a local Git repo in `/config` (the `.git/` directory exists). This section wires it to GitHub and pushes safely.

### 2.1 Safety: ensure you do NOT commit secrets, DBs, logs
Your `/config` directory contains items that should **not** be pushed to GitHub, including:
- `secrets.yaml` (credentials)
- `home-assistant_v2.db*` (database)
- `home-assistant.log*` (logs)
- `.storage/` (often contains tokens and UI-configured integration details)

#### Recommended `/config/.gitignore`
Edit or create `/config/.gitignore` to contain at least:

```gitignore
# Secrets
secrets.yaml
secrets/*.yaml
*.pem
*.key

# Databases / runtime artifacts
home-assistant_v2.db*
*.db
*.db-shm
*.db-wal

# Logs
home-assistant.log*
*.log
*.log.*

# Lock files
.ha_run.lock

# UI storage (often contains tokens)
.storage/
```

Verify what is staged before committing:

```bash
cd /config
git status
```

If anything sensitive is listed as “to be committed”, fix `.gitignore` and unstage:

```bash
git restore --staged .
```

Then re-check `git status`.

---

### 2.2 Create an SSH key for GitHub (recommended)
You attempted to create a key under `/config/.ssh/` but the folder did not exist. Create it first.

#### Step 1: Create `/config/.ssh` and set permissions
```bash
cd /config
mkdir -p /config/.ssh
chmod 700 /config/.ssh
```

#### Step 2: Generate the key
If you want **no passphrase** (typical for embedded hosts), press Enter when prompted.

```bash
ssh-keygen -t ed25519 -C "ha-config" -f /config/.ssh/id_ed25519
```

#### Step 3: Start ssh-agent and add the key
```bash
eval "$(ssh-agent -s)"
ssh-add /config/.ssh/id_ed25519
```

#### Step 4: Copy the public key and add to GitHub
```bash
cat /config/.ssh/id_ed25519.pub
```

In GitHub:
- **Settings → SSH and GPG keys → New SSH key**
- Title: `HomeAssistant /config`
- Paste the public key text

#### Step 5: Test SSH to GitHub
```bash
ssh -T git@github.com
```

Expected result: authentication succeeds (GitHub does not provide shell access).

---

### 2.3 Create a GitHub repository
In GitHub under `arvopaukkunen`, create a repository, for example:
- `home-assistant-config`

Recommended: **Private** repository.

---

### 2.4 Set (or replace) `origin` remote and push

#### Step 1: Inspect existing remotes
```bash
cd /config
git remote -v
```

If you already have an `origin` you want to replace:
```bash
git remote remove origin
```

#### Step 2: Rename branch to `main` (optional but recommended)
Your repo may be on `master` currently. Rename to `main`:

```bash
cd /config
git branch -M main
```

#### Step 3: Add GitHub SSH remote
Replace repo name if different:

```bash
cd /config
git remote add origin git@github.com:arvopaukkunen/home-assistant-config.git
```

#### Step 4: Commit and push
```bash
cd /config
git add -A
git commit -m "Initial Home Assistant configuration"
git push -u origin main
```

---

### 2.5 Quick verification commands
```bash
cd /config
git status -sb
git remote -v
git log --oneline --max-count=5
```

---

## 3) Operational Notes and Recommended Workflow

### 3.1 Normal change workflow
```bash
cd /config
git pull --rebase
git add -A
git commit -m "Describe change"
git push
```

### 3.2 If you use UI-based integrations heavily
Be cautious with `.storage/`. It is convenient to version but often contains sensitive material.
Default recommendation: keep `.storage/` excluded and treat Git as “infrastructure + YAML” versioning.

---

## 4) Troubleshooting

### 4.1 “Saving key failed: No such file or directory”
Cause: target folder does not exist. Fix:

```bash
mkdir -p /config/.ssh
chmod 700 /config/.ssh
```

### 4.2 “Permission denied (publickey)” when testing SSH
- Ensure the public key was added to GitHub
- Ensure `ssh-add` succeeded
- Re-test:

```bash
ssh -vT git@github.com
```

### 4.3 Accidentally committed secrets
If you committed `secrets.yaml` or `.storage/`, treat it as a leak:
- Remove from Git history (requires rewrite), rotate tokens/credentials, and force push.
- Prefer prevention via `.gitignore`.

---

## Appendix A: Your HA endpoints (reference)
- Home Assistant UI: `http://192.168.123.208:8123`
- InfluxDB 2.x (example): `http://192.168.123.115:8086` (adjust to your actual host)

