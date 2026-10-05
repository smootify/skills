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
| `@set: P = v` (and `@set: Variant = N`) | `set_component_instance_prop_values`; the variant takes its id from `get_component` with `includeVariants` |
| `@cms: P = Collection.Field` · `@cms: attr:<name>\|text\|image\|link = Collection.Field` | Bind the instance prop to the CMS field; the `attr:`/`text`/`image`/`link` form binds a plain page element (a wrap too). On a plain element, the attribute's CMS recipe (`static_json` with `sourceType: "cms"`, see Limitations). If binding an instance prop to CMS fails through the MCP, report it as a manual step with the exact field |
| `@use: Component` | Insert an instance of that component instead of building the frame. On a main component: build no component for it, and place the target (with its `@set` values) wherever its instances are |
| `@page: template C` | Build on the CMS template page of collection C |
| `@list: C limit=… sort=…` | A Collection List (`DynamoWrapper`) with `source`, `limit`, `sort` set through `set_settings` |
| `@manual` | Collect for the summary |
| *(no directive)* a tag whose catalogue row must contain `form` | If the design has no form inside it, wrap the tag's content in a Form Block yourself (FormWrapper > FormForm, with its Success and Error messages), then put the fields inside. It is never a manual step |
| `@note` | Ignore |

The sections below describe the older syntax; where they differ from the format file, the format file wins.

### Bind Validation### Bind Validation

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

**Form elements can be built with `element_builder`. Form submission configuration (email notification, redirect, etc.) remains manual.**

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

## Workflow

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

### Phase 7: Inner and Sibling Components

If there are nested or repeated (sibling) components:
1. Build each distinct inner component fully (Phases 1–6), once per distinct component — not once per occurrence
2. Use `element_builder` to insert an instance of the inner component wherever it recurs, via `insert_component_instance` on the outer's canvas
3. Then continue building the outer component

### Phase 8: Manual Summary

1. Collect all `@manual` directives into a checklist
2. Present as remaining work

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
| `set_text` inside `children[]` is ignored — children are created with Webflow's placeholder text | Set the text after creation, then read it back: do not assume it took |

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
