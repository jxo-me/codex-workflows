# Feature Engineering Records

Each feature uses:

FEATURE-ID/
├── 00-source/
├── 01-requirement.md
├── 02-current-system.md
├── 03-impact-analysis.md
├── 04-solution-design.md
├── 05-implementation-plan.md
├── 06-test-plan.md
├── 07-delivery-checklist.md
└── 08-retrospective.md

Create the detailed, backward-compatible profile with:

    ./scripts/feature-init.sh FEATURE-ID

Create the concise profile for routine changes with:

    ./scripts/feature-init.sh --profile compact FEATURE-ID

Both profiles preserve the same eight-stage lifecycle and filenames, so prompts
and review gates remain compatible.

Prompt mapping:

1. `feature-start.md`
2. `feature-current-system.md`
3. `feature-impact.md`
4. `feature-design.md`
5. `feature-plan.md`
6. `feature-implement.md`, followed by `feature-test.md`
7. `feature-review.md`, followed by `feature-delivery.md`
8. `feature-retrospective.md`

Chinese operating instructions are available in
`docs/guides/feature-development.zh-CN.md`.
