可以，而且我建议你不要手工一次次创建。最适合的是做成一个**项目初始化器 + Codex 分阶段填充流程**。目标是任何新 Workspace 第一次接入时，只需要执行一次：

```bash
./codex-workflow-init.sh
```

然后让 Codex 按固定顺序扫描、分析、填充，最终形成开箱即用的工程骨架。

这里最关键的一点是：**初始化脚本只创建“空骨架和约束”，真正的系统知识必须让 Codex 基于真实代码逐步填充，不能预先猜。** 这也符合 OpenAI 当前推荐的做法：让 `AGENTS.md` 保持短小、作为导航地图，把真正的系统知识沉淀到结构化 `docs/` 中。([OpenAI][1])

---

# 一、最终目标目录

我建议任何 Workspace 第一次初始化后都形成：

```text
workspace/
├── AGENTS.md
├── ARCHITECTURE.md
├── README-AI-WORKFLOW.md
│
├── docs/
│   ├── architecture/
│   │   ├── system-map.md
│   │   ├── repository-map.md
│   │   ├── service-dependencies.md
│   │   ├── data-flow.md
│   │   ├── event-flow.md
│   │   ├── database-map.md
│   │   └── runtime-map.md
│   │
│   ├── domain/
│   │   └── index.md
│   │
│   ├── standards/
│   │   ├── go-style.md
│   │   ├── architecture-rules.md
│   │   ├── error-handling.md
│   │   ├── transaction.md
│   │   ├── idempotency.md
│   │   ├── logging-observability.md
│   │   ├── testing.md
│   │   └── delivery.md
│   │
│   ├── adr/
│   │   ├── README.md
│   │   └── template.md
│   │
│   ├── features/
│   │   └── README.md
│   │
│   ├── runbooks/
│   │   └── README.md
│   │
│   └── generated/
│       └── .gitkeep
│
├── .codex/
│   ├── prompts/
│   │   ├── 00-bootstrap.md
│   │   ├── 01-repository-analysis.md
│   │   ├── 02-architecture-analysis.md
│   │   ├── 03-domain-analysis.md
│   │   ├── 04-standards-analysis.md
│   │   ├── 05-verification.md
│   │   ├── feature-start.md
│   │   ├── feature-impact.md
│   │   ├── feature-design.md
│   │   ├── feature-implement.md
│   │   ├── feature-review.md
│   │   └── feature-delivery.md
│   │
│   ├── templates/
│   │   ├── feature/
│   │   │   ├── 01-requirement.md
│   │   │   ├── 02-current-system.md
│   │   │   ├── 03-impact-analysis.md
│   │   │   ├── 04-solution-design.md
│   │   │   ├── 05-implementation-plan.md
│   │   │   ├── 06-test-plan.md
│   │   │   ├── 07-delivery-checklist.md
│   │   │   └── 08-retrospective.md
│   │   └── adr.md
│   │
│   └── skills/
│       ├── requirement-analysis/
│       │   └── SKILL.md
│       ├── repository-analysis/
│       │   └── SKILL.md
│       ├── impact-analysis/
│       │   └── SKILL.md
│       ├── architecture-design/
│       │   └── SKILL.md
│       ├── go-implementation/
│       │   └── SKILL.md
│       ├── go-testing/
│       │   └── SKILL.md
│       ├── code-review/
│       │   └── SKILL.md
│       └── delivery-review/
│           └── SKILL.md
│
└── scripts/
    ├── codex-workflow-init.sh
    ├── feature-init.sh
    └── verify-workspace.sh
```

这个结构适合单仓库，也适合：

```text
workspace/
├── gateway/
├── game-service/
├── wallet/
├── common/
└── proto/
```

这种多仓库 Workspace。

Skills 本质就是可复用 workflow，通常由 `SKILL.md` 描述输入、步骤、输出和最终检查，因此用它封装这套流程非常合适。([OpenAI][2])

---

# 二、第一步：创建通用初始化脚本

直接建立：

```bash
scripts/codex-workflow-init.sh
```

内容推荐：

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(pwd)}"

echo "Initializing Codex engineering workflow in:"
echo "  ${ROOT}"

mkdir -p \
  "${ROOT}/docs/architecture" \
  "${ROOT}/docs/domain" \
  "${ROOT}/docs/standards" \
  "${ROOT}/docs/adr" \
  "${ROOT}/docs/features" \
  "${ROOT}/docs/runbooks" \
  "${ROOT}/docs/generated" \
  "${ROOT}/.codex/prompts" \
  "${ROOT}/.codex/templates/feature" \
  "${ROOT}/.codex/skills/requirement-analysis" \
  "${ROOT}/.codex/skills/repository-analysis" \
  "${ROOT}/.codex/skills/impact-analysis" \
  "${ROOT}/.codex/skills/architecture-design" \
  "${ROOT}/.codex/skills/go-implementation" \
  "${ROOT}/.codex/skills/go-testing" \
  "${ROOT}/.codex/skills/code-review" \
  "${ROOT}/.codex/skills/delivery-review" \
  "${ROOT}/scripts"

touch "${ROOT}/docs/generated/.gitkeep"

cat > "${ROOT}/AGENTS.md" <<'EOF'
# Workspace Engineering Instructions

## Purpose

This workspace is maintained as a production engineering system.

Codex must prioritize:

1. correctness
2. backward compatibility
3. data consistency
4. operational safety
5. observability
6. maintainability
7. performance

## Working Rules

Before modifying production code:

1. inspect existing implementation
2. identify repository boundaries
3. identify similar implementations
4. trace the relevant call chain
5. analyze impact
6. create or update implementation plan
7. define verification strategy

Never invent architecture based only on filenames.

Prefer evidence from:

- source code
- tests
- configuration
- schemas
- migrations
- deployment files
- existing documentation

## Knowledge Sources

Read:

- ARCHITECTURE.md
- docs/architecture/
- docs/domain/
- docs/standards/

Feature work lives under:

- docs/features/

## Change Discipline

Do not:

- perform unrelated refactoring
- introduce new dependencies without justification
- change API/database/event contracts silently
- modify repositories outside explicitly permitted write scope

## Verification

Use repository-specific checks.

For Go projects, normally include:

- go test ./...
- go test -race ./...
- go vet ./...
- golangci-lint run

Only report a check as passed if it actually ran successfully.

## Uncertainty

Use these labels:

- UNKNOWN
- UNCERTAIN
- ASSUMPTION
- NEEDS_VERIFICATION
- BLOCKED
EOF

cat > "${ROOT}/ARCHITECTURE.md" <<'EOF'
# Architecture Overview

Status: NOT_INITIALIZED

This file is the high-level architecture entry point.

Detailed architecture lives under:

- docs/architecture/system-map.md
- docs/architecture/repository-map.md
- docs/architecture/service-dependencies.md
- docs/architecture/data-flow.md
- docs/architecture/event-flow.md
- docs/architecture/database-map.md
- docs/architecture/runtime-map.md

This document must be generated from actual repository evidence.
EOF

cat > "${ROOT}/README-AI-WORKFLOW.md" <<'EOF'
# AI Engineering Workflow

## Workspace Bootstrap

Run Codex prompts in this order:

1. .codex/prompts/00-bootstrap.md
2. .codex/prompts/01-repository-analysis.md
3. .codex/prompts/02-architecture-analysis.md
4. .codex/prompts/03-domain-analysis.md
5. .codex/prompts/04-standards-analysis.md
6. .codex/prompts/05-verification.md

## Feature Workflow

Create a feature workspace:

./scripts/feature-init.sh FEATURE-ID

Then execute:

1. requirement analysis
2. current-system analysis
3. impact analysis
4. solution design
5. implementation plan
6. implementation
7. testing
8. adversarial review
9. requirement coverage review
10. delivery review
11. retrospective / knowledge capture
EOF

for file in \
 system-map \
 repository-map \
 service-dependencies \
 data-flow \
 event-flow \
 database-map \
 runtime-map
do
cat > "${ROOT}/docs/architecture/${file}.md" <<EOF
# ${file}

Status: NOT_INITIALIZED

Generated from repository evidence.

Do not fill this document using assumptions.
EOF
done

cat > "${ROOT}/docs/domain/index.md" <<'EOF'
# Domain Knowledge

Status: NOT_INITIALIZED

Document important business domains discovered from the codebase.

Each domain should eventually have its own document.
EOF

cat > "${ROOT}/docs/adr/README.md" <<'EOF'
# Architecture Decision Records

Use ADRs for decisions that materially affect:

- architecture
- persistence
- API contracts
- event contracts
- consistency models
- major dependencies
EOF

cat > "${ROOT}/docs/adr/template.md" <<'EOF'
# ADR-XXXX: Title

## Status

Proposed

## Context

## Decision

## Alternatives

## Consequences

## Risks

## Validation
EOF

cat > "${ROOT}/docs/features/README.md" <<'EOF'
# Feature Engineering Records

Each feature uses:

FEATURE-ID/
├── 00-source/
├── 01-requirement.md
├── 02-current-system.md
├── 03-impact-analysis.md
├── 04-solution-design.md
├── 05-implementation-plan.md
├── 06-test-plan.md
├── 07-delivery-checklist.md
└── 08-retrospective.md
EOF

cat > "${ROOT}/docs/runbooks/README.md" <<'EOF'
# Operational Runbooks

Document operational procedures only after they are verified against the deployed system.
EOF

echo "Codex workflow skeleton created successfully."
```

然后：

```bash
chmod +x scripts/codex-workflow-init.sh
```

以后任何 Workspace：

```bash
cd /workspace/project

/path/to/codex-workflow-init.sh .
```

即可。

---

# 三、第二步：初始化 Feature 的脚本

再建立：

```bash
scripts/feature-init.sh
```

内容：

```bash
#!/usr/bin/env bash
set -euo pipefail

FEATURE_ID="${1:-}"

if [[ -z "${FEATURE_ID}" ]]; then
  echo "Usage:"
  echo "  $0 FEATURE-ID"
  exit 1
fi

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
DEST="${ROOT}/docs/features/${FEATURE_ID}"
TPL="${ROOT}/.codex/templates/feature"

if [[ -e "${DEST}" ]]; then
  echo "Feature already exists:"
  echo "  ${DEST}"
  exit 1
fi

mkdir -p "${DEST}/00-source"

for file in \
  01-requirement.md \
  02-current-system.md \
  03-impact-analysis.md \
  04-solution-design.md \
  05-implementation-plan.md \
  06-test-plan.md \
  07-delivery-checklist.md \
  08-retrospective.md
do
  cp "${TPL}/${file}" "${DEST}/${file}"
done

echo "Created feature workspace:"
echo "  ${DEST}"
```

然后：

```bash
chmod +x scripts/feature-init.sh
```

以后：

```bash
./scripts/feature-init.sh GAME-2451
```

就生成：

```text
docs/features/GAME-2451/
├── 00-source/
├── 01-requirement.md
├── 02-current-system.md
├── 03-impact-analysis.md
├── 04-solution-design.md
├── 05-implementation-plan.md
├── 06-test-plan.md
├── 07-delivery-checklist.md
└── 08-retrospective.md
```

---

# 四、第三步：Feature 模板不要空白

`01-requirement.md`：

```markdown
# Requirement Analysis

Feature:

Status: DRAFT

## Business Goal

## Actors

## Preconditions

## Trigger

## Main Flow

## Alternative Flow

## Exception Flow

## Business Rules

## State Transitions

## Data Requirements

## API Requirements

## Event Requirements

## Permission Requirements

## Audit Requirements

## Compatibility Requirements

## Non-functional Requirements

## Acceptance Criteria

### AC-001

Given:

When:

Then:

## Ambiguities

## Missing Information

## Assumptions

## Open Questions
```

`02-current-system.md`：

```markdown
# Current System Analysis

## Relevant Repositories

## Existing Implementation

## Similar Features

## Call Chain

## Data Flow

## API

## Domain

## Storage

## Cache

## Events

## Configuration

## Tests

## Observability

## Evidence

Every architectural statement should reference:

repository/path:symbol
```

`03-impact-analysis.md`：

```markdown
# Impact Analysis

## API

## Domain

## Database

## Cache

## Event / MQ

## Configuration

## Security

## Permission

## Performance

## Observability

## Compatibility

## Deployment

## Rollback

## Failure Modes

## Risk Matrix

| Risk | Probability | Impact | Mitigation | Verification |
|---|---|---|---|---|
```

`04-solution-design.md`：

```markdown
# Solution Design

## Summary

## Background

## Existing Architecture

## Constraints

## Option A

## Option B

## Comparison

## Recommended Design

## Request Flow

## Data Flow

## State Transition

## API Changes

## Database Changes

## Event Changes

## Transaction Boundary

## Idempotency

## Concurrency

## Error Handling

## Observability

## Compatibility

## Rollout

## Rollback

## Risks

## Open Questions
```

`05-implementation-plan.md`：

```markdown
# Implementation Plan

## Scope

## Read Scope

## Write Scope

## Dependencies

## Tasks

### TASK-001

Repository:

Files:

Symbols:

Purpose:

Change:

Dependencies:

Tests:

Validation:

Risk:

## Execution Order

## Out of Scope
```

---

# 五、第四步：第一次让 Codex 做 Bootstrap

这一步非常关键。

你执行完脚本以后，**不要直接让 Codex 自动填所有文档。**

第一条 Prompt 应该只做环境侦察。

保存：

```text
.codex/prompts/00-bootstrap.md
```

内容：

```text
You are bootstrapping this workspace for long-term AI-assisted engineering.

This is DISCOVERY ONLY.

Do not modify production source code.

You may update engineering documentation under:

AGENTS.md
ARCHITECTURE.md
docs/
.codex/

Tasks:

1. Identify workspace root.
2. Identify every Git repository under the workspace.
3. Identify repository boundaries.
4. Identify programming languages.
5. Identify Go modules.
6. Identify build systems.
7. Identify testing tools.
8. Identify linters.
9. Identify deployment/configuration systems.
10. Identify likely service entry points.

Do not infer service responsibilities yet.

Produce a bootstrap report containing:

- repositories
- repository paths
- languages
- Go modules
- executable entry points
- build commands
- test commands
- lint commands
- config/deployment locations

For every statement provide file-based evidence.

Mark unclear items:

UNKNOWN
UNCERTAIN
NEEDS_VERIFICATION

Update only:

docs/architecture/repository-map.md

Do not edit other architecture files yet.
```

第一轮的目标只是：

```text
Codex：“我知道这里有什么。”
```

不是：

```text
Codex：“我已经理解整个系统。”
```

---

# 六、第五步：Repository Analysis

第二轮：

```text
.codex/prompts/01-repository-analysis.md
```

```text
Analyze every repository identified in:

docs/architecture/repository-map.md

Do not modify production code.

For every repository determine:

1. responsibility
2. entry points
3. public interfaces
4. internal packages
5. database usage
6. Redis usage
7. MQ usage
8. external service dependencies
9. shared libraries
10. configuration
11. tests
12. observability
13. deployment artifacts

Do not infer responsibility from repository names alone.

Evidence hierarchy:

1. implementation
2. tests
3. schemas
4. configuration
5. documentation
6. naming

For every important claim provide:

repo/path:symbol

Update:

docs/architecture/repository-map.md

At the end include:

UNKNOWN
UNCERTAIN
POTENTIAL_COUPLING
NEEDS_VERIFICATION
```

---

# 七、第六步：Architecture Analysis

第三轮开始真正理解系统。

```text
.codex/prompts/02-architecture-analysis.md
```

Prompt：

```text
Act as Principal Backend Architect.

Using actual repository evidence, reconstruct the system architecture.

Do not modify production code.

Analyze:

HTTP
gRPC
RPC
MySQL
PostgreSQL
Redis
ClickHouse
Kafka
NATS
RabbitMQ
Cron
Background workers
Configuration
Service discovery
Observability
Deployment

Trace actual interactions.

Generate or update:

ARCHITECTURE.md

docs/architecture/system-map.md
docs/architecture/service-dependencies.md
docs/architecture/data-flow.md
docs/architecture/event-flow.md
docs/architecture/database-map.md
docs/architecture/runtime-map.md

Identify:

service boundaries
data ownership
request flow
event flow
transaction boundaries
consistency boundaries
failure boundaries
shared infrastructure

Pay special attention to:

shared databases
distributed transactions
implicit coupling
cross-repository dependencies
retry semantics
timeout semantics
idempotency
message ordering
duplicate delivery
eventual consistency

Every important claim must reference code evidence.

Never manufacture missing architecture.
```

这一步通常是整个初始化过程中价值最高的一步。

---

# 八、第七步：Domain Analysis

架构理解完成后再做业务领域。

```text
.codex/prompts/03-domain-analysis.md
```

```text
Analyze the business domains represented by this workspace.

Do not modify production code.

Identify:

entities
aggregates
state machines
business invariants
business workflows
ownership boundaries
cross-domain interactions

Look primarily at:

domain models
services
database schemas
events
tests

Do not derive business rules only from API names.

Create:

docs/domain/index.md

and create one document per meaningful domain:

docs/domain/<domain>.md

Each domain document should include:

Purpose
Entities
State
Business Rules
Invariants
Commands
Events
Data Ownership
Dependencies
Failure Cases
Relevant Code

Every business rule must reference evidence where possible.

Mark uncertain business semantics:

NEEDS_PRODUCT_CONFIRMATION
```

---

# 九、第八步：让 Codex 从项目自身反推标准

这个步骤非常重要。

很多人犯的错误是：

> 先把自己喜欢的 Go Style 强塞给历史项目。

这会导致 Codex“大规模现代化重构”。

正确做法是：

**先分析当前项目真实约定。**

```text
.codex/prompts/04-standards-analysis.md
```

Prompt：

```text
Analyze existing engineering conventions.

Do not refactor code.

Determine the dominant conventions actually used by this codebase.

Analyze:

Go package structure
handler/service/repository layering
dependency injection
configuration
error handling
logging
context usage
transactions
database access
cache
MQ
idempotency
concurrency
testing
mocking
integration testing
metrics
tracing

Separate findings into:

CURRENT_STANDARD
LEGACY_PATTERN
INCONSISTENT_PATTERN
RISKY_PATTERN

Do not automatically classify newer patterns as better.

Generate:

docs/standards/go-style.md
docs/standards/architecture-rules.md
docs/standards/error-handling.md
docs/standards/transaction.md
docs/standards/idempotency.md
docs/standards/logging-observability.md
docs/standards/testing.md
docs/standards/delivery.md

Prefer describing existing successful patterns.

Do not rewrite application code.
```

这个设计能防止 Codex：

```text
“我觉得 Clean Architecture 更优雅”
```

然后把你的项目改成另一套架构。

---

# 十、第九步：Verification 阶段

前面所有文档生成以后，再让 Codex 自己质疑一次。

```text
.codex/prompts/05-verification.md
```

```text
Act as an independent architecture reviewer.

Assume the generated workspace documentation may contain errors.

Review:

AGENTS.md
ARCHITECTURE.md
docs/architecture/
docs/domain/
docs/standards/

Validate important claims against the actual source code.

Find:

unsupported claims
incorrect service relationships
incorrect data ownership
missing repositories
missing event flows
missing database dependencies
contradictory documentation
stale documentation
overconfident assumptions

Classify every finding:

CONFIRMED_ERROR
LIKELY_ERROR
UNVERIFIED
DOCUMENTATION_GAP

Correct documentation only when code evidence supports the correction.

Do not modify production code.

Finally produce a section:

Workspace Readiness

with:

READY
READY_WITH_GAPS
NOT_READY

and list remaining gaps.
```

这一步相当于：

```text
AI 生成知识
↓
AI 独立审计知识
```

不要省。

---

# 十一、第十步：最后才让 Codex 更新 AGENTS.md

这是一个重要顺序。

**不要初始化脚本后马上让 Codex 写完整 AGENTS.md。**

因为那时它还不懂系统。

应该等：

```text
Repository Map
Architecture
Domain
Standards
Verification
```

完成后再执行：

```text
Based on the verified workspace documentation:

ARCHITECTURE.md
docs/architecture/
docs/domain/
docs/standards/

update the root AGENTS.md.

AGENTS.md must remain concise.

Target:

approximately 80-150 lines.

Its purpose is navigation and high-value engineering constraints.

Do not copy detailed documentation into AGENTS.md.

Include only:

workspace purpose
repository map
key architecture rules
important business invariants
change discipline
verification commands
documentation pointers
known high-risk areas

Detailed information must remain in docs/.

Do not modify application source code.
```

OpenAI 当前实践明确推荐把 `AGENTS.md` 当“目录/地图”而不是百科全书；具体知识保留在结构化 docs。([OpenAI][1])

---

# 十二、完整初始化生命周期

因此第一次 Workspace 应严格跑：

```text
INIT
 │
 ▼
创建骨架
 │
 ▼
00 Bootstrap
 │
 ▼
Repository Map
 │
 ▼
01 Repository Analysis
 │
 ▼
02 Architecture Analysis
 │
 ▼
03 Domain Analysis
 │
 ▼
04 Standards Analysis
 │
 ▼
05 Independent Verification
 │
 ▼
完善 AGENTS.md
 │
 ▼
Workspace Ready
```

从这以后就不要再跑 Bootstrap。

---

# 十三、Workspace 状态建议增加一个文件

我建议增加：

```text
.codex/workspace-status.md
```

内容：

```markdown
# Workspace Initialization Status

## Initialization

- [x] Skeleton created
- [x] Repository discovery
- [x] Repository analysis
- [x] Architecture analysis
- [x] Domain analysis
- [x] Engineering standards analysis
- [x] Documentation verification
- [x] AGENTS.md finalized

## Workspace Status

READY

Last verified:

2026-09-09

## Known Gaps

- xxx
- xxx
```

以后 Codex 第一眼就知道：

```text
这是成熟 Workspace
```

还是：

```text
这是第一次初始化
```

---

# 十四、Feature 真正做到“一条命令开箱”

Workspace 完成后：

```bash
./scripts/feature-init.sh GAME-2451
```

把产品材料放：

```text
docs/features/GAME-2451/00-source/
```

例如：

```text
GAME-2451/
├── 00-source/
│   ├── requirement.pdf
│   ├── prototype.png
│   ├── api.xlsx
│   └── notes.md
```

然后 Codex 执行：

```text
Read:

AGENTS.md
ARCHITECTURE.md
docs/architecture/
docs/domain/
docs/standards/

Start feature:

GAME-2451

Source:

docs/features/GAME-2451/00-source/

Execute requirement-analysis phase only.

Do not modify production code.

Generate:

docs/features/GAME-2451/01-requirement.md
```

接下来：

```text
01 Requirement
      ↓
02 Current System
      ↓
03 Impact Analysis
      ↓
04 Solution Design
      ↓
05 Implementation Plan
      ↓
Coding
      ↓
06 Test Plan
      ↓
Review
      ↓
07 Delivery
      ↓
08 Retrospective
```

---

# 十五、最好再建立 feature-start Prompt

`.codex/prompts/feature-start.md`

```text
# FEATURE START

Feature ID:

{{FEATURE_ID}}

Read first:

AGENTS.md
ARCHITECTURE.md
docs/architecture/
docs/domain/
docs/standards/

Feature sources:

docs/features/{{FEATURE_ID}}/00-source/

Current phase:

REQUIREMENT ANALYSIS

Do not modify production code.

Analyze:

business objective
actors
preconditions
main flow
alternative flows
exception flows
business rules
state transitions
data requirements
API requirements
event requirements
permission
audit
compatibility
non-functional requirements

Explicitly identify:

AMBIGUOUS
MISSING
CONFLICTING
ASSUMPTION
NEEDS_CONFIRMATION

Do not infer backend rules merely from UI behavior.

Produce:

docs/features/{{FEATURE_ID}}/01-requirement.md

Include acceptance criteria using:

Given
When
Then

Stop after requirement analysis.
```

---

# 十六、Skills 应该怎样与 Prompt 分工

我建议不要把 Prompt 和 Skills 搞成重复内容。

职责应该是：

```text
AGENTS.md
=
长期规则

docs/
=
系统知识

skills/
=
标准流程

prompts/
=
任务启动入口

feature docs
=
本次需求状态
```

这是一个非常重要的结构。

例如：

```text
Skill:
impact-analysis
```

告诉 Codex：

> Impact Analysis 应该怎样做。

而：

```text
Prompt:
GAME-2451 impact analysis
```

告诉 Codex：

> 现在对 GAME-2451 执行这个 Skill。

Skills 的定位本来就是把重复、多步骤、固定格式的 workflow 封装下来，而不是每次重新解释。([OpenAI][2])

---

# 十七、推荐一个实际 SKILL.md

例如：

```text
.codex/skills/impact-analysis/SKILL.md
```

可以写：

```markdown
# Impact Analysis

## Purpose

Analyze the full engineering impact of a proposed feature before implementation.

## Required Inputs

- verified requirement document
- current-system analysis
- workspace architecture documentation

## Workflow

1. Identify affected repositories.
2. Identify affected APIs.
3. Identify domain changes.
4. Identify persistence changes.
5. Identify cache impact.
6. Identify asynchronous messaging impact.
7. Identify configuration impact.
8. Identify compatibility risks.
9. Identify security implications.
10. Identify observability changes.
11. Identify deployment implications.
12. Identify rollback strategy.

## Mandatory Risk Checks

Always examine:

- data migration
- historical data
- API backward compatibility
- event schema compatibility
- idempotency
- duplicate delivery
- ordering
- race conditions
- partial failures
- distributed consistency
- timeout
- retry
- feature flags

## Output

Produce:

03-impact-analysis.md

## Evidence Rule

Every concrete implementation claim must reference:

repository/path:symbol

## Final Check

Never mark impact as NONE unless verified from code.
```

这就是好的 Skill。

不是 500 行巨型 Prompt。

---

# 十八、再增加一个真正实用的 verify-workspace.sh

可以自动发现 Go 项目：

```bash
#!/usr/bin/env bash
set -uo pipefail

ROOT="${1:-$(pwd)}"

FAILED=0

echo "======================================"
echo "Workspace Verification"
echo "======================================"

while IFS= read -r gomod; do
  dir="$(dirname "${gomod}")"

  echo
  echo "--------------------------------------"
  echo "Go module:"
  echo "${dir}"
  echo "--------------------------------------"

  (
    cd "${dir}"

    echo "[1] go test ./..."
    go test ./... || exit 11

    echo "[2] go vet ./..."
    go vet ./... || exit 12

    if command -v golangci-lint >/dev/null 2>&1; then
      echo "[3] golangci-lint run"
      golangci-lint run || exit 13
    else
      echo "[3] golangci-lint: SKIPPED"
    fi
  )

  rc=$?

  if [[ "${rc}" -ne 0 ]]; then
    echo "FAILED: ${dir}"
    FAILED=1
  fi

done < <(
  find "${ROOT}" \
    -type f \
    -name go.mod \
    -not -path '*/vendor/*' \
    -not -path '*/.git/*'
)

exit "${FAILED}"
```

这样验证可以统一：

```bash
./scripts/verify-workspace.sh
```

---

# 十九、但这里我要挑战一个“全自动初始化”的想法

不要追求：

```text
一条 Prompt
↓
扫描几十个 repo
↓
写所有文档
↓
自动完成
```

看起来很高级，实际上**可靠性更差**。

真正稳的方式是：

```text
Stage 1
发现

Stage 2
理解

Stage 3
建模

Stage 4
审计
```

原因非常简单：

如果 Codex 第一轮就把某个服务职责判断错了，后面：

```text
system-map
domain
standards
feature impact
```

全部都会继承这个错误。

所以最好做：

```text
Repository Map
     ↓
人工快速看一眼
     ↓
Architecture
     ↓
人工快速看一眼
     ↓
Domain
     ↓
Verification
```

人不是负责重新阅读所有代码，而是做**关键 checkpoint**。

---

# 二十、多 Git Repository Workspace 还应该增加一张 manifest

我强烈建议你增加：

```text
.codex/workspace.yaml
```

例如：

```yaml
version: 1

workspace:
  name: gaming-platform

repositories:
  - name: gateway
    path: ./gateway
    role: api-gateway

  - name: game-service
    path: ./game-service
    role: game-domain

  - name: wallet
    path: ./wallet
    role: wallet-domain

  - name: common
    path: ./common
    role: shared-library

  - name: proto
    path: ./proto
    role: interface-contract

defaults:
  read_scope:
    - "*"

  write_scope: []

verification:
  go:
    test: "go test ./..."
    race: "go test -race ./..."
    vet: "go vet ./..."
    lint: "golangci-lint run"
```

不过初始化时：

```yaml
role: UNKNOWN
```

让 Codex分析以后再填。

不要初始化器猜职责。

---

# 二十一、Repository 自己也要有 AGENTS.md 吗？

第一次初始化时，**不要自动给所有 repo 创建复杂 AGENTS.md。**

先分析。

然后让 Codex判断：

```text
哪些 Repository 存在足够特殊的规则，
值得建立 repository-level AGENTS.md？
```

例如：

```text
workspace/
├── AGENTS.md
│
├── wallet/
│   └── AGENTS.md
│
└── settlement/
    └── AGENTS.md
```

因为 Codex 的 AGENTS 规则是有目录作用域的，越深层的 `AGENTS.md` 可以对相应目录施加更具体约束。([OpenAI][3])

这个功能对多服务 Workspace 很有价值。

---

# 二十二、什么时候应该生成 Repository-level AGENTS.md？

例如发现：

```text
wallet/
```

有特殊规则：

```text
所有余额修改必须走 ledger

禁止直接 UPDATE balance

必须使用 transaction

所有 request 必须有 idempotency_key
```

这种必须进入：

```text
wallet/AGENTS.md
```

而不是只埋在：

```text
docs/domain/wallet.md
```

因为这是**修改代码必须遵守的规则**。

---

# 二十三、建议初始化完成后的评分 Gate

我建议让 Codex 最后评分：

```text
Repository Discovery      100%
Architecture Map           95%
Domain Documentation       85%
Engineering Standards      90%
Testing Knowledge          95%
Deployment Knowledge       80%
Operational Knowledge      70%
```

然后：

```text
Workspace Readiness:
READY_WITH_GAPS
```

例如：

```text
Known gaps:

1. settlement replay behavior not fully verified
2. legacy game-service retry semantics unclear
3. production ClickHouse topology unavailable
```

比假装：

```text
Initialization Completed
```

靠谱得多。

---

# 二十四、以后新 Feature 就变得非常简单

Workspace 初始化只做一次。

以后每一个 Feature：

```bash
./scripts/feature-init.sh GAME-2788
```

然后：

```text
/product requirement
        ↓
feature-start
        ↓
01 requirement
        ↓
current-system
        ↓
02 current-system
        ↓
impact-analysis skill
        ↓
03 impact
        ↓
architecture-design skill
        ↓
04 design
        ↓
implementation planning
        ↓
05 plan
        ↓
go-implementation skill
        ↓
code
        ↓
go-testing
        ↓
06 tests
        ↓
code-review
        ↓
delivery-review
        ↓
07 delivery
        ↓
08 retrospective
        ↓
docs / AGENTS / skills feedback
```

这就是真正的闭环。

---

# 二十五、我建议最终做成一个独立 Git Template Repository

不要把 `codex-workflow-init.sh` 到处复制。

直接建立：

```text
engineering-codex-workflow/
```

例如：

```text
engineering-codex-workflow/
├── README.md
├── install.sh
├── skeleton/
│   ├── AGENTS.md
│   ├── ARCHITECTURE.md
│   ├── docs/
│   ├── .codex/
│   └── scripts/
└── VERSION
```

然后任何工程：

```bash
git clone <engineering-codex-workflow>

./engineering-codex-workflow/install.sh \
    /opt/projects/gaming-platform
```

最终：

```text
Template v1
   ↓
Project A
Project B
Project C
```

都使用同一套工程规范。

未来你优化：

```text
impact-analysis skill
code-review skill
Go testing rules
security checks
```

只更新：

```text
engineering-codex-workflow
```

这比在几十个项目里各维护一套 Prompt 强很多。

---

# 二十六、推荐最终演进成三层体系

成熟以后应该是：

```text
┌─────────────────────────────────────────┐
│ Organization Engineering Harness        │
│                                         │
│ Codex Workflow Template                 │
│ Shared Skills                           │
│ Go Standards                            │
│ Security Standards                      │
│ Review Standards                        │
└───────────────────┬─────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│ Workspace Knowledge                     │
│                                         │
│ AGENTS.md                               │
│ ARCHITECTURE.md                         │
│ docs/architecture                       │
│ docs/domain                             │
│ repository AGENTS.md                    │
└───────────────────┬─────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│ Feature Context                         │
│                                         │
│ requirement                             │
│ impact                                  │
│ design                                  │
│ implementation-plan                     │
│ tests                                   │
│ delivery                                │
└─────────────────────────────────────────┘
```

三种知识生命周期完全不同：

**组织层**长期复用。

**Workspace 层**跟随系统演进。

**Feature 层**跟随一次需求生命周期。

不要混在一起。

---

## 最终建议的真正落地顺序

第一次不要花时间制作 30 个 Skill。先落地最小但完整的 V1：

1. `codex-workflow-init.sh`
2. `feature-init.sh`
3. 根 `AGENTS.md`
4. `ARCHITECTURE.md`
5. `docs/architecture/`
6. `docs/domain/`
7. `docs/standards/`
8. 8 个 Feature 模板
9. 5 个 Bootstrap Prompt
10. `repository-analysis / impact-analysis / code-review` 三个核心 Skill
11. `verify-workspace.sh`

先用一个真实 Go Workspace 完整跑一遍。

跑完第一个真实 Feature 后，再根据实际发现把：

```text
重复出现的 Prompt
↓
升级成 Skill

反复出现的系统规则
↓
升级到 AGENTS.md

稳定的系统知识
↓
升级到 docs/

一次性需求信息
↓
留在 features/
```

这样这套系统不会迅速膨胀成另一个没人维护的“流程文档项目”，而会逐步形成真正有效的 **Codex Engineering Harness**。对于你这种长期维护的 Go 多服务系统，这比单纯研究“最强 Prompt”高一个层级：最终资产不是 Prompt，而是**Codex 能可靠理解、修改、验证和交付整个工程的机器可读工程体系**。

[1]: https://openai.com/index/harness-engineering/?utm_source=chatgpt.com "Harness engineering: leveraging Codex in an agent-first world | OpenAI"
[2]: https://openai.com/academy/skills/?utm_source=chatgpt.com "Using skills | OpenAI"
[3]: https://openai.com/zh-Hans-CN/index/introducing-codex/?utm_source=chatgpt.com "Codex 简介 | OpenAI"
