# AI 工程工作流

[English](README-AI-WORKFLOW.md) | [简体中文](README-AI-WORKFLOW.zh-CN.md)

## 安装工作流

从本仓库的完整检出目录运行安装器：

```bash
bash scripts/codex-workflow-init.sh /path/to/workspace
```

安装器会复制随仓库提供的提示词、模板、Skills、文档和辅助脚本。除非显式
使用 `--force`，否则不会覆盖内容不同的文件。使用 `--dry-run` 可以在不
写入文件的情况下验证安装。模板源码检出目录和目标 Workspace 必须是不同
目录。

每次安装都会生成 `.codex/workflow-install.manifest`，其中包含工作流版本
以及每个受管资产的 SHA-256 校验和。从更新且完整的工作流检出目录预览并
执行升级：

```bash
bash scripts/codex-workflow-init.sh --dry-run --upgrade /path/to/workspace
bash scripts/codex-workflow-init.sh --upgrade /path/to/workspace
```

升级只会替换仍与上一份清单一致的资产。本地修改或非受管文件仍会被视为
冲突，需要显式协调处理；`--force` 是单独的操作者覆盖选项。如果新版不再
提供某项既有受管资产，目标文件会被保留并记录为 `retired`，删除仍需操作
者明确决定。安装器也会拒绝解析到目标 Workspace 外部的符号链接路径。

## Workspace 初始化

按以下顺序运行 Codex 提示词：

1. `.codex/prompts/00-bootstrap.md`
2. `.codex/prompts/01-repository-analysis.md`
3. `.codex/prompts/02-architecture-analysis.md`
4. `.codex/prompts/03-domain-analysis.md`
5. `.codex/prompts/04-standards-analysis.md`
6. `.codex/prompts/05-verification.md`
7. `.codex/prompts/06-agents-finalization.md`

首次执行前请阅读
[Workspace 初始化手册](docs/guides/workspace-bootstrap.zh-CN.md)。

仓库级可复用工作流位于：

    .agents/skills/

## Feature 工作流

创建 Feature 工作区：

```bash
./scripts/feature-init.sh FEATURE-ID
```

为了向后兼容，默认使用内容详细的 `extended` 模板。对于范围明确的常规
变更，可以使用较小的模板档位：

```bash
./scripts/feature-init.sh --profile compact FEATURE-ID
```

仅当调用的脚本没有安装在目标 Workspace 中时，才需要把 Workspace 根
目录作为第二个参数传入：

```bash
./scripts/feature-init.sh FEATURE-ID /path/to/workspace
```

然后依次执行：

1. `.codex/prompts/feature-start.md`
2. `.codex/prompts/feature-current-system.md`
3. `.codex/prompts/feature-impact.md`
4. `.codex/prompts/feature-design.md`
5. 执行 `.codex/prompts/feature-plan.md`，然后批准 `05-implementation-plan.md`
6. 使用 `.codex/prompts/feature-implement.md`，每次只实现一个任务
7. `.codex/prompts/feature-test.md`
8. `.codex/prompts/feature-review.md`
9. `.codex/prompts/feature-delivery.md`
10. `.codex/prompts/feature-retrospective.md`

各阶段操作和返回规则见
[Feature 开发操作手册](docs/guides/feature-development.zh-CN.md)。

## 验证

对所有发现的 Go Module 执行测试、竞态检测、vet，并在已安装时执行
golangci-lint：

```bash
./scripts/verify-workspace.sh
```

默认情况下，未发现 Go Module 会导致验证失败。对于明确不使用 Go 的
Workspace，需要显式确认这一情况：

```bash
./scripts/verify-workspace.sh --allow-no-go-modules
```
