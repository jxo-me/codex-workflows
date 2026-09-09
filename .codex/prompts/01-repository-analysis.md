Analyze every repository identified in:

docs/architecture/repository-map.md

Do not modify production code.

For every repository determine:

1. responsibility
2. entry points
3. public interfaces
4. internal packages
5. database usage
6. Redis usage
7. MQ usage
8. external service dependencies
9. shared libraries
10. configuration
11. tests
12. observability
13. deployment artifacts

Do not infer responsibility from repository names alone.

Evidence hierarchy:

1. implementation
2. tests
3. schemas
4. configuration
5. documentation
6. naming

For every important claim provide:

repo/path:symbol

Update:

docs/architecture/repository-map.md

At the end include:

UNKNOWN
UNCERTAIN
POTENTIAL_COUPLING
NEEDS_VERIFICATION