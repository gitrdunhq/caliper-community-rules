# Content Rules

Rules for spelling, documentation quality, and internationalization.

## Threat model

Misspelled variable names cause bugs. Misspelled UI strings erode user trust. Missing translations break international deployments. These rules enforce content quality deterministically.

## What belongs here

- **Spelling** -- custom dictionaries for domain-specific terms
- **Documentation** -- required sections, formatting standards
- **i18n** -- missing translation keys, hardcoded strings

## Scanners

| Directory | Scanner | File format |
|-----------|---------|-------------|
| `typos/` | typos | `_typos.toml` config files (extend-words, allowlists) |
