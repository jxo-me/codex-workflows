# Workspace 初始化操作手册

初始化必须按阶段执行。每个阶段只允许修改指定工程文档，不允许修改生产
代码。阶段完成条件见 [phase-gates.zh-CN.md](phase-gates.zh-CN.md)。

## 阶段 1：Skeleton created

由 `codex-workflow-init.sh` 完成。检查安装清单、目标架构入口、提示词、Skills、
模板、脚本和本手册均已安装。初始状态应为 `NOT_READY`。

## 阶段 2：Repository discovery

执行：

```text
读取并严格执行 .codex/prompts/00-bootstrap.md。
```

输入是 Workspace 文件树、Git 边界、构建配置和部署配置。输出是
`docs/architecture/workspace-inventory.md`，只记录客观清单，不判断仓库职责。

检查是否覆盖所有 Git 仓库、语言、Go Module、入口点、构建、测试、lint、
配置和部署位置。遗漏范围时保持该阶段未完成。

## 阶段 3：Repository analysis

执行 `.codex/prompts/01-repository-analysis.md`。输出
`docs/architecture/repository-map.md`。

每个仓库必须有职责、入口、接口、数据、缓存、消息、外部依赖、测试、
可观测性和部署证据。重要结论使用 `repo/path:symbol` 引用。

## 阶段 4：Architecture analysis

执行 `.codex/prompts/02-architecture-analysis.md`，补全根 `ARCHITECTURE.md`
以及 `docs/architecture/` 下的系统、依赖、数据、事件、数据库和运行时视图。

必须覆盖服务边界、数据所有权、事务与一致性边界、重试、超时、幂等、消息
顺序和部分失败。无法证明的关系使用 `UNKNOWN` 或 `NEEDS_VERIFICATION`。

## 阶段 5：Domain analysis

执行 `.codex/prompts/03-domain-analysis.md`。输出 `docs/domain/index.md` 和每个
实际领域的独立文档。

领域规则应来自模型、服务、数据库、事件和测试。需要产品确认的语义标为
`NEEDS_PRODUCT_CONFIRMATION`，不得根据 API 名称或页面行为自行补全。

## 阶段 6：Engineering standards analysis

执行 `.codex/prompts/04-standards-analysis.md`，补全 `docs/standards/`。

将证据分类为 `CURRENT_STANDARD`、`LEGACY_PATTERN`、
`INCONSISTENT_PATTERN` 或 `RISKY_PATTERN`。常见写法不等于批准标准；存在
冲突时由维护者确认目标规范。

## 阶段 7：Documentation verification

以独立任务执行 `.codex/prompts/05-verification.md`。固定输出：

```text
docs/generated/documentation-verification.md
```

验证生成文档中的重要结论，列出错误、遗漏、矛盾、陈旧内容和未验证项。
这一阶段不能将 Workspace 标为 `READY`。

## 阶段 8：AGENTS.md finalized

执行 `.codex/prompts/06-agents-finalization.md`。根据已经验证的文档精简并
最终化根 `AGENTS.md`；仅在局部规则确有差异时创建嵌套 `AGENTS.md`。

最终状态只能是：

- `READY`：没有影响后续工程工作的重大缺口；
- `READY_WITH_GAPS`：缺口已知、已记录且可接受；
- `NOT_READY`：仍有阻止可靠开发的缺口。

## 初始化完成检查

- 八个状态项与实际证据一致；
- `Last verified` 是真实验证日期；
- 文档验证报告存在；
- `AGENTS.md` 中的路径和命令可以执行；
- `verify-workspace.sh` 已运行并记录真实结果；
- 未将 `SKIPPED` 或 `NEEDS_VERIFICATION` 写成 `PASS`。
