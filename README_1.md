> **文档状态：设计参考。** 本文保留工作流方法论和设计背景；当前可执行命令、目录位置及兼容性约定以根目录 `README.md`、`README-AI-WORKFLOW.md` 和 `scripts/` 为准。

可以把这件事做成一套真正可复制的 **AI-assisted SDLC**，而不是“拿需求丢给 Codex，让它改代码”。

你现在这种场景——**资深 Go 后端 + IDEA 多工程 + 多 Git 仓库 + 已有成熟系统 + 产品原型/需求文档 + Codex**——最适合建立下面这条链路：

> **需求输入 → 需求澄清 → Repository Recon → 系统影响分析 → 技术方案 → Implementation Plan → 分阶段编码 → 单测/集成测试 → 静态检查 → Diff Review → 风险审查 → 验收矩阵 → PR/发布 → 复盘 → 知识沉淀**

这与 OpenAI 当前建议的 Codex 使用方式高度一致：大型改动先做 Ask/Plan，再进入 Code；提示词像 GitHub Issue 一样写清范围、文件、组件和验收标准；用 `AGENTS.md` 提供持久上下文。OpenAI 内部还特别强调不要把 `AGENTS.md` 写成百科全书，而应把它做成“地图”，真正详细的工程知识放在结构化 `docs/` 中。([OpenAI][1])

下面我给你一套适合长期积累的版本。

---

# 一、先改变 Codex 的定位

不要把 Codex 当成：

```text
代码生成器
```

而应该把它当成：

```text
Senior Backend Engineer
        ↓
System Analyst
        ↓
Architecture Reviewer
        ↓
Implementation Engineer
        ↓
Test Engineer
        ↓
Code Reviewer
```

但是有一个非常重要的约束：

> **不要让同一个 Prompt 同时做需求分析、架构设计、改代码、补测试和提交。**

这是很多 AI Coding 工作流最容易犯的错误。

一次性说：

```text
分析这个需求然后帮我实现。
```

虽然方便，但质量通常不稳定。

正确做法应该是：

```text
Phase 0  Workspace Bootstrap
Phase 1  Repository Understanding
Phase 2  Requirement Analysis
Phase 3  Impact Analysis
Phase 4  Solution Design
Phase 5  Implementation Plan
Phase 6  Development
Phase 7  Testing
Phase 8  Review
Phase 9  Delivery
Phase 10 Knowledge Capture
```

Codex 官方当前也建议复杂工作采用这种分解、迭代方式，而不是把大型任务塞进一个模糊提示词。([OpenAI][1])

---

# 二、IDEA 多项目的正确组织方式

假设你的业务平台存在：

```text
platform/
├── gateway/
├── wallet/
├── game-service/
├── player-service/
├── risk-service/
├── common/
├── proto/
└── deployment/
```

每一个都是独立 Git Repository。

IDEA 可以全部打开。

但 Codex 的真实工作空间最好统一成：

```text
~/workspace/platform/
```

例如：

```text
~/workspace/platform
│
├── gateway
├── wallet
├── game-service
├── player-service
├── risk-service
├── common
├── proto
├── deployment
│
├── AGENTS.md
│
└── docs
```

重点：

```text
IDEA Project View ≠ Codex Workspace
```

你需要让 Codex 明确知道：

```text
workspace root
repo boundary
read scope
write scope
dependency relationship
```

例如每次新需求开场都明确：

```text
Workspace:

/workspace/platform

Repositories:

gateway/
game-service/
player-service/
common/
proto/

Read scope:
all repositories

Write scope:
game-service
common

Do NOT modify:
gateway
player-service
proto
```

这是非常重要的安全机制。

否则 Codex 跨工程扫描后，很容易“顺手”修改本不应该修改的仓库。

---

# 三、建立 Workspace 级 AGENTS.md

推荐：

```text
/workspace/platform/AGENTS.md
```

不要写几千行。

建议控制在大约：

```text
80~150 lines
```

OpenAI 当前工程实践同样强调：

> 给 Codex 一张地图，不要给它一本 1000 页说明书。([OpenAI][2])

例如：

```md
# Platform Engineering Instructions

## Role

You are working on a production Go backend platform.

Priorities:

1. correctness
2. backward compatibility
3. data consistency
4. observability
5. maintainability
6. performance

Never optimize for fewer lines of code at the expense of clarity.

---

## Workspace

Repositories:

- gateway
- game-service
- player-service
- wallet
- risk-service
- common
- proto
- deployment

Read:
docs/architecture/system-map.md

---

## Architecture

Primary architecture:

HTTP/gRPC
    ↓
Handler
    ↓
Service
    ↓
Domain
    ↓
Repository
    ↓
MySQL / ClickHouse / Redis

Async:

Service
 ↓
NATS/Kafka
 ↓
Consumer
 ↓
Domain Service

---

## Go conventions

Go version:
1.xx

Required:

- context.Context propagation
- errors.Is / errors.As
- error wrapping
- structured logging
- idempotency for async consumers
- explicit transaction boundaries

Avoid:

- package globals
- hidden goroutines
- panic for business errors
- cyclic dependencies

---

## Before changing code

Always:

1. inspect existing implementation
2. find analogous features
3. identify call chain
4. identify data ownership
5. identify compatibility risks
6. propose implementation plan

Do not implement before completing impact analysis.

---

## Verification

Minimum:

go test ./...
go vet ./...
golangci-lint run

Run repository-specific integration tests when applicable.

---

## Documentation

Architecture:
docs/architecture/

Feature specs:
docs/features/

ADRs:
docs/adr/

Runbooks:
docs/runbooks/
```

这样 Codex 每次进入 workspace 就获得稳定规则。

官方也明确说明 `AGENTS.md` 可以提供命名规范、业务逻辑、已知陷阱和无法单纯从代码推断出来的依赖信息。([OpenAI][1])

---

# 四、每个 Repository 再放自己的 AGENTS.md

例如：

```text
platform/
├── AGENTS.md
│
├── game-service/
│   ├── AGENTS.md
│
├── wallet/
│   ├── AGENTS.md
│
└── risk/
    └── AGENTS.md
```

其中：

```text
root AGENTS
```

负责：

```text
跨系统原则
工程地图
通用规范
```

而：

```text
game-service/AGENTS.md
```

负责：

```text
该服务特有架构
测试方式
数据库
MQ topic
代码规范
特殊陷阱
```

例如：

```md
# game-service

## Responsibility

Owns:

- game round lifecycle
- bet settlement
- game provider integration

Does NOT own:

- player wallet balance
- authentication

## Storage

MySQL:
transactional data

ClickHouse:
analytics / historical queries

Redis:
temporary state

## Important rules

Round settlement must be idempotent.

Do not change settlement state directly.

All state transitions must go through:

internal/domain/round/state_machine.go

## Related docs

docs/game-round.md
docs/settlement.md
```

这样层级非常清楚。

---

# 五、建立真正的 Repository Knowledge Base

推荐最终形成：

```text
docs/
│
├── architecture/
│   ├── system-map.md
│   ├── service-dependencies.md
│   ├── data-flow.md
│   ├── event-flow.md
│   └── database-map.md
│
├── domain/
│   ├── player.md
│   ├── wallet.md
│   ├── game-round.md
│   └── settlement.md
│
├── standards/
│   ├── go-style.md
│   ├── error-handling.md
│   ├── logging.md
│   ├── transaction.md
│   ├── idempotency.md
│   ├── api.md
│   └── testing.md
│
├── features/
│
├── adr/
│
├── runbooks/
│
└── generated/
```

我尤其建议你建立：

```text
system-map.md
```

这是 Codex 最有价值的上下文文件之一。

---

# 六、第一次建立系统地图

第一次使用 Codex，不要急着开发。

先让它理解整个系统。

Prompt：

```text
你现在作为本项目的 Principal Go Backend Engineer。

当前 workspace 包含多个独立 Git repository。

任务：

建立系统级 Repository Map。

不要修改任何代码。

请扫描当前 workspace：

1. 识别所有 repository
2. 识别每个 repository 的职责
3. 识别 Go module
4. 识别入口程序
5. 识别 HTTP/gRPC API
6. 识别数据库
7. 识别 Redis 使用方式
8. 识别 MQ producer / consumer
9. 识别跨服务调用
10. 识别 shared libraries
11. 识别 configuration
12. 识别 deployment
13. 识别 observability
14. 识别主要 domain model

重点分析：

- 服务依赖
- 数据所有权
- 调用方向
- 事件流
- transaction boundary
- failure boundary
- consistency model

不要根据目录名称猜测。

每一个重要结论必须给出：

repository
file path
symbol/function/type

输出：

docs/architecture/system-map.md

并列出：

UNKNOWN
UNCERTAIN
NEEDS_VERIFICATION

三类信息。
```

这一步非常值钱。

---

# 七、建立 Service Dependency Map

第二个 Prompt：

```text
基于当前 workspace 的真实代码：

生成跨服务依赖分析。

重点分析：

HTTP
gRPC
NATS
Kafka
Redis
MySQL
ClickHouse

输出服务关系：

Caller
→ Protocol
→ Callee
→ API/Event
→ Data
→ Failure behavior

额外识别：

- cyclic dependency
- hidden coupling
- shared database
- distributed transaction
- retry
- timeout
- idempotency
- compensation

输出：

docs/architecture/service-dependencies.md

禁止修改业务代码。
```

以后任何需求分析都依赖这份地图。

---

# 八、新功能正式开始时，不要直接读原型然后编码

假设产品给了：

```text
requirements/
GAME-2451/
├── requirement.pdf
├── prototype.png
├── api.xlsx
└── notes.md
```

我推荐每个 Feature 建立自己的工作区：

```text
docs/features/GAME-2451/
│
├── 00-source/
│
├── 01-requirement.md
├── 02-current-system.md
├── 03-impact-analysis.md
├── 04-solution-design.md
├── 05-implementation-plan.md
├── 06-test-plan.md
├── 07-delivery-checklist.md
└── 08-retrospective.md
```

这是整个工作流的核心。

---

# 九、Phase 1：需求理解

不要让 Codex 修改代码。

Prompt：

```text
角色：

Senior Product-aware Backend Engineer
+
Senior Go Backend Architect

任务：

分析需求 GAME-2451。

输入：

docs/features/GAME-2451/00-source/

当前阶段：

REQUIREMENT ANALYSIS ONLY

禁止：

- 修改业务代码
- 设计具体实现
- 创建数据库 migration
- 修改 API

请分析：

1. 用户目标
2. Business Goal
3. Actor
4. Preconditions
5. Trigger
6. Main Flow
7. Alternative Flow
8. Exception Flow
9. Business Rules
10. State Transition
11. Data Requirements
12. API Requirements
13. Async Requirements
14. Permission Requirements
15. Audit Requirements
16. Compatibility Requirements
17. Non-functional Requirements

然后识别：

AMBIGUOUS
MISSING
CONFLICTING
ASSUMPTION
RISK

尤其不要把原型 UI 行为直接当成后端业务规则。

最后生成：

docs/features/GAME-2451/01-requirement.md

最后附：

Acceptance Criteria

采用：

Given
When
Then

形式。
```

这里有个重要原则：

> **原型不是需求，原型只是需求的一种表达。**

尤其后端工程师很容易被前端页面带着走。

---

# 十、Phase 2：Current System Analysis

现在才允许它阅读代码。

Prompt：

```text
基于：

docs/features/GAME-2451/01-requirement.md

分析当前系统如何支持相关业务。

不要修改代码。

找到当前最接近需求的已有实现。

要求 trace 完整调用链：

API
→ Handler
→ Service
→ Domain
→ Repository
→ Database

如果存在异步流程：

Producer
→ Topic
→ Consumer
→ Domain
→ Storage

需要输出：

1. 当前相关功能实现
2. 相关 repository
3. 关键 package
4. 关键 type
5. 关键 function
6. DB table
7. cache
8. event
9. API
10. configuration
11. test
12. observability

寻找至少一个类似功能作为 implementation reference。

每个结论给出：

repo/path:symbol

输出：

docs/features/GAME-2451/02-current-system.md
```

---

# 十一、Phase 3：Impact Analysis

这是资深工程师和普通 AI Coding 最大的区别之一。

Prompt：

```text
基于：

01-requirement.md
02-current-system.md

进行 Feature Impact Analysis。

不要写实现代码。

分析：

API impact
Domain impact
Database impact
Cache impact
MQ impact
Config impact
Security impact
Permission impact
Observability impact
Performance impact
Backward compatibility
Deployment impact
Rollback impact

尤其检查：

1. 是否影响已有 API contract
2. 是否改变数据语义
3. 是否需要 migration
4. 是否存在历史数据兼容问题
5. 是否存在消息 schema compatibility
6. 是否存在 duplicate processing
7. 是否存在 race condition
8. 是否存在 distributed consistency
9. 是否存在 partial failure
10. 是否需要 feature flag

输出：

docs/features/GAME-2451/03-impact-analysis.md

最后建立：

Risk Matrix

格式：

Risk
Probability
Impact
Mitigation
Verification
```

---

# 十二、Phase 4：Solution Design

现在才开始设计。

这里建议强制 Codex 给出至少：

```text
Option A
Option B
```

而不是直接接受它的第一方案。

Prompt：

```text
设计 GAME-2451 技术方案。

输入：

01-requirement.md
02-current-system.md
03-impact-analysis.md

提出至少两种实现方案。

对比：

complexity
maintainability
compatibility
performance
data consistency
operational risk
rollback
testability

优先：

最小化系统复杂度
最小化跨服务修改
最大化 backward compatibility
复用现有 pattern

不要为了所谓“更优雅”引入新的 framework、
middleware、
message queue、
storage 或 abstraction。

最终推荐一个方案。

输出：

docs/features/GAME-2451/04-solution-design.md
```

这里我特别建议加入：

```text
不要为了实现新需求顺手重构旧系统。
```

这是 Coding Agent 很常见的问题。

---

# 十三、设计文档必须包含什么

`04-solution-design.md` 最好固定模板：

```text
# Summary

# Background

# Requirements

# Existing Architecture

# Proposed Design

# Request Flow

# Data Flow

# State Transition

# API Changes

# Database Changes

# Cache Changes

# Event Changes

# Error Handling

# Idempotency

# Transaction Boundary

# Concurrency

# Observability

# Security

# Compatibility

# Rollout

# Rollback

# Alternatives

# Risks

# Open Questions
```

---

# 十四、Phase 5：Implementation Plan

这是 Codex 真正开始编码之前的最后一道门。

Prompt：

```text
基于已批准的：

04-solution-design.md

制定 Implementation Plan。

不要修改代码。

将工作拆成小的、可验证任务。

原则：

每个 task：

- 单一职责
- 独立验证
- 尽量 < 300 LOC
- 能独立 review

每个 task 必须包含：

Repository
Files
Symbols
Change
Dependencies
Tests
Validation
Risk

按照依赖顺序排列。

输出：

docs/features/GAME-2451/05-implementation-plan.md
```

推荐最终得到：

```text
TASK-01 domain model

TASK-02 repository

TASK-03 service

TASK-04 handler

TASK-05 event producer

TASK-06 consumer

TASK-07 metrics

TASK-08 tests

TASK-09 compatibility tests

TASK-10 docs
```

OpenAI 自己也建议 Codex 处理**范围明确的小任务**，而非任由一个庞大任务无限扩散。([OpenAI][1])

---

# 十五、真正开始 Coding

不要说：

```text
实现 GAME-2451
```

而应该：

```text
执行：

GAME-2451
TASK-03

严格按照：

04-solution-design.md
05-implementation-plan.md

修改范围：

repo:
game-service

files:

internal/service/game.go
internal/domain/game.go

禁止修改：

API contract
database schema
MQ schema

除非 plan 明确要求。

实现过程中：

1. 先阅读类似实现
2. 遵循现有 architecture
3. 不创建新的 abstraction，除非必要
4. 保持 backward compatibility
5. 添加 unit tests
6. 不顺带 refactor 无关代码

完成后运行：

go test ./...
go vet ./...

最后汇报：

Changed Files
Behavior Change
Tests
Remaining Risk

不要 commit。
```

---

# 十六、Go 项目特别需要 Codex 检查的内容

你的 Go Backend Prompt 建议始终包含：

```text
Check specifically for:

context propagation

goroutine leak

channel leak

race conditions

nil handling

error wrapping

transaction boundary

connection lifecycle

resource cleanup

timeout

retry

idempotency

duplicate event

message ordering

partial failure

cache consistency

SQL transaction isolation

N+1 query

index usage

large allocation

hot-path allocation

lock contention

backward compatibility
```

这比一句：

```text
帮我 review 一下
```

强太多。

---

# 十七、Phase 6：Test Plan

测试不能等开发完成以后临时补。

建立：

```text
06-test-plan.md
```

Prompt：

```text
根据：

requirement
solution design
implementation plan
current diff

建立完整 Test Matrix。

至少覆盖：

Happy Path

Boundary Cases

Invalid Input

Permission

Concurrency

Retry

Timeout

Dependency Failure

Database Failure

Duplicate Request

Duplicate Event

Out-of-order Event

Backward Compatibility

Regression

Rollback

对于每个测试：

Scenario
Precondition
Input
Expected Result
Test Layer
Automated?
Existing/New

输出：

docs/features/GAME-2451/06-test-plan.md
```

---

# 十八、建议 Go 测试门禁

你的项目可以统一：

```bash
go test ./...
go test -race ./...
go vet ./...
golangci-lint run
```

必要时：

```bash
staticcheck ./...
```

以及：

```bash
go test -cover ./...
```

微服务则增加：

```text
contract tests
integration tests
DB migration tests
MQ compatibility tests
```

---

# 十九、Phase 7：Independent Review

非常重要：

**不要让 Codex 只 review 自己刚刚写的代码时依赖原实现思路。**

应该重新给它一个“Reviewer”任务：

```text
你现在不是代码作者。

你是 Principal Go Backend Reviewer。

不要假设当前实现正确。

基于：

requirement
solution design
git diff

进行 adversarial review。

重点找：

P0:
data corruption
security issue
financial inconsistency

P1:
incorrect business logic
race condition
duplicate processing
compatibility break

P2:
maintainability
observability
performance

检查：

API compatibility
transaction
idempotency
concurrency
retry
timeout
MQ ordering
cache consistency
SQL
error handling
logging
metrics

不要评价代码风格，除非它影响 correctness。

输出：

Finding
Severity
Evidence
Impact
Fix
```

这就是你要求的“压力测试”。

---

# 二十、再做一次 Requirement Coverage Review

这是特别容易漏掉的一环。

Prompt：

```text
不要 review 代码风格。

只做：

Requirement → Implementation Coverage Analysis。

逐条检查：

01-requirement.md

中的每一个：

Business Rule
Acceptance Criterion
Edge Case
Error Case

找到对应实现和测试。

生成：

Requirement
Implementation
Test
Status

Status：

PASS
PARTIAL
MISSING
CONFLICT

如果无法证明实现存在：

不能标记 PASS。
```

这一步能发现：

```text
代码写得很好
但需求没实现完整
```

这种最危险的问题。

---

# 二十一、Delivery Gate

建立：

```text
07-delivery-checklist.md
```

例如：

```text
[ ] Requirement approved
[ ] Architecture reviewed
[ ] API compatibility checked
[ ] DB migration reviewed
[ ] MQ schema checked
[ ] Unit tests pass
[ ] Integration tests pass
[ ] race detector pass
[ ] golangci-lint pass
[ ] observability added
[ ] metrics added
[ ] logs reviewed
[ ] feature flag considered
[ ] rollout plan
[ ] rollback plan
[ ] documentation updated
```

---

# 二十二、Git 最佳实践

Codex 不应该一次产生巨大 commit。

推荐：

```text
feat(game): add domain support for xxx

feat(game): implement xxx repository

feat(game): implement xxx service

test(game): add xxx integration tests

docs(game): document xxx rollout
```

不要：

```text
feat: implement GAME-2451
```

然后：

```text
47 files changed
6000 insertions
```

这种 PR 无论人还是 AI 都很难可靠 review。

---

# 二十三、最终 PR Prompt

```text
基于当前 branch：

生成 Pull Request Description。

输入：

git diff main...HEAD

requirements
solution design
test plan

输出：

## Summary

## Business Context

## Architecture

## Key Changes

## API Changes

## Database Changes

## Event Changes

## Compatibility

## Test Evidence

## Risk

## Deployment

## Rollback

## Monitoring

## Checklist

禁止夸大。

无法从代码或测试证明的内容必须标记：

NOT VERIFIED
```

---

# 二十四、Feature 完成后做 Knowledge Capture

这是很多团队完全没有做，但实际上是 AI 编程最有价值的长期资产。

开发结束之后运行：

```text
Review GAME-2451 development.

Identify reusable knowledge learned during implementation.

Classify as:

Architecture Knowledge
Domain Knowledge
Coding Convention
Operational Knowledge
Known Pitfall
Testing Pattern

判断哪些应该写入：

AGENTS.md
docs/architecture
docs/domain
docs/standards
docs/runbooks

不要把 feature-specific details 塞进 AGENTS.md。

更新必要文档。
```

这样：

```text
Feature 1
 ↓
知识沉淀
 ↓
Feature 2 Codex 更聪明
 ↓
知识沉淀
 ↓
Feature 10
```

你的 repository 就逐渐变成：

> **AI-readable engineering system**

---

# 二十五、我推荐你真正建立的 Skills

如果你准备长期用 Codex，我建议不是疯狂下载几十个 Skill。

先建立这 **8 个核心工程 Skill**：

```text
.agents/skills/
│
├── requirement-analysis/
│
├── repository-analysis/
│
├── impact-analysis/
│
├── architecture-design/
│
├── go-implementation/
│
├── go-testing/
│
├── code-review/
│
└── delivery-review/
```

OpenAI 当前已经把 Skills 作为可版本化资源提供，也支持建立和迭代 skill 版本；这非常适合把团队稳定流程封装，而不是每次复制几百行 Prompt。([OpenAI Developers][3])

---

# 二十六、Skill 1：requirement-analysis

职责：

```text
PRD
原型
UI
Issue
会议纪要
       ↓
Backend Requirement Spec
```

输出：

```text
business rules
actors
state
edge cases
ambiguities
acceptance criteria
```

---

# 二十七、Skill 2：repository-analysis

负责：

```text
Repo Recon
Call Chain
Dependency
Data Flow
```

禁止：

```text
直接修改代码
```

---

# 二十八、Skill 3：impact-analysis

专门检查：

```text
API
DB
MQ
Cache
Security
Performance
Compatibility
Deployment
```

---

# 二十九、Skill 4：architecture-design

负责：

```text
Option A
Option B
Tradeoffs
ADR
```

---

# 三十、Skill 5：go-implementation

把你的 Go 编程规范固化：

```text
context
errors
transactions
idempotency
logging
metrics
repository
domain
tests
```

---

# 三十一、Skill 6：go-testing

统一：

```text
table-driven tests
mock policy
integration test policy
race
benchmark
contract tests
```

---

# 三十二、Skill 7：code-review

尤其建议做成**攻击型 Reviewer**：

```text
Assume implementation may be wrong.

Search for correctness failures.
```

而不是：

```text
please review code
```

---

# 三十三、Skill 8：delivery-review

负责：

```text
Requirement Coverage
Release Risk
Migration
Rollback
Observability
Production Verification
```

---

# 三十四、推荐形成下面的最终目录

这是我最推荐你直接落地的结构：

```text
workspace/
│
├── AGENTS.md
│
├── docs/
│   │
│   ├── architecture/
│   │   ├── system-map.md
│   │   ├── service-dependencies.md
│   │   ├── data-flow.md
│   │   └── database-map.md
│   │
│   ├── domain/
│   │   ├── player.md
│   │   ├── wallet.md
│   │   └── game.md
│   │
│   ├── standards/
│   │   ├── go-style.md
│   │   ├── error-handling.md
│   │   ├── transaction.md
│   │   ├── idempotency.md
│   │   ├── logging.md
│   │   └── testing.md
│   │
│   ├── adr/
│   │
│   └── features/
│       └── GAME-2451/
│           ├── 00-source/
│           ├── 01-requirement.md
│           ├── 02-current-system.md
│           ├── 03-impact-analysis.md
│           ├── 04-solution-design.md
│           ├── 05-implementation-plan.md
│           ├── 06-test-plan.md
│           ├── 07-delivery-checklist.md
│           └── 08-retrospective.md
│
├── .agents/
│   └── skills/
│       ├── requirement-analysis/
│       ├── repository-analysis/
│       ├── impact-analysis/
│       ├── architecture-design/
│       ├── go-implementation/
│       ├── go-testing/
│       ├── code-review/
│       └── delivery-review/
│
├── gateway/
├── game-service/
├── player-service/
├── wallet/
├── common/
└── proto/
```

---

# 三十五、以后每个新需求，你实际上只需要执行这条 SOP

```text
                 Product Requirement
                         │
                         ▼
                Requirement Analysis
                         │
                         ▼
               Requirement Questions
                         │
                         ▼
                 Current System
                         │
                         ▼
                   Impact Analysis
                         │
                         ▼
                  Solution Design
                         │
                  ┌──────┴──────┐
                  ▼             ▼
               Option A      Option B
                  └──────┬──────┘
                         ▼
                 Architecture Review
                         │
                         ▼
               Implementation Plan
                         │
              ┌──────────┼──────────┐
              ▼          ▼          ▼
            Task 1     Task 2     Task N
              │          │          │
              └──────────┼──────────┘
                         ▼
                       Tests
                         │
                         ▼
                  Adversarial Review
                         │
                         ▼
               Requirement Coverage
                         │
                         ▼
                    Delivery Gate
                         │
                         ▼
                        PR
                         │
                         ▼
                     Production
                         │
                         ▼
                    Retrospective
                         │
                         ▼
                 Knowledge Capture
                         │
                         ▼
                AGENTS / docs / skill
```

这才是完整闭环。

---

# 三十六、给你一个“新需求启动 Prompt”，以后基本可以复用

这是我最推荐保留下来的总入口：

```text
# ROLE

You are the Principal Go Backend Engineer responsible for this production system.

Your responsibility is not merely to implement code.

You must ensure:

- requirement correctness
- architectural consistency
- backward compatibility
- data correctness
- operational safety
- testability
- maintainability

# FEATURE

Feature ID:

GAME-XXXX

Source documents:

docs/features/GAME-XXXX/00-source/

# WORKSPACE

Workspace root:

<workspace>

Repositories:

<repos>

Read scope:

<repos>

Write scope:

NONE

# CURRENT PHASE

PHASE 1 — REQUIREMENT AND SYSTEM ANALYSIS

DO NOT MODIFY PRODUCTION CODE.

# WORKFLOW

Perform the following sequentially.

1. Requirement Analysis

Produce:

01-requirement.md

Identify:

business goal
actors
business rules
states
flows
edge cases
ambiguities
missing information
acceptance criteria

2. Current System Analysis

Inspect the actual code.

Find:

existing implementation
similar features
call chain
data flow
storage
MQ
cache
API
configuration
tests

Produce:

02-current-system.md

Every architectural claim must reference:

repository
file
symbol

Do not infer architecture only from filenames.

3. Impact Analysis

Analyze:

API
domain
database
cache
MQ
configuration
security
performance
observability
compatibility
deployment
rollback

Produce:

03-impact-analysis.md

4. Stop.

Do NOT design or implement yet.

# IMPORTANT RULES

Do not invent missing requirements.

Mark uncertainty as:

UNKNOWN
AMBIGUOUS
ASSUMPTION
NEEDS_CONFIRMATION

Prefer evidence from:

code
tests
schemas
configuration
documentation

over assumptions.

At the end provide:

Key Findings
Open Questions
Risks
Recommended Next Step
```

这条 Prompt 可以成为所有新 Feature 的入口。

---

# 三十七、最终建议：采用“两层 + 八阶段”的体系

我不会建议你把 Codex Workflow 搞得过度复杂。

真正成熟的结构其实只有两层：

```text
长期上下文

AGENTS.md
docs/
skills/
```

加：

```text
Feature 生命周期

Requirement
↓
System Analysis
↓
Impact
↓
Design
↓
Plan
↓
Code
↓
Verify
↓
Deliver
```

其中最重要的不是 Prompt，而是 **Repository Harness**。

OpenAI 最新关于 Codex 工程实践给出的经验其实也指向这一点：

> Agent 能力越来越强以后，决定结果上限的东西从“Prompt 写得多聪明”，逐渐转变成“Repository 是否为 Agent 提供了清晰、可验证、可导航的工程环境”。OpenAI 团队因此把结构化 repo 知识作为 system of record，而不是把所有东西塞进一个巨型 `AGENTS.md`。([OpenAI][2])

所以你的长期目标不应该是积累：

```text
100 个高级 Prompt
```

而应该是积累：

```text
10 个稳定 Skills
+
完整 AGENTS.md
+
可靠 architecture docs
+
标准 feature docs
+
自动测试/静态检查
+
稳定 delivery gate
```

这样新需求进来之后，Codex 才真正从：

```text
AI 写代码
```

升级成：

```text
Product Requirement
        ↓
AI Engineering Harness
        ↓
Architecture
        ↓
Implementation
        ↓
Verification
        ↓
Human Review
        ↓
Production
        ↓
Knowledge Feedback
```

**这套模式尤其适合你现在这种 Go 微服务/游戏平台后端、多仓库、MQ、ClickHouse/MySQL、跨服务调用、长期维护型系统。** 关键不是让 Codex 写更多代码，而是让它每一次修改都能回答五个问题：**为什么改、影响什么、为什么这样设计、怎样证明正确、出问题怎样回滚。**

[1]: https://openai.com/business/guides-and-resources/how-openai-uses-codex/?utm_source=chatgpt.com "How OpenAI uses Codex | OpenAI"
[2]: https://openai.com/index/harness-engineering/?utm_source=chatgpt.com "Harness engineering: leveraging Codex in an agent-first world | OpenAI"
[3]: https://developers.openai.com/api/reference/go/resources/skills?utm_source=chatgpt.com "Skills | OpenAI API Reference"
