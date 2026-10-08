# Smootify skills

Skills for AI agents that build stores with [Smootify](https://www.smootify.io), the official integration between
Webflow and Shopify. They follow the Smootify 2.0 markup contract and glossary, so your agent writes the elements and
attributes Smootify reads, and checks them.

> **Beta.** This is `2.0.0-beta.1`: the skills are being tested on real projects. Expect changes before 2.0.0.

| Skill | What it does |
|---|---|
| [`figma-annotate-smootify`](skills/figma-annotate-smootify) | Prepares a Figma design for Webflow and Smootify: which components to build, their props and bindings, the Smootify elements inside them. Writes it all into the file as Dev Mode annotations, and asks when the design does not settle a choice. |
| [`figma-to-webflow-smootify`](skills/figma-to-webflow-smootify) | Builds Webflow components from the annotated design, with the Figma and Webflow MCP servers, and checks every binding. |
| [`smootify-site-audit`](skills/smootify-site-audit) | Audits a Smootify site: the version it loads, every element against the contract, the published pages, the store's unused features. Writes a report. |
| [`smootify-iterate`](skills/smootify-iterate) | Answers the review notes of Smootify Studio's Iterate: finds the cause, fixes the site in Webflow when the site is the cause, and writes the cause and its confidence back into the note. |
| [`smootify-custom-script`](skills/smootify-custom-script) | Writes and changes a site's custom scripts on the public `window.Smootify` API, its events and filters. Smootify Studio loads it for you. |

They work best with the [Smootify MCP](https://www.smootify.io/developers/mcp), which checks markup and pages against
the same contract.

## Install

### Claude Code

```bash
claude plugin marketplace add smootify/skills
claude plugin install smootify@smootify
```

Or, inside a session: `/plugin marketplace add smootify/skills`, then `/plugin install smootify@smootify`. The skills
load as `/smootify:figma-annotate-smootify` and so on, and Claude uses them when a task calls for them.

**MCP servers.** The plugin adds the Smootify MCP and the Webflow MCP, and installs Figma's official plugin
(`figma@claude-plugins-official`) with the Figma MCP. Sign in to each the first time from `/mcp`. A server you already
have at the same URL is used once, not twice.

**Updates.** Claude Code installs a new copy when the plugin's version changes. Run
`claude plugin marketplace update smootify`, or turn on auto-update for the marketplace in `/plugin`.

### Claude on the web and desktop

Download the zip of a skill and upload it in **Settings → Customize → Skills**:

| Skill | Zip |
|---|---|
| Figma annotation | [figma-annotate-smootify.zip](https://cdn.smootify.io/skills/beta/figma-annotate-smootify.zip) |
| Figma to Webflow | [figma-to-webflow-smootify.zip](https://cdn.smootify.io/skills/beta/figma-to-webflow-smootify.zip) |
| Site audit | [smootify-site-audit.zip](https://cdn.smootify.io/skills/beta/smootify-site-audit.zip) |
| Iterate | [smootify-iterate.zip](https://cdn.smootify.io/skills/beta/smootify-iterate.zip) |
| Custom script | [smootify-custom-script.zip](https://cdn.smootify.io/skills/beta/smootify-custom-script.zip) |

`beta` always holds the latest beta; each version also stays at its own address, such as
`https://cdn.smootify.io/skills/2.0.0-beta.1/figma-annotate-smootify.zip`. To update, upload the new zip in place of the
old one. On a Team or Enterprise plan, an admin can provide them to the whole organization from this repository.

### Other agents

Each skill is a folder with a `SKILL.md`: copy it where your agent reads skills.

## Versions

The plugin's version is in `.claude-plugin/plugin.json` and in [CHANGELOG.md](CHANGELOG.md). Each release has a tag and
a GitHub release with the zips. Betas (`2.0.0-beta.N`) come first; `2.0.0` follows once the skills have held up on real
stores.

## License

[Apache 2.0](LICENSE).
