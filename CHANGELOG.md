# Changelog

## 2.0.0-beta.1

First public release of the Smootify 2.0 skills, as a beta: they follow the Smootify 2.0 markup contract and glossary,
and are still being tested on real projects.

- `figma-annotate-smootify`: prepares a Figma design for Webflow and Smootify, and writes its decisions into the file
  as Dev Mode annotations.
- `figma-to-webflow-smootify`: builds Webflow components from the annotated design, with the Figma and Webflow MCP
  servers.
- `smootify-site-audit`: audits a Smootify site and reports what is broken, what is fragile and what the store could
  use. Replaces the 1.x `smootify-auditor` (repository `smootify/website-checker-skill`).
- `smootify-custom-script`: writes and changes the custom scripts of a Smootify site, the skill Smootify Studio loads.
