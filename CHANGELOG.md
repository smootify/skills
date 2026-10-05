# Changelog

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
