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
