# Template: analyze-trace
# Variables: {LANGUAGE}, {ASYNC_SECTION}, {ROOT_CAUSE_TYPE_HINT}, {NEXT_SKILLS}
#
# Language skill files that use this template keep their frontmatter and
# language-specific $ARGUMENTS section, and declare: template: analyze-trace

Parse and explain the provided {LANGUAGE} stack trace / error.

Rules:
- Do NOT emit a "Fix" section until Root Cause is complete
- Trace full execution path: inputs → transformation → outputs

Steps:
1. Identify the error/exception type and message
2. Walk the stack from origin to failure point
3. Identify the exact line and why it failed
4. Distinguish root cause from propagation chain
{ASYNC_SECTION}

Output:
- **Failure**: type and message
- **Root cause location**: file:line
- **Root cause explanation**: why it happened ({ROOT_CAUSE_TYPE_HINT})
- **Suggested next step**: fix, or run {NEXT_SKILLS}
