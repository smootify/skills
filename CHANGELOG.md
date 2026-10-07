# Changelog

## 2.0.0-beta.13

From the review of the starter on staging, with Smootify 2.0 running.

- The builder installs Smootify first (Phase 0): it reads the site's head code, adds the loader with any options, writes the whole block back, and checks the published page for it.
- On a site with Webflow's Popover element, the builder places the native Popover through Claude in Chrome, inside its Smootify element, and positions it as the design draws it; the element writes `popover` and `popovertarget` itself. Without it, an attribute popover gets the design's position in the site custom code, or the browser opens it in the middle of the page.
- What works together is one component: a trigger and the panel it opens (the cookie preferences button and the consent banner, a search field and its results), a list and its item template.
- Every card and every link has a target: a product card links with `product="link"`, a collection card is a CMS item, and every static link gets a note with its page.
- Where a panel opens is the design's choice, written in a note; the skills give technical rules only.
- The catalogue follows the 2.0 contract of 2026-10-07: one country hides the country switcher and the market suggestion, `smootify-search` takes its only text field, fields in a hidden block are not sent, `booking-calendar` takes `is-not-bookable` and asks nothing while hidden.

## 2.0.0-beta.12

From the report of the starter build (60 `@manual` steps done through the MCP).

- The builder has `references/mcp-recipes.md`: the MCP calls for the steps that used to be `@manual` (a hidden select
  with options, Dropdown and Tabs, a popover with its trigger and close, `details` in repeated templates, a slot, a form
  inside a custom tag, a wrapper that shows or hides an instance, a filtered Collection List, instances on pages, the
  site custom code), and what to check before retrying a call.
- Class names come from the component and the role, never from sample text or a layer in another language; one class
  per design; images get `display: block` and `object-fit: cover`.
- New rules for the build: elements Smootify removes when the store lacks their data, cart upsells with
  `direct-add-to-cart`, counters Smootify writes (`filter="active-count"`), Webflow Slider arrows, the reserved
  `/search` slug, no `display` on panel classes, reserved attributes, props bound to attributes are `string`.
- The annotator gives every variant a decision, annotates what a prop cannot drive (an instance's visibility, a
  field's Name, a placeholder) differently, puts numbers Smootify writes in their own layer, annotates each panel's
  trigger and close, and lists what the store must have.

## 2.0.0-beta.11

- The catalogue covers the elements added to 2.0 on 2026-10-06: `wishlist-share` (a wishlist shared through a link, with
  the conditions `shared-wishlist` and `own-wishlist`), `configurator-share` (a configuration in a link),
  `smootify-metaobject[data-handle-param]` (the entry named in the page link) and `booking-calendar[data-required]`.
- The glossary has the metafield modifiers (`data-attr`, `separator`, `data-digits`, `data-path`) on customer and company
  metafields.
- A `@wrap` is written on the first layer of its span, never on the parent (the annotation format says so; the Smootify
  MCP flags it as `annotation.wrap-on-parent`).

## 2.0.0-beta.10

From the review of the second annotated starter.

- A product block that depends on the product uses what Smootify already reads before any new CMS field: an element
  that removes itself without data (`subscription-swatches`), a `condition`, or `if-metafield=<key>` on a `@wrap`.
- Tablet and Mobile frames carry only their top-frame note; inside them only what exists at that size alone is annotated.
- When an `@inline` master holds a layer that is legal in one host only, it becomes two masters, one per host.
- `@set: <Prop> = prop:<Name>` connects an instance's prop to a prop of the component it sits in (a card inside a
  carousel takes the carousel's Limit); the builder binds it in Webflow.
- The catalogue covers slot booking (`booking-calendar`, `booking-form` and the fields the form reads).

## 2.0.0-beta.9

- The plugin sets up the MCP servers the skills use: the Smootify MCP (`https://mcp.smootify.io/mcp`) and the Webflow MCP
  (`https://mcp.webflow.com/mcp`), both signed in with OAuth on first use (`/mcp`). Claude Code connects to a server once
  when the same URL is already configured, so nothing is doubled.
- It depends on Figma's official plugin (`figma@claude-plugins-official`), installed with it: the Figma MCP and the
  `figma-use` skill the annotation skill loads.

## 2.0.0-beta.8

- `@inline: <master>`: an instance of a primitive that is not a Webflow component (a popover, a checkbox) is built as a
  copy of the master's annotated markup. It replaces the notes that said "inline", which the builder never read.
- `@element: FormSuccess` and `FormError`: the Success and Error messages of a Form Block.
- Glossary errata: `hide-if-product-in-cart=false` keeps the card visible, so a boolean prop can drive it.

## 2.0.0-beta.7

From the review of the first annotated starter.

- A Form Block that a tag requires is built by `figma-to-webflow-smootify` from the catalogue: no `@manual`, no directive.
  `@wrap` also takes Webflow element types (`DivBlock`, `FormBlock`) for the containers the design lacks.
- What a product state shows is a badge with a `condition` attribute (a Condition prop), not a `@state` class.
- Shop values the design does not show (metafield keys, metaobject types, handles) are proposed from the visible labels
  and listed as assumptions, instead of asked.
- In a starter or a kit every drawn alternative (Dropdown, select, popover) becomes its own component.
- On a product template the `smootify-product` wrap spans the whole main content.
- Predictive search results use `smootify-product[data-id=search]` cards.

## 2.0.0-beta.6

- A part the build needs (a Form Block a tag requires, a popover panel, an inline part) is a `@manual`, never a `@note`:
  the builder ignores notes. The final check also refuses `@ask` with `@skip`, and a tag named like an HTML tag (`map`)
  without `@element: DOM`.
- Glossary errata: `hide-if-product-in-cart` (it counts when present, whatever its value), `remove-parent`, the option
  labels and the subscription totals are in 2.0; `subscription=canceledAt` is not.

## 2.0.0-beta.5

- `figma-annotate-smootify`: a main component that is not built as a component still gets one line saying why — the
  frame where its page-structure markup is written, or that its instances are annotated where they are placed — and
  the final check fails when a component page has no annotation at all. Icons need nothing.

## 2.0.0-beta.4

- The catalogue's list of attribute values leaves out the deprecated ones (`address=territoryCode`, `product=images`
  as a gallery piece) and lists them apart, each with the value to write instead.

## 2.0.0-beta.3

- A submit button outside its form (a sticky add to cart, tied with `form=<form id>`) now works like one inside, with
  its loading label and disabled state: the errata says how to annotate it.

## 2.0.0-beta.2

From the first run of the annotation skill on the Smootify 2.0 starter.

- The catalogue lists every host attribute of each tag and its whole description: they were cut, so attributes
  such as `data-collection` on `smootify-search-discovery` and `data-new-days` on `smootify-product` seemed not to
  exist.
- The catalogue lists the field Names each form element reads (*Campi dei form*), and the format says how to annotate
  them: `@attr: name=<Name>`, case included.
- `@cms` works on page elements and on wraps, not only on component instances: `@cms: attr:<name>`, `text`, `image`,
  `link`, and `@cms: wrap attr:<name>` for the wrapper a `@wrap` creates (the `smootify-product` around a product
  page).
- New patterns: a Figma variant whose value becomes an attribute (a `string` prop bound to `attr:`), a "Popover ID"
  prop for popovers inside components placed twice, merged main components (`@use` + `@set` on the main component).
- `@manual: conditional` also covers Webflow conditional visibility on a CMS template (one Products template for
  several kinds of product).
- Attribute values: the glossary's name wins over the catalogue's aliases.
- Follows Smootify 2.0 as of 2026-10-05: the address forms read `countryCode` (Shopify deprecated `territoryCode`), and
  form fields are read as designers name them in Webflow. The glossary copies are of 2026-10-05.
- The glossary errata lists the runtime facts a kit needs: status classes on order, shipment and subscription
  pills, the wishlist toggle's classes and Rive, `data-new-days`, opening the cart, line properties, bundle and box
  items, the default address, sticky add to cart, `product-slider`, search page cards.

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
