---
name: figma-annotate-smootify
description: Prepares a Figma design for Webflow + Smootify. It decides which Webflow components to create, with which variants and props, where each prop is bound and where every instance is connected, reusing one component wherever the design repeats one, and it writes all of it back into the file as Dev Mode annotations for the build skill. Use it whenever someone shares a Figma file, page or frame and wants it annotated or prepared for Webflow or Smootify — "annotate this", "annota il figma", "prepare this for Webflow", "which components does this need", "what Smootify elements are in this design" — and whenever a Figma file needs `@component`/`@prop`/`@tag`/`@attr` directives it does not have yet. It asks whenever it is not sure instead of guessing. This is the annotation half: `figma-to-webflow-smootify` reads its output and builds Webflow. It never writes to Webflow.
---

# Figma → Smootify annotation

## What this skill does, and where it stops

It reads a Figma file and works out, in this order:

1. **which Webflow components** the design needs, each built **once**;
2. **their API**: variants, props, tooltips, what each prop is bound to, slots;
3. **the Smootify markup** inside them: custom tags, attributes, the invisible containers;
4. **where each instance is connected**: which page, which prop values, which CMS field.

Then it **writes all of it back into the file as Dev Mode annotations** and stops. It never touches Webflow.
`figma-to-webflow-smootify` reads those annotations and builds the site without further decisions — so every
annotation is a decision, and a wrong one becomes a wrong site.

**Pair:** this skill annotates → the person reviews in Figma → `figma-to-webflow-smootify` builds.

## The rule above every other: ask, never guess

The person running this skill knows the design and the shop; you know the vocabulary. **Whenever a decision
is not settled by what you can see plus a rule in this skill plus an entry in the references, ask.** More
questions are better than one guessed answer: a wrong guess produces markup that looks right in the Designer
and does nothing at runtime, and nobody notices until a customer does.

You must ask when:

- two components look alike — are they one component with a variant or prop, or two?
- a frame looks like an existing component but is not an instance of it;
- a Figma property does not clearly fall into one `@axis` kind (see step 3);
- a text could be a fixed label, a value the person placing the component chooses, or data Smootify fills in;
- a picker inside an add to cart could pick a variant, an add-on or a configurator field (see step 4);
- a control could be a native select, a Webflow Dropdown or a popover and the design does not say;
- an image could be an `<img>` or a background;
- the design and `ui-kit-components.md` disagree;
- a value you need (CMS collection, field, metafield key, Shopify option) is not visible anywhere;
- a tag or an attribute value is not in the catalogue or the glossary;
- a component would need a step that no tool can do (`@manual`).

**How to ask.**

- Ask in the language of the person you are working with.
- Group the questions by component, a handful at a time. Number them, give the options, put the one you
  would pick first and say why in half a line. Use a multiple-choice question tool if the client has one.
- Show where the thing is: the layer path, and a screenshot of the node when it helps.
- Never ask what the references already answer. That wastes the person's attention on the wrong questions.
- **Propose shop values from the context instead of asking.** A metafield key, a metaobject type, a collection or box
  handle that the design does not show: derive it from the visible label (`VAT number` → `company-metafield=vat_number`,
  a reviews list → type `review`, a "Best sellers" carousel → handle `best-sellers`), write it, and list it in the
  report under assumptions. Ask only when nothing in the design suggests a value.
- If the person does not know yet, write `@ask: <the question>` on the node and move on. An `@ask` stops the
  build skill on that node, which is the point.
- When an answer settles a whole class of cases ("every Webflow Dropdown in this file is a popover"), apply it
  everywhere and say so once. Do not ask the same thing twice.

## Sources of truth — read them before proposing anything

| File | What it decides |
|---|---|
| `references/annotation-format.md` | **The format.** Every directive, where it goes, and the transport rules that keep it intact. Shared with the build skill |
| `references/ui-kit-components.md` | The 2.0 kit: every component, where it appears, its Figma variants and states, the props it expects in Webflow, its markup. Written in Italian; **names and props go to Webflow in English** |
| `references/smootify-catalog.md` | **Tags**: every legal Smootify tag, what it must be inside, all its host attributes, the state classes Smootify toggles, and the field Names each form element reads (*Campi dei form*). Generated from the 2.0 markup contract |
| `references/glossary.json` | **Attribute values**: for each value, the element it must be inside (`inside`), the kind of Webflow element it goes on (`on`), whether it repeats the element (`note`). **Load it live first** — see *Load the glossary* below; the copy in `references/` is the fallback |
| `references/glossary-errata.md` | What the glossary does not say: `button` means the button tag, how swatches pick their option, legal attributes it lacks, the 1.x functions still being ported, the two names the kit list gets wrong. **It wins over the kit list** |

If a tag or a value is in none of them, it does not exist. Never invent one, never carry one over from memory
of another project or of Smootify 1.x.

When the kit list and the catalogue or glossary disagree on markup, the glossary wins, then the catalogue.
Report the disagreement so the list can be fixed.

**Attribute values come from the glossary.** The catalogue's *Valori leciti* is a list of names that also holds
aliases (`cart=totalQuantity` is `cart=count`): when both name a value, write the glossary's. A value that only
the catalogue has is legal but not described: ask before using it. A value the kit uses and neither has does
not exist: remove it and say so in the report.

## Before you start

- **Tools.** You need the Figma MCP with `use_figma` (it reads and writes annotations) and `get_screenshot`.
  Load the `figma-use` skill before the first `use_figma` call. Without `use_figma` you can still plan, but you
  cannot write: say so and give the annotations as text.
- **Scope.** Ask which file and which pages, if not given.
- **One library per file.** The starter and each of the three themes is its own Webflow site with its own
  components. Reuse means: inside one file, never build the same thing twice.
  Across files, an earlier annotated file is **evidence** for a role or a decision, never the answer — confirm it.

## Load the glossary — live first

The glossary is corrected and republished on the CDN whenever the runtime changes, so the live file beats the
copy in this skill. Before proposing any attribute, get it in this order and **stop at the first that works**:

1. **`curl`**, if you can run commands. The raw JSON, never a web-reading tool: those summarise or cut a
   50 kB file.
   ```bash
   curl -sf https://cdn.smootify.io/components-v2/glossary.json -o glossary.json
   curl -sfI https://cdn.smootify.io/components-v2/glossary.json | grep -i last-modified
   ```
2. **`fetch` inside `use_figma`**, if commands cannot reach the network (on claude.ai the sandbox may not
   allow the domain). The CDN answers every origin (`access-control-allow-origin: *`), so the plugin context
   can read it. Return only what you need if the result is too large for one call.
   ```js
   const res = await fetch('https://cdn.smootify.io/components-v2/glossary.json', { cache: 'no-store' });
   if (!res.ok) throw new Error('glossary ' + res.status);
   return { lastModified: res.headers.get('last-modified'), glossary: await res.json() };
   ```
3. **`references/glossary.json`**, the copy of 2026-10-05, when neither works. Tell the person you are
   working from the copy.

Check that what you got has `"runtime": "2.0"` and the `attributes` and `conditions` arrays; otherwise treat it
as a failure and go to the next source. `references/glossary-errata.md` applies whichever source you used.

## Step 0 — Questions before starting

Some answers change annotations across the whole file, and none of them can be read from the design. **Ask them
all together, in one message, before reading the file**, and do not start step 1 until they are answered.

1. **The product image: a Webflow Image or an `img` custom element?** Since 2.0 the Smootify sync can bring
   the featured image into the CMS in two ways, and the product card and product page are built to match:
   - **Webflow Image element** bound to the CMS **Image** field. Webflow downloads the file and hosts it
     again.
   - **`img` custom element** (`@element: DOM @tag: img`) with `src` bound to the CMS **Image URL** text field
     and `alt` to **Image Alt**. The image stays on Shopify's CDN and the import is faster.
   The same choice holds for collection images. If the Webflow site already exists and its Products
   collection has only one of the two fields, that field is the answer: ask only to confirm it. If it has
   both, the person chooses.
2. **The Webflow site**, if one exists already: its components, CMS collections and field names are then read
   instead of assumed. None yet → the Smootify defaults (`Products`, `Collections`, `Vendors`, the field
   `Shopify ID`).
3. **The Smootify plan**: with `server` or without (without it, `configurator-*`, `file-uploader` and the other
   server elements are out).
4. **Pickers and panels**: when the design shows a menu that opens, is it a Webflow Dropdown, a native select
   or a popover? And a popover: the native Popover element of Webflow (beta, built by hand) or the `popover`
   attributes (built by the MCP)?

Write the answers on the top frame of the file's first page, as one annotation:
`@setup: image=url site=<site id or none> plan=standard pickers=dropdown popover=attributes`. On a later run,
read `@setup` first and ask only what it lacks. The build skill reads it too.

How question 1 lands in the annotations, on the product card:

| Answer | The image node | The card's props | Where it is placed |
|---|---|---|---|
| `image=image` | `@element: Image @attr: variant=image @bind: image = Image` | `@prop: image Image` | `@cms: Image = Products.Image` |
| `image=url` | `@element: DOM @tag: img @attr: variant=image @bind: attr:src = Image URL @bind: attr:alt = Image alt` | `@prop: string Image URL` `@prop: string Image alt` | `@cms: Image URL = Products.Image URL @cms: Image alt = Products.Image Alt` |

The CMS gives the picture that is in the page before Smootify runs; `variant=image` then follows the selected
variant. Keep both.

## Step 1 — Read the file in few calls

A product page alone is ~200 nodes. Never call `get_design_context` per node. One `use_figma` call per page
returns everything the decisions need; one `get_screenshot` per top frame gives the picture.

```js
const PAGE_ID = '…';                        // one call per page
const page = await figma.getNodeByIdAsync(PAGE_ID);
await figma.setCurrentPageAsync(page);
const out = [];
const walk = async (n, depth, path) => {
  const row = { id: n.id, name: n.name, type: n.type, depth, path,
                w: Math.round(n.width || 0), h: Math.round(n.height || 0) };
  if ('characters' in n) row.text = n.characters.slice(0, 80);
  if ('annotations' in n && n.annotations.length)
    row.ann = n.annotations.map(a => ({ md: a.labelMarkdown || a.label, cat: a.categoryId }));
  if ('fills' in n && Array.isArray(n.fills) && n.fills.some(f => f.type === 'IMAGE')) row.imageFill = true;
  if ('layoutMode' in n && n.layoutMode !== 'NONE') row.layout = n.layoutMode;
  if (n.componentPropertyReferences) row.refs = n.componentPropertyReferences;   // which prop drives visible/text/swap
  if (n.type === 'COMPONENT_SET' || (n.type === 'COMPONENT' && n.parent?.type !== 'COMPONENT_SET')) {
    row.props = n.componentPropertyDefinitions;                                   // VARIANT / BOOLEAN / TEXT / INSTANCE_SWAP
    if (n.description) row.description = n.description;
  }
  if (n.type === 'COMPONENT' && n.parent?.type === 'COMPONENT_SET') row.variant = n.variantProperties;
  if (n.type === 'INSTANCE') {
    const mc = await n.getMainComponentAsync();
    if (mc) {
      const set = mc.parent?.type === 'COMPONENT_SET' ? mc.parent : null;
      row.component = set ? set.name : mc.name;
      row.componentId = (set || mc).id;
      row.remote = mc.remote;
      row.values = Object.fromEntries(Object.entries(n.componentProperties).map(([k, v]) => [k, v.value]));
      const d = (set || mc).description; if (d) row.description = d;
    }
    out.push(row);
    return;                                   // an instance's insides belong to its component: read them there
  }
  out.push(row);
  if ('children' in n) for (const c of n.children) await walk(c, depth + 1, path + '/' + n.name);
};
for (const top of page.children) await walk(top, 0, '');
return out;
```

`componentPropertyReferences` is the best evidence you have: it says which Figma boolean shows or hides a layer
and which text property fills it. A boolean that drives `visible` is a `boolean` prop bound to `visibility`,
almost always.

Read **every page that holds main components** (often a "Components" page) as well as the pages that use them.

## Step 2 — Inventory: what gets built once

Before annotating anything, list every component the file needs. This step prevents duplicate work, and it is
the first checkpoint with the person.

1. **Main components and sets** in the file: each is a candidate Webflow component.
2. **Match each to `ui-kit-components.md`** by name and content. The kit names them `Area / Component`
   (`Prodotto / Card`). In Webflow: group = the area in English, name = the component in English
   (`Product` / `Product card`). Translate plainly and list the translations for confirmation.
3. **Find the duplicates** — each is a question, never a silent merge:
   - two components with the same structure and different names;
   - a frame drawn by hand with the structure of an existing component (a detached instance) → `@use`;
   - several main components that are one Webflow component (nine card masters for one card) → keep one, and
     write `@use` + `@set` on each of the others: their instances are built as instances of the one you keep;
   - two components that differ only in styles or in one optional part → probably one component with a
     variant or a boolean prop;
   - the same thing drawn at desktop and mobile size → one component, responsive styles.
   - **in a starter or a kit** (a library the Designer App will offer), every drawn alternative becomes its own
     component: the Dropdown, the native select and the popover version of a filter are three components, not one
     chosen version. On a shop's own site, build only the versions the shop uses.
4. **Find what is not a component.** A component is justified when a structure **repeats**. The layout of a
   product page or of an account page does not repeat: it is page structure, not a component. The 404, policy
   pages, header and footer are Webflow; the skeletons and the banners Smootify injects are not drawn at all.
   **A master you do not build as a component still gets one line saying why**, on the master itself, so whoever
   opens its component page can tell a decision from a forgotten component:
   - page structure: `@note: page structure, annotated on <page> › <frame> (<node id>)`, naming the frame where its
     markup is written;
   - a primitive built inline (an input, a tab, a popover): `@note: not a component, each instance is annotated where it is placed`,
     and every instance of it gets `@inline: <master>`, never a `@note` saying "inline": the builder reads `@inline`.
     `@inline` copies **every** layer of the master. When a layer is legal in one host and not in another (the
     stock and pick-up time of a store row: `store-availability` yes, `store-locator` no), make **two masters**,
     one per host, never one master with a note.
   Icons and other plain graphics need nothing.
5. **Nesting and build order.** A component used inside another (the price inside the card, the swatches inside
   the add to cart) is built first and placed as an instance. Where the outer component takes one of several
   inner components (a card that ends with a form, a quick-view button or nothing), prefer a **slot**
   (`@slot`) to one outer component per combination — and ask.
6. **Drawn copies.** Four thumbnails, three cart lines, five filter values: one template Smootify repeats
   (`@repeat`), the rest `@skip`. Never a component per copy, never an instance per copy.

**Checkpoint 1.** Show the person the inventory as a table — Webflow group and name, Figma source, used on
which pages and how many times, new or merged, built inside what — with the duplicate and naming questions
underneath. Do not design any component API before this is agreed.

## Step 3 — The API of each component

Go component by component, innermost first. For each one decide root, variants, props, bindings, slots.

### The root

- If the component **is** a Smootify element (`smootify-product`, `variant-swatches`, `smootify-cart` …), the
  root carries its `@tag`.
- Classes: `sm-` + the English name in kebab case for the root (`sm-product-card`), `sm-<component>-<part>`
  for the parts (`sm-product-card-title`). Utility classes keep their own name. No underscores.
- **Without `@style`, the builder names the class from the layer.** A layer named with sample text ("Caring for
  solid oak", "S", "92"), a selector or another language ("Freccia sinistra") gives a class nobody can use. Give
  those layers an `@style` from the role (`sm-size-guide-size-value`, `sm-gallery-arrow-prev`).
- **One class, one design.** Two layers with the same name and different designs (a filter label in a checkbox
  list and in a dropdown) need different `@style`, or the second design is lost.
- `@desc`: what it is and what it needs to work ("One product. Needs the Shopify ID of the product").

### Every Figma property gets an `@axis`

Read `componentPropertyDefinitions` on the set and classify every property. This is where most mistakes come
from, so classify each one explicitly and ask whenever it is not obvious:

| The property… | Kind | Webflow |
|---|---|---|
| is decided by Smootify at runtime — selected, unavailable, loading, out of stock, on sale, new, empty, error, logged in | `state` | No variant, no prop. On each state variant write `@state: <class> on <layer>` with the class from the catalogue's *Classi di stato* list, or annotate the element that shows only in that state (`condition=…`, `data-state=…`, `skeleton=…`, Webflow form done/fail) |
| is hover, focus, pressed | `interaction` | Pseudo-state styles |
| names a size or a device: Desktop, Tablet, Mobile | `breakpoint` | Responsive styles. Annotate both frames and say on each `@note: same element as <other> at another size` |

**Tablet and Mobile frames of a page** carry only their top-frame note, `@note: same element as <Desktop id> at
another size`. Everything inside that the Desktop frame also has (tabs, inputs, cards, forms) gets **no annotation**:
it is the Desktop element at another breakpoint. Annotate inside them only what exists at that size alone, such as
a mobile account nav dropdown or a sticky buy bar, and say so in a note: `@note: mobile only`.
| is chosen by whoever places the component, and **only styles** change | `variant` | A Webflow variant: `@variant: <Name>` on each variant |
| is chosen by whoever places it, and **a part shows or not** | `prop` | `@prop: boolean <Name>` + `@bind: visibility = <Name>` on the part |
| is chosen by whoever places it, and **its value becomes an attribute** (Option 1 \| 2 \| 3) | `prop` | `@prop: string <Name> = <default>` + `@bind: attr:<name> = <Name>`; each instance `@set: <Name> = <value>` |
| is chosen by whoever places it, and **the Smootify tag, the attributes of the children or the structure** change | `split` | One component per value, each with its own `@component` on the variant |
| only changes the sample content | `sample` | Nothing |

Cases from the kit that show the difference:

- `Prodotto / Card`, *Stati* Default | Caricamento | Esaurito | In offerta | Nuovo → **state**, and what each state
  shows is a **badge with a condition attribute**, not a `@state` class: a Badge component with `@prop: string
  Condition` bound to `attr:condition` (`is-new`, `on-sale`, `out-of-stock`), placed with `@set`. Use `@state` only
  for what the state restyles on the card itself (a faded image when sold out). *Formato* =
  Griglia | Orizzontale | Mini → **variant** if only the layout changes; if Mini drops parts, those parts get
  boolean props — ask. *Aggiunta* = Nessuna | Form | Quick view → the structure changes: a **slot** for the
  bottom of the card, or **split** — ask.
- `Filtri / Gruppo`, *Tipo* = Checkbox | Swatch | Prezzo → **split**: `filter-checkbox`, `filter-swatches`,
  `filter-price` are different elements, not faces of one. Never one component with a "type" variant.
- `Varianti / Swatch`, *Stile* = Colore | Immagine | Pillola → the children carry different attributes
  (`option=bg-color`, an `<img>` with `option=image`, `option=title`) → **split**. *Prezzo* = Nessuno |
  Differenza → **prop** (the `option=price-difference` text shows or not). *Contenitore* = In linea | Popover →
  **split**.
- `Prodotto / Prezzo`, *Dimensione* = Card | PDP → **variant**.

**Every variant gets a decision.** A state variant with no `@state`, no annotated block and no `@skip` is not
built, and the build cannot tell an oversight from a choice. The ones missed on the starter: Open = No on
filters and sort, Zero on a result count, Loading and Disabled on pagination, Updating and Removing on a cart line,
Loading / Applied / Error on a discount field. Annotate what changes, or `@note: drawn for reference` on the
variant.

Webflow variants are one flat list per component and change styles only. With two `variant` properties on one
set, list the combinations the design really uses and ask which to create.

### Props — only what the person placing the component chooses

A prop exists when **the value differs between instances and the person placing the instance is the one who
supplies it**. Everything else is not a prop.

| Is a prop | Is not a prop |
|---|---|
| A Smootify setting that differs per instance: `data-option`, `limit`, a filter's `label`, a carousel's source (`data-id`), a threshold (`data-amount`) → always `string`, bound with `attr:<name>` (a `number` prop defaults to 0 and ships as `limit="0"`) | **Data Smootify fills in**: titles, prices, product images, stock. The text in Figma is a placeholder; the element gets `@attr: product=title` and nothing else. The one exception is the featured image connected to the CMS as step 0 decided |
| The Shopify ID on a card or a product wrapper → `string Product ID`, `@bind: attr:data-id = Product ID`, connected to the CMS with `@cms` where the instance is placed | **Runtime states** (they are `state`) |
| A text written per instance: a section title, a button label that changes between placements → `text` | A label identical everywhere ("Add to cart"): static text, unless the person says otherwise |
| An optional part (a Figma BOOLEAN property) → `boolean`, `@bind: visibility` | Styles (they are variants) |
| An image or a link chosen per instance → `image` / `link` | Anything the kit list does not expect and the design does not show varying — ask instead |

For each prop write `@prop` (type, English name, default), `@tip` (one line: what it is and where the value
comes from — "The Shopify product ID. On a CMS page, connect it to the Shopify ID field"), and the `@bind` on
the node it drives. Start from the *Prop Webflow* line of the kit list and translate; add what the design
shows and the list misses, and ask about it.

A Smootify attribute bound to a prop is built without manual steps (the build skill has the recipe). So one
component with a `string` prop always beats three components that differ by one attribute.

What a prop cannot drive, so annotate it differently:

- **the visibility or the position of an instance**: an instance has neither. Put the instance in a frame and
  annotate the frame (`@bind: visibility = Show wishlist`, and the absolute position of a heart on the image);
- **a form field's Name**: it is not bindable. When the Name changes between uses (a `coupon` field and a
  `gift-card` field), it is a `split`;
- **a placeholder**: Webflow reserves it. Write the text in a `@note`; the person sets it.

**Popovers inside a component.** A trigger and its panel are tied by an id, and a component placed twice would
repeat it. Add `@prop: string Popover ID`, bind it with `@bind: attr:popovertarget = Popover ID` on the trigger
and `@bind: domId = Popover ID` on the panel, and give each instance its own value with `@set`. Never ask about
it again in the same file.

## Step 4 — The Smootify markup inside each component

### Containers first — they are invisible

`smootify-product`, `smootify-add-to-cart`, `smootify-search-discovery`, `smootify-cart` have no appearance,
and everything inside depends on them. Place them before any leaf. When no single frame covers the right span
(the pickers and the buy button are siblings with no shared parent, but `smootify-add-to-cart` must wrap them
all), write `@wrap` on the first node of the span. Never stretch an existing frame to mean something it does
not.

### Shape from the structure, prefix from the context

Tags read `prefix-shape`: `variant-swatches`, `filter-dropdown`, `addon-select`.

| What you see | Suffix |
|---|---|
| A row of pills or buttons, one selected | `-swatches` |
| A native select | `-selector` (variants) / `-select` (everything else) |
| A Webflow Dropdown | `-dropdown` |
| A trigger that opens a panel above the page | `-popover` |
| A checkbox with a label | `-checkbox` |
| A radio list | `-radio` / `-list` |
| Two number inputs and two range inputs | `filter-price` |
| Tabs with radios, "one-time / subscribe" | `subscription-swatches` |

A native select, a Webflow Dropdown and a popover can be drawn identically: `@setup` says which one the file uses (step 0).

The **prefix** is the role, and a design does not contain it:

- inside `smootify-search-discovery` → `filter-` or `sort-`; the label usually decides ("Sort by");
- inside `smootify-add-to-cart` → `variant-`, `addon-` or `configurator-`. **The ancestor chain is the same
  for all three, so it cannot decide.** Narrow it — not on the `server` plan → no `configurator-`; the label is
  a Shopify option (Color, Size) → probably `variant-`; the choices carry their own prices (+ €10) → probably
  `addon-` — and then **ask**, once for each group of controls that share a role.

A wrong prefix is the worst mistake this skill can make: the markup is legal and dead.

### Names and descriptions are evidence, not answers

A layer name comes from whoever drew it; a component description says what the component *usually* is. A
component named `Filter / Swatches` is `filter-swatches` on the collection page and the colour picker —
`variant-swatches` — on the product page, where there is no `smootify-search-discovery`. **When the ancestor
chain disagrees with a name or a description, the chain wins**; note the disagreement in the report.

### The six ways an attribute goes wrong

Each one was caught by a person reviewing a real annotated page.

1. **The catalogue's host-attribute column mixes inputs and outputs.** Write only the attributes you can
   explain and whose value the person building the page supplies. `data-option` and `data-option-name` are
   both inputs on swatches (the name wins, and a name that matches nothing removes the widget); `data-value`
   on the buttons is written by Smootify — never annotate it.
2. **A binding attribute writes into the element it is on** — text for a text element, `src` for an image,
   `href` for a link. Put it on the leaf that holds exactly that thing, never on a wrapper that also holds a
   heading. Check the glossary's `on` against the element type every time.
3. **The element type is part of the decision.** `on: image` means an `<img>`: a frame with an image fill is a
   background, with no alt text and no indexing. `on: button` means a real `<button>`: write
   `@element: DOM @tag: button` — Webflow's Button element publishes an `<a>` and its FormButton an `<input>`,
   and Smootify ignores both. `on: rich` means a Rich Text element.
4. **Some values repeat the element instead of writing into it** (the glossary's note says "One copy per…" or
   "Template"; plural names like `images`, `media`, `tags`, `collections`; every `list.*` metafield). They go on
   the element to repeat, which gets `@repeat`; the drawn copies get `@skip`.
5. **One line of text often hides a repeated pair.** A cart line showing `Black · M` is a `cart-item=options`
   container with one row — `option=name` and `option=value` — repeated per option. Look for it in every
   label-and-value pair, spec table or comma list.
6. **A tag that renders sub-parts needs its children annotated.** `smootify-price` fills
   `data-prop=price|compareAtPrice|total` children; a price with only the host annotated stays empty. Whenever
   a tag's description names an `[attribute=…]`, find those children and annotate them.

**Numbers Smootify writes are never sample text.** "Filters (2)" is a static "Filters" and a
`filter="active-count"` layer; "Cart (3)" is a static "Cart" and a `cart=count` layer. When the drawn number
shares a layer with a word, ask for the layer to be split or note it, so the build does not drop the word.

**Every panel needs its trigger and its close.** A popover, a dialog or a drawer is annotated with the button that
opens it (`popovertarget`) and a close that is a real button (`popovertargetaction="hide"`), not a bare icon.
Arrows drawn in a carousel's header are the Webflow Slider's own arrows, moved there: Smootify does not drive
arrows outside a slider.

**Metafield blocks** (a feature list, a rich text, a size guide): annotate the inner element Smootify writes into;
if the metafield renders whole (rich text), mark the drawn content `@skip`. Drawn rows with no attribute are built
as static sample text.

And one that is knowledge, not vocabulary: **some elements look the way their vendor decides.** Shop Pay is
Shopify's purple button; an outlined "Buy it now" is not `smootify-shop-pay`. The Judge.me widgets are drawn by
Judge.me. For those, only the space is ours.

## Step 5 — Where each instance is connected

For every page:

- `@page: static`, or `@page: template <Collection>` on a CMS template (product, collection, vendor pages).
- Each placed instance: `@set` for every prop whose value is not the default here, `@set: Variant = <Name>`
  when not the base, `@cms: <Prop> = <Collection>.<Field>` when the value comes from the CMS item.
  On a product template: `@cms: Product ID = Products.Shopify ID`.
- A grid of cards fed by the CMS is a collection list: `@list: <Collection> limit=… sort=…` on the list node,
  the card instance inside it with its `@cms`. A grid fed by Smootify (search & discovery, carousels, wishlist)
  is **not** a collection list: the card goes inside the Smootify element, with the `data-id` value that element
  requires (for example `filter`).
- A wrapper the page needs and no component provides (the `smootify-add-to-cart` around a PDP's pickers) is a
  `@wrap` on the page, not a new component.
- **Page elements and wraps take CMS fields too.** On a template page, any element except `body` can take a CMS
  field: `@cms: attr:<name> = <Collection>.<Field>` (or `text`, `image`, `link`). A product page is
  `body > header, main, footer`, and the `smootify-product` around the main content is usually a wrap:
  `@wrap: smootify-product over <first>..<last> @cms: wrap attr:data-id = Products.Shopify ID`, spanning **the whole
  main content** between header and footer (gallery, buy column, description, carousels), not only the buy area. The same for a
  collection page: `@cms: wrap attr:data-collection = Collections.Shopify ID` on the `smootify-search-discovery`
  wrap, and `@cms: text = Collections.Name` on its heading.
- **One template per collection.** Webflow has one Products template: product pages drawn differently
  (standard, configurator, subscription) are one page with every block, and each block shows according to the
  product. **First the conditions Smootify already has, never a new CMS field**:
  - a Smootify element that removes itself without data needs nothing: `subscription-swatches` disappears when the
    product has no selling plans (the catalogue says what each tag does *outside its context*);
  - otherwise a condition from the glossary on a wrapper: `condition=subscription`, `condition=is-variable`…, or a
    product metafield with `if-metafield=<key>` (key proposed from the context, in the report):
    `@wrap: DivBlock over <first>..<last> @attr: wrap if-metafield=configurator`.

  `@manual: conditional` on a CMS field only when Smootify reads nothing that tells the products apart, and say why
  in the report.

  A **bookable product** (a service, a visit) is told apart by a product tag, `bookable`, with
  `tagged="bookable"` / `not-tagged="bookable"` on the wrappers. Its booking schedule lives in Smootify, not in a
  metafield, so `if-metafield` cannot read it.
- **Tablet and Mobile frames that change the structure** still need no second element: annotate the extra
  element on the desktop master or page, hidden at desktop by responsive styles, and say so in a `@note`. The
  cases seen so far: a "Filters" button that opens the filter panel (a popover, `popover` / `popovertarget`, the
  panel still inside `smootify-search-discovery`); a dropdown in place of a row of tabs; a sticky bar of the magic box, which goes **inside** `smootify-magic-box-cart` (the box counters and its
  `smootify-price` work only there), fixed at the bottom on small screens; a sticky add-to-cart bar outside its form,
  tied with `form="<form id>"`; thumbnails that scroll instead of wrapping.
- **Search & discovery filters**: a filter's `label` must be the label of a filter set in the store's Search &
  Discovery app (Availability, Price, Color…). List the labels you use in the report, as an assumption to check
  in the store.

- **What the store must have**, or Smootify removes the element and the page is empty: a public Mapbox token for
  `store-locator` (without it the store list goes too); a Magic Box entry whose handle is the `data-handle` of
  `smootify-magic-box`; local pickup on a location for `store-availability`. List each one in the report as a
  store prerequisite.
- **Reserved slugs**: Webflow keeps `/search` for its site search. Point search forms and `search="search-page"`
  links to the page's real slug (`/search-page`), not to `/search`.

Collection and field names: use what the Webflow site has if you can read it; otherwise the Smootify defaults
(`Products` with `Shopify ID`, `Collections`, `Vendors`) — and list them in the report as assumptions to confirm.

## Step 6 — Refute your own proposal

Before writing, check every annotated node:

- the tag exists in the catalogue, and its required container is in the tree **you are proposing**;
- every attribute value is in the glossary, its `inside` holds, its `on` matches the element type;
- every child a tag needs (`data-prop`, `option=…`) is annotated;
- every `@bind` names a `@prop` of the nearest `@component` above it, and every `@prop` is bound somewhere;
- every `@set` and `@cms` names a prop of the instance's component;
- every Figma property of every set has an `@axis`;
- **every main component and set in the file carries a Smootify annotation**: its directives, `@use` + `@set`, or
  the `@note` that says why it is not a component. Icons and plain graphics are the only exception. A component
  page with no annotation at all is a failed check;
- no node carries both `@ask` and the directive it asks about, nor `@ask` together with `@skip` (the builder skips the
  node and the question disappears);
- **nothing the build needs lives only in a `@note`** (the builder ignores notes):
  - a Form Block a tag requires (its catalogue row says it must contain `form`) needs no directive: the builder adds it;
  - a missing container the MCP can build (a panel, a wrapper) is a `@wrap`, with `@attr: wrap …` for its attributes;
  - only what no tool can do is `@manual`;
- a `@tag` that is also an HTML tag (`map`) carries `@element: DOM`, so it is not read as plain HTML;
- no value contains a double quote, a newline or an `@`, and no class contains an underscore.

A proposal that fails a check is wrong: fix it or ask — never write it and let the build skill find out.

**Checkpoint 2.** Before writing, show the person the plan: per component its variants, props (with what each
is bound to) and slots; per page what is placed and how it is connected; and every open question. Write after
the answers.

## Step 7 — Write

```js
const WRITES = [ /* { id, text } — one line of directives per node */ ];
const cats = await figma.annotations.getAnnotationCategoriesAsync();
const cat = cats.find(c => c.label === 'Smootify')
  || await figma.annotations.addAnnotationCategoryAsync({ label: 'Smootify', color: 'violet' });
const done = [], skipped = [];
for (const { id, text } of WRITES) {
  const n = await figma.getNodeByIdAsync(id);
  if (!n || !('annotations' in n)) { skipped.push(id); continue; }        // groups, sections
  const others = n.annotations.filter(a => a.categoryId !== cat.id);      // never touch other notes
  n.annotations = [...others, { labelMarkdown: text, categoryId: cat.id }];
  done.push(id);
}
return { done, skipped };
```

- Component directives on the main component or the set; instance directives on the instance. Never on a layer
  inside an instance: that belongs to the component.
- Rewriting a node replaces its Smootify annotation. On a file annotated before, read what is there first and
  keep what the person corrected by hand — their correction is an answer.
- Batch the writes, a few dozen nodes per call, and read them back: `get_design_context` on one annotated
  component shows what the build skill will see.

## Step 8 — Report

In this order:

1. **Components to create**: a table with group, name, variants, props (type → bound to), slots, nested
   components, used on which pages. This is what the build skill will do.
2. **Open questions**: every `@ask` left, phrased so the person can answer it.
3. **Assumptions** to confirm: CMS collections and fields, translated names, file-wide conventions.
4. **`@wrap` introduced**: they become Webflow elements that do not exist in the design. Then the masters left as
   page structure, each with the frame its `@note` points to.
5. **Manual steps**: every `@manual`.
6. **Disagreements**: kit list vs glossary, names or descriptions vs context, nodes annotated on an ancestor
   because the right node was a group.
7. **Vocabulary used**: where the glossary came from (CDN via `curl`, CDN via `use_figma`, or the copy) and its
   `last-modified`, so a wrong annotation can be traced to the vocabulary it was made with.

Never report a count as success. Twenty confident annotations and one wrong role are worse than nineteen and a
question.

## What stays manual

Almost nothing does now. Through the Webflow MCP the build skill does per-instance prop values and variants,
attributes bound to props and to CMS fields, visibility bound to props, slots, collection-list source, filters,
sort and limit, interactions and fonts, **Form Blocks and wrappers**. Never write `@manual` for a Form Block a tag
requires (the builder adds it from the catalogue) or for a container a `@wrap` can make. Write `@manual` only for:

- `conditional` — Webflow conditional visibility: an element that depends on the active component variant
  (prefer a boolean prop or a split, and write it only if the person insists), or a block of a CMS template
  that shows only for some items (one Products template for several kinds of product). The MCP cannot read or
  write it;
- `popover` — the native Popover element of Webflow (beta). The MCP cannot create it; the same markup works
  with the `popover` / `popovertarget` attributes, which it can;
- `other` — anything else, described so precisely that someone (or an agent driving the Designer in Chrome)
  can do it without looking at the design: the element, the panel, the value.

**Not `@manual`**, because the build skill does them through the MCP (the starter build did them by hand from
`@manual` lines, and they belong in the annotation):

- the block of a **state** variant (out of stock, logged in, empty, reached, above the limit): annotate the block
  on the variant with its `condition` / `data-state`; the builder puts every state's block in the one component
  and Smootify shows the right one;
- a hidden `select` with options (the configurator's `value|formula` options, with their visible text), number
  and range inputs, a Webflow Dropdown built from a toggle and a list, a template moved into another element, a
  block placed next to another, a collection list, a page wrapper.

**Field names** come from the catalogue (contract §2.13), not from the layer: a field inside an add-on picker
takes any Name, the configurator's popover keeps one template button for all its options, the cart's gift card
field is `gift-card`, `booking-form` reads `name`, `email`, `phone`, `note`.
