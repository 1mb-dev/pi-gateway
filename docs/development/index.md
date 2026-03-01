---
title: Development
nav_order: 5
has_children: true
layout: default
---

# Development

Contributing to Pi Gateway, extending functionality, and working with the codebase.

## Guides

- **[Extensions]({{ site.baseurl }}/development/extensions/)** — Building custom extensions for Pi Gateway

## Development Setup

Clone the repository and run tests:

```bash
git clone https://github.com/1mb-dev/pi-gateway.git
cd pi-gateway
make test      # Run all tests
make lint      # Check code quality
```

## Contributing

Contributions are welcome. To get started:

1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Run `make test` and `make lint`
5. Submit a pull request

See the [GitHub repository](https://github.com/1mb-dev/pi-gateway) for contribution guidelines.

## Related

- **How the system works** → [Architecture]({{ site.baseurl }}/guides/architecture/)
- **Full technical context** → [Knowledge Transfer]({{ site.baseurl }}/reference/knowledge-transfer/)
