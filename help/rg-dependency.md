# rg-dependency

This topic documents the optional `rg` dependency declared by the demo package.

The dependency is intentionally non-essential:

- it exists to test dependency download and cleanup
- it does not block the skill when missing
- it stays skill-local and does not use any shared installation path

Use `rg-check` when you want to verify:

- the expected local dependency path
- whether the binary exists after installation
- whether `rg --version` can run from that path
