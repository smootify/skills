---
name: smootify-iterate
description: Works through the review notes Smootify Studio's Iterate collects on a published Webflow + Smootify site, one note at a time. For each note it finds the cause, fixes the site in Webflow when the cause is the site, and answers inside the note with the cause and how sure it is. Use it when Studio sends the notes to Claude ("Use the smootify-iterate skill"), when a site folder has a notes/ folder with note files, or when the user asks to go through, fix or answer Iterate notes.
---

# Smootify iterate

Studio's **Iterate** lets the person click an element of their published site and write what is wrong with it. Each
note lands in the site's folder. This skill answers those notes: it finds why the element is wrong, fixes the site
in Webflow when the site is the cause, and writes back into the note what it did, the cause and how sure it is.

Studio reads the notes again on its own and shows your answer to the person. When the cause is Smootify itself,
your answer goes to Smootify's support as it is, so it has to stand on its own.

## The note format belongs to Studio

The format of a note is written in `notes/README.md`, in the site's folder, next to the notes. **Read it first, every
time**: Studio owns it and may add fields. Do not rely on a memory of it. In short, as of this version:

- one note per file, `notes/<YYYY-MM-DD>/<id>.json`, with `<id>-element.png` (the element) and `<id>-window.png`
  (the whole window), and `<id>-after.png` once Studio has looked again after a fix;
- what to read: `note`, `type`, `severity`, `url`, `window.device`, `publishedAt`, `element` (`selector`, `tag`,
  `classes`, `attributes`, `text`, `html`, `rect`, and `kind`: `"area"` for a zone the person dragged, with the
  selectors it covers in `inside`, `"page"` for the whole page, absent for one element), `smootify` (the Smootify
  elements around it, nearest first), `smootifyScript` (`version`: `"1.x"`, `"2.0"` or `null`, and the scripts the
  page loads), `consoleErrors`, `failedRequests` (calls to Smootify or Shopify that failed in the two minutes
  before the note: `url` without query string, `status`, `0` when nothing answered), `replies`;
- what you write, and nothing else: `status`, `resolution` and a new entry in `replies`.

If `notes/README.md` says something different from this list, the README wins.

## Where you may look: only what is public

The person's site, Smootify's public documentation and the public tools. Nothing else.

- **The site:** the Webflow MCP (pages, elements, classes, attributes, components and instances, CMS bindings, the
  site's custom code and the scripts it loads) and the published page itself.
- **Smootify:** the Smootify MCP when it is connected (`get_element`, `resolve_vocabulary`, `suggest_attributes`,
  `get_options`, `get_example`, `check_markup`, `audit_page`, `diagnose`, `find_capability`, `probe_storefront`, and
  `get_changes` / `plan_migration` for a 1.x site), the documentation at smootify.io/docs, and the public
  instructions of the other Smootify skills.
- **The site's brief:** `CLAUDE.md` in the site's folder, which Studio writes: the Webflow site, the store, the plan,
  the collections.

You do not have Smootify's source code or its internal notes, and you must not reason as if you did. When the public
material does not settle a question, say so in the answer instead of guessing.

## How to work through the notes

Take the open notes one at a time, oldest first, and finish each one before the next.

1. **Read the note.** The text, the type and severity, the device it was taken on, both screenshots, the element and
   the Smootify elements around it, the console errors. A note that was reopened carries the reason in its last
   reply: start from there, not from your previous answer.
2. **Look at the published page**, at the note's width, before anything else. A note on an area covers every
   element in `inside`; a note on the page has no element, so read the window screenshot. Compare it with the screenshots. If
   `publishedAt` is older than the last change on the site, the note may describe an old version: check what is live
   now.
3. **Check the site first.** Most notes are about how the site is built, not about Smootify. With the Webflow MCP,
   read the element and what is around it: its structure, classes and combo classes, custom attributes, whether it is
   a component or an instance and what its props are, its CMS bindings, the Smootify options in the custom code, and
   which Smootify script the site loads (1.x or 2.0).
4. **Check what is documented.** With the Smootify MCP and the docs, find what the element and its attributes should
   be and do: `get_element` for a tag, `resolve_vocabulary` for an attribute's values, `check_markup` on the element's
   outline, `audit_page` on the page, `diagnose` with the symptom. Compare with what the site has.
5. **Decide the cause** (see below), with a confidence.
6. **When the cause is the site, fix it.** Say in one line what you will change, then change it with the Webflow MCP.
   Read the element back after every write. Change only what the note is about, but at its source: when the cause
   is a shared component, class or template, fix it there, look at the other places that use it, and list them in
   the answer.
7. **Answer in the note** (see below). Then the next note.

Never publish the site. Studio tells the person when a fix is waiting for a publish.

## The cause, and how sure you are

Every answer names one cause and a confidence from 0 to 1:

| `cause` | When |
|---|---|
| `site` | The site's markup, classes, attributes, bindings, options, content or Webflow settings are wrong or missing. |
| `runtime` | Smootify's script does not do what its documentation says, on markup that matches the documentation. |
| `annotate-skill` | The Figma annotation skill wrote a wrong instruction that the build followed. |
| `build-skill` | The Figma to Webflow skill built against a correct annotation, wrongly. |
| `missing-feature` | What the person wants is not something Smootify does today, by its documentation. A request, not a bug. |

**Be very careful before blaming Smootify or a skill.** Most of the time Smootify works and the configuration is
wrong. Something that looks like a bug is usually one of these:

- the site loads the 1.x script while the markup is written for 2.0, or the other way round: read
  `smootifyScript.version` first (`null` means the page loads no Smootify script at all);
- an attribute value that is not in the documentation, a typo, or a value on the wrong element;
- an element outside the parent it needs, so Smootify removes it or ignores it;
- a state that the design never styled (a combo class such as `is-active`, `is-invalid` or `is-disabled`);
- a block hidden or shown with CSS where the documentation asks for a condition, or the reverse;
- the store's data: a product, metafield, market, location or filter that does not exist in Shopify, or is not
  visible to the storefront;
- a Webflow default that was never reset (a margin, a fixed height, an alignment);
- a page published before the last changes, or a note taken before a fix: when the element already changed after
  the note's time, answer that it is fixed on the current version and ask to look again after the next publish.

Choose a cause other than `site` only when all of these hold:

- the site's markup matches the documentation for that element, checked with the Smootify MCP or the docs;
- the documentation says what should happen, and the page does something else;
- you have ruled out the store's data and the published version;
- `failedRequests` is empty, or you have checked what failed: a request with status `0`, a 401 or a 404 to
  Smootify or Shopify usually means a page loaded mid-deploy, a missing token or a store setting, not a bug in the
  script.

How to set the confidence:

- **0.8 or more:** you checked the markup against the documentation and the documented behaviour is clearly not what
  happens.
- **0.5 to 0.8:** the markup looks right, but you could not check everything (the store's data, a logged-in state, a
  checkout).
- **Under 0.5:** you cannot exclude the site's configuration. Studio then shows "Reopen" before "Send to Smootify", so
  say what the person should check first.

A `site` cause also gets a confidence: how sure you are that your fix answers the note.

## The answer

Write only `status`, `resolution` and one new entry in `replies`, as `notes/README.md` describes:

```json
{
  "status": "resolved",
  "resolution": {
    "at": "2026-10-08T18:20:00Z",
    "by": "claude",
    "cause": "site",
    "confidence": 0.9,
    "text": "The sort label was overwritten…",
    "refs": ["https://www.smootify.io/docs/build/filters"]
  },
  "replies": [{ "at": "2026-10-08T18:20:00Z", "by": "claude", "text": "…" }]
}
```

- `status`: `resolved` when you changed the site, `rejected` when you left the site as it is (the cause is
  elsewhere, the note asks for something the site should not do, or there was nothing to fix).
- `text`: plain words for the person. What was wrong, what you changed, what to look at after publishing.
- `refs`: the documentation pages and the MCP findings you relied on.
- When the cause is not `site`, the `text` stands on its own for Smootify's support: the page URL, the element, what
  the documentation says should happen, what happens, what you checked on the site to rule out the configuration,
  and how to see it again.

## What you never do

- Publish the site.
- Work around a Smootify bug on the site (extra scripts, CSS that hides a wrong value, removed attributes). Answer
  with the cause instead, so it gets fixed where it is.
- Change anything the note is not about, or rewrite the design.
- Change other fields of the note, delete notes or screenshots.
- Guess at Smootify's internals.
