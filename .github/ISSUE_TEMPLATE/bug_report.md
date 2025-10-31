---
name: Bug Report
about: Report a bug or unexpected behavior
title: '[BUG] '
labels: bug
assignees: ''
---

## Bug Description
Clear description of the bug.

## Steps to Reproduce
1. Run command: `...`
2. Configure setting: `...`
3. Observe error: `...`

## Expected Behavior
What should happen.

## Actual Behavior
What actually happened.

## Environment
- **Pi Gateway Version:** (run `cat VERSION`)
- **Raspberry Pi Model:** (e.g., Pi 4 Model B 8GB)
- **OS:** (run `cat /etc/os-release | grep PRETTY_NAME`)
- **Installation Method:** (quick-install / manual / git clone)

## Logs
```
Paste relevant logs from:
- /tmp/pi-gateway-*.log
- sudo journalctl -u ssh
- sudo journalctl -u wg-quick@wg0
```

## Additional Context
Any other relevant information.
