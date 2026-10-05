# Annotation format 2

The contract between the two skills: `figma-annotate-smootify` writes it into Figma, `figma-to-webflow-smootify`
reads it and builds Webflow. **The same file lives in both skills — change both copies together.**

## Transport — verified on a real file

Directives travel as a **Dev Mode annotation**, which `get_design_context` returns as
`data-smootify-annotations`. The path is lossy, and every rule below comes from a measured loss:

| Rule | Why |
|---|---|
| One annotation per node, category **`Smootify`**, written to **`labelMarkdown`** | Writing `labelMarkdown` fills `label` too; writing `label` leaves `labelMarkdown` empty, and `labelMarkdown` is the one that travels. The category keeps our directives apart from developer notes (`data-development-annotations`) |
| **One line.** Directives separated by a space | Newlines come back as spaces on every path |
| **No double quotes** | They come back as `'` |
| **No `@` inside a value** | `@` starts a directive |
| **Avoid `_`** — class names use hyphens | Underscores come back escaped as `\_`. A CMS field slug or a metafield key may still contain one: the reader unescapes |
| Never touch annotations of other categories | They are someone else's notes |

**Reading.** Split on `(^|\s)@([a-z][a-z-]*):\s*` — each match starts a directive, its value runs to the next
match. Then unescape `\_` → `_`, `&lt;` → `<`, `&gt;` → `>`, and trim. A directive may repeat (`@attr`, `@prop`,
`@bind`, `@set`).

`GROUP` and `SECTION` nodes cannot hold an annotation. The directive goes on the nearest frame above, with
`@target: <layer name>` naming the node it is really about.

## Where a directive goes

| Node | Carries |
|---|---|
| **Main component** (`COMPONENT`), or the **component set** for what is true of every variant | `@component` `@group` `@desc` `@axis` `@prop` `@tip` + the element directives of the root |
| A **variant** inside a set | only what that variant changes: `@variant`, `@state`, `@component` (when the axis is `split`) |
| A node **inside** a component | element directives, `@bind`, `@slot`, `@repeat`, `@skip` |
| An **instance** placed on a page or inside another component | only what differs for this placement: `@set`, `@cms` |
| A **frame drawn by hand** that should have been an instance | `@use` + `@set` |
| A **main component** that duplicates another (nine card masters that are one card) | `@use` + `@set` on the main component: every instance of it is built as an instance of the target, with those values |
| A **page element** that is not a component (a heading, a `@wrap`) on a CMS template or in a collection list | `@cms: attr:<name>`, `text`, `image` or `link`, as below |
| The **top frame of a page** | `@page`, `@list` |
| The **top frame of the file's first page** | `@setup`, once for the whole file |

Annotate a component **once**, on its definition. Every instance inherits it; never copy the component's
directives onto instances.

## Directives

### Identity

| Directive | Meaning | Example |
|---|---|---|
| `@component: <Name>` | This node is a Webflow component. English, sentence case, no prefix | `@component: Product card` |
| `@group: <Group>` | Webflow component group | `@group: Product` |
| `@desc: <text>` | What it is and its constraints, not what it looks like. Becomes the Webflow description | `@desc: One product. Needs the Shopify ID of the product` |

### Element

| Directive | Meaning | Example |
|---|---|---|
| `@element: <type>` | Webflow element type. **Omit it** when `@tag` names a custom tag (it is then a custom-tag element) and when the Figma type makes it obvious. Values: `Paragraph` `Heading` `TextBlock` `TextLink` `LinkBlock` `Button` `Image` `DivBlock` `Section` `Container` `DOM` `RichText` `Slider` `Lightbox` `Tabs` `Dropdown` `FormBlock` `FormTextInput` `FormTextarea` `FormSelect` `FormCheckboxInput` `FormRadioInput` `FormButton` `CollectionList` | `@element: Heading` |
| `@tag: <tag>` | A Smootify custom tag from the catalogue, or the HTML tag of a `DOM` element | `@tag: variant-swatches` · `@element: DOM @tag: button` |
| `@style: <class>\|<combo>` | Classes, base first. Library classes start with `sm-` | `@style: sm-swatch\|sm-swatch-large` |
| `@attr: <name>=<value>` | A static attribute | `@attr: product=title` |
| `@wrap: <tag or element> over <first>..<last>` | A new ancestor that does not exist in the design, spanning the named siblings: a custom tag, or a Webflow element type (`DivBlock`, `FormBlock`). `@attr: wrap <name>=<value>` and `@cms: wrap attr:<name> = <Collection>.<Field>` on the same node go on the wrapper, not on the node | `@wrap: smootify-product over Header..Footer @cms: wrap attr:data-id = Products.Shopify ID` |
| `@repeat: <what>` | This node is the template Smootify repeats at runtime | `@repeat: one per product image` |
| `@skip: <why>` | Do not build this node | `@skip: copy of Thumbnail, drawn to show the row` |
| `@target: <layer>` | The directives are about this descendant (a group or section that cannot hold an annotation) | `@target: Price row` |

**A form field's Name is `@attr: name=<Name>`** on a `FormTextInput`, `FormTextarea`, `FormSelect`, `FormCheckboxInput` or `FormRadioInput`. It is the field's Name setting in Webflow, not a custom attribute, and Smootify reads it as written: case included (`email`, not `Email`). The names each form element reads are in the catalogue, *Campi dei form*.

**A real `<button>` is `@element: DOM @tag: button`.** Webflow's Button element publishes an `<a>` and the
FormButton an `<input>`; every Smootify `button[...]` selector ignores both.

### Component API

| Directive | Meaning | Example |
|---|---|---|
| `@axis: <Figma property> = <kind>` | How a Figma variant or boolean property becomes Webflow. Kinds: `variant` `state` `interaction` `breakpoint` `prop` `split` `sample` — see below | `@axis: State = state` |
| `@prop: <type> <Name> = <default>` | A component prop. Types: `text` `string` `number` `boolean` `image` `link` `richText` `altText` `id`. The default may be empty | `@prop: string Option = 1` |
| `@tip: <Name> = <text>` | The prop's tooltip — the only guidance the person using the component sees | `@tip: Option = Position of the Shopify option, 1 to 3` |
| `@bind: <target> = <Prop>` | Binds a setting of this node to a prop. Targets: `text` `attr:<name>` `visibility` `image` `alt` `link` `domId` | `@bind: attr:data-option = Option` |
| `@slot: <Name>` | This node becomes a component slot; component instances go in it | `@slot: Actions` |
| `@variant: <Name>` | On a variant of an `axis=variant` property: the Webflow variant name | `@variant: Compact` |
| `@state: <class> [on <layer>]` | On a variant of an `axis=state` property: the combo class Smootify toggles for that state, and the layer it lands on (the root when omitted) | `@state: is-active on Value` |

**The seven kinds of `@axis`:**

| Kind | When | In Webflow |
|---|---|---|
| `state` | Smootify decides it at runtime: selected, unavailable, loading, out of stock, on sale, new, empty, error, logged in | Nothing to choose per instance. The combo class Smootify toggles (`@state`), or an element carrying `condition` / `data-state` / `skeleton`, or Webflow's form done/fail blocks |
| `interaction` | Hover, focus, pressed | Pseudo-state styles on the class |
| `breakpoint` | The value names a size: Desktop, Tablet, Mobile, Compact-for-mobile | Responsive styles on the same element. Never a second element |
| `variant` | The person placing the component chooses it, and only styles change | A Webflow variant (style overrides) |
| `prop` | The person placing it chooses whether a part shows (a Figma BOOLEAN property, or a variant that only hides a part), or a value that becomes an attribute (`Option = 1 \| 2 \| 3`) | A `boolean` prop bound to `visibility`, or a `string` prop bound to `attr:<name>`: `@prop: string Option = 1` + `@bind: attr:data-option = Option`, and `@set: Option = 2` on the instances |
| `split` | The Smootify tag, the attributes of the children or the structure change | One Webflow component per value, each with its own `@component` on the variant |
| `sample` | Only the sample content changes (long title, short title) | Nothing |

**A popover inside a component** needs an id that is unique on the page, and a component placed twice would repeat it. Give the component `@prop: string Popover ID`, bind it with `@bind: attr:popovertarget = Popover ID` on the trigger and `@bind: domId = Popover ID` on the panel, and `@set: Popover ID = <unique value>` on every instance.

### Placement — where the component is connected

| Directive | Meaning | Example |
|---|---|---|
| `@use: <Component>` | This hand-drawn frame is an instance of that component | `@use: Product card` |
| `@set: <Prop> = <value>` | This instance's value. The variant is a prop too | `@set: Option = 2` · `@set: Variant = Compact` |
| `@cms: <Prop> = <Collection>.<Field>` | On a CMS template or inside a collection list: the prop takes its value from a CMS field | `@cms: Product ID = Products.Shopify ID` |
| `@cms: attr:<name>\|text\|image\|link = <Collection>.<Field>` | The same on a page element that is not a component: an attribute, its text, image or link takes the CMS field. Only `body` cannot take attributes; a `smootify-product` around the page content can | `@cms: attr:data-collection = Collections.Shopify ID` |
| `@page: <kind> [<Collection>]` | `static`, or `template <Collection>` for a CMS template page | `@page: template Products` |
| `@list: <Collection> [limit=N] [sort=<field> asc\|desc]` | This node is a Webflow collection list | `@list: Products limit=8 sort=created desc` |

### File

| Directive | Meaning | Example |
|---|---|---|
| `@setup: key=value …` | The answers that hold for the whole file. `image=image\|url` (the featured image as a Webflow Image bound to the CMS Image field, or an `img` custom element bound to Image URL and Image Alt), `site=<Webflow site id>\|none`, `plan=standard\|server`, `pickers=dropdown\|select\|popover`, `popover=native\|attributes` | `@setup: image=url site=none plan=standard pickers=dropdown popover=attributes` |

### Review

| Directive | Meaning | Example |
|---|---|---|
| `@ask: <question>` | An open question. **The builder does not build the node's Smootify part while it stands.** Never together with the directive it asks about | `@ask: does this pick a variant or an add-on?` |
| `@manual: <kind>: <detail>` | A step no tool can do. Kinds: `conditional` (Webflow conditional visibility: on a component variant, or on a CMS field of the template item, such as one Products template that shows the configurator block only on configurable products), `popover`, `other`. Everything else is buildable — see the build skill | `@manual: conditional: show Configurator only when Products.Type is Configurable` |
| `@note: <text>` | For people. The builder ignores it, so never put in a note something the build needs: a container is a `@wrap`; a Form Block a tag requires needs nothing (the builder adds it) | `@note: same element as the Desktop variant` |

## A complete component

A set `Variant / Pills` with the properties `Price = None | Difference` and `State = Default | Selected |
Unavailable`:

```
[COMPONENT_SET  Variant / Pills]
@component: Variant pills @group: Variant @desc: One Shopify option as a row of text buttons. Goes inside Add to cart @tag: variant-swatches @style: sm-variant-pills @prop: string Option = 1 @tip: Option = Position of the Shopify option, 1 to 3 @bind: attr:data-option = Option @prop: boolean Show price difference = false @tip: Show price difference = Adds + 5 € next to the values that cost more @axis: Price = prop @axis: State = state

  [TEXT  Label]
  @attr: selected-option=title

  [FRAME  Value]
  @element: DOM @tag: button @style: sm-pill @repeat: one per value of the option

    [TEXT  Name]
    @attr: option=title

    [TEXT  Price]
    @attr: option=price-difference @bind: visibility = Show price difference

  [FRAME  Value 2]   [FRAME  Value 3]
  @skip: copy of Value, drawn to show the row

[COMPONENT  State=Selected]      @state: is-active on Value
[COMPONENT  State=Unavailable]   @state: is-disabled on Value

[INSTANCE of Variant pills, on the product page]
@set: Option = 2 @set: Show price difference = true
```

The state variants are drawn to show how `sm-pill` looks with the class Smootify adds; they are built as combo
class styles, not as Webflow variants.
