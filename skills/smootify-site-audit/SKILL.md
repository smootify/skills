---
name: smootify-site-audit
description: Audits a Webflow project that uses Smootify and reports what is broken, what is fragile, and what the store is paying for but not using. Activates when the user asks to review, audit, debug or "check" a Smootify project — whether they give a Webflow site id, a published URL, or a sandbox link. Supersedes the older smootify-auditor skill.
---

# Smootify site audit

Audits Webflow projects built with Smootify, the official Webflow + Shopify integration.

This is the successor to `smootify-auditor`. Two things changed. It reads the project **itself** — over the
Webflow MCP and, when a published URL exists, from the published pages — instead of asking a human to paste a
sandbox link and describe the symptom. And its structural rules come from `references/rules.json`, generated
from three sources: Smootify's markup contract (tags and their contexts, written from the 2.0 sources), the
Smootify glossary (attribute values) and the 2.0 sources (state classes, events, public API).

## With the Smootify MCP: use it first

When the **Smootify MCP** is connected (`https://mcp.smootify.io/mcp`, tools such as `audit_page`,
`check_markup`), its engine runs the checks below deterministically, with the same `rules.json` and glossary.
Use it instead of applying the rules by hand:

- **Published URL:** `audit_site` (or `audit_page` per page). It covers the version, the options, the link bases,
  the markup, the custom code, the pixels and the licence, with one finding per cause. It takes its pages from
  `sitemap.xml`, or without one from the links of the page you give it: check that it reached a product page, a
  collection page and the cart, and pass the missing ones to `audit_page`.
- **Webflow site in the Designer:** read the page tree with the Webflow MCP and pass it to `check_markup` as an
  `outline` (`{tag, type, attributes, children}`). For a component, pass it with `pastedInside`.
- **Symptom only:** `diagnose` with the symptom and, when there is one, the page URL.
- **Store questions** (metafields empty, swatches missing): `probe_storefront` on the product page.

Report its findings as they are: severity, message, fix, where. Its `source` names the rule, not a page the user
can open: cite `contract §1 <tag>` as the element's page (`reference` of that tag in `rules.json`,
`https://www.smootify.io/docs/reference/elements/<tag>`), `glossary <group>` as
`https://www.smootify.io/docs/reference/attributes/<group>` (conditions: `/docs/reference/conditions/<group>`), and
MIGRATION / BREAKING-CHANGES / CHANGELOG as the public pages in principle 2. Then apply the rules of this skill
**only** to what the report lists under `coverage.notChecked`, and to the audit parts the MCP does not have yet: the
support checklist (images without CDN sizing, search & discovery limits…), the runtime audit (B) and the account and
extension usage. Without the MCP, apply everything below by hand.

## Operating principles

1. **Structure comes from `rules.json`.** `references/rules.json` is the authority on which tags exist, what
   each must be nested inside, and which attribute values are legal. Never invent a tag or an attribute: if it
   is not in `rules.json`, it does not exist.
2. **Every claim about behaviour cites a source the user can open.** For a 2.0 site:
   - an element: its page, the `reference` of the tag in `rules.json`
     (`https://www.smootify.io/docs/reference/elements/<tag>`); an attribute value: the `reference` of its entry in
     `attributes` (`https://www.smootify.io/docs/reference/attributes/<group>`, conditions under
     `/docs/reference/conditions/<group>`), or the glossary itself (`https://cdn.smootify.io/components-v2/glossary.json`);
   - what 2.0 removed, renamed or changed: `https://www.smootify.io/docs/start/changes`; moving a 1.x site, the URL
     defaults and the options: `https://www.smootify.io/docs/start/migrate`; what is new:
     `https://www.smootify.io/changelog/2-0`; the debugger: `https://www.smootify.io/docs/start/debugger`; image
     sizes and loading: `https://www.smootify.io/docs/start/performance`; everything else through
     `references/doc-map.md`.
   - Every page of `https://www.smootify.io/docs/` is fetchable as markdown by adding `.md` to its path
     (`https://www.smootify.io/docs/start/changes.md`).
   - **docs.smootify.io** describes 1.x: cite it only when the site runs 1.x.

   Fetch, then explain, then cite. Do not paraphrase from memory, and never cite a file the user cannot open.
3. **No general-knowledge fallback.** Do not answer Smootify questions from training knowledge about Webflow
   or Shopify. If none of the sources above covers it, say so and point to the Discord:
   `https://discord.com/invite/MKeQqEZmjd`.
4. **Report what you actually checked.** If a check could not run — no published URL, no MCP access, a page
   you could not read — say so in "Not checked". Never let an unrun check read as a pass.
5. **Match the user's language.** Attribute and tag names stay in English.

## Getting access

Ask for whichever of these the user has. More is better, but one is enough to start:

- **Webflow site id or site name** — enables the **MCP mode** of the structural audit. The best input.
- **Published URL** (`*.webflow.io` or the custom domain) — enables the **published HTML mode** of the
  structural audit and the runtime audit.
- **CMS collection slugs** for Products, Collections and Vendors, if they differ from the defaults. The 2.0
  defaults are `products`, `collections`, `vendors` (1.x: `product`, `collection`, `vendor`). Non-default slugs
  must also be declared in the Smootify options script (`productsBase`, `collectionsBase`, `vendorsBase` in
  `SmootifyUserOptions`), and that mismatch is a common cause of 404s and empty data — including on a 1.x site
  moved to 2.0 whose CMS collections are still singular.

If the user only describes a symptom with no access, fall back to `references/support-checks.md` and targeted
questions — that is the old skill's mode, and it still works.

### The two modes of the structural audit

- **MCP mode** (site id). Read the project with `data_pages_tool` and `data_element_tool` (custom code with
  `data_scripts_tool`). You see the Designer tree: elements, their attributes, components, and which CMS field
  an attribute or a `data-id` is bound to — but not bound values, and not what the runtime clones.
- **Published HTML mode** (URL only). Fetch the published pages — at least home, a product page, a collection
  page, the cart page if any — and audit the static HTML. CMS bindings are already resolved: a `data-id` shows the
  actual id, not the field; a Collection List appears as many `.w-dyn-item` copies of the same markup (which is
  why findings are grouped, see below). Smootify has not run in fetched HTML, so there are no state classes, no
  cloned lines, no rendered values: judge the markup, not its output. Pages not reachable from the site's links
  (templates of empty collections, password pages) stay in "Not checked".

Say in the report which mode you used. When both are available, run MCP mode and use the published HTML to
confirm bindings resolve (an empty `data-id` in the HTML is a CMS item with no Shopify ID).

## What to run

### 0. Version gate — first, before any rule

Read which Smootify the site loads — only from the `src` of `<script>` tags and the `href` of stylesheet
`<link>`s (published HTML `<head>`, or the site's custom code over MCP), never from inline script text, which
can mention other versions (a local-build switch, a comment):

- `cdn.smootify.io/assets/v2/…` (the 2.0 loader) → the site runs **2.0**: apply the rules as below.
- `cdn.smootify.io/assets/latest/…` (`assets/latest/js/index.js`, `assets/latest/css/index.css`) → the site
  runs **1.x**. Say so at the top of the report. `rules.json` describes 2.0, so present its structural findings
  under **"Moving to 2.0"**: what breaks or changes when this site switches to the 2.0 loader, not current bugs.
  They do not subtract from the score. The support checks and the runtime audit still report current defects,
  judged against 1.x (cite docs.smootify.io).
- Neither found → no Smootify script: that is the first blocker (support check 2), and the rest is "Not checked".

Then two mismatches between the loader and the site, each **one blocker**, not a list of defects:

- **2.0 markup on a 1.x loader.** The loader is `assets/latest` but the page carries markup only 2.0 knows: any
  selector of `onlyIn2` in `rules.json` (`smootify-consent`, `[popover][data-is="market-dialog"]`,
  `[product="gallery"]`, `booking-calendar`…). Report one error, "2.0 markup on the 1.x loader: switch the loader",
  with what that markup does on 1.x today (a cookie banner designed in Webflow shown open next to Shopify's, a gallery
  that stays empty…). The rest of the structural findings stay under "Moving to 2.0".
- **Link bases that do not match the loader** (support check 2): 1.x builds `/product/…`, `/collection/…`,
  `/vendor/…` links, 2.0 `/products/…`, `/collections/…`, `/vendors/…`. CMS pages on the other form, with no
  `productsBase` / `collectionsBase` / `vendorsBase` in `SmootifyUserOptions`, mean every link Smootify writes is a
  404. Count it once, whichever direction.

### A. Structural audit

For every page that contains Smootify elements, check against `rules.json`:

- **Nesting.** §1 of the contract is written from the 2.0 sources, and each entry of `tags` carries it:
  `context.requiresAncestorOneOf` (selectors, one of which must be an ancestor — a combination like
  `smootify-add-to-cart smootify-product` means that chain, `.w-slider` or `details` are plain selectors),
  `context.notInside` (selectors it must not be inside, e.g. `.w-condition-invisible`) and `context.anywhere`. What
  a broken context does is in `outsideContext`: `effect` `removed` (the element takes itself out of the page — an
  **error**), `inert` (it stays and does nothing — a **warning**) or `error`, with `debugger: true` when the
  2.0 debugger reports it too, and a `detail` to quote. A host listed in `scopeExtensions` widens its content: for
  `smootify-search-discovery[data-expand]`, the elements its selector matches (an off-canvas filter panel) count
  as inside the host. Some entries are selectors, not tag names (`smootify-product[data-id="wishlist"]`,
  `[policy]`, `button[data-is="direct-add-to-cart"]`, `selector: true`): match them as selectors.
- **Required descendants.** `context.mustContain` must all be there (e.g. `smootify-add-to-cart` must contain a
  `form`), and one of `context.mustContainOneOf` (e.g. `variant-popover`: `[popover] a` or
  `[popover] button:not([popovertarget])`). `context.mustContainWhen` adds children only for one form of the
  element: an `edit-address` with a `select[name="countryCode"]` also needs the zone select, while one without it is
  a "Set as default" form and needs only its `form`. A missing one follows `outsideContext` too.
- **What it needs.** `requires` lists the plan (`plan: "server"`), the licence extensions (`extensions`, the names
  of the licence field `a`) and Customer Accounts (`accounts`). The licence and the accounts setting are not in
  the HTML: list them under "Not checked" unless the licence was read.
- **Marker tags.** Entries with `kind: "marker"` (`registered: false`) are templates the elements in `readBy`
  clone or fill (`cart-item`, `store-location`, `search-result`, `line-item`…); they must exist in the markup,
  inside their `context`. A cart with no `cart-item` renders nothing.
- **Removed tags.** An entry with `kind: "removed"` (`removed: true`: the classic-account forms, `smootify-prop`,
  `add-to-wishlist`, `sm-debugger`…) does nothing on a 2.0 site; `replacement` names what to use instead.
- **Unknown tags.** A custom tag that looks like Smootify's (`smootify-*`, or a prefix Smootify uses) and is not
  in `tags` is a finding. If `tags` has entries with `origin: "glossary"` (named by the glossary, not by the
  contract), they are known: never report them as unknown.
- **Attribute values.** The vocabularies come from the Smootify glossary
  (`cdn.smootify.io/components-v2/glossary.json`), the same file the Designer App and the Figma skills read.
  A value used with an attribute listed in `bindings` (`product=`, `variant=`, `cart=`, `cart-item=`,
  `condition=`, `data-action=`, `upload=`, `gallery=` and the rest) must appear in that list or among an entry's
  `aliases` (other spellings 2.0 reads the same way); a typo is silent — the element just stays empty — so this
  check catches bugs nobody reports. An entry marked `deprecated` still works and names its replacement.
  `variation=` is not valid markup, only `variant=` works: treat a `variation=` attribute as a finding.
- **Where a value goes.** Each entry of `attributes` says where it works (`inside`: the Smootify elements
  that must be an ancestor, outermost first; empty = anywhere) and on what (`on`). For **`data-action=`** values
  only (and for `button[...]` selectors the contract names), `button` means an element with the button tag: a
  Webflow Button is a link and a Form Button an input, and a `data-action=` on either does nothing — unless the
  entry's `on` also lists `link` (the consent banner's actions, for example, work on any element). For every
  other attribute `on` is a hint about the usual element, not a requirement: `skeleton="button"` on a link is
  fine.
- **Generic attribute names.** Entries marked `generic: true` (`name`, `type`, `data-name`, `data-wait`,
  `property`, `index`, `data-type`, `data-format`, `data-required`) use names every page uses for its own reasons:
  Webflow writes a `data-name` on every field and a `data-wait` on every submit, and `name="email"` is in every
  newsletter and contact form. They are never "outside their place": check them only where one of their entries is
  in place (its `inside` matches), and there only what they need to work (`name="buy-now"` on an element with the
  button tag). A `name="email"` outside a `booking-form`, a `name="note"` outside the cart, a `data-wait` on any
  submit: not findings.
- **Submit buttons tied with `form=`.** A `[type="submit"][form="<id>"]` outside its form (a sticky add-to-cart
  bar) submits the Smootify form whose `id` is that value, and gets its `data-state`, `data-wait` and disabled state.
  Check that the page has exactly one element with that id and that it is a `form`. No match: the button submits
  nothing — an **error**, whatever else is said about its children (Webflow names a Form Block's form
  `wf-form-<Name>`, so a bar written for `product-form` points nowhere unless the form's ID was set). Two elements
  with that id: a **warning**.
- **Skeleton.** In 2.0 every element Smootify renders into loses its `[skeleton]` (and so do the hosts and the
  repeated rows), so a `[skeleton]` is never a finding by itself: on an element Smootify does not write (a
  `smootify-product[data-id="loader"]` placeholder, a `smootify-metaobject[data-handle="load"]` waiting for a
  script) it is the designer's choice. On a 1.x site, placeholders on account, policy, wishlist-count,
  store-location and box-item elements stayed forever: report them under "Moving to 2.0" (fixed there).
- **Loaders.** `smootify-product[data-id="loader"]` is a design tool, not leftover markup: CMS lists that search &
  discovery, the search page and the sliders fill later. `rules.json` gives it a context, as the contract does, but
  a loader outside it is never a finding: never report it, and never suggest removing it.
- **Host attributes.** An attribute listed in a tag's own `hostAttributes`, on that tag, is checked against those,
  not against glossary entries of other elements with the same name (`data-buy-now` on
  `smootify-magic-box-cart` is its own option, not the buy-again one). `ancestorAttributes` are read on the
  ancestor named in `on` (`single-addon-swatch` on `smootify-add-to-cart`), and `writes` are the attributes
  Smootify sets itself: never report those as the designer's.
- **Server-plan elements.** Tags with `serverPlanOnly: true` (elements only) are removed from the page unless the
  site is on the `server` plan. The markers they use (`input[type="file"]`, `[upload=…]`, `error-message`) go with
  their host: never list a marker, or a plain file input, as "removed without the server plan". The plan is not
  visible in the HTML or the Designer tree, so do not report them as findings: list them under "Not checked" —
  "<tags> found; if the site is not on the server plan, these are removed". That also explains a user's "my element
  disappeared".

#### Severities

Each rule type has a fixed severity. Use these, and state in the report which rule type produced each finding:

| Severity | Rule types |
|---|---|
| `error` | a value not in the vocabulary and not an alias · a `variation=` attribute · a `data-action` on something that is not an element with the button tag, where the entry's `on` is only `button` · a context or a required child missing where `outsideContext.effect` is `removed` or `error` · a removed tag |
| `warning` | an unknown Smootify-looking tag · a context or a required child missing where `outsideContext.effect` is `inert` · an attribute value outside its glossary `inside` · a value that needs a companion attribute it does not have (`with`) |
| `info` | a `deprecated` value (name the replacement) · an element inside a `notInside` selector (a Webflow condition hides it) · an `on` kind mismatch for anything other than `data-action` · an alias spelling (it works; suggest the canonical value) · in a fragment checked without its ancestors, a missing context ("paste it inside…") |

These are the severities the MCP engine uses: a report from `audit_page` or `check_markup` already carries them.

**Judge by effect, then by rule type.** A value not in the vocabulary is an `error` because the element stays
empty. When something else makes the element work, or the value only keeps an element as designed, it is `info`:

- `data-action="reset"` on a `button[type="reset"]`: the button's own type resets the form;
- an unknown `data-prop` or `location` value on a label inside a `country-switcher` or `location-switcher`
  toggle: Smootify leaves that element as designed, which keeps a fixed label ("Change ▾") in the toggle. Say so,
  and suggest `data-prop="name"` / `location="name"` only if the text should follow the country.

A submit tied with `form=` to a form id that does not exist is an `error` (see "Submit buttons tied with `form=`").

The support checks carry their own severity, mapped the same way: blocker → `error`, important → `warning`,
minor → `info`.

#### One finding per cause

Group occurrences by element + cause, not by rule. One group is one finding, with the number of occurrences,
the pages, and up to three example selectors. Two rules hitting the same elements for the same reason (a
`max-width` outside its `inside` and without its `with` on the same images) are one finding, counted once. A product card repeated forty times in a Collection List is one
finding with a count of forty, not forty findings. When many values fail for the same missing or wrong host —
every `market-dialog=` value in a dialog that is not `[popover][data-is="market-dialog"]`, every `data-prop` inside
a `location-switcher` — report the host once, with the values it carries, not one finding per value.

Then run the support checklist in `references/support-checks.md` — eleven checks distilled from real support
tickets (CMS structure, script order, image CDN compression, add-to-cart structure, cart, template pages,
Search & Discovery, Apple-device performance). Those are hand-won and still authoritative; do not skip them
because the structural pass was clean. Each one states its severity.

### B. Runtime audit — in the browser, only with a published URL

- Console errors and failed requests on a product page, a collection page and the cart.
- Which `smootify:*` events actually fire. `smootify:loaded` never firing means the script never booted;
  `smootify:product_loaded` missing on a PDP points at `data-id` or CMS binding.
- Whether `window.Smootify` exists and the licence resolved (a plan banner in the page is a strong signal).
- **Look at the page as a guest.** A screenshot of the home and of a product page, logged out, after Smootify has
  run: two cookie banners at once, a banner or panel shown open when it should not be, customer-only or
  company-only elements (prices for companies, a quote list) visible to a guest, blocks left empty. The static pass
  cannot see these; they are often the most visible defects.
- On a `.webflow.io` page running 2.0, the **debugger** (`?smootify-debug=1`,
  `https://www.smootify.io/docs/start/debugger`) helps with the runtime half. Its Components pane lists every
  Smootify element with its status (loaded, loading, not found, not running), including store-locator, the magic box
  tags, every server extension and the selector hosts (`[popover][data-is="market-dialog"]`,
  `button[data-is="preferences-button"]`, `[policy]`). Its Checks pane warns about the Customer Accounts key for
  all 18 account elements. Quote it, and still run the structural pass: it does not report everything (an element
  that removed itself is simply gone from the page), and when it and `rules.json` disagree, `rules.json` wins.
- If a defect comes from the runtime rather than the markup (the debugger or the page contradicts the reference
  for markup that is right), say which loader channel and version the page runs and report it as a runtime issue
  for Smootify, not as the site's.
- The site's custom code against the 2.0 surface in `rules.json` (with the MCP: `check_custom_code`, or
  `audit_page`, which checks the inline scripts): a listener on an event that is not in
  `documentEvents` or `elementEvents` never runs (`notEmittedDocumentEvents`, today `smootify:color_patterns`,
  is declared but never dispatched); a name in `deprecatedDocumentEvents` (`smootify_wishlist:*`) still fires
  but should move to `smootify:wishlist:*`; a `window.Smootify.<method>` call not in `publicApi` fails. CSS or
  interactions that target a state class not in `stateClasses` never apply. On a 1.x site these go under
  "Moving to 2.0".
- Page weight and Core Web Vitals on a product page, a collection page and the cart: the commercial pages, and the
  ones where cards and lines arrive late. Lab LCP over 2.5 s or CLS over 0.1 is a `warning` (lab numbers: say so,
  and that field data decides); a console error from Smootify or a failed Smootify request is a `warning`, an
  error at boot (`smootify:loaded` never fires) an `error`.
- Images served raw from the Shopify CDN without sizing parameters: support check 3.

### C. Opportunity checks — what the store is paying for and not using

This is the part the old skill did not do, and usually the most valuable to the reader. Report these
separately from defects: they are not errors.

Look for a capability the store's own data shows it needs, and a Smootify feature that would serve it:

- Products carrying `list.*` metafields rendered one-by-one, where `separator="repeat"` would clone the
  element per value.
- Metaobject references rendered as plain text, where `metaobject-url="/path/{handle}"` would link them.
- Hand-built "related products" collection lists, where a `smootify-product[data-id="related"]` or
  `"complementary"` needs no CMS at all.
- Add-ons producing separate cart lines where `use-magic-box` would produce one titled, imaged bundle line.
- Per-product option forms duplicated across templates, where `dynamic-property` would let the merchant
  define them in Shopify once.
- A configurator hand-wired in JavaScript, where `configurator-field[data-formula]` exists.
- Popovers built with the `popover` attribute on a div (no class `w-popover`, no `data-w-popover-mode`), where
  Webflow's native Popover element would give them **Animate open** and **Animate close** and Smootify drives it the
  same way: one opportunity for all of them, with the list of ids.

## Output

Lead with the Smootify version and the mode, then the score, then defects worst-first, then opportunities.
Always include the JSON block: it is what makes two audits of the same site comparable.

```
## Smootify audit — <site>

**Smootify <2.0 | 1.x>** · <MCP | published HTML | both> mode
<on 1.x: "This site runs Smootify 1.x. Structural findings are listed under 'Moving to 2.0': they describe
what changes when the site switches to the 2.0 loader, not current bugs.">

**Score: <0-100>** · <n> errors · <n> warnings · <n> info · <n> opportunities

### Errors
1. <name> — <rule type> · <count> occurrences
   - Where: <pages> → up to three example selectors
   - What is wrong:
   - Why it breaks:
   - Fix:
   - Reference: <public URL: the element or attribute page (`reference` in rules.json), /docs/start/changes,
     /docs/start/migrate, /changelog/2-0, or docs.smootify.io for a 1.x site>

### Warnings / Info
…

### Moving to 2.0 (1.x sites only)
…

### Opportunities
- <feature> — <what in this store's data suggests it> — <reference>

### Checks passed
…

### Not checked
- <check> — <why: no published URL, no MCP access, page unreadable>
- Server-plan elements: <tags> — if the site is not on the server plan, these are removed
```

Then:

```json
{ "site": "", "score": 0, "checkedAt": "YYYY-MM-DD",
  "smootify": "2.0|1.x", "mode": "mcp|html|both",
  "rulesVersion": "<rules.json generatedAt>",
  "findings": [{ "id": "", "severity": "error|warning|info|opportunity|migration",
                 "ruleType": "", "count": 0, "pages": [], "examples": [],
                 "rule": "", "reference": "" }],
  "notChecked": [] }
```

Scoring: start at 100; −15 per error, −5 per warning, counted per finding (per cause), not per occurrence.
Info, opportunities and "Moving to 2.0" items do not subtract. Floor at 0. State the arithmetic so the number is
arguable rather than oracular.

## Out of scope

Generic Webflow issues (CMS limits, billing, hosting) → `https://help.webflow.com`. Shopify admin beyond what
Smootify documents → `https://help.shopify.com`. Anything else → the Discord.

## References

- `references/rules.json` — generated from Smootify's markup contract and glossary. **Never edit by hand**:
  tags and contexts come from Smootify's markup contract, attribute values (with their `inside`, `on`, `with`,
  `aliases`, `deprecated`) from the glossary (`cdn.smootify.io/components-v2/glossary.json`), state classes,
  events and public API from the 2.0 runtime; Smootify regenerates it. Each tag and attribute carries the public
  page to cite (`reference`).
- `references/support-checks.md` — the eleven support-derived checks.
- `references/doc-map.md` — topic → doc path, with what the 1.x docs do not cover yet.
