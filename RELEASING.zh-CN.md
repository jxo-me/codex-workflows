# 发布流程

[English](RELEASING.md) | [简体中文](RELEASING.zh-CN.md)

发布版本必须从干净的评审分支准备，并且只有在全部必要证据可用后才能
发布。

## 版本策略

- `VERSION` 只包含一个稳定的语义化版本号（`MAJOR.MINOR.PATCH`）。
- `CHANGELOG.md` 必须包含该版本对应的带日期条目。
- `.codex/workspace-status.md` 必须包含相同版本；在首个稳定生产声明获得
  批准前，其状态保持为 `DEVELOPMENT`。
- 对安装器、清单、提示词、模板或受管文件契约的破坏性变更必须提升主
  版本号。
- 向后兼容的能力提升次版本号；缺陷修复提升补丁版本号。

## 发布门禁

从仓库根目录运行：

```bash
bash scripts/verify-release.sh
WORKFLOW_REQUIRE_GOLANGCI_LINT=1 bash tests/workflow-smoke.sh
shellcheck scripts/*.sh tests/*.sh
actionlint .github/workflows/ci.yml
```

所有检查都必须通过。缺少必要工具属于发布门禁失败，不能视为跳过。创建
标签之前，托管 GitHub Actions 也必须通过。

## 发布

1. 确认 `VERSION`、`CHANGELOG.md` 和 `.codex/workspace-status.md` 一致。
2. 确认变更日志说明了兼容性和迁移行为。
3. 运行所有发布门禁，并将其证据附加或链接到变更评审。
4. 合并已评审的变更。
5. 在已评审提交上创建带注释的 `vVERSION` 标签。
6. 使用对应的变更日志条目发布 Release Notes。
7. 验证全新安装，并验证从上一个受支持版本升级。

## 回滚

不要移动或复用现有发布标签。应在新的补丁版本中修复问题。目标 Workspace
会保留本地修改和 retired 文件，因此应用修正版升级前需要审查其安装清单。
