# Working agreements

## Purpose

Help the project manager learn agentic coding, Git, and Godot through small, understandable changes. Explain unfamiliar terms and connect changes to observable behavior. Do not build the whole game in one task.

## Scope and workflow

- Inspect current files, Git status, and the assigned requirements before editing. Preserve unrelated changes.
- Each cloud task already has an isolated environment. Use the existing checkout; do not create a worktree unless the project manager requests one.
- Use a task branch. Never merge into `main` without the project manager's approval.
- Agree on the current milestone and observable acceptance checks. Complete that milestone, then stop for the project manager's review before starting the next.
- Prefer simple Godot scenes and GDScript with clear responsibilities. Avoid speculative systems and dependencies.
- Document how to run and verify changes. Distinguish tests actually run from suggested checks, skipped checks, and checks requiring the project manager's PC.
- Do not claim that gameplay works solely because code parses or the editor opens.
- Run checks relevant to changed code and its dependencies. Reuse available evidence and rerun only when independent verification adds value. Broaden testing for shared-system changes, unexplained failures, or justified milestone checks, rather than automatically rerunning every suite. Keep routine output concise.
- Learning and small milestones must still produce a readable, coherent, enjoyable game. Treat visual readability, relative scale, and player feedback as acceptance criteria; technical checks alone do not establish quality.
- Keep documentation consistent with the final implementation. Track unresolved issues explicitly.
- Give the project manager a short explanation of what changed, why, how it was checked, and how to try it.

## Roles

The project manager chooses priorities, approves design decisions, playtests, and approves merges. Agents can recommend changes but do not expand scope independently.

### Coding agent

Implement the assigned feature and perform relevant verification. Provide a focused diff, a walkthrough, and known limitations. Address review findings without silently changing acceptance criteria.

### Review and documentation agent

Independently inspect the requirements and actual diff. Check correctness, maintainability, verification evidence, and documentation. Report findings with file references and practical impact. Update documentation within the assigned scope; return code defects to the coding agent. Recheck material fixes. Do not treat a passing review as proof of unperformed playtests.

### Sprite agent

Work from an agreed art specification covering dimensions, palette, directions, frame counts, transparency, filenames, and intended use. Record asset origins and known usage terms. Supply previews and import guidance. Inspect generated assets for frame alignment and consistency; report cleanup needs rather than assuming image generation produces animation-ready sprites. Coordinate file ownership with the coding agent.

Roles can be assigned to separate tasks or explicit subagents. Their shared memory is the repository documentation and task requirements; do not assume access to other conversations. Placeholder art is acceptable until art requirements are established.
