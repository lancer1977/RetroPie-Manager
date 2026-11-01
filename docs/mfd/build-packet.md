---
title: Mapped-Frontier Build Packet - RetroPie-Manager documentation and CI baseline
status: draft
owner: lancer1977
issue: Not applicable: GitHub Issues are disabled on lancer1977/RetroPie-Manager (confirmed via `gh issue list`, "the repository has disabled issues"). No tracking issue exists; this PR is self-tracking.
created: 2026-11-01
updated: 2026-11-01
---

# Mapped-Frontier Build Packet: RetroPie-Manager documentation and CI baseline

## Intent

Record the current, real delivery boundary for `lancer1977/RetroPie-Manager`
(a Recalbox-Manager fork for RetroPie 4.x, explicitly marked unmaintained in
`README.md`) so future maintenance changes have an accurate, evidence-based
map of what CI actually validates, what is not validated, and what
infrastructure/decision gaps exist. This packet is docs-only: it does not
change code, workflows, secrets, settings, or branch protection.

Users: RetroPie-Manager contributors/forkers and the repository owner
deciding whether/how to accept future changes.

Non-goals: porting the Python 2/Django 1.8 application or its asset
pipeline, adding new CI jobs or test tiers, enabling GitHub Issues, changing
branch protection, or claiming any runtime/application validation beyond the
existing structural `scripts/validate.sh` check.

Success: `docs/mfd/build-packet.md` and `.mfd/project.yaml` accurately
describe current CI, branch protection, and test-tier reality for this repo,
with every gap stated explicitly rather than invented.

## Acceptance criteria

- [ ] AC1: `docs/mfd/build-packet.md` exists, is filled for every template
      section (`Not applicable` with a reason where a section does not
      apply), and the Approval decision is explicitly `Pending`.
- [ ] AC2: `.mfd/project.yaml` schema_version 2 `merge_policy` block mirrors
      the packet's Per-project merge policy section exactly (integration
      branch, protected branch, required checks, test tiers, escalate
      paths/labels).
- [ ] AC3: Every test tier (unit/integration/automation/smoke) maps only to
      a command/job that actually exists in `.github/workflows/ci.yml` or
      `scripts/validate.sh`; any tier with no real CI counterpart is marked
      `GAP: none in CI` with `Required: No`.
- [ ] AC4: The packet passes `tools/mfd/tools/validate_mfd_packet.py` from
      `lancer1977/workstation-kit` with no `FAIL` lines.

## Current behavior

- `lancer1977/RetroPie-Manager` is a legacy Django 1.8 / Python 2 web UI for
  managing a RetroPie system (health/disk, EmulationStation config,
  RetroArch config, `autostart.sh`, logs, BIOS, ROMs). `README.md` states the
  project is not maintained anymore.
- Default branch is `retropie`; `dev` exists as the integration branch for
  this packet's PR target (per task scope), but is not the repository's
  default branch.
- `docs/validation.md` and `repo-state.md` both record: no automated test
  suite is present; the current Linux environment has Python 3.14 and no
  Python 2, so a real app runtime/compile check is not possible here;
  `scripts/validate.sh` is the only repeatable structural check.
- `.github/workflows/ci.yml` defines one job, `validate`, running on
  `ubuntu-latest`, triggered on `push` to `retropie`, on every `pull_request`
  (any base branch, including `dev`), and on `workflow_dispatch`. It runs
  `node --check Gruntfile.js` and a Python 3 script that JSON-parses
  `project/assets.json` and HTML-parses files under `project/templates/`,
  then runs `bash scripts/validate.sh`.
- `dev` branch protection: `gh api repos/lancer1977/RetroPie-Manager/branches/dev/protection`
  returns HTTP 404 "Branch not protected" — there are currently no required
  status checks configured on `dev`.
- GitHub Issues are disabled on this repository (`gh issue list` returns
  "the repository has disabled issues"). No MFD/build-packet tracking issue
  could be created; this is recorded as a Blocker below rather than worked
  around by changing repository settings (forbidden under this task's
  docs-only scope).
- No `.mfd/` or `docs/mfd/` packet existed before this change; this is a new
  packet, not an expansion of a prior one.

## Behavior map

1. A contributor opens a PR against `dev`. GitHub Actions runs the `validate`
   job (`ci.yml`), which performs the Gruntfile/asset/template structural
   checks and `scripts/validate.sh`. There is no branch-protection gate
   requiring this job to pass before merge, since `dev` has no required
   status checks configured.
2. A maintainer merges a PR to `dev` or `retropie`. On `retropie`, the same
   `validate` job runs via the `push` trigger; there is no separate
   deployment or release pipeline in this repository.
3. Full application behavior (Django app startup, RetroPie-Setup install
   path, BIOS/ROM management UI) is not exercised anywhere in CI. It
   requires a RetroPie-compatible Python 2 / Django 1.8 host, per
   `docs/validation.md`. This gap is pre-existing and not changed by this
   packet.
4. Failure state: if `scripts/validate.sh` fails (e.g. malformed
   `project/assets.json`, broken `project/templates/*.html`, or a
   `Gruntfile.js` syntax error), the `validate` job fails and is visible on
   the PR/commit, but — absent branch protection — does not itself block a
   merge.

## UI proof

Not applicable: this packet is a docs-only change (adds
`docs/mfd/build-packet.md` and `.mfd/project.yaml`). No application UI,
template, or frontend asset is modified.

## Technical contract

- No API, event, data, auth, or runtime contract changes. This packet adds
  two documentation/metadata files only.
- Ownership: `lancer1977` is the repository owner and product owner for
  approval.
- Dependencies: none introduced. Existing dependencies are unchanged
  (`pip-requirements/`, `package.json`, `compass/Gemfile`).
- Operations: no deployment, infrastructure, or operational surface exists
  for this repository beyond the CI job described above.

## Verification map

| Requirement | Scenario | Validation | Expected evidence |
| --- | --- | --- | --- |
| AC1 | Packet written with every template section filled | Manual review of `docs/mfd/build-packet.md` against `tools/mfd/templates/mfd-build-packet.md` | All sections present; `Not applicable` sections carry a reason |
| AC2 | `.mfd/project.yaml` mirrors packet merge policy | Diff packet "Per-project merge policy" table against `.mfd/project.yaml` `merge_policy` | Integration/protected branch, required checks, and test tiers match |
| AC3 | Test tiers map only to real CI | Read `.github/workflows/ci.yml` and `scripts/validate.sh`; confirm no invented commands | Only `automation` tier has a real CI command; unit/integration/smoke are `GAP: none in CI` |
| AC4 | Validator run | `python3 tools/mfd/tools/validate_mfd_packet.py docs/mfd/build-packet.md` (from a checkout of `lancer1977/workstation-kit` at `a7c72842` or later) | No `FAIL:` lines; prints `OK: valid MFD packet` |

## Per-project merge policy

- Required checks: None configured on `dev` (HTTP 404 from branch protection
  API — no required status checks exist today). CI still runs the `validate`
  job on every PR; it is just not a merge-blocking requirement.
- Integration branch: `dev`
- Protected branch: `main` (this repository's long-term protected/release
  branch per the global DevOps contract; the repository's actual GitHub
  default branch is `retropie`, a pre-existing naming divergence this packet
  records rather than changes)

| Test tier | Command | Required | CI job name |
| --- | --- | --- | --- |
| Unit | GAP: none in CI | No | None — `repo-state.md`/`docs/validation.md` confirm no automated test suite exists |
| Integration | GAP: none in CI | No | None |
| Automation | `node --check Gruntfile.js` and the JSON/HTML structural Python check, followed by `bash scripts/validate.sh` | No (no branch protection requires it on `dev`; it runs informationally) | `validate` (`.github/workflows/ci.yml`) |
| Smoke | GAP: none in CI | No | None — full runtime needs a RetroPie-compatible Python 2/Django 1.8 host per `docs/validation.md`; not available in current CI or this environment |

## Delivery map

| Order | GitHub issue / card | Requirement / scenario | Dependencies | Validation |
| --- | --- | --- | --- | --- |
| 1 | Not applicable: Issues disabled on this repo; tracked by this PR directly | AC1-AC4 | None | `python3 tools/mfd/tools/validate_mfd_packet.py docs/mfd/build-packet.md` |

### Rollout and rollback

Not applicable: docs-only addition, no deployable artifact. Rollback is a
plain `git revert` of the commit adding these two files.

### Blockers

| Blocker | Owner | Unblock condition |
| --- | --- | --- |
| GitHub Issues are disabled on `lancer1977/RetroPie-Manager`, so no numbered tracking issue could be created for this packet, and future work cannot use issue-linked delivery tracking without a settings change | lancer1977 | Owner decides whether to enable Issues on this repository (a repository-settings change, out of scope for this docs-only task) |
| `dev` has no branch protection / required status checks, so the `validate` CI job is informational only and does not gate merges | lancer1977 | Owner decides whether to configure branch protection on `dev` (also out of scope for this docs-only task) |

### Future requirements

- Secrets: None required by this packet. No secrets exist in this
  repository's current CI. If a future change needs one, source it via
  Security Bot / Infisical path only, e.g. `infisical:/retro/RetroPie-Manager/<NAME>`
  — never an inline value.
- Infrastructure: None required by this packet.
- Hardware: None required by this packet. Full runtime validation (if ever
  undertaken) would need a RetroPie-compatible Raspberry Pi or equivalent
  Linux host with Python 2, per `docs/validation.md`.

### Open decisions

| Decision | Options | Recommendation |
| --- | --- | --- |
| Whether to enable GitHub Issues on this repo | (A) Enable Issues so future MFD packets have numbered tracking issues; (B) Keep Issues disabled and continue self-tracking via PRs only | (A) — enabling Issues costs nothing and restores standard issue-linked delivery tracking for an unmaintained-but-still-forked repo; this is a repository-settings change and is left to the owner, not made by this docs-only task |
| Whether to add branch protection / required status checks on `dev` | (A) Require the `validate` job to pass before merge to `dev`; (B) Leave `dev` unprotected as today | (A) — the `validate` job already exists and runs on every PR; requiring it costs nothing extra and prevents a known-broken structural change from merging; this is a branch-protection change and is left to the owner |
| Whether to pursue a real Python 2/Django 1.8 CI runtime check (unit/integration/smoke tiers) | (A) Stand up a legacy-environment runner/container to run real app tests; (B) Accept the current structural-only validation as the permanent ceiling for this unmaintained fork | (B) — the repository is explicitly marked unmaintained; investing in legacy runtime CI is likely not worth the cost unless the owner intends active maintenance to resume |

## Approval

- Product owner: lancer1977
- Decision: Pending
- Date: Pending
- Approved commit or immutable revision: Pending
- Approval evidence: Pending
- Approval brief: Pending

## Deviations

| Date | Requirement / boundary | Decision | Approver | Follow-up |
| --- | --- | --- | --- | --- |
| None | None | None | None | None |

## Release controls and closeout evidence

- Target branch: `dev`
- Pull request: Pending
- Required reviewers: Pending (no required reviewers configured on `dev`)
- CI and validation evidence: Pending

### Deployment contract

- Deployment applicability: Not applicable: this packet adds documentation
  and metadata files only; no deployable artifact or runtime change exists.
- Target environments: Not applicable: no rollout is in scope.
- Deployment authority (separate from approval): Not applicable: no
  deployment occurs.
- Source commit: Pending immutable packet revision.
- Immutable artifact / digest: Not applicable: no artifact is produced.
- Rollout record: Not applicable: no rollout is in scope.
- Authenticated smoke proof: Not applicable: no live/runtime surface is
  changed by this packet.
- Rollback target: Revert the commit adding `docs/mfd/build-packet.md` and
  `.mfd/project.yaml`.

### Release closeout record

- Live verification result: Not applicable: no live/runtime change is
  authorized or made by this packet.
- Deferred drift / follow-up issue: Owner decision needed on enabling
  GitHub Issues and/or `dev` branch protection (see Open decisions above)
  before any future packet can use numbered issue tracking or a
  merge-blocking CI gate.
