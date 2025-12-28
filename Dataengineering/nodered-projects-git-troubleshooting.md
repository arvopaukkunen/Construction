# Node-RED Projects + GitHub Version Control (Troubleshooting & Fix)

_Last updated: 2025-12-28_

This note captures a practical troubleshooting session to get **Node-RED Projects** pushing to a **GitHub** repository, and to explain why the Node-RED **History** panel may show no changes.

---

## Environment

- Node-RED URL: `http://mynodered1:1880/` (host: `192.168.123.178`)
- GitHub repository: `https://github.com/arvopaukkunen/nodered-config`
- Node-RED service user (important for SSH keys): `localadmin`

Verified by:

```bash
systemctl show -p User nodered
# User=localadmin
```

---

## Symptom

- Node-RED Project exists and contains multiple flows.
- Node-RED **History** sidebar shows:
  - **Local Changes**: _None_
  - **Changes to commit**: _None_
- User expectation: pushing should update GitHub, but nothing appears to push.

---

## Key point: what the History panel shows

Node-RED Projects’ **History** panel shows **uncommitted Git working tree changes**.  
If the Git repo is clean, **History will be empty**, and there is **nothing to push**.

Also: flow edits typically become file changes only after **Deploy** (which writes `flows.json` / `flows_cred.json`).

---

## Step 1 — Confirm the Project folder and Git repo

Check the Node-RED userDir and projects:

```bash
ls -la ~/.node-red
ls -la ~/.node-red/projects
```

Example output showed a project folder:

```text
~/.node-red/projects/Smarthome
```

Confirm the project contains flows and is a Git repo:

```bash
cd ~/.node-red/projects/Smarthome
ls
# flows.json  flows_cred.json  package.json  README.md

git status
git log --oneline --decorate -10
```

A clean repo with existing commits looked like:

```text
On branch main
nothing to commit, working tree clean
<multiple "Update flow files" commits...>
```

---

## Root cause found: remote name not `origin`

Node-RED Projects UI commonly expects the primary remote to be named **`origin`**.
A non-standard remote name (e.g., `origin-nodered-config`) can prevent the UI push workflow from behaving as expected.

Example problematic config:

```bash
git remote -v
# origin-nodered-config  git@github.com:arvopaukkunen/nodered-config (fetch)
# origin-nodered-config  git@github.com:arvopaukkunen/nodered-config (push)
```

---

## Fix — rename remote to `origin` and set canonical GitHub SSH URL

Run:

```bash
cd ~/.node-red/projects/Smarthome

# Rename remote to what Node-RED expects
git remote rename origin-nodered-config origin

# Set canonical SSH URL (recommended to include .git)
git remote set-url origin git@github.com:arvopaukkunen/nodered-config.git

git remote -v
```

---

## Step 2 — Verify GitHub SSH authentication (for the Node-RED service user)

Because Node-RED runs as `localadmin`, ensure SSH keys and Git operations work for **that same user**.

Test auth:

```bash
ssh -T git@github.com
```

Expected message:

```text
Hi <user>! You've successfully authenticated, but GitHub does not provide shell access.
```

Then confirm the push path:

```bash
git push -u origin main
```

If everything is already synchronized:

```text
branch 'main' set up to track 'origin/main'.
Everything up-to-date
```

---

## Why “Nothing is visible in UI” can still be correct

If:

- `git status` says **working tree clean**, and
- `git push` says **Everything up-to-date**

…then Node-RED’s History panel showing **None** is expected.  
There are no local changes to commit or push.

---

## Validation test — prove the Node-RED UI is attached to the same Git working tree

On the Raspberry Pi, modify a file in the project (safe test):

```bash
cd ~/.node-red/projects/Smarthome
echo "# ui-change-test $(date -Is)" >> README.md
git status
```

Then in Node-RED editor:
- Right sidebar → **history**
- Click the **refresh** icon (top-right)

Expected: `README.md` appears under **Local Changes**.

### If it does NOT appear
Node-RED may be running with a different `--userDir` than the one you edited.
Confirm Node-RED runtime parameters:

```bash
systemctl show -p ExecStart -p WorkingDirectory -p User nodered
ps -ef | grep -i node-red | grep -v grep
```

---

## Operational workflow (what to do day-to-day)

1. Make flow edits in Node-RED.
2. Click **Deploy** (writes changes to `flows.json` / `flows_cred.json` in the project).
3. Open the **history** sidebar:
   - Review **Local Changes**
   - **Commit** with a message
4. Push to GitHub:
   - Use Node-RED Projects UI push, or
   - CLI: `git push`

Node-RED Projects does **not** auto-commit/auto-push; it requires explicit commit/push actions.

---

## Summary

- The local repo and flows were present and committed.
- The key configuration issue was the Git remote name not being `origin`.
- After renaming to `origin`, verifying SSH auth, and confirming push status, the system behaved correctly.
- An empty Node-RED History panel is normal when Git is clean and nothing has changed since the last commit/deploy.

