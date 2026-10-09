---
name: figma-to-webflow-smootify
description: Translates Figma designs into Webflow components using the Figma and Webflow MCP servers, driven by plain-text `@element`/`@style`/`@component`/`@prop`/`@bind`/`@attr`/`@manual` annotations placed on Figma layers. Use this whenever the user shares a Figma file/frame URL and asks to build, recreate, or implement it in Webflow, whenever they mention turning a Figma component into a Webflow component, or whenever Figma layer annotations using these directives come up — even if they don't say "Webflow" explicitly but do have both Figma and Webflow MCP tools available. Also use it to interpret existing `@`-prefixed annotations already present in a Figma file's layers. This is the Smootify fork: it carries the Smootify element/attribute catalogue in `references/` and hard-prohibits the builder tool that destroys custom tags.
---

# Figma → Webflow MCP Skill

## Overview

Standardized workflow to translate Figma designs to Webflow components using MCP tools. The annotations are written by `figma-annotate-smootify` in **annotation format 2** (`references/annotation-format.md`): one Dev Mode annotation per layer, category `Smootify`, all directives on one line.

Annotations are read from the layer's **Dev Mode annotation**, which is what `figma_get_design_context` returns (as `data-smootify-annotations`), or in one pass over the whole page with `use_figma` (`node.annotations`, the `labelMarkdown` of the `Smootify` category). If a layer carries directives in its name or description instead, they will not be picked up — move them into a Dev Mode annotation first.

## Never use `data_whtml_builder`

**Use `data_element_builder` for every element you create. Never `data_whtml_builder`.**

This is not a style preference. `data_whtml_builder` silently destroys exactly what this skill exists to
produce (verified 2026-09-17):

- **custom tags are deleted** — a `<smootify-product>` disappears and its children are flattened into the
  parent, so the product wrapper that every binding depends on is gone;
- **non-`data-*` attributes are discarded** — `product=title`, `variant=image`, `condition=in-stock`,
  `label=…` are dropped. These are the majority of the Smootify vocabulary.

The failure is silent: the build reports success, the page looks right in the Designer, and nothing works at
runtime. It is also invisible in `get_all_elements`.

`data_whtml_builder` may look like a faster bulk path when you are building many elements. It is not a
trade-off — it produces a broken page. If you catch yourself reaching for it, use `data_element_builder` with
`type: "BY_CUSTOM_TAG"` + `custom_tag` (or `type: "DOM"` + `set_dom_config`) and set attributes afterwards
with `set_attributes`.

## An attribute CAN vary per instance — and you can build the whole chain

Tested end to end on a real site, 2026-09-21. All three legs work through the MCP:

1. **Create the prop** — `data_component_props_tool > create_prop`, type `string`.
2. **Bind the attribute value to it** — `data_element_settings_tool > set_settings`, key `attributes`,
   using **`static_json`**. The documented `value_binding` branch is broken; see below.
3. **Set a different value per instance** — `set_component_instance_prop_values`.

**Step 2 is the trap.** This is what the schema advertises, and it fails:

```
attributes: [{ name_static: "cart", value_binding: { source_type: "prop", prop_id: "…" } }]
→ "value must be a string or a binding"
```

This is what works — the raw stored shape, passed as JSON:

```
{ key: "attributes",
  static_json: { value: '[{"name":"cart","value":{"sourceType":"prop","propId":"<id>"}}]' } }
```

Only `propId` is required; the server fills in `propName` and `propGroup`. Verify with `get_attributes`:
without `with_resolved_bindings` you should see the binding object, with it the resolved value.

**So build one component, not one per value.** An element whose Smootify attribute must differ per instance
is still a single component: give it a `string` prop, bind the attribute to it, and set the value on each
instance. Do not emit `@manual` for this, and do not build N components — that advice was based on a
limitation that does not exist.

- `domId` binds the ordinary way, via `set_dom_id` with `binding`.

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

How each directive is built:

| Directive | Build |
|---|---|
| `@setup` | Read it first. `site=` is the site to build on (ask if `none`); the other answers are already in the annotations: `image=url` means the image nodes are `DOM img` with `src`/`alt` bound to props that `@cms` connects to Image URL / Image Alt |
| `@ask` | **Do not build** the node's Smootify part. List it first in the summary: the annotation is not finished |
| `@skip` | Do not build the node |
| `@repeat` | Build this node once; Smootify repeats it. Its `@skip` siblings are drawn copies |
| `@wrap: <tag or element> over <a>..<b>` | Create the wrapper (a custom tag, or a Webflow element type such as `DivBlock` or `FormBlock`) and move the siblings from `a` to `b` inside it. Then `@attr: wrap …` and `@cms: wrap attr:…` on the same node go on the wrapper |
| `@target: <layer>` | Apply the node's directives to that descendant (a group that could not hold them) |
| `@component` `@group` `@desc` | `transform_element_to_component` with `group` and `description` at creation |
| `@prop` + `@tip` | `create_prop` with the tooltip |
| `@bind: text\|image\|alt\|link\|domId = P` | `set_settings` binding to the prop (`domId` with `set_dom_id`) |
| `@bind: attr:<name> = P` | The `static_json` recipe of *An attribute CAN vary per instance* |
| `@bind: visibility = P` | `set_visibility` with a prop binding |
| `@slot` | `data_element_builder` type `ComponentSlot` in the component |
| `@axis: X = variant` + `@variant: N` on each variant | `create_variant` N, then `set_variant_styles` with what that variant changes |
| `@axis: X = state` + `@state: <class> on <layer>` | A combo class style `<base>` + `<class>` on that layer with what the state changes. Not a Webflow variant |
| `@axis: X = interaction` | Pseudo-state styles (`hover`, `focus`, `pressed`) on the class |
| `@axis: X = breakpoint` | Responsive styles on the same element, from the other frame's values. Never a second element |
| `@axis: X = split` | Each variant carrying `@component` is a separate component |
| `@axis: X = prop` / `sample` | Already covered by the prop it names (a `boolean` bound to visibility, or a `string` bound to `attr:`) / nothing |
| `@attr: name=<Name>` on a form field | The field's Name setting (element settings), not a custom attribute; keep the case |
| `@set: P = v` (and `@set: Variant = N`) | `set_component_instance_prop_values`; the variant takes its id from `get_component` with `includeVariants`. `@set: P = prop:Q`: the same call with `type: bindable`, `binding_source_type: prop` and `binding_prop_id` = the id of prop Q of the component being built, with `scope_component_id` set to it |
| `@cms: P = Collection.Field` · `@cms: attr:<name>\|text\|image\|link = Collection.Field` | Bind the instance prop to the CMS field; the `attr:`/`text`/`image`/`link` form binds a plain page element (a wrap too). On a plain element, the attribute's CMS recipe (`static_json` with `sourceType: "cms"`, see Limitations). If binding an instance prop to CMS fails through the MCP, report it as a manual step with the exact field |
| `@inline: Master` | Build a copy of that master's annotated elements in place of the instance (not a component instance); bind its `@bind`s to the props of the component it lands in, matched by name |
| `@element: FormSuccess` / `FormError` | The content of the Form Block's Success / Error message (the one you add for the tag, or the drawn one) |
| `@use: Component` | Insert an instance of that component instead of building the frame. On a main component: build no component for it, and place the target (with its `@set` values) wherever its instances are |
| `@page: template C` | Build on the CMS template page of collection C |
| `@list: C limit=… sort=…` | A Collection List (`DynamoWrapper`) with `source`, `limit`, `sort` set through `set_settings` |
| `@manual` | Collect for the summary |
| *(no directive)* a tag whose catalogue row must contain `form` | If the design has no form inside it, wrap the tag's content in a Form Block yourself (FormWrapper > FormForm, with its Success and Error messages), then put the fields inside. It is never a manual step |
| `@note` | Ignore |

The sections below describe the older syntax; where they differ from the format file, the format file wins.

### Bind Validation

Before Phase 4, verify every `@bind` on a component's descendants references a prop already declared via `@prop` on that same component (nearest ancestor with `@component`). If a `@bind` has no matching `@prop`:

- Treat it as a build error for that binding — do not attempt to bind it.
- Add a corresponding line to the `@manual` checklist (e.g. `@manual: "Prop 'X' referenced by @bind but never declared — bind manually or add @prop"`).

## Element Type Mapping

| `@element` | Webflow `type` | Notes |
|---|---|---|
| `DOM` | `type: "DOM"` + `set_dom_config` | Standard tags: section, nav, header, footer, main, aside, article, span |
| `BY_CUSTOM_TAG` | `type: "BY_CUSTOM_TAG"` + `custom_tag` | Arbitrary tags like `smootify-product`, `web-component` |
| `Image` | `type: "Image"` | Use `@bind: assetId` for swappable images |
| `Heading` | `type: "Heading"` | Use element_builder or set_heading_level |
| `Paragraph` | `type: "Paragraph"` | Text content element |
| `TextBlock` | `type: "TextBlock"` | Inline text |
| `Button` | `type: "Button"` | Supports link binding |
| `TextLink` | `type: "TextLink"` | Inline link |
| `LinkBlock` | `type: "LinkBlock"` | Block link |
| `Container` / `Section` / `DivBlock` | Respectively | Use `@tag: div` to retag after creation |
| `CMSCollection` | `type: "CMSCollection"` | **Manual** — must be bound to CMS in Designer |
| `CMSSlot` | `type: "PageSlot"` | **Manual** — CMS slot for dynamic content |
| `Form` | `type: "Form"` | Form wrapper — create it, then configure submission manually |
| `FormTextInput` | `type: "FormTextInput"` | Single-line text input |
| `FormTextarea` | `type: "FormTextarea"` | Multi-line text input |
| `FormSelect` | `type: "FormSelect"` | Dropdown select |
| `FormCheckboxInput` | `type: "FormCheckboxInput"` | Checkbox |
| `FormRadioInput` | `type: "FormRadioInput"` | Radio button |
| `FormFileUploadWrapper` | `type: "FormFileUploadWrapper"` | File upload |
| `FormButton` | `type: "FormButton"` | Submit button |
| `FormBlockLabel` | `type: "FormBlockLabel"` | Field label |

**Form elements can be built with `element_builder`.** A form's redirect is `set_settings` key `redirect` on the
form (`FormForm`, value `/newsletter-confirmed`); the email notification stays manual.

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

**Special case — empty `@style` value:** if `@style:` is present but has no value (as opposed to being entirely absent), do not derive a class from the layer name. Instead, fall back to the default Figma→Webflow MCP class-generation behavior for that element.

## Component Decision Rules

A node becomes a component when it has `@component: Name`. All descendants of that node belong to the component. Nested and sibling components follow these rules:

- **Inner components first**: If a node has `@component` and one of its children also has `@component`, build the inner component first.
- **Sibling components are not rebuilt — they're instanced**: Webflow components aren't rebuilt per occurrence. If multiple sibling nodes at the same depth share `@component: Name` (or are Figma instances of the same component), build it **once**, then insert instances via `insert_component_instance` for each remaining occurrence, and set each instance's props (see *Props on instances* below). Do not flag per-instance differences as `@manual`: they are settable.
- **Props on the component**: All `@prop` directives on descendant nodes define the component's props. Collect them at the component level.
- **Bindings scope**: `@bind` references a prop defined on the **nearest ancestor** with `@component`.

### Prefer components, and make the difference a prop

This project goes **full components** in Webflow. When a node repeats with the same structure, it is a
component — even when every occurrence differs. Differences are props, not copies:

| What differs between occurrences | How |
|---|---|
| Text | `textContent` prop, bound to the element's `text` setting |
| A Smootify attribute's value (`cart=`, `data-option=`) | `string` prop, bound to the attribute — see *An attribute CAN vary per instance* above |
| Visual style (muted, emphasised, active) | A **variant**, not a second component |
| **An element that exists in one case and not another** | A **second component** — not a conditional, see below |
| Layout at another breakpoint | Nothing — same element, responsive styles |
| An image, a link, whether something shows per instance | `image` / `link` / `boolean` prop |
| A slot that would sit inside a Form | A **second component** with the content placed directly: Webflow rejects slots inside a Form ("Slots can not be placed inside Form"), so an Add to cart or a metaobject form with different pickers or fields is one component per layout |
| Parts that only work together (a trigger and the panel it opens, such as the cookie preferences button and the consent banner; a field and its results panel) | **One component**, with both inside the Smootify element that ties them. Two components that must be placed in pairs, and stay in the same element, are a build error |
| A block that exists only in a **state** variant (out of stock, logged in, empty, reached) | Nothing to choose: build the union in the one component, the base plus the block of each state variant with the `condition` / `data-state` its annotation gives. Smootify shows the right one. Never a `@manual` that says "add the block of variant X" |

Build **one** component per structure. Two components are justified when the *structure* differs — an
element present in one case and absent in another — and never when only a value does.

> **Webflow can do better than this, and we are deliberately not using it.** A conditional on `visibility`
> lets one component show or hide elements depending on the active variant, which would absorb structural
> differences too. But conditionals cannot be authored through the MCP — `visibility` reads back as
> `{sourceType: "conditional"}` and the condition itself is not exposed, written, or resolvable — so every
> one of them is a manual step in the Designer, per component.
>
> **Do not design around conditionals for now.** A second component costs
> the agent nothing to build; a conditional costs a person. Prefer the second component, and revisit if
> Webflow ever exposes conditionals through the MCP.

### Naming and grouping

**Mirror the Figma file.** The Figma page a component lives on becomes its Webflow **group**; its Figma
name becomes its Webflow **name**, unchanged. The two libraries are meant to be the same library seen from
two sides, and a designer who can find `Cart line` under *Cart* in Figma must find it in the same place in
Webflow.

- Pass `group` and `description` on `transform_element_to_component` — not afterwards. Both are accepted at
  creation, and a component created without a group lands loose in the panel where nobody looks.
- The `description` is the component's documentation and it **travels to the agent**: it shows up in
  `get_design_context`. Write what the thing is and what its constraints are, not what it looks like.
- Names are human and unprefixed — `Cart line`, `Summary row`, `Free shipping bar`. No `smootify-` prefix:
  the tag is in the markup, not in the name.
- Variant names describe the case, not the styling — `Muted`, `Total`, `Compact` — because they read as
  `Component / Variant` in the panel.
- Use `set_component_metadata` only to fix an existing component; prefer getting it right at creation.

### Props on instances

All three legs work through the MCP. Verified 2026-09-21.

1. **Define** — `data_component_props_tool > create_prop` with `component_id` and `props[]`. Types:
   `textContent`, `string`, `richText`, `image`, `link`, `video`, `number`, `boolean`, `id`, `altText`.
   Give every prop a `tooltip`: it is the only guidance whoever uses the component will see.
2. **Bind** — `set_settings` on the element inside the component definition, passing `scope_component_id`.
   Text binds with `{key: "text", binding: {source_type: "prop", prop_id}}`; `domId` with `set_dom_id`;
   attributes need the `static_json` workaround documented above.
3. **Set per instance** — `set_component_instance_prop_values` with `element_id` and `values[]`, each
   `{prop_id, type, string_value}`. Confirm with `query_elements` and a `component_filter`: the instance
   reports `hasOverride: true` on every prop you set.

**The variant is a prop too.** As soon as a component has variants, Webflow adds a `Variant` prop of type
`variant` by itself. Set it per instance like any other, passing the **variant id** as `string_value` —
`get_component` with `options.includeVariants` gives you the ids. So style-per-instance needs no extra
components and no manual step.

> **Gotcha:** `set_text` inside `element_schema.children[]` does not apply — children are created with
> Webflow's placeholder text regardless. Create the tree first, then set the text with `set_settings`
> (`{key: "text", static_text: {value: "…"}}`) or `set_text`. Check it; do not assume it took.

## Smootify rules the build must apply

Learned on the starter build (beta.10, October 2026). Each one cost a question or a manual step there.

- **Popovers.** When the site has Webflow's Popover element (the beta), use it: the MCP cannot create it yet, so
  place it in the Designer through Claude in Chrome, inside the Smootify element it belongs to, and position it as
  the design draws it. The element writes `popover`, `popovertarget` and the close action itself: add none of them. Its trigger is any Webflow Button or Link Block, with Link → Type *Popover*, its Target and the Action (Toggle, Show, Hide); a close button is the same with Action Hide. A DOM `button` cannot target it. Only on a site without it, build the panel with the `popover` attribute and the trigger with
  `popovertarget`, and give the panel the design's position in the site custom code: without one, the browser opens
  every popover in the middle of the page, which is right only when the design puts it there. Never put a popover inside a template Smootify repeats (an address card,
  a cart line): every copy repeats the id. Use `details` / `summary` there.
- **A trigger lives in the element it opens.** `data-action="open-cart"` opens only the `smootify-cart` that
  contains the button: the cart icon goes inside the same `smootify-cart` as its drawer panel, not in another one.
  The same for the other Smootify triggers: check the catalogue's context before placing a trigger elsewhere.
- **Field names.** Read the Name from the catalogue (contract §2.13), not from the layer:
  - a field inside an add-on picker takes any Name (Webflow wants one): Smootify renames it;
  - a configurator dropdown or popover reads a hidden `select` whose options are `value|formula` with the visible
    text; the popover keeps **one** template button, Smootify repeats it per option;
  - the cart's gift card field is `gift-card`, the discount field `coupon`;
  - `booking-form` reads `name`, `email`, `phone`, `note`.
- **Search & discovery filters.** A filter's `label` must be the label of a filter set in the store's
  Search & Discovery app (Availability, Price, Color…), or Smootify removes the filter.
- **CSS the Designer cannot write lives in the component.** A child styled by its parent's state
  (`is-not-available` on a search result, `is-full` on a booking day), a chevron turned while a popover is open
  (`:has([popover]:popover-open)`), `:has()` rules, a panel's position: put them in a Code Embed inside the
  component, a `<style>` scoped to the component's root class, with its visibility bound to a boolean prop such as
  *Include styles* (default on), so whoever does not want it switches it off on the instance. The site's custom code
  keeps only what belongs to the whole site: Smootify's options, scripts, global variables.
- **Elements Smootify removes when the store lacks their data.** Check the store before building, or the page
  comes out empty: `store-locator` without `data-api-key` (the store list goes too, not only the map);
  `smootify-magic-box` whose `data-handle` is not the handle of a Magic Box entry in the store; a booking
  element on a product that is not bookable. List what the store must have in the report.
- **Inside the cart form, cards add with a button.** A cart upsell card sits in the cart's Form, so it adds with
  `button[data-is="direct-add-to-cart"]`, never an add-to-cart form (Webflow does not nest forms).
- **Counters Smootify writes.** Before writing a number as static text, look for its attribute: "Filters (2)" is
  `filter="active-count"`, the box counters are `data-prop` inside `smootify-magic-box-cart`.
- **Slider arrows.** Smootify does not drive arrows outside a Webflow Slider: the arrows a design draws in a
  section header are the Slider's own arrows, styled and placed there.
- **A name that is a Webflow element is that element.** A component or variant called Dropdown, Tabs, Slider,
  Lightbox or Popover is built with that Webflow element (a Cart dropdown is a `smootify-cart` around a Webflow
  Dropdown, not a button and a popover), because Smootify drives each of them in its own way. Two variants built
  on the same mechanism are one variant drawn twice.
- **Reserved slugs.** Webflow keeps `/search` for its own site search: the page with `smootify-search-page` takes
  another slug (`/search-page`), and every search form's action and `search="search-page"` link point to it.
- **Class names.** Name classes from the component and the role (`sm-` library classes for shared parts such as
  buttons), never from a layer's sample text or another language.
- **What the MCP cannot do**, so it goes to the person, in the report, with the page and the element:
  site redirects, deleting pages, placeholders of native fields, `type="date"` on inputs, the Current state of
  links and tabs, copying a design into the 404 utility page, publishing.
- **Every empty state is built.** The annotation lists the empty states (cart, search, collection and filters,
  orders, addresses, subscriptions, store credit, wishlist, gift lists, recently viewed, a day with no slot, 404).
  Build each one with its condition, and check it on the published page with the state forced (an empty cart, a
  customer with no orders). If one has no design, do not leave the section blank: use the site's Empty state
  component, say so in the report, and ask the person to approve it.
- **System pages first.** The 404 (and the other utility pages the design draws) goes in the plan with the first
  pages, not at the end: while pages are missing, every link to them lands on it, and on a theme that is not a
  starter it must be the designed one, not Webflow's default.
- **Required fields are `data-required`.** Webflow strips a custom `required` attribute, so a Field or Checkbox
  component carries `data-required="True"` / `"False"` (a prop), and Smootify makes the field required in every
  form of the page. Do not replace the component with a native input to get `required`.
- **An `edit-address` without the country select is a "Set as default" form.** It sends only the address id and
  `defaultAddress`, and the address stays as it is. The country and zone selects are required only in a form that
  edits the address: do not add them, hidden, to a "Set as default" button.
- **The search page has three states.** `[search="no-query"]` before a search (suggestions, popular searches),
  `[search="with-query"]` once there is one (the "Results for …" line and the results), `[search="empty-state"]`
  when it finds nothing; the host gets `has-query` and `is-empty`. Outside `with-query`, `search="query"` has no
  query to write and keeps its text: the line that shows it goes inside `with-query`. The field can be
  `input[type=search]`; its Clear is a `button type="reset"`, and the browser's own clear icon is hidden in the
  site CSS when the design draws one.
- **Store credit's empty state.** `store-credit` stays on the page with a zero balance; the "no credit yet" state
  is `customer-condition="no-store-credit"`, the card with a balance `has-store-credit`.
- **Policies are Shopify's HTML.** `policy="refund|terms|privacy|shipping"` writes the policy's HTML from the
  admin: style its `h2`, `p` and `ul` with descendant selectors in the site custom code (the style API cannot write
  them). Numbering the sections as the design draws them is a CSS counter, only on a policy the merchant wrote:
  Shopify's automatic privacy policy has its own headings.
- **The consent preferences button hides while the banner shows.** `button[data-is="preferences-button"]` is
  hidden while the cookie banner is on screen and shows once the shopper has chosen: that is how it works, not a
  bug to fix.

## Webflow rules the build must apply

Also from the starter build: each of these broke something before it was known.

- **Panels and their styles.** With Smootify loaded, a closed popover stays hidden whatever `display` its class
  has, so give the panel its layout on its class. Smootify adds no backdrop: where the design draws one (a cart
  drawer, a dialog), set `--smootify-backdrop-color` on the panel's class. A panel that is a popover only on small
  screens (filters in a column on desktop) gets `--smootify-closed-display: flex` at the desktop breakpoint, with
  `position: static`, `inset: auto` and `margin: 0`, and `none` below. On a `dialog` or a `.w-dropdown-list` a
  `display` on the class still keeps it open: give their layout to the open state in the site custom code.
- **Labels are Field Labels.** A form field's label is Webflow's Field Label element tied to its field (the "For"
  setting), never a text block: a tap on it focuses the field and screen readers read it.
- **Webflow's form defaults.** `.w-input` and `.w-select` have `margin-bottom: 10px` and a fixed height, and
  `.w-radio` / `.w-checkbox` a left padding and a float. Where a field sits in a row with a button (discount code,
  search, newsletter) or in a card, reset them on the field's class, or the row comes out taller than the field
  and the button no longer lines up.
- **A DOM `button` keeps the browser's look.** A Custom element `button` (a consent action, a text link that is a
  button, a toggle) starts with the browser's grey background, border and padding. Reset them on its class
  (`background-color: transparent`, `border: 0`, `padding: 0`, `font: inherit`, `color: inherit`) unless the design
  draws them, or a light text lands on a light background.
- **Required fields on a shared template.** A required field in a block a condition hides (`if-metafield`, Webflow's
  conditional visibility) does not count while hidden; one hidden by CSS or `display: none` still blocks the form.
  On a product template that every product shares, hide such blocks with a condition only.
- **Templates Smootify repeats are Webflow's own elements.** A radio Smootify copies (a subscription plan, a
  configurator choice, a `dynamic-property` with choices) is Webflow's Radio Button (`w-radio` with its Field Label),
  never a Div with a custom input: the custom one is not repeated and its value never reaches the cart. A
  `dynamic-property` checkbox is Webflow's Checkbox (`w-checkbox`). Never wrap the input in a `label` of your own:
  Smootify writes the property's title into every plain `label` inside a `dynamic-property`, so a label that holds
  the input is emptied and the element removes itself. Titles and help texts go in a div or in a Field Label with no
  input inside. These Webflow elements live only inside a Form, so place them in the page's Form of
  `smootify-add-to-cart`, not in a component. Keep the design's classes on them and reset Webflow's offsets (see the
  form defaults above).
- **Everything in a repeated copy follows the same state.** In a template Smootify repeats per value (`option-values`,
  a swatch, a cart line), an element Smootify hides for one value (an `[option-metafield]` with no data gets
  `w-condition-invisible`) does not hide its siblings. When a row only makes sense with that data (a "next batch"
  note and its "Join the waitlist" link), hide the whole row with the state, for example
  `.row:has(> [option-metafield].w-condition-invisible) { display: none; }` in the component's styles.
- **No image without a source.** An image bound to a component prop ships `src=""` when the prop is left empty on an
  instance: give every image prop a default, set it on each instance, and before the report look for `img[src=""]`
  in the published pages. A decorative icon keeps `alt=""`, a picture that means something gets its alt.
- **Error states carry a text.** Smootify blocks an invalid configurator field without the browser's message: build
  each `error-message` the design draws, with the field's limits, and the `is-invalid` style on the field.
- **Reserved attributes.** `id`, `type`, `placeholder`, `value`, `checked` and `disabled` cannot be set as
  attributes. `id` goes through `set_dom_id`; an input `type` through its settings (text, email, password, tel,
  number, url only); the rest is manual.
- **Attributes on a Form Block** land on the inner form, not on the `.w-form` wrapper, and cannot be removed from
  the wrapper afterwards. Put Smootify attributes on the form or on an element around the Form Block.
- **A prop bound to an attribute is a `string`**, whatever the annotation says (a limit, a delay, a flag): a
  `number` prop defaults to 0 and cannot be cleared, so the attribute ships as `limit="0"`.
- **The Current state cannot be styled through the MCP**: a `w--current` combo comes out as `_w--current`. Make
  the nav links of type *page*, so Webflow marks the current one, and leave the style to the person.
- **Not as styles**: a CSS custom property (`--metafield-rating`) and a variable in `accent-color` are refused.
  Put the first in the site custom code, write the second as a literal colour.
- **The Designer canvas is not the site.** It does not load the site custom code, draws `details` closed, keeps
  old snapshots after changes made headless, and cannot reach utility pages. Styles created or updated through the
  data API (`create_style`, `update_style`) are saved and publish, but a Designer already open does not load them:
  the new classes vanish from its canvas and changes to existing ones do not show until the person reloads it.
  Measure only classes the canvas already had; check everything else on the published staging, and say in the
  report what you could only check from the data.
- **A variant's size comes from all its instances.** Before giving a component variant an `aspect-ratio` or a
  height, look at every instance of that variant in the file: a ratio taken from one frame (a card 221 px wide on
  the tablet home) is wrong where the same variant is 432 px wide. When the image keeps one height at every width,
  the rule is that height.
- **A state border over a picture goes on `::after`.** A button with a border and a full-bleed image inside shows
  the border only where there is no image: draw the selected border on an `::after` with `inset: 0` in the
  component's styles (a swatch with a photo).
- **Images are the picture alone, at 2x.** Export the image fill of the picture's rectangle, never the whole card
  (photo, band and text), or the text comes back wherever the image is reused. `get_screenshot` does not go past
  the node's size: for a 2x export, add a temporary rectangle with the same fill at twice the size, take the
  screenshot, delete the rectangle. Product and collection pictures stay in Shopify.

## Workflow

### Phase 0: Install Smootify on the site

Before the first component, read the site's head code (`get_site_freeform_code`) and make sure Smootify loads on
every page. Without it nothing works on the published site, and no check of the Designer or of the markup shows it.

- Add the loader line from the Install guide (docs.smootify.io, *Install Smootify 2.0*) at the top of the head
  code, with the options script before it if the site needs one (template URLs that are not `products`,
  `collections`, `vendors`).
- `set_site_freeform_code` replaces the whole block: write back what was there, plus the loader. The site rules
  of *Webflow rules the build must apply* go in the same block, after it.
- **Customer accounts need the store's Customer Account API client id.** When the design has anything for
  logged-in customers (sign in, account pages, orders, addresses, profile, store credit, entries a customer owns),
  ask the person for it before building those parts, and put it in the options script as
  `newCustomerAccountsPublicKey`. Without it Smootify turns off the login and every account element, so the account
  pages come out empty and nothing in the Designer shows why.
- If the person gives you another install (a test site that loads a local build), use theirs and say so in the
  report.
- After the first publish, check the page source for the line: it is the first thing to look at when a page
  shows sample text instead of products.

### Phase 1: Analyze

1. Call `figma_get_design_context` for the target frame
2. Parse the `Smootify` annotation of every node by `@` token (see *Annotation format 2*); stop and report every `@ask` before building
3. Build a tree of components vs static elements
4. For nested components, identify the inner-most components first
5. Collect all `@manual` directives for the final summary
6. Identify the root node of the component (the one with `@component`)

### Phase 2: Build Root

1. On a regular Designer page, create **only the root element** via `element_builder`
2. Apply `@tag`, `@style` (split by `|` for multiple classes, applied as combo classes; if empty, use default MCP class behavior), `@attr` directives
3. Transform the root into a component via `transform_element_to_component`

### Phase 3: Create Props

1. Open the component canvas via `designer_tool > open_canvas`
2. Create ALL props via `create_prop` — props must exist before binding
3. Validate every planned `@bind` against the created props (see [Bind Validation](#bind-validation)); route unmatched binds to `@manual`

### Phase 4: Build Children with Bindings

1. Use `element_builder` with `scope_component_id` to create children, passing `set_style` (styles) and `set_text`/`set_attributes` (static content) directly in the creation call.
2. **Binding timing depends on element type** — `element_builder`'s `settings[].binding` reliably pre-applies bindings only on plain `DOM` / `BY_CUSTOM_TAG` elements. For built-in element types (`Image`, `Paragraph`, `Heading`, `TextBlock`, `Button`, etc.), bindings set at creation time are unreliable; instead:
   - Create the element first via `element_builder` (style/text/attributes only, no `settings[].binding`).
   - Fetch its element id via `get_all_elements` (`scope_component_id`, `depth: -1`) — nested `children[]` passed to `element_builder` don't return per-child ids in the creation response, so this lookup is required regardless of element type.
   - Bind afterward via `data_element_tool > set_settings`, passing `{ key: <setting key>, binding: { source_type: "prop", prop_id } }`. Confirm the exact setting key first with `get_settings type: "all_raw_settings"` (e.g. `text` for Paragraph/Heading/TextBlock/Button, `assetId` for Image) — don't assume it matches the `@bind` setting-key name verbatim.
3. Static attributes via `set_attributes` with `scope_component_id`
4. Styles via `set_style` with `scope_component_id` (pass the full array of classes from `\|`-separated `@style`)

### Phase 5: Root Bindings

1. Root domId via `set_dom_id` with `scope_component_id`
2. Root static attributes via `set_attributes`

### Phase 6: Verify

1. `get_settings` with `type: "all_raw_settings"` + `scope_component_id` to verify bindings
2. `get_all_elements` with `scope_component_id` to verify tree
3. Insert instance on the target page specified by the requester, take snapshot
4. **On the published page, with Smootify running** (the Designer shows neither the runtime nor the site custom
   code), use it as a shopper would, at desktop, tablet and mobile width:
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
     the base class, or every item looks selected.
   What fails goes in the report before anything else: a component that renders but cannot be used is not done.

### Phase 7: Inner and Sibling Components

If there are nested or repeated (sibling) components:
1. Build each distinct inner component fully (Phases 1–6), once per distinct component — not once per occurrence
2. Use `element_builder` to insert an instance of the inner component wherever it recurs, via `insert_component_instance` on the outer's canvas
3. Then continue building the outer component

### Phase 8: Manual Summary

1. **Do every `@manual` the MCP can do**, with the calls in `references/mcp-recipes.md`: a hidden select with
   options, number and range inputs, a Webflow Dropdown or Tabs, a template moved into another element, a block
   placed next to another, a popover and its trigger, a slot, a form inside a custom tag, a page wrapper, a
   collection list, an instance placed on a page. Write each one in the report as "done by hand", with its node
   id, so the annotation can turn it into a directive next time.
2. Collect what is left, the steps no tool can do (see *Smootify rules the build must apply*), into a checklist
   for the person
3. Present it as remaining work

## Limitations & Workarounds

| Limitation | Workaround |
|---|---|
| `set_settings` rejects `attributes` with `value_binding`, and `element_builder` rejects the `attributes` settings key at creation | Bind with `set_settings` + `static_json` carrying the raw shape — see *An attribute CAN vary per instance*. Webflow MCP bug, not a Webflow limit |
| ~~Cannot set CMS bindings via MCP~~ | **They can.** An attribute binds to a CMS field with `set_settings`, key `attributes`, `static_json` carrying `[{"name":"data-id","value":{"sourceType":"cms","collectionId":"…","collectionName":"Products","fieldId":"…","fieldName":"Shopify ID","fieldGroup":null,"fieldType":"plainText"}}]` — it replaces the whole attribute list, so pass the static ones too. A Collection List's source, filters, sort and limit are `set_settings` keys on the `DynamoWrapper` |
| ~~Cannot create interactions~~ | `data_interactions_tool` (IX3). Confirm in Preview: an accepted interaction can still not run |
| ~~Cannot install fonts programmatically~~ | `data_fonts_tool > create_font` |
| The native Popover element (beta) cannot be created or copied | Build the same markup with the `popover` / `popovertarget` attributes; the element itself is `@manual: popover` |
| Bindings not visible in `get_all_elements` | Always use `get_settings type: "all_raw_settings"` to verify |
| ~~Cannot set per-instance prop overrides via MCP~~ | **Not true** — `set_component_instance_prop_values` works, variants included. Verified 2026-09-21 |
| `element_builder`'s `settings[].binding` doesn't reliably pre-apply on built-in element types (Image, Paragraph, Heading, etc.) at creation time | Create the element first (style/text/attributes only), look up its id via `get_all_elements`, then bind with a follow-up `set_settings` call |
| Conditional visibility (show/hide by variant) can be neither read nor written via MCP | Don't use conditionals — build a second component instead |
| `element_builder` with nested `children[]` doesn't return per-child element ids in the creation response | Follow up with `get_all_elements` (`scope_component_id`, `depth: -1`) to resolve every child's id before binding or further edits |
| `set_text` and `set_link` inside `children[]` are ignored — children are created with Webflow's placeholder text and no link | Set them after creation, then read them back: do not assume they took. A top-level Button takes both |
| `set_style` on an element inside a component answers "styles not found" when its classes form a combo that does not exist yet, even if each class exists | Create the combo first (`parent_style_names`), then apply it |
| `remove_properties` and `properties` on the same property in one call: the removal wins | To replace a value pass only `properties` |
| A FormSelect has no setting for its options | A DOM `select` with DOM `option` children: `set_attributes` for each `value`, `set_settings` `text` for the label |
| An instance cannot be the anchor of `before` / `after` (`insert_component_instance`, `data_element_builder`) | `prepend` / `append` in the parent, or anchor on a plain element next to it |
| Slots cannot be placed inside a Form, and an instance cannot be detached on a template | A second component for each layout of the form (see *Component Decision Rules*) |
| No tool for site redirects, deleting pages, noindex, placeholders, `type="date"`, the Current state, custom checkbox and radio styles, the 404 utility page | The person does them: list them in the report with page and element. A page to delete goes to draft, renamed "(to delete)" |
| A form field's Name written through the API does not reach the published HTML (it still publishes `field-N`) | Set every Name in the Designer's settings panel, through Claude in Chrome, and check it on the published page |
| `bulk_update_pages` answers ok and changes nothing | `update_page_settings`, one page at a time |
| `unlink_component_instance` is refused by the permission system | Do not work around it: build what the instance should contain another way (a second component) |
| The Webflow Navbar (`w-nav`) cannot be created; a new Form Block comes with Name, Email and Submit; a new Rich Text with sample headings and lists | Build the nav from Div blocks; delete the sample content right after creating the element |
| `transform_element_to_component` leaves an element without its class when the style does not exist yet | Create the styles first, then transform |

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
