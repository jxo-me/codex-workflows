# Feature 开发操作手册

开始前，Workspace 应为 `READY` 或经批准的 `READY_WITH_GAPS`。

## 1. 准备输入并创建目录

选择模板：复杂、跨仓库或高风险变更使用默认 `extended`；范围明确的常规
变更可使用 `compact`。

```bash
./scripts/feature-init.sh FEATURE-ID
./scripts/feature-init.sh --profile compact FEATURE-ID
```

将需求、原型、接口、事件、数据库和约束材料放入
`docs/features/FEATURE-ID/00-source/`，保留来源和版本信息。

## 2. 分析和设计

依次执行，每个提示词都需要替换 `{{FEATURE_ID}}`：

1. `feature-start.md`：生成 `01-requirement.md` 和 Given/When/Then 验收条件。
2. `feature-current-system.md`：生成 `02-current-system.md`。
3. `feature-impact.md`：生成 `03-impact-analysis.md`。
4. `feature-design.md`：生成 `04-solution-design.md`。
5. `feature-plan.md`：生成 `05-implementation-plan.md`。

设计和计划必须经过人工批准。存在 `NEEDS_CONFIRMATION`、关键
`UNKNOWN`、未决兼容性或回滚问题时，不得进入实现。

## 3. 分任务实现

对计划中的每个任务单独执行 `feature-implement.md`，同时提供
`FEATURE_ID` 和 `TASK_ID`。一次只实现一个获批任务，并在该任务结束时记录：

- 修改的仓库、文件和行为；
- 实际执行的检查及结果；
- 未完成项和剩余风险；
- 是否需要调整设计或计划。

如果实现发现需求或设计错误，应返回对应阶段更新文档并重新批准，不要在
代码中静默改变契约。

## 4. 测试与独立审查

执行 `feature-test.md`，更新 `06-test-plan.md` 并记录真实验证证据。随后执行
`feature-review.md`，独立检查 diff、调用链、兼容性、安全、数据一致性、
并发、回滚和验收标准覆盖。

Review 发现需要修改代码时，新建或恢复明确的实现任务；修复后重新运行相关
测试和 review。

## 5. 交付

执行 `feature-delivery.md`，更新 `07-delivery-checklist.md`。至少确认：

- API、数据库和事件兼容性；
- 多仓库部署顺序和迁移顺序；
- 回滚触发条件和数据恢复方式；
- 指标、日志、告警和生产验证步骤；
- 所有跳过、阻塞和接受风险均有负责人。

交付决策只能是 `NOT_READY`、`READY_WITH_ACCEPTED_RISK` 或 `READY`。

## 6. 复盘和知识沉淀

交付后执行 `feature-retrospective.md`，更新 `08-retrospective.md`。将已经由
交付行为证明的可复用知识回写到：

- `docs/architecture/`
- `docs/domain/`
- `docs/standards/`
- `docs/adr/`
- `docs/runbooks/`

不要仅因方案中曾经计划某项行为，就把它写成系统事实。
