# Template: check-async
# Variables: {LANGUAGE}, {ASYNC_MODEL}, {CONCURRENCY_CHECKS}, {NEXT_SKILLS}
#
# Language skill files that use this template keep their frontmatter and
# language-specific $ARGUMENTS section, and declare: template: check-async

Review the provided {LANGUAGE} code for async/concurrency issues specific to the {ASYNC_MODEL} model.

Rules:
- Trace all async call paths completely before reporting
- Distinguish runtime bugs from design smells

Checks:
{CONCURRENCY_CHECKS}

Output per issue:
- **Location**: file:line
- **Issue type**: (e.g. unhandled rejection, race condition, deadlock, missing await)
- **Description**: what will go wrong and why
- **Suggested fix**: concrete corrective action
- **Suggested next step**: fix, or run {NEXT_SKILLS}
