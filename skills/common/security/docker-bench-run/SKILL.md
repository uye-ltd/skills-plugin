---
name: docker-bench-run
description: Live CIS Docker Benchmark execution. Runs docker/docker-bench-security against the local Docker host and parses all §1–§7 results into CIS-numbered findings. Covers host configuration, daemon, runtime, ops, and Swarm — sections unreachable by static analysis. Emits TOOL_UNAVAILABLE if Docker is inaccessible.
language: common
used-by: docker-security
---

Execute docker-bench-security against the live Docker host and parse all findings.

## Step 1 — Detect availability

Check in order:
1. `which docker-bench-security` — natively installed
2. `docker info > /dev/null 2>&1` exits 0 — Docker daemon accessible for container-mode run

If neither succeeds, emit:
```
TOOL_UNAVAILABLE: docker-bench-security is not installed and Docker daemon is not accessible.
Sections §1, §6, and §7 could not be audited. Static analysis covers §2–§5 only.
To enable live audit, run: docker info (verify Docker is running and accessible)
```
Then stop — the docker-security agent will proceed with static results only.

## Step 2 — Run the tool

**Preferred (container mode — no native install required):**
```bash
docker run --rm --net host --pid host --userns host --cap-add audit_control \
  -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
  -v /etc:/etc:ro \
  -v /lib/systemd/system:/lib/systemd/system:ro \
  -v /usr/bin/containerd:/usr/bin/containerd:ro \
  -v /usr/bin/runc:/usr/bin/runc:ro \
  -v /usr/lib/systemd:/usr/lib/systemd:ro \
  -v /var/lib:/var/lib:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  --label docker_bench_security \
  docker/docker-bench-security 2>/dev/null
```

**Native install:**
```bash
sudo docker-bench-security 2>/dev/null
```

If neither can be run in the current session (e.g. requires sudo), provide the exact command above and ask the user to share the output, then proceed to Step 3 with the pasted results.

## Step 3 — Parse output

docker-bench-security emits lines in this format:
```
[PASS] 1.1.1 Ensure a separate partition for containers has been created
[WARN] 2.1  Ensure network traffic is restricted between containers on the default bridge network
[INFO] 4.5  Ensure Content trust for Docker is Enabled
[NOTE] 5.14 Ensure that the on-failure container restart policy is set to 5
```

Severity mapping:
| Tag | Default severity | Upgrade to critical if… |
|-----|-----------------|------------------------|
| WARN | major | CIS ID is 5.2 (privileged), 5.4 (host network), 5.5 (host PID), 5.6 (host IPC), 4.10 (secrets) |
| INFO | minor | — |
| NOTE | nit | — |
| PASS | skip | — |

## Step 4 — Classify by section and fixability

Map each finding to its CIS section header:

| Range | Section |
|-------|---------|
| 1.x | §1 Host Configuration |
| 2.x | §2 Docker Daemon Configuration |
| 3.x | §3 Docker Daemon Configuration Files |
| 4.x | §4 Container Images and Build Files |
| 5.x | §5 Container Runtime |
| 6.x | §6 Docker Security Operations |
| 7.x | §7 Docker Swarm Configuration |

Fixability rules for live findings:
- **yes** (Executor can edit files): §2 daemon.json settings, §4 Dockerfile controls, §5 compose controls
- **no** (MANUAL): §1 host-level (kernel params, partitions, auditd), §3 file permissions, §6 ops procedures, §7 Swarm TLS and node configuration

For §1 MANUAL findings, always include the verification and fix command:
- 1.1.1: `mount | grep /var/lib/docker` — create dedicated partition
- 1.1.2–1.1.21: `auditctl -l | grep docker` — configure auditd rules

## Step 5 — Output

```
## Docker Bench Live Execution

### Tool
<native | container | TOOL_UNAVAILABLE>

### Sections covered
§1–§7 (all) | or note which were skipped and why

### Findings
| CIS ID | Section | Severity | Description | Fixable |
|--------|---------|----------|-------------|---------|
| 2.1    | §2 Daemon   | major    | Network traffic not restricted between containers on default bridge | yes |
| 5.2    | §5 Runtime  | critical | Container running with privileged flag                             | yes |
| 1.1.1  | §1 Host     | major    | No separate partition for /var/lib/docker. Fix: mount dedicated partition. Verify: mount \| grep /var/lib/docker | no |
| 6.1    | §6 Ops      | minor    | Image vulnerability scanning not documented                        | no |

### Summary
- Critical: N  Major: N  Minor: N  Nit: N
- Sections with findings: §N, §N
- Auto-fixable: N  Requires human: N
```

$ARGUMENTS
