---
name: figma-to-webflow-smootify
description: Translates Figma designs into a Smootify store, either as Webflow components using the Figma and Webflow MCP servers or as an Astro project using @smootify/astro, driven by plain-text `@element`/`@style`/`@component`/`@prop`/`@bind`/`@attr`/`@manual` annotations placed on Figma layers. Use this whenever the user shares a Figma file/frame URL and asks to build, recreate, or implement it in Webflow, or in an Astro site ("Figma → Astro", "build this in my Astro site"), whenever they mention turning a Figma component into a Webflow component (or an Astro component), or whenever Figma layer annotations using these directives come up — even if they don't say "Webflow" explicitly but do have both Figma and Webflow MCP tools available. Also use it to interpret existing `@`-prefixed annotations already present in a Figma file's layers. This is the Smootify fork: it carries the Smootify element/attribute catalogue in `references/`, builds into Webflow (Webflow MCP) or into an Astro project (@smootify/astro) from one `references/target-*.md` file chosen in Phase 0, and hard-prohibits, on Webflow, the builder tool that destroys custom tags.
---

# Figma → Webflow / Astro

## Overview

Standardized workflow to translate Figma designs into a Smootify store, with one of two outputs: Webflow components built through the Webflow MCP (`references/target-webflow.md`), or an Astro project built with `@smootify/astro` (`references/target-astro.md`). The annotations are written by `figma-annotate-smootify` in **annotation format 2** (`references/annotation-format.md`): one Dev Mode annotation per layer, category `Smootify`, all directives on one line.

Annotations are read from the layer's **Dev Mode annotation**, which is what `figma_get_design_context` returns (as `data-smootify-annotations`), or in one pass over the whole page with `use_figma` (`node.annotations`, the `labelMarkdown` of the `Smootify` category). If a layer carries directives in its name or description instead, they will not be picked up — move them into a Dev Mode annotation first.

## Choose the output (Phase 0)

The same annotated Figma file builds into Webflow or into Astro. Decide before the first element:

1. Read the licence of the **Smootify site id** (`@setup: site=`, or the one the person gives; on Webflow it is the Webflow site id, on Astro the id Smootify generated): `https://cdn.smootify.io/keys/<Smootify site id>.json`. Its field `f` is the platform: **`0` (or the field absent) = Webflow, `1` = Astro**. Any other value (`2`, `3`…): **stop** and tell the person "this platform is not supported by this version of the skill: update the skill". If the file answers 404, the fetch fails or there is no network, do not stop and do not guess from the id: go to step 2.
2. No site id, or no licence to read: the Webflow MCP connected together with a Webflow site id means **Webflow**, and it wins over everything else (a repository can hold an Astro project while the build goes to Webflow). Otherwise an `astro.config.mjs` in the working directory, or a request that names an Astro project or folder, means Astro. Neither: Webflow.
3. Then **read the whole target file before building**: `references/target-webflow.md` or `references/target-astro.md`. **Everything in the target file wins over the generic wording in this file.** On Webflow, the ban on `data_whtml_builder` comes right after the target file's short overview: read it first.

**On Webflow, never `data_whtml_builder`**: it deletes custom tags and non-`data-*` attributes (details in `target-webflow.md`).

This file is the common core: annotation format, directive meanings, how to read the Figma file, the Smootify rules that are runtime truths on any platform, the catalogue and the report. The target file says how each of them is written on that platform.

## Annotation format 2

**`references/annotation-format.md` is the contract. Read it before building.** It lists every directive, the
node each one goes on, and how to read them. The points that change how you build:

- **Parse by `@` token, never by line.** Newlines do not survive the MCP. Split on `(^|\s)@([a-z][a-z-]*):\s*`,
  then unescape `\_` → `_`, `&lt;` → `<`, `&gt;` → `>`.
- **`@element` is optional.** `@tag` with a Smootify custom tag means a custom-tag element (`BY_CUSTOM_TAG`);
  `@element: DOM @tag: button` is a real `<button>`, which every Smootify `button[...]` selector needs — a
  Webflow Button is an `<a>`, a FormButton an `<input>`. Otherwise fall back to the tables below.
- **Prop defaults carry no quotes**: `@prop: text Title = Summer sale`. `text` is the `textContent` type.
- **Classes**: `@style` as written, base first. Without `@style`, `sm-` + the kebab-case layer name.

### What each directive means

How each one is written is in the target file (*How each directive is built in Webflow / Astro*).

| Directive | Meaning |
|---|---|
| `@setup` | Read it first: `site=` is the Smootify site (ask if `none`); `image=url` means the product pictures are plain `img` with `src` / `alt` from the data. The other answers are already in the annotations |
| `@ask` | **Do not build** the node's Smootify part. List it first in the report: the annotation is not finished |
| `@skip` | Do not build the node |
| `@repeat` | Build this node once; Smootify repeats it. Its `@skip` siblings are drawn copies |
| `@wrap: <tag or element> over <a>..<b>` | A new wrapper around the siblings from `a` to `b`; `@attr: wrap …` and `@cms: wrap attr:…` on the same node go on it |
| `@target: <layer>` | The node's directives apply to that descendant (a group that could not hold them) |
| `@component` `@group` `@desc` | A reusable component; the group is the Figma page, the description its documentation |
| `@prop` + `@tip` | A property of the component, with its tooltip |
| `@bind: text\|image\|alt\|link\|domId\|attr:<name>\|visibility = P` | The element's text, image, alt, link, id, an attribute or its visibility follows prop `P` of the nearest component |
| `@slot` | Where the person placing the component puts content |
| `@axis: X = variant` / `state` / `interaction` / `breakpoint` / `split` / `prop` / `sample` | How a Figma property becomes code: a variant (styles per case), a state Smootify toggles with a class, a pseudo-state, responsive styles on the same element, a separate component per value, a prop already declared, or nothing |
| `@attr: name=<Name>` on a form field | The field's name, case included |
| `@set: P = v` | The value of a prop on this instance (`@set: Variant = N` the variant) |
| `@cms: P = Collection.Field` · `@cms: attr:<name>\|text\|image\|link = Collection.Field` | The prop (or the plain element) shows that field of the store's data |
| `@inline: Master` | Copy that master's annotated elements in place of the instance |
| `@element: FormSuccess` / `FormError` | The success / error content of the form around it |
| `@use: Component` | Place that component instead of building the frame |
| `@page: template C` | The page that is the template of collection C |
| `@list: C limit=… sort=…` | A list of the items of collection C |
| `@manual` | Collect for the report, after doing everything the target can do |
| *(no directive)* a tag whose catalogue row must contain `form` | If the design has no form inside it, put one around the tag's content; never a manual step |
| `@note` | Ignore |

The sections below describe the older syntax; where they differ from the format file, the format file wins.

### Bind Validation

Before Phase 4, verify every `@bind` on a component's descendants references a prop already declared via `@prop` on that same component (nearest ancestor with `@component`). If a `@bind` has no matching `@prop`:

- Treat it as a build error for that binding — do not attempt to bind it.
- Add a corresponding line to the `@manual` checklist (e.g. `@manual: "Prop 'X' referenced by @bind but never declared — bind manually or add @prop"`).

### Element Type Fallback (when `@element` is absent)

`@element` is always optional — this includes component root nodes (i.e. a node can have `@component` without `@element`). When absent, infer from the Figma node type:

| Figma native type | Fallback `@element` |
|---|---|
| Text | `Paragraph` (or `Heading` if font size/weight suggests a heading) |
| Rectangle / Square | `DivBlock` (or `Image` if it has an image fill) |
| Ellipse / Polygon / Star | `DivBlock` |
| Frame | `DivBlock` (or `Section` if frame has visible padding) |
| Image / Vector | `Image` |
| Component / ComponentSet | The component's root `@element`, or `DivBlock` if unspecified |
| BooleanOperation | `DivBlock` |
| Line | `DivBlock` |
| Instance of a component | Use the source component's root element |

`@element` always overrides the fallback — if explicitly set, use it; if absent, apply the table above.

## Style Auto-Generation

If a node has no `@style` directive, derive the class name from the Figma layer name:

- Layer `"Product Name"` → `@style: sm-product-name`
- Layer `"Product Card Image"` → `@style: sm-product-card-image`
- Layer `"Variant Button"` → `@style: sm-variant-button`

Apply it automatically during element creation unless `@style` explicitly overrides it.

The layer name is a hint, not the class. When it is sample text ("Caring for solid oak", "S", "92"), a selector
(`a href=/search?q=…`) or another language ("Freccia sinistra", "Percorso"), name the class from the component
and the element's role instead: `sm-metafield-rich-heading`, `sm-size-guide-size-value`,
`sm-gallery-arrow-prev`, `sm-breadcrumb-path`. Keep names short (`sm-search-result-title`, not the full path of
layers), and give a page element a name that no component uses (`sm-cart-page-form`, not `sm-cart-form`).

**One class, one design.** When the same layer name has different designs in different components (a filter
label in a checkbox list and in a dropdown), give each its own class (`sm-filter-checkbox-label`,
`sm-filter-dropdown-label`): a Webflow class has one style.

What the styles carry over from Figma, and what they do not:

- an image (`img`) gets `display: block` and `object-fit: cover`, not the flex layout of its Figma frame;
- Figma's *clip content* becomes `overflow: hidden` only where the design needs it (an image mask, a slider),
  never on a wrapper that holds a popover, a dropdown or a sticky part;
- a negative gap is not a gap: use a negative margin on the children, or nothing;
- a font the site does not have falls back: install it, or use the stack the person chose, before comparing
  screenshots.

**Special case — empty `@style` value:** if `@style:` is present but has no value (as opposed to being entirely absent), do not derive a class from the layer name. The target file says what to do instead.

## Component Decision Rules

A node becomes a component when it has `@component: Name`. All descendants of that node belong to the component. Nested and sibling components follow these rules:

- **Inner components first**: If a node has `@component` and one of its children also has `@component`, build the inner component first.
- **Props on the component**: All `@prop` directives on descendant nodes define the component's props. Collect them at the component level.
- **Bindings scope**: `@bind` references a prop defined on the **nearest ancestor** with `@component`.
- **What changes per use is a prop, never a manual step.** When an instance needs a setting the component does
  not expose (required or not, a placeholder, a link shown or not), add a prop to the component and set it on the
  instance; do not leave it to the person in the Designer.
- **Sibling components are not rebuilt, they are instanced.** If several sibling nodes at the same depth share `@component: Name` (or are Figma instances of the same component), build it **once**, then place an instance for each remaining occurrence and set its props. Per-instance differences are never `@manual`.

### Prefer components, and make the difference a prop

When a node repeats with the same structure, it is a component, even when every occurrence differs. Differences are props, not copies:

- text, an image, a link, whether something shows, an attribute's value (`cart=`, `data-option=`): a prop (`textContent`, `image`, `link`, `boolean`, `string`);
- visual style (muted, emphasised, active): a **variant**, not a second component;
- layout at another breakpoint: nothing, the same element with responsive styles;
- a block drawn only in the Tablet or Mobile frame (a filter bar that replaces the sidebar, a tab bar that replaces the side nav): build it too, hidden at the breakpoints that do not draw it, the Desktop counterpart hidden in turn. Never leave it out as "tablet only": the review checks all three widths;
- an element that exists in one case and not in another: a **second component** (the Webflow note on conditionals is in `target-webflow.md`; on Astro a `boolean` prop can also show or hide it);
- parts that only work together (a trigger and the panel it opens, a field and its results panel): **one component**, with both inside the Smootify element that ties them;
- a block that exists only in a **state** variant (out of stock, logged in, empty, reached): build the union in the one component, the base plus the block of each state variant with the `condition` / `data-state` its annotation gives. Smootify shows the right one. Never a `@manual` that says "add the block of variant X".

Build **one** component per structure. Two are justified when the *structure* differs, never when only a value does. The Webflow-specific rows (slots inside a Form, conditionals) are in `target-webflow.md`.

### Naming and grouping

**Mirror the Figma file.** The Figma page a component lives on is its group; its Figma name is its name, unchanged: a designer who can find `Cart line` under *Cart* in Figma must find it in the same place in code. Names are human and unprefixed (`Cart line`, `Summary row`, `Free shipping bar`; no `smootify-` prefix, the tag is in the markup). The description says what the thing is and what its constraints are, not what it looks like. Variant names describe the case, not the styling (`Muted`, `Total`, `Compact`).

## Smootify rules the build must apply

Learned on the starter build (beta.10, October 2026). Each one cost a question or a manual step there.


- **A trigger lives in the element it opens.** `data-action="open-cart"` opens only the `smootify-cart` that
  contains the button: the cart icon goes inside the same `smootify-cart` as its drawer panel, not in another one.
  The same for the other Smootify triggers: check the catalogue's context before placing a trigger elsewhere.
- **Where a value goes is part of the attribute.** `data-prop` goes on the children of `smootify-price`
  (`price`, `compareAtPrice`, `total`), never on the host: a price annotated on the host stays empty. An amount in
  a button ("Buy now · € 120") is a `smootify-price` with a `[data-prop="total"]` child inside it. `option-values`
  goes on the element Smootify repeats per value (the swatch), not on the flex row that holds the copies.
  `product="url"` and `cart-item="url"` write the product title into an element whose only child is text: when the
  link keeps its own label ("View product"), put the label in a child element.
- **A second button for the same form is tied with `form`.** A sticky add-to-cart bar repeats the button, not
  the element: a submit with `form="<id of the add-to-cart form>"` outside it, never a second
  `smootify-add-to-cart`. Smootify gives it the same states as the button inside.
- **One cookie banner per site.** One `smootify-consent` (in the Footer component, so every page has it);
  anywhere else, a cookie policy page included, a `button[data-is="preferences-button"]` reopens its preferences.
- **Email preferences are two forms.** A subscribe toggle is a `customer-subscribe-email` and a
  `customer-unsubscribe-email`, each shown by its condition (`customer-condition="email-not-subscribed"` /
  `"email-subscribed"`), each with a `button type="submit"` drawn as the toggle (`aria-pressed` and an
  `aria-label` saying what it does). The submit does the change: no Save button.
- **References in a `metaobject-creator` form are hidden inputs.** A product reference is an
  `input type="hidden"` with the field's name, whose value is the product's Shopify ID (a CMS binding on the
  template); a variant reference is an `input type="hidden"` with `variant="id"` inside `smootify-product`, which
  follows the chosen variant.
- **Sort and cart options take values.** A sort component's `selected-value` is one the page offers (Best
  selling on a collection; on a search only relevance and the two prices exist); its labels are renamed with
  `window.SmootifySortLabels` in the head, before Smootify. `smootify-cart[data-open]` takes a value (`on-add`),
  not a bare attribute.
- **A list of products to pick in a form** (a gift list, an alert for several products) is a Collection List whose
  checkbox `value` is bound to the item's Shopify ID: a checkbox with no value sends `on`.
- **Where the design draws a Smootify value with a fixed width**, leave the element free to grow or to cut with
  an ellipsis: the sort toggle, an option name and a price change length with the data. An element Smootify fills
  as a background image (`data-prop="flag"`) gets `background-size: cover` and `background-position: center`.
- **Field names.** Read the Name from the catalogue (contract §2.13), not from the layer:
  - a field inside an add-on picker takes any Name (Webflow wants one): Smootify renames it;
  - a configurator dropdown or popover reads a hidden `select` whose options are `value|formula` with the visible
    text; the popover keeps **one** template button, Smootify repeats it per option;
  - the cart's gift card field is `gift-card`, the discount field `coupon`;
  - `booking-form` reads `name`, `email`, `phone`, `note`.
- **Search & discovery filters.** A filter's `label` must be the label of a filter set in the store's
  Search & Discovery app (Availability, Price, Color…), or Smootify removes the filter.
- **Elements Smootify removes when the store lacks their data.** Check the store before building, or the page
  comes out empty: `store-locator` without `data-api-key` (the store list goes too, not only the map);
  `smootify-magic-box` whose `data-handle` is not the handle of a Magic Box entry in the store; a booking
  element on a product that is not bookable. List what the store must have in the report.
- **Inside the cart form, cards add with a button.** A cart upsell card sits in the cart's Form, so it adds with
  `button[data-is="direct-add-to-cart"]`, never an add-to-cart form (Webflow does not nest forms).
- **Counters Smootify writes.** Before writing a number as static text, look for its attribute: "Filters (2)" is
  `filter="active-count"`, the box counters are `data-prop` inside `smootify-magic-box-cart`.
- **Class names.** Name classes from the component and the role (`sm-` library classes for shared parts such as
  buttons), never from a layer's sample text or another language.
- **Every empty state is built.** The annotation lists the empty states (cart, search, collection and filters,
  orders, addresses, subscriptions, store credit, wishlist, gift lists, recently viewed, a day with no slot, 404).
  Build each one with its condition, and check it on the published page with the state forced (an empty cart, a
  customer with no orders). If one has no design, do not leave the section blank: use the site's Empty state
  component, say so in the report, and ask the person to approve it.
- **System pages first.** The 404 (and the other utility pages the design draws) goes in the plan with the first
  pages, not at the end: while pages are missing, every link to them lands on it, and on a theme that is not a
  starter it must be the designed one, not Webflow's default.
- **An `edit-address` without the country select is a "Set as default" form.** It sends only the address id and
  `defaultAddress`, and the address stays as it is. The country and zone selects are required only in a form that
  edits the address: do not add them, hidden, to a "Set as default" button.
- **The search page has three states.** `[search="no-query"]` before a search (suggestions, popular searches),
  `[search="with-query"]` once there is one (the "Results for …" line and the results), `[search="empty-state"]`
  when it finds nothing; the host gets `has-query` and `is-empty`. Outside `with-query`, `search="query"` has no
  query to write and keeps its text: the line that shows it goes inside `with-query`. The field can be
  `input[type=search]`; its Clear is a `button type="reset"`, and the browser's own clear icon is hidden in the
  site CSS when the design draws one.
- **The predictive search's host classes.** `smootify-search` gets `has-products` / `is-empty` only once a query has
  an answer: style the "Products" heading and "View all results" region from `has-products`, the "nothing found"
  text from `is-empty`, never from the field being filled.
- **Store credit's empty state.** `store-credit` stays on the page with a zero balance; the "no credit yet" state
  is `customer-condition="no-store-credit"`, the card with a balance `has-store-credit`.
- **Policies are Shopify's HTML.** `policy="refund|terms|privacy|shipping"` writes the policy's HTML from the
  admin: style its `h2`, `p` and `ul` with descendant selectors in the site custom code (the style API cannot write
  them). Numbering the sections as the design draws them is a CSS counter, only on a policy the merchant wrote:
  Shopify's automatic privacy policy has its own headings.
- **Every Smootify submit button has both states.** `[data-state="default"]` and `[data-state="loading"]` go inside
  every submit of a Smootify form, the compact ones too (a "+ Add" in a table row, a "+ Quote list"): without the
  loading child the click gives no feedback while the request runs.
- **A link whose only text is a customer field gets a fallback.** `customer="first-name"` alone inside the header
  account link leaves an empty, invisible link for a customer without a first name: add `data-fallback="Account"`
  (or the design's word) to the bound element.
- **Breadcrumbs link every crumb that has a page.** A Breadcrumbs component with one text prop for the trail leaves
  "Account" unclickable on the account pages: give it an optional linked parent (a boolean, a label and a link prop)
  and keep the text prop for the crumbs that have no page ("Service", "Legal").
- **The consent preferences button hides while the banner shows.** `button[data-is="preferences-button"]` is
  hidden while the cookie banner is on screen and shows once the shopper has chosen: that is how it works, not a
  bug to fix.
- **Toasts are one global component.** `smootify-toasts` goes once per page, in a component that is on every page,
  with a class that places it (position fixed and its offsets); each `[toast="…"]` template inside it is designed in
  place (the Designer shows them, the published site hides them), with `[toast-item]` on the parts Smootify fills and
  `button[data-action="close"]`. On a site without a mini cart, the `added-to-cart` template is what tells the
  shopper the product is in the cart: build it when the design draws a toast, and its "View cart" is a link to the
  cart page with `data-action="open-cart"`. Optional parts (`variant-title`) are hidden when empty: design the toast
  so it holds without them.
- **Smootify's tags are inline.** A `smootify-*` custom element (and every other Smootify tag) is `inline` by
  default, like any unknown HTML tag: give its class `display: block` (or flex, grid) whenever it carries layout,
  or widths, margins and gaps on it do nothing.
- **Icons follow their control.** An SVG icon inside a button or link uses `currentColor`, so it follows the
  text colour in every state; an icon that fills on a state (a filled heart) loses its own `fill` attribute and
  gets `fill` from the class and its state combo. Every clickable element that is not a link or a button
  (thumbnails, swatches, clickable cards) gets `cursor: pointer`.
- **Rows drawn at one height stay at one height** with real texts of different length: stretch the cards and pin
  the price or the button to the bottom.
- **Error states carry a text.** Smootify blocks an invalid configurator field without the browser's message: build
  each `error-message` the design draws, with the field's limits, and the `is-invalid` style on the field.
- **A variant's size comes from all its instances.** Before giving a component variant an `aspect-ratio` or a
  height, look at every instance of that variant in the file: a ratio taken from one frame (a card 221 px wide on
  the tablet home) is wrong where the same variant is 432 px wide. When the image keeps one height at every width,
  the rule is that height.
- **Images are the picture alone, at 2x.** Export the image fill of the picture's rectangle, never the whole card
  (photo, band and text), or the text comes back wherever the image is reused. `get_screenshot` does not go past
  the node's size: take the originals with `download_assets` on the frame that holds the photography, and match
  them to the layers by SHA-1 = `imageHash`. Never add temporary layers to the Figma file. Product and collection
  pictures stay in Shopify.
- **A popover is never inside a template Smootify repeats.** Never put a popover inside a template Smootify repeats (an address card, a cart line): every copy repeats the id. Use `details` / `summary` there.
- **The cookie preferences' Necessary box** is checked, disabled and without a `name`; the other categories stay switchable.
- **Required fields**: Smootify reads `data-required="True"` / `"False"` on a field and makes it required in every form of the page. How the attribute is written depends on the output (see the target file).
- **Popover panels and their styles.** With Smootify loaded, a closed popover stays hidden whatever `display` its class has, so give the panel its layout on its class. Smootify adds no backdrop: where the design draws one (a cart drawer, a dialog), set `--smootify-backdrop-color` on the panel's class. A panel that is a popover only on small screens gets `--smootify-closed-display: flex` at the desktop breakpoint, with `position: static`, `inset: auto` and `margin: 0`, and `none` below.

The rules that are about the platform's own mechanics (Webflow's Popover element, Field Labels, reserved attributes, the Designer…) are in the target file.

## Catalogue, glossary and `check_markup`

- `references/smootify-catalog.md` is the catalogue: every Smootify tag with where it must sit (*Dentro*), what it must contain, what happens outside its context, the extension it needs and its host attributes. Read the context column before placing a trigger or a child.
- `references/glossary.json` is the glossary of attribute values: on what kind of element each value goes and which values repeat the element. For a value, the glossary decides; the catalogue's value list is only names.
- With the Smootify MCP connected, run `check_markup` on what you built (on Webflow, on each component's tree with the Smootify elements it will sit in; on Astro, on the built HTML of every page), and use `resolve_vocabulary` / `get_example` for a value or a structure the annotation lacks instead of guessing. Never invent an element or an attribute value.
- `check_markup` answers "unknown" for what no rule can check: say so in the report, never read it as approval.

## Workflow

### Phase 0: Decide the output, ask for everything the build needs

Choose the output (above), read the target file, then **ask for everything the build needs in one message**, before building. What it holds is in the target file (*Phase 0*); in both outputs it covers the site and its licence (plan and extensions the design uses), the store being ready (products, collections, the metafield and metaobject definitions the design reads), the Customer Account API client id when the design has account parts, and the redirects, policies and admin settings the design depends on.

**Ask only what the person decides.** A question the catalogue, the contract or the annotation already answers
(which attribute, which state class, which value) is not a question: apply it and write the choice in the report.
Ask about what the design does not settle (copy, a variant, whether to build a proposal), and group those
questions instead of stopping on each.

### Phase 1: Analyze

1. Call `figma_get_design_context` for the target frame
   (the annotations of component masters are not in its result: read them with `use_figma`, `node.annotations`, category `Smootify`; on a whole page it truncates, so call it per section)
2. Parse the `Smootify` annotation of every node by `@` token (see *Annotation format 2*); stop and report every `@ask` before building
3. Build a tree of components vs static elements
4. For nested components, identify the inner-most components first
5. Collect all `@manual` directives for the final summary
6. Identify the root node of the component (the one with `@component`)

### Phases 2–5: Build

Follow the target file: *Phases 2–5* in `references/target-webflow.md` (root, props, children with bindings, root bindings, through the Webflow MCP), *Build (Phases 2–5 for Astro)* in `references/target-astro.md`. Inner components first; one component per distinct structure.

### Phase 6: Verify

The target file has the checks of its platform (*Phase 6*, or *Verify (Phase 6 for Astro)*). Use the output as a shopper would, with Smootify running, at desktop, tablet and mobile width:

   - every card, link and button goes somewhere: no `href="#"` left, cards open their product or collection;
   - every panel opens from its trigger, closes, and does not cover what opened it;
   - lists and pages with no data (empty cart, no reviews, nothing recently viewed, a visitor not logged in) show
     their empty state or hide, never a bare title;
   - text the runtime fills (names, prices, counts, the searched words) changes with the data;
   - forms send the Names Smootify reads; nothing overflows sideways on mobile;
   - every product picture is an `img` (never an empty slide that Smootify fills as a background), and on a CMS
     template its `src` and `alt` are bound to the CMS, so the page shows it before Smootify loads; images Smootify
     fills carry `max-width` (about twice their displayed width, such as `192` on a 96px thumbnail);
   - a state style (the active thumbnail, the selected swatch) sits only on its combo class (`is-active`), never on
     the base class, or every item looks selected;
   - no block ships empty: every accordion item, tab pane and panel has its bound rows or its text;
   - every link template Smootify fills (`[product=url|link]`, `[cart-item=url]`, `[subscription=url]`,
     `[order=url]`) has a fallback URL (`/shop`), so the published HTML never carries `href="#"`;
   - `img[src=""]` and similar checks run on the rendered DOM, not on the HTML: a selector in the head CSS is a false
     positive;
   - while pages are still missing, the report lists the links that lead to them.
   - every state class the catalogue lists for what you built (`is-active`, `is-disabled`, `is-done`, `is-invalid`, `is-full`…) has a style that shows it, checked with the state forced, and a disabled control looks disabled;
   - in a product list or on a product template, the card's title, price, compare-at price and link are real content in the HTML, not sample text for Smootify to replace: search engines read it before Smootify loads.

What fails goes in the report before anything else: a component or page that renders but cannot be used is not done.

### Phase 7: Inner and Sibling Components

Build each distinct inner component fully (Phases 1–6), once per distinct component, not once per occurrence; place it wherever it recurs, then continue with the outer one (on Webflow with `insert_component_instance`, on Astro with an import).

### Phase 8: Manual Summary

Do every `@manual` the target can do (Webflow: with the calls in `references/mcp-recipes.md`; Astro: in code, there is no Designer). Write each one in the report as "done by hand", with its node, so the annotation can turn it into a directive next time. Collect what is left, the steps no tool can do, into a checklist for the person, and present it as remaining work.

## Summary Output Template

```
## ✅ Automated — Complete
- Component "X" created with N props
- [prop] → [element] binding set
- All styles applied
- All static attributes set

## 🔧 Manual Steps Required
- [ ] @manual content line 1
- [ ] @manual content line 2
```

## Example

The complete component at the end of `references/annotation-format.md` — a set with a prop axis and a state
axis, a repeated value, drawn copies and a placed instance — is the reference case.
