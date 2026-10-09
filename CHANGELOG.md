# Changelog

## 2.0.0-beta.20

- `smootify-iterate` has a sixth cause, `store`: the note comes from the store's data or setup in Shopify (a metafield or metaobject definition, an option value without its image, a product's price or description, a pickup location, a market, a Search & Discovery filter). The site is left as it is, and the answer says what the store must have and where it is set in the Shopify admin. Smootify Studio shows it as "Store (Shopify admin)" and never sends it to Smootify.

## 2.0.0-beta.19

- The catalogue follows the 2.0 contract of 2026-10-09 evening: the predictive search's host classes (`has-query`, `has-suggestions`, `has-products`, `is-empty`, `without-initial-state`) and the gift card's `Recipient name` and `Message` fields.
- The annotator and the builder place the predictive search's "Products" and "View all results" in a region shown only with `has-products`, and the gift card's recipient fields (`Recipient email`, `Recipient name`, `Message`, `Send on`) as ordinary fields of the add to cart, repeated in a preview with `form-value`.

## 2.0.0-beta.18

From everything the builder had to ask during the first demo store build, the 140 review notes on the starter and the demo store, and the earlier build, review and QA reports.

- The builder starts with one checklist for the person (site, licence and extensions, store and CMS sync, Customer Account API client id with its allowed origins, spam protection) and asks only what the design does not settle: anything the catalogue or the annotation answers is applied and written in the report.
- What changes per use is a component prop, never a manual step. Placeholders, form names and native Popovers are done in the Designer through Claude in Chrome before a page goes to review.
- Smootify rules: where `data-prop`, `option-values` and `url` go; a sticky add-to-cart tied with `form`; one cookie banner per site and its Necessary box; email preferences as two forms; references in a metaobject form; sort values and `SmootifySortLabels`; `smootify-cart[data-open]` values; Smootify's tags are inline.
- Webflow rules: the defaults that break a layout (`.w-form` margin, FormButton text, Dropdown toggle and icon, style-only Code Embeds), elements that cannot be removed (Form Success and Error, Slider nav), `details` open at publish, unique form and field ids, fields created as required, Collection List self links, page titles, icons that follow their control, rows that keep one height.
- The builder's checks on the published page now include every state class styled and disabled controls that look disabled, no empty blocks, no Webflow sample text, and links to pages not built yet; with the Smootify MCP connected, `check_markup`, `resolve_vocabulary` and `get_example`.
- The annotator: in a starter or kit, every Smootify feature block is a component with its settings as props; never a slot inside a Form; the cart's Form spans the whole cart; the quote cart's states; picker labels from the option name; the page's `h1` outside components; checkout totals with `data-fallback`; text that repeats the shopper's choices bound with `form-value` and the configurator values; B2B paths by Smootify conditions; slider arrows' disabled state; Magic Box sizes; products without their own page; grids without products not sold on their own; `data-overflow-body`; visible states and disabled looks; required consent boxes; honest success messages; real quantities. It reads hidden frames, checks its work with `check_annotations` when the Smootify MCP is connected, and renames layers a `@wrap` cannot name.
- `smootify-iterate` fixes a shared component, class or template at its source and lists the other places it touched, and recognises a note taken before a fix.

## 2.0.0-beta.17

From the first build of a demo store from its Figma (Millimetro), with Smootify 2.0 running.

- Empty states are required: the annotator lists each one (cart, search, collection and filters, orders, addresses, subscriptions, store credit, wishlist, gift lists, recently viewed, a day with no slot, 404) as an open question before the build when the design lacks it, and the builder builds and checks every one, with the site's Empty state component as a fallback the person approves.
- More usability checks for the annotator: a breadcrumb has at least one link or it is not there; a label promises only what the control does; texts that come from the store are written for the shopper; every page has a link that leads to it and every anchor exists; emails and phones are `mailto:` / `tel:` links; a difference written in a note is a prop; dynamic text never sits inside a text prop; layout choices are drawn, not noted; an image is the fill of its rectangle, never an export of the card around it; a popover inside a repeated template is a `details` / `summary`.
- The builder asks for the store's Customer Account API client id (`newCustomerAccountsPublicKey`) when the design has account parts, builds the 404 and the other system pages first, resets the browser's look on DOM buttons, builds dynamic-property choices as Webflow Radio and Checkbox elements in the page's Form, hides a whole repeated row with the state of its data, and never ships an image without a source.
- Smootify rules for the builder: `data-required` for required fields (Webflow strips `required`), an `edit-address` without the country select as a "Set as default" form, the three states of the search page, the store credit's empty state, Shopify's policy HTML styled in the site CSS, the consent preferences button hidden while the banner shows.
- Webflow and MCP facts for the builder: styles written through the data API do not show in an open Designer until it is reloaded; an instance cannot anchor `before` / `after`; `set_link` in `children[]` is ignored; a combo class must exist before `set_style`; a form's redirect and a select's options can be written; a duplicated page keeps its element ids; a variant's size comes from all its instances; a state border over a picture goes on `::after`; images exported at 2x.
- `smootify-iterate` reads the Smootify script, the failed requests and the kind of element from Studio's notes.
- The catalogue follows the 2.0 contract of 2026-10-09: `form-value`, `configurator-price` and `configurator-formula` with `data-fallback`, `data-required` in every form, name your price not on gift cards, `variant="id"`, the order page for a logged-out customer, `has-store-credit` / `no-store-credit`, "Set as default" on an address, the search page's `search="no-query"` / `"with-query"` and `has-query`, `input[type=search]`.

## 2.0.0-beta.16

- New skill, `smootify-iterate`: answers the review notes that Smootify Studio's Iterate collects on a published site. For each note it reads the published page and the site in Webflow first, checks the element against Smootify's documentation and MCP, fixes the site when the site is the cause, and writes back into the note the cause (`site`, `runtime`, `annotate-skill`, `build-skill` or `missing-feature`) with a confidence from 0 to 1. It works only from public sources, is cautious before blaming Smootify or a skill, never publishes and never works around a Smootify bug on the site. The note format stays Studio's, in the site's `notes/README.md`.

## 2.0.0-beta.15

From the second day of review on the starter, with Smootify 2.0 running.

- Forms that a shopper can understand: a field with limits or a required value (a size, a quantity, a configurator choice) has its error state with a text that says the limits. Smootify blocks an invalid configurator field without the browser's message, so the annotator checks for the text and the builder builds every `error-message` the design draws, with the `is-invalid` style on the field.
- Webflow's form defaults: the builder resets the bottom margin and fixed height of `.w-input` and `.w-select`, and the offsets of `.w-radio` and `.w-checkbox`, where a field sits in a row with a button or in a card.
- Required fields on a shared product template live in a block hidden by a condition (`if-metafield`, conditional visibility): hidden that way they do not block the other products; hidden with CSS they do.
- Templates Smootify repeats are Webflow's own elements: a subscription plan or a configurator choice is a Webflow Radio Button, never a Div with a custom input.
- The catalogue follows the 2.0 contract of 2026-10-08 evening: `cart="shipping"`, `data-fallback` on every cart value (an empty one is ignored), `is-disabled` on Webflow Slider arrows when every card fits, `hide-if-product-in-cart` hiding its whole slide, a subscription tab that picks its group's first plan, add-ons disabled while a plan is picked, `error-message` in `configurator-radio`, the link and share button of a created metaobject entry and the customer's entries in the account, `data-vendor` needing the Vendor filter of Search & Discovery.

## 2.0.0-beta.14

From the manual review of the starter, with Smootify 2.0 running.

- The annotator runs usability checks before writing: everything that looks clickable goes somewhere, every panel opens and closes, every list has an empty state and every account page a logged-out state, state-only content lives in its state's region, customer data is never sample text, forms can be sent, small screens work, controls are what they look like, product pictures are images bound to the CMS. What the design lacks goes into a new "Usability suggestions" section of the report, not into the annotations.
- The builder checks the published page as a shopper would, at three widths, before calling a component done: links, panels, empty states, data Smootify fills, form Names, images (`img` with CMS `src`/`alt` and a `max-width`), state styles only on their combo class.
- CSS the Designer cannot write (a child styled by its parent's state, a chevron turned while a popover is open, `:has()` rules, a panel's position) goes in a Code Embed inside the component, behind a boolean prop such as *Include styles*; the site's custom code keeps only what belongs to the whole site.
- Webflow's Popover element: its trigger is any Button or Link Block with Link → Type *Popover*; a close is the same with Action Hide. Popover styles follow the 2.0 CSS: no backdrop unless the panel's class sets `--smootify-backdrop-color`, `--smootify-closed-display` for a panel that is a popover only on small screens.
- A component or variant named after a Webflow element (Dropdown, Tabs, Slider, Lightbox, Popover) is built with that element; form labels are Field Labels; a field Name set through the API does not publish, so it is set in the Designer.
- The catalogue follows the 2.0 contract of 2026-10-08: `selected-option="name"`, `data-fallback`, `order="totalDiscounts"`, the default address (`is-default`, `address-condition="default"`), completed Magic Box categories (`is-complete`, `box-condition="category-complete"`), the sort trigger keeping the designer's text, consent in one component (`is-applicable`).

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
