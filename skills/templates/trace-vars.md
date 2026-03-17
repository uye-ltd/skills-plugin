# Template: trace-vars
# Variables: {LANGUAGE}, {RUNTIME_NOTES}, {NEXT_SKILLS}
#
# Language skill files that use this template keep their frontmatter and
# language-specific $ARGUMENTS section, and declare: template: trace-vars

Trace variable state through the provided {LANGUAGE} code to identify where a value diverges from expected.

Rules:
- Focus on the execution path leading to the failure, not the whole file
- Record each transformation of the target variable(s)

Steps:
1. Identify the variable(s) under investigation
2. Trace each assignment, mutation, and read in execution order
3. Identify the first point where the value becomes incorrect
4. Note any aliasing, shadowing, or unexpected mutation
{RUNTIME_NOTES}

Output:
- **Variable(s) traced**: name and expected type
- **Divergence point**: file:line — first incorrect value
- **Cause**: assignment, mutation, aliasing, or missing initialisation
- **Suggested next step**: fix inline, or run {NEXT_SKILLS}
