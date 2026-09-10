# 首次使用指南

## 1. 准备目标 Workspace

将所有需要共同分析的 Git 仓库检出到同一个 Workspace 下。安装前确认：

- 目标路径不是本工作流的源码目录；
- 现有修改已经提交或备份；
- 已知哪些仓库属于本次分析范围；
- Bash 4、GNU coreutils、findutils 和 sed 可用；
- 验证 Go 项目时，Go 和仓库要求的 lint 工具可用。

## 2. 预览并安装

从完整的工作流发布目录运行：

```bash
bash scripts/codex-workflow-init.sh --dry-run /path/to/workspace
bash scripts/codex-workflow-init.sh /path/to/workspace
```

如果报告冲突，先阅读
[故障排查手册](troubleshooting.zh-CN.md)，不要直接使用 `--force`。

安装完成后确认：

```text
.codex/workflow-install.manifest
.codex/workspace-status.md
ARCHITECTURE.md
README-AI-WORKFLOW.zh-CN.md
docs/guides/
```

初始 Workspace 状态必须为 `NOT_READY`。

## 3. 启动 Codex

从目标 Workspace 根目录启动 Codex，使根 `AGENTS.md`、`.agents/skills/`
和工程文档处于发现范围内。

每个阶段使用独立任务。向 Codex 发出类似指令：

```text
读取并严格执行 .codex/prompts/00-bootstrap.md。
只完成该阶段；不要修改生产代码。
```

完成并审核当前阶段产物后，再进入下一个提示词。完整顺序见
[Workspace 初始化手册](workspace-bootstrap.zh-CN.md)。

## 4. 完成初始化

依次完成 discovery、仓库、架构、领域、标准、文档验证和 AGENTS 最终化。
每一步都应检查 `.codex/workspace-status.md`，不能手工跳过未完成项。

初始化完成后运行仓库验证：

```bash
./scripts/verify-workspace.sh /path/to/workspace
```

仅当 Workspace 明确不包含 Go Module 时才能使用：

```bash
./scripts/verify-workspace.sh --allow-no-go-modules /path/to/workspace
```

## 5. 保存基线

人工审查生成文档，确认没有密钥、个人数据、构建产物或未经验证的结论。
然后在目标仓库中按照团队分支和提交规范提交初始化文档。工作流不会自动
提交、推送、合并或发布。

下一步阅读 [Feature 开发手册](feature-development.zh-CN.md)。
