# 阶段门禁与状态规则

## 通用规则

每个阶段都必须具备明确输入、产物和审核证据。只有满足完成条件后，才能在
`.codex/workspace-status.md` 中勾选对应项目。

| 阶段 | 必要输入 | 主要产物 | 完成条件 |
|---|---|---|---|
| Skeleton | 完整工作流发布、目标路径 | 安装资产、manifest | 安装无冲突且状态为 NOT_READY |
| Discovery | 全部在范围内的目录 | workspace-inventory | 所有 Git 边界和工具链已记录 |
| Repository | inventory、源码和配置 | repository-map | 每个仓库均有证据支持的职责与依赖 |
| Architecture | repository-map、实现证据 | 根架构及架构视图 | 主要调用、数据、事件和运行时边界完整 |
| Domain | 模型、数据、事件和测试 | domain index及领域文档 | 规则、不变量和所有权可追溯 |
| Standards | 成熟实现、测试和配置 | standards 文档 | 现行、遗留、不一致和风险模式已区分 |
| Verification | 全部生成文档和源码 | verification report | 所有范围内文档已独立复核 |
| AGENTS finalization | 已验证文档和报告 | 最终 AGENTS、readiness | 命令与链接有效，剩余缺口明确 |

## 动作权限

- 初始化阶段：只修改工程文档，不修改生产代码。
- Feature 需求、现状、影响、设计和计划阶段：只修改 Feature 文档。
- 只有实现计划得到人工批准后，才允许执行 `feature-implement.md`。
- 测试和 review 阶段默认只读；修复必须作为明确的新实现任务进行。
- Git commit、push、merge、tag 和部署需要用户或项目流程明确授权。

## 状态含义

- `NOT_INITIALIZED`：尚未基于目标代码生成。
- `DRAFT`：已开始但未批准。
- `NOT_READY`：存在阻塞缺口。
- `READY_WITH_GAPS`：已知缺口不阻塞当前范围，并已明确风险。
- `READY`：当前范围所需证据和门禁均已完成。
- `UNKNOWN`：没有足够证据得出结论。
- `UNCERTAIN`：存在证据，但结论仍不稳定。
- `NEEDS_VERIFICATION`：已有判断尚待指定验证。
- `BLOCKED`：缺少外部输入、权限或环境，当前无法继续。

状态描述不能替代证据；任何 `PASS` 都必须对应实际运行的命令或检查记录。
