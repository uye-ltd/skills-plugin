# Contract: Docker Security Report

Produced by: docker-security agent
Consumed by: Executor (on FIX_NOW), or User (on REVIEW_REQUIRED or CLEAN)

## Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| Audit mode | yes | enum: `static-only`, `live+static` | Which analysis methods ran |
| CIS sections covered | yes | list | Each of §1–§7 with source (`static`, `live`, `both`, `skipped`) |
| Findings | yes | table | All CIS findings; use "No findings" if clean |
| Summary | yes | counts | Critical/major/minor/nit counts; fixable vs manual breakdown |
| Manual actions required | yes | list | MANUAL findings with verify and fix commands; use "None" if all fixable or clean |
| Recommended action | yes | enum: `CLEAN`, `FIX_NOW`, `REVIEW_REQUIRED` | Outcome and next step |
| Docker Security Fix Request | conditional | block | Required when `Recommended action: FIX_NOW` |

### Findings table columns

| Column | Required | Description |
|--------|----------|-------------|
| CIS ID | yes | CIS control identifier (e.g. `4.9`, `5.2`) |
| Section | yes | §N name |
| Severity | yes | `critical`, `major`, `minor`, `nit` |
| Source | yes | `static`, `live`, or `both` |
| File | yes | File path, or `—` for live-only / host-level findings |
| Line | yes | Line number, or `—` |
| Description | yes | What was found and why it matters |
| Fixable | yes | `yes` or `no` |

### Recommended action values

| Value | Condition | Next step |
|-------|-----------|-----------|
| `CLEAN` | No findings at any severity | Done — no action required |
| `FIX_NOW` | At least one FIXABLE finding exists | Append Fix Request; hand off to Executor |
| `REVIEW_REQUIRED` | Findings exist but all are MANUAL | Surface to user; no Executor handoff |

## Fix Request format

Appended after the report when `Recommended action: FIX_NOW`:

```
## Docker Security Fix Request

### Context
<one sentence: what was found and in which files>

### Fixes to apply (in order)
1. [<file>:<line>] <exact change to make> — CIS <ID> (<severity>)
2. ...

### Verification
<command or instruction to confirm all FIXABLE findings now pass>

### Executor note
Set `docker_security_fix: true` in the Execution Summary.
```

## Invariants

- Findings table must always be present (use "No findings" if clean)
- Manual actions section must always be present (use "None" if clean or all fixable)
- TOOL_UNAVAILABLE must be documented in "CIS sections covered" with explicit statement of skipped sections
- Fix Request must contain only FIXABLE findings — never MANUAL ones
- The `docker_security_fix: true` Executor note is mandatory in every Fix Request
- Severity must follow the mappings: `critical` for privilege escalation and secrets exposure; `major` for missing security controls; `minor` for best-practice deviations; `nit` for §3 host-level notes
- Source deduplication: when both static and live flag the same CIS ID, produce one row tagged `source: both`

## Severity quick-reference

| Severity | Examples |
|----------|---------|
| critical | `privileged: true` (5.2), host network (5.4), host PID/IPC (5.5/5.6), secrets in ENV (4.10) |
| major | Missing `USER` (4.1), `insecure-registries` (2.5), Docker socket mounted (5.21), no `userns-remap` (2.8) |
| minor | Missing `HEALTHCHECK` (4.6), `ADD` instead of `COPY` (4.9), no `mem_limit` (5.10), no `pids_limit` (5.28) |
| nit | §3 file permission verification notes, missing optional hardening |

## Example

```markdown
## Docker Security Report

### Audit mode
live+static

### CIS sections covered
- §1 Host Configuration — live (docker-bench-security container)
- §2 Docker Daemon Configuration — static (daemon.json) + live
- §3 Docker Daemon Configuration Files — static (notes only; host verification required)
- §4 Container Images and Build Files — static (Dockerfile)
- §5 Container Runtime — static (docker-compose.yml) + live
- §6 Docker Security Operations — live
- §7 Docker Swarm Configuration — live (no Swarm detected — skipped)

### Findings
| CIS ID | Section | Severity | Source | File | Line | Description | Fixable |
|--------|---------|----------|--------|------|------|-------------|---------|
| 5.2    | §5 Runtime  | critical | both   | docker-compose.yml | 34 | privileged: true grants full host access to container | yes |
| 4.9    | §4 Images   | minor    | static | Dockerfile         | 12 | ADD used instead of COPY                               | yes |
| 4.6    | §4 Images   | minor    | static | Dockerfile         | —  | No HEALTHCHECK instruction present                     | yes |
| 1.1.1  | §1 Host     | major    | live   | —                  | —  | No separate partition for /var/lib/docker              | no  |
| 3.15   | §3 Files    | nit      | static | —                  | —  | Docker socket permissions require host verification    | no  |

### Summary
- Critical: 1  Major: 1  Minor: 2  Nit: 1
- Auto-fixable: 3  Requires human: 2

### Manual actions required
1. **CIS 1.1.1** — Create a dedicated partition for Docker data. Verify: `mount | grep /var/lib/docker`. Fix: mount `/var/lib/docker` on its own partition before starting the Docker daemon.
2. **CIS 3.15** — Verify Docker socket ownership and permissions. Verify: `stat -c '%U %G %a' /var/run/docker.sock` should show `root docker 660`.

### Recommended action
FIX_NOW

---

## Docker Security Fix Request

### Context
CIS Docker Benchmark audit found 3 auto-fixable findings in Dockerfile and docker-compose.yml.

### Fixes to apply (in order)
1. [docker-compose.yml:34] Remove `privileged: true` from the service definition — CIS 5.2 (critical)
2. [Dockerfile:12] Replace `ADD` with `COPY` — CIS 4.9 (minor)
3. [Dockerfile] Add `HEALTHCHECK` instruction before the final CMD — CIS 4.6 (minor)

### Verification
Re-run the docker-security agent after applying fixes. Expected: CIS 5.2, 4.9, and 4.6 resolve to [PASS].

### Executor note
Set `docker_security_fix: true` in the Execution Summary.
```
