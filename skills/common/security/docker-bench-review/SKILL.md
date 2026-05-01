---
name: docker-bench-review
description: Static CIS Docker Benchmark analysis. Reviews Dockerfiles, docker-compose.yml, and daemon.json against CIS §2–§5 controls without requiring a running Docker host. Produces a CIS-numbered findings table with auto-fixable flags. Invoked by the docker-security agent and by Reviewer when Docker files change.
language: common
used-by: docker-security, reviewer
---

Perform a static CIS Docker Benchmark analysis of all Docker-related files in scope.

## Step 1 — Locate inputs

Find and read all of the following if present in the project:
- All `Dockerfile` and `Dockerfile.*` variants
- `docker-compose.yml`, `docker-compose.yaml`, `docker-compose.*.yml`, `compose.yml`, `compose.yaml`
- `daemon.json` in the project root or at `/etc/docker/daemon.json`
- `.dockerignore`

If no Docker files are found, output: `No Docker files found in scope — skipping static analysis.`

## Step 2 — Apply CIS controls

### §2 — Docker Daemon Configuration (`daemon.json`)

| CIS ID | Check | Fixable |
|--------|-------|---------|
| 2.1 | `"icc": false` — inter-container communication restricted | yes |
| 2.2 | `"log-level": "info"` — not `"debug"` in production | yes |
| 2.5 | No `"insecure-registries"` entries | yes |
| 2.6 | `"storage-driver"` is not `"aufs"` | yes |
| 2.8 | `"userns-remap"` is configured | yes |
| 2.14 | `"live-restore": true` | yes |
| 2.15 | `"userland-proxy": false` | yes |
| 2.17 | `"experimental": false` (production) | yes |

### §3 — Docker Daemon Configuration Files

These require host-level inspection; record all as MANUAL with remediation commands.

| CIS ID | Check | Fixable |
|--------|-------|---------|
| 3.1 | `docker.service` owned by `root:root` | no |
| 3.2 | `docker.service` permissions `644` or stricter | no |
| 3.15 | Docker socket owned by `root:docker` | no |
| 3.16 | Docker socket permissions `660` or stricter | no |
| 3.20 | `daemon.json` owned by `root:root` | no |
| 3.22 | `daemon.json` permissions `644` or stricter | no |

For each §3 finding, include the verification command:
- 3.1/3.2: `stat -c '%U %G %a' /lib/systemd/system/docker.service`
- 3.15/3.16: `stat -c '%U %G %a' /var/run/docker.sock`
- 3.20/3.22: `stat -c '%U %G %a' /etc/docker/daemon.json`

### §4 — Container Images and Build Files (`Dockerfile`)

| CIS ID | Check | Fixable |
|--------|-------|---------|
| 4.1 | `USER` instruction present and not `root` or `0` | yes |
| 4.2 | `FROM` uses a named, non-`latest` base image from a trusted registry | no — MANUAL (trust decision) |
| 4.5 | `ENV DOCKER_CONTENT_TRUST=1` present, or `ARG DOCKER_CONTENT_TRUST=1` | yes |
| 4.6 | `HEALTHCHECK` instruction present | yes |
| 4.7 | `RUN apt-get update` always chained with `apt-get install` in the same layer | yes |
| 4.8 | `RUN find / -xdev -perm /6000 -type f -exec chmod a-s {} \;` or equivalent setuid/setgid removal | yes |
| 4.9 | `COPY` used instead of `ADD` (flag `ADD` unless tar extraction is intentional) | yes |
| 4.10 | No secrets in `ENV` or `ARG` (passwords, tokens, keys, `_SECRET`, `_PASSWORD`, `_KEY` patterns) | no — MANUAL (requires secret management strategy) |
| 4.11 | Package versions pinned in `apt-get install`, `apk add`, `pip install` etc. | yes |

### §5 — Container Runtime (`docker-compose.yml`)

| CIS ID | Check | Fixable |
|--------|-------|---------|
| 5.2 | No `privileged: true` | yes |
| 5.3 | No sensitive host paths mounted: `/`, `/etc`, `/proc`, `/sys`, `/dev`, `/run` | no — MANUAL |
| 5.4 | No `network_mode: host` | yes |
| 5.5 | No `pid: host` | yes |
| 5.6 | No `ipc: host` | yes |
| 5.7 | No host ports < 1024 mapped (e.g. `"80:80"`) unless intentional and documented | yes |
| 5.10 | `mem_limit` (or `deploy.resources.limits.memory`) set per service | yes |
| 5.12 | `read_only: true` on container root filesystem | yes |
| 5.14 | `restart` policy is `on-failure` with a max count, not `always` without limit | yes |
| 5.21 | Docker socket (`/var/run/docker.sock`) not mounted as a volume | no — MANUAL |
| 5.25 | `security_opt: ["no-new-privileges:true"]` present per service | yes |
| 5.28 | `pids_limit` set per service | yes |

## Step 3 — Severity mapping

| Condition | Severity |
|-----------|---------|
| Privilege escalation (5.2 privileged, 5.4 host network, 5.5 host PID, 5.6 host IPC, 4.10 secrets) | critical |
| Missing security control (5.25, 5.21, 4.1 no USER, 2.5 insecure registries) | major |
| Best-practice deviation (4.6 HEALTHCHECK, 4.9 ADD, 5.10 mem_limit, 5.28 pids) | minor |
| §3 file permission notes, documentation gaps | nit |

## Output format

```
## Docker Bench Static Analysis

### Findings
| CIS ID | Section | Severity | File | Line | Description | Fixable |
|--------|---------|----------|------|------|-------------|---------|
| 5.2    | §5 Runtime  | critical | docker-compose.yml | 34 | privileged: true grants full host access | yes |
| 4.9    | §4 Images   | minor    | Dockerfile         | 12 | ADD used instead of COPY                 | yes |
| 3.15   | §3 Daemon Files | nit  | —                  | —  | Docker socket permissions require host verification: stat -c '%U %G %a' /var/run/docker.sock | no |

### Summary
- Critical: N  Major: N  Minor: N  Nit: N
- Auto-fixable: N  Requires human: N
```

Use `—` for File and Line when the check requires host inspection (§3 controls).
Omit PASS results — only report failures.

$ARGUMENTS
