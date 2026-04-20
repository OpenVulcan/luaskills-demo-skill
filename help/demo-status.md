# demo-status

Use `demo-status` when you want one stable JSON response that proves:

- the skill loaded correctly
- the current skill directory is resolved
- the request context reached the skill runtime
- the package can be called after install or update

Suggested checks:

- call it immediately after installation
- call it again after an update
- compare the `skill_dir` and `timestamp` values
