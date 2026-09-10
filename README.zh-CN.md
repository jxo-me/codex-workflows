# Codex 工程工作流

[English](README.md) | [简体中文](README.zh-CN.md)

这是一个仓库模板，用于将基于证据、分阶段执行的工程工作流安装到
现有的单仓库或多仓库 Workspace 中。

状态：开发中（DEVELOPMENT）

当前实现提供：

- 安全且可感知文件冲突的 Workspace 安装
- 基于版本和校验和保护的 Workspace 升级
- 仓库级 Codex Skills
- 分阶段的 Workspace 探索提示词
- Feature 分析、设计、实现、审查和交付提示词
- 包含八份文档的 `compact` 和 `extended` Feature 模板档位
- 多 Go Module 验证
- GitHub Actions 冒烟验证

## 从这里开始

- 第一次安装和初始化，请阅读
  [首次使用指南](docs/guides/first-run.zh-CN.md)。
- 完整的八阶段初始化流程见
  [Workspace 初始化手册](docs/guides/workspace-bootstrap.zh-CN.md)。
- 日常需求开发见
  [Feature 开发操作手册](docs/guides/feature-development.zh-CN.md)。
- 阶段完成条件见
  [阶段门禁与状态规则](docs/guides/phase-gates.zh-CN.md)。
- 安装、升级或验证失败时见
  [故障排查手册](docs/guides/troubleshooting.zh-CN.md)。

## 环境要求

- Linux
- Bash 4 或更高版本
- GNU coreutils、findutils 和 sed
- 验证 Go Module 时需要 Go
- 仓库要求执行 lint 时需要 golangci-lint
- 发布验证需要 ShellCheck 和 actionlint

## 安装

预览将要安装的文件：

    bash scripts/codex-workflow-init.sh --dry-run /path/to/workspace

执行安装：

    bash scripts/codex-workflow-init.sh /path/to/workspace

默认情况下，如果目标中存在内容不同的文件，安装器会拒绝覆盖。仅在审查
所有冲突之后，才应考虑显式使用 `--force` 安装。

安装器会将版本和受管文件校验和记录到
`.codex/workflow-install.manifest`。升级时，请检出新版工作流，然后运行
该版本自带的安装器：

    bash scripts/codex-workflow-init.sh --dry-run --upgrade /path/to/workspace
    bash scripts/codex-workflow-init.sh --upgrade /path/to/workspace

`--upgrade` 只会替换当前校验和仍与上一份清单一致的受管文件。本地修改
过的文件仍会被视为冲突。工作流源码检出目录不能作为其自身的安装目标。
新版不再提供的资产会保留在目标 Workspace 中，并以 `retired` 记录写入
格式 2 的清单；安装器不会隐式删除这些文件。如果目标路径通过符号链接
解析到了 Workspace 外部，安装器会在写入任何文件之前拒绝安装。

## 开始一个 Feature

在已安装工作流的 Workspace 中运行：

    ./scripts/feature-init.sh FEATURE-ID

为了保持向后兼容，默认使用内容详细的 `extended` 模板。对于范围明确的
常规变更，可以显式选择较短的模板档位：

    ./scripts/feature-init.sh --profile compact FEATURE-ID

将经过验证的输入资料放入 `docs/features/FEATURE-ID/00-source/`，然后按照
[README-AI-WORKFLOW.zh-CN.md](README-AI-WORKFLOW.zh-CN.md) 执行。

请从已安装 Workspace 的根目录启动 Codex，以确保根目录下的 `AGENTS.md`
指导和仓库级 Skills 位于其发现路径中。

## 验证

    ./scripts/verify-workspace.sh /path/to/workspace

该命令会对发现的每个 Go Module 执行测试、竞态检测、vet，并在已安装时
执行 golangci-lint。如果未发现 Go Module，验证默认失败；仅当这是预期
情况时，才能显式使用 `--allow-no-go-modules`。

运行安装器和 Feature 生命周期回归测试：

    bash tests/workflow-smoke.sh

## 发布

验证版本、变更日志、仓库状态和脚本语法：

    bash scripts/verify-release.sh

完整的发布门禁和标签流程记录在
[RELEASING.zh-CN.md](RELEASING.zh-CN.md) 中。面向使用者的变更记录在
[CHANGELOG.zh-CN.md](CHANGELOG.zh-CN.md) 中。

## 设计来源

- [README_1.md](README_1.md) 描述分阶段的 AI 辅助软件开发生命周期。
- [README_2.md](README_2.md) 是原始的引导实现方案。

这些文档用于说明设计意图。本文档、英文版 [README.md](README.md)、
[README-AI-WORKFLOW.zh-CN.md](README-AI-WORKFLOW.zh-CN.md) 以及可执行行为共同构成
当前操作层面的事实来源。
