# Template: detect-bugs
# Variables: {LANGUAGE}, {LANGUAGE_PATTERNS}, {NEXT_SKILLS}
#
# Language skill files that use this template keep their frontmatter and
# language-specific $ARGUMENTS section, and declare: template: detect-bugs

Statically analyse the provided {LANGUAGE} code to identify likely bugs before they surface at runtime.

Rules:
- Distinguish confirmed bugs (will fail) from likely bugs (may fail under certain inputs)
- Do not report style issues — focus on correctness

Checks:
- Off-by-one errors and boundary conditions
- Null / nil / None dereferences
- Unhandled error / exception paths
- Incorrect boolean logic or operator precedence
- Resource leaks (file handles, connections, goroutines)
{LANGUAGE_PATTERNS}

Output per bug:
- **Location**: file:line
- **Severity**: confirmed | likely
- **Description**: what will go wrong and under what condition
- **Suggested fix**: minimal corrective action
- **Suggested next step**: fix, or run {NEXT_SKILLS}
