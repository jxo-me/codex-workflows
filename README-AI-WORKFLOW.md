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
