---
title: Development
nav_order: 5
has_children: true
---

# Development

Contributing to Pi Gateway, extending functionality, and working with the codebase.

## For Contributors

- **[Contributing Guide](contributing/)** — How to contribute to the project
- **[Testing Strategy](testing/)** — Test frameworks and how to write tests
- **[Architecture Deep-Dive](architecture-decisions/)** — Design decisions and rationale
- **[Knowledge Transfer](knowledge-transfer/)** — Comprehensive development guide

## For Extension Developers

- **[Extensions API](extensions/)** — Building custom extensions
- **[Extension Examples](extension-examples/)** — Reference implementations

## For Maintainers

- **[Release Process](releases/)** — How to make a release
- **[Maintenance Guide](maintenance/)** — Long-term project maintenance
- **[Security Policy](security-policy/)** — Vulnerability reporting

## Getting Started with Development

1. **First time?** → Read [Contributing Guide](contributing/)
2. **Want to write a test?** → Check [Testing Strategy](testing/)
3. **Need to understand design?** → Review [Architecture Decisions](architecture-decisions/)
4. **Building an extension?** → See [Extensions API](extensions/)
5. **Want more context?** → Read full [Knowledge Transfer](knowledge-transfer/)

## Development Setup

Clone the repository and run tests:

```bash
git clone https://github.com/1mb-dev/pi-gateway.git
cd pi-gateway
make test      # Run all tests
make lint      # Check code quality
make dev-setup # Set up development environment
```

## Questions?

- **How does the system work?** → [Knowledge Transfer](knowledge-transfer/)
- **What's the architecture?** → [Architecture Decisions](architecture-decisions/)
- **How do I test my changes?** → [Testing Strategy](testing/)
- **How do I contribute?** → [Contributing Guide](contributing/)
- **How do I make a release?** → [Release Process](releases/)
