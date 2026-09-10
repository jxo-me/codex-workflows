# 变更日志

[English](CHANGELOG.md) | [简体中文](CHANGELOG.zh-CN.md)

所有重要的工作流变更都记录在这里。版本遵循语义化版本规范，日期采用
ISO 8601 格式。

## [未发布]

## [0.4.0] - 2026-09-10

### 新增

- 中文首次使用、Workspace 初始化、阶段门禁、Feature 开发和故障排查手册。
- 独立的 AGENTS 最终化、实现计划、测试执行和复盘知识沉淀提示词。
- 独立的 Workspace discovery inventory 产物。

### 变更

- 初始化提示词现在会定义阶段产物、完成条件和
  `.codex/workspace-status.md` 状态转换。

## [0.3.0] - 2026-09-10

### 新增

- 发布一致性验证和发布门禁文档。
- ShellCheck 和 actionlint CI 门禁。
- 使用可审计的 `retired` 清单记录，保存被新版工作流移除的受管资产信息。
- 目标路径范围检查，拒绝通过符号链接逃逸出 Workspace。

### 变更

- 升级清单改用格式 2，同时保持读取格式 1 的能力。
- 升级会拒绝格式错误的清单、重复记录、不安全路径、重复版本、同版本安装
  和降级。

## [0.2.0] - 2026-09-10

### 新增

- 基于版本和校验和保护的工作流安装与升级。
- 分离源码仓库状态和目标 Workspace 初始化状态。
- Compact 和 Extended Feature 模板档位。
- GitHub Actions 冒烟验证。

## [0.1.0] - 2026-09-10

### 新增

- 可感知冲突的安装器和原子化 Feature 初始化。
- Repository Analysis、Impact Analysis 和 Code Review Skills。
- Feature 生命周期提示词、工程标准骨架和多 Go Module 检查。
